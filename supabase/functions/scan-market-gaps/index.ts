import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const FOURSQUARE_API_KEY = Deno.env.get("FOURSQUARE_API_KEY")!
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!
const SERPAPI_KEY = Deno.env.get("SERPAPI_KEY")!

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

// Business categories to scan
const CATEGORIES = [
  { type: "restaurant", label: "Restoran/Warung Makan" },
  { type: "cafe", label: "Kafe/Kedai Kopi" },
  { type: "bakery", label: "Toko Roti/Kue" },
  { type: "laundry", label: "Laundry" },
  { type: "hair_salon", label: "Salon/Barbershop" },
  { type: "convenience_store", label: "Minimarket/Toko Kelontong" },
  { type: "pharmacy", label: "Apotek" },
  { type: "car_repair", label: "Bengkel" },
  { type: "gym", label: "Gym/Fitness" },
  { type: "pet_store", label: "Pet Shop" },
  { type: "electronics_store", label: "Toko Elektronik" },
  { type: "clothing_store", label: "Toko Pakaian" },
  { type: "book_store", label: "Toko Buku" },
  { type: "florist", label: "Toko Bunga" },
  { type: "car_wash", label: "Cuci Mobil/Motor" },
]

async function countNearby(type: string, lat: number, lng: number, radiusMeters: number): Promise<number> {
  // Use a zoom level roughly corresponding to the radius. 14z is good for ~2km
  const url = `https://serpapi.com/search.json?engine=google_maps&q=${encodeURIComponent(type)}&ll=@${lat},${lng},14z&hl=id&gl=id&api_key=${SERPAPI_KEY}`

  try {
    const resp = await fetch(url)
    if (!resp.ok) return 0;
    
    const data = await resp.json()
    const places = data.local_results || []
    return places.length
  } catch (e) {
    console.error("Error fetching from SerpApi:", e);
    return 0;
  }
}

async function profileArea(lat: number, lng: number, radiusMeters: number): Promise<Record<string, number>> {
  const types = ["university", "school", "shopping_mall", "tourist_attraction", "hospital", "office"]
  const results: Record<string, number> = {}
  
  const promises = types.map(async (t) => {
    results[t] = await countNearby(t, lat, lng, radiusMeters)
  })
  await Promise.all(promises)
  
  return results
}

// Load capital reference from database
async function loadCapitalReference(supabase: any): Promise<Record<string, { min: number; max: number }>> {
  try {
    const { data } = await supabase
      .from("business_category_capital_reference")
      .select("category_key, capital_min, capital_max")

    const ref: Record<string, { min: number; max: number }> = {}
    if (data) {
      for (const row of data) {
        ref[row.category_key] = { min: row.capital_min, max: row.capital_max }
      }
    }
    return ref
  } catch {
    return {}
  }
}

// Determine capital match label based on user budget vs category capital range
function getCapitalMatchLabel(userBudget: number | null, capitalMin: number, capitalMax: number): string {
  if (!userBudget || userBudget <= 0) return "no_budget"

  if (userBudget >= capitalMin) {
    return "sesuai" // Modal cukup atau lebih
  }

  // Selisih < 30% dari capitalMin
  const deficit = (capitalMin - userBudget) / capitalMin
  if (deficit < 0.3) {
    return "sedikit_kurang" // Modal sedikit kurang, tapi bisa dipertimbangkan
  }

  return "jauh_lebih_besar" // Butuh modal jauh lebih besar
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders })

  try {
    const { latitude, longitude, location_name, radius_km, user_budget } = await req.json()
    const radiusMeters = (radius_km || 2) * 1000
    const budget = user_budget ? Number(user_budget) : null

    // Initialize Supabase client
    const authHeader = req.headers.get("Authorization")!
    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } })

    // Load capital reference in parallel with category scan
    const [capitalRef, categoryResults, areaProfile] = await Promise.all([
      loadCapitalReference(supabase),
      // Scan all categories concurrently to prevent 15-second timeout!
      Promise.all(CATEGORIES.map(async (cat) => {
        const count = await countNearby(cat.type, latitude, longitude, radiusMeters)
        return { ...cat, count }
      })),
      profileArea(latitude, longitude, radiusMeters),
    ])

    // Determine area density
    const totalNearby = Object.values(areaProfile).reduce((s, v) => s + v, 0)
    const areaDensity = totalNearby > 10 ? "Padat" : totalNearby > 5 ? "Sedang" : "Sepi"

    // Sort by gap potential (least competitors first)
    categoryResults.sort((a, b) => a.count - b.count)

    // Use Gemini to generate reasons and estimated capital
    let gapCandidates = categoryResults.filter(c => c.count <= 3)
    if (gapCandidates.length === 0) {
      // Fallback: If area is extremely crowded, at least suggest the top 3 with least competitors
      gapCandidates = categoryResults.slice(0, 3)
    } else {
      gapCandidates = gapCandidates.slice(0, 8)
    }
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=${GEMINI_API_KEY}`

    const budgetContext = budget
      ? `\n\nUser memiliki modal sebesar Rp ${budget.toLocaleString("id-ID")}. Pertimbangkan ini saat memberikan rekomendasi.`
      : ""

    const prompt = `Kamu adalah konsultan bisnis UMKM Indonesia. Untuk lokasi "${location_name || `${latitude},${longitude}`}" dengan profil area: ${JSON.stringify(areaProfile)} dan kepadatan "${areaDensity}", berikut kategori bisnis yang minim pesaing:

${gapCandidates.map(c => `- ${c.label}: ${c.count} kompetitor`).join("\n")}${budgetContext}

Untuk setiap kategori, berikan JSON array (tanpa markdown code block):
[{"category":"nama","score":0.0-1.0,"reason":"alasan singkat kenapa ini peluang bagus atau tidak di area ini","estimated_capital":"perkiraan modal awal dalam format teks","estimated_capital_min":angka_rupiah_min,"estimated_capital_max":angka_rupiah_max}]

Pertimbangkan: minim pesaing di area sepi bukan berarti peluang bagus. Beri skor rendah jika area tidak mendukung.
PENTING: estimated_capital_min dan estimated_capital_max WAJIB berupa angka integer (bukan string), dalam satuan Rupiah.`

    const geminiResp = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.7, maxOutputTokens: 4096, responseMimeType: "application/json" },
      }),
    })

    const geminiData = await geminiResp.json()
    const geminiText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text || "[]"
    let gapCategories: any[]
    try {
      const cleaned = geminiText.replace(/```json\n?/gi, "")
                                .replace(/```\n?/g, "")
                                .replace(/`/g, '"') // Fix hallucinated backticks
                                .trim()
      const gaps = JSON.parse(cleaned)
    
      if (!Array.isArray(gaps)) {
         throw new Error("Output bukan array");
      }
      gapCategories = gaps;
    } catch {
      gapCategories = gapCandidates.map(c => ({
        category: c.label, competitor_count: c.count,
        area_density: areaDensity, score: c.count === 0 ? 0.8 : 0.5,
        reason: `Hanya ${c.count} kompetitor ditemukan dalam radius`, estimated_capital: "Bervariasi",
        estimated_capital_min: 0, estimated_capital_max: 0,
      }))
    }

    // Enrich with competitor count, area density, capital reference, and match label
    gapCategories = gapCategories.map((g: any) => {
      const found = gapCandidates.find(c => c.label.toLowerCase().includes(g.category?.toLowerCase() || ""))
      const categoryType = found?.type || ""

      // Use manual capital reference if available, otherwise use AI estimate
      let capitalMin = g.estimated_capital_min || 0
      let capitalMax = g.estimated_capital_max || 0
      let capitalSource = "ai_estimate"

      if (capitalRef[categoryType]) {
        capitalMin = capitalRef[categoryType].min
        capitalMax = capitalRef[categoryType].max
        capitalSource = "manual"
      }

      const capitalMatchLabel = getCapitalMatchLabel(budget, capitalMin, capitalMax)

      return {
        ...g,
        competitor_count: found?.count ?? g.competitor_count ?? 0,
        area_density: areaDensity,
        estimated_capital_min: capitalMin,
        estimated_capital_max: capitalMax,
        capital_source: capitalSource,
        capital_match_label: capitalMatchLabel,
      }
    })

    // Sort: if user provided budget, prioritize matching categories
    if (budget && budget > 0) {
      const matchOrder: Record<string, number> = {
        "sesuai": 0,
        "sedikit_kurang": 1,
        "jauh_lebih_besar": 2,
        "no_budget": 3,
      }
      gapCategories.sort((a: any, b: any) => {
        const orderDiff = (matchOrder[a.capital_match_label] ?? 3) - (matchOrder[b.capital_match_label] ?? 3)
        if (orderDiff !== 0) return orderDiff
        return (b.score || 0) - (a.score || 0)
      })
    } else {
      gapCategories.sort((a: any, b: any) => (b.score || 0) - (a.score || 0))
    }

    // Save to database
    const { data: { user } } = await supabase.auth.getUser()

    const { data: record, error } = await supabase.from("market_gap_scans").insert({
      user_id: user!.id, latitude, longitude,
      location_name, radius_km: radius_km || 2,
      gap_categories: gapCategories,
      area_profile: { type: areaDensity, density_indicators: areaProfile },
      user_budget: budget,
    }).select().single()

    if (error) throw error

    return new Response(JSON.stringify(record), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})
