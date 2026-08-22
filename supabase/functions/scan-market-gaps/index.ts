import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const FOURSQUARE_API_KEY = Deno.env.get("FOURSQUARE_API_KEY")!
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!

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
  const url = `https://api.foursquare.com/v3/places/search?ll=${lat},${lng}&radius=${radiusMeters}&query=${type}&limit=50`
  const resp = await fetch(url, {
    method: "GET",
    headers: {
      "Accept": "application/json",
      "Authorization": FOURSQUARE_API_KEY,
    }
  })
  if (!resp.ok) return 0;
  const data = await resp.json()
  return (data.results || []).length
}

async function profileArea(lat: number, lng: number, radiusMeters: number): Promise<Record<string, number>> {
  const types = ["university", "school", "shopping_mall", "tourist_attraction", "hospital", "office"]
  const results: Record<string, number> = {}
  for (const t of types) {
    results[t] = await countNearby(t, lat, lng, radiusMeters)
  }
  return results
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders })

  try {
    const { latitude, longitude, location_name, radius_km } = await req.json()
    const radiusMeters = (radius_km || 2) * 1000

    // Scan all categories (batched to avoid rate limits)
    const categoryResults: Array<{ type: string; label: string; count: number }> = []
    for (const cat of CATEGORIES) {
      const count = await countNearby(cat.type, latitude, longitude, radiusMeters)
      categoryResults.push({ ...cat, count })
    }

    // Profile area
    const areaProfile = await profileArea(latitude, longitude, radiusMeters)

    // Determine area density
    const totalNearby = Object.values(areaProfile).reduce((s, v) => s + v, 0)
    const areaDensity = totalNearby > 10 ? "Padat" : totalNearby > 5 ? "Sedang" : "Sepi"

    // Sort by gap potential (least competitors first)
    categoryResults.sort((a, b) => a.count - b.count)

    // Use Gemini to generate reasons and estimated capital
    const gapCandidates = categoryResults.filter(c => c.count <= 3).slice(0, 8)
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=${GEMINI_API_KEY}`
    const prompt = `Kamu adalah konsultan bisnis UMKM Indonesia. Untuk lokasi "${location_name || `${latitude},${longitude}`}" dengan profil area: ${JSON.stringify(areaProfile)} dan kepadatan "${areaDensity}", berikut kategori bisnis yang minim pesaing:

${gapCandidates.map(c => `- ${c.label}: ${c.count} kompetitor`).join("\n")}

Untuk setiap kategori, berikan JSON array (tanpa markdown code block):
[{"category":"nama","score":0.0-1.0,"reason":"alasan singkat kenapa ini peluang bagus atau tidak di area ini","estimated_capital":"perkiraan modal awal"}]

Pertimbangkan: minim pesaing di area sepi bukan berarti peluang bagus. Beri skor rendah jika area tidak mendukung.`

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
      }))
    }

    // Enrich with competitor count and area density
    gapCategories = gapCategories.map((g: any) => {
      const found = gapCandidates.find(c => c.label.toLowerCase().includes(g.category?.toLowerCase() || ""))
      return {
        ...g,
        competitor_count: found?.count ?? g.competitor_count ?? 0,
        area_density: areaDensity,
      }
    }).sort((a: any, b: any) => (b.score || 0) - (a.score || 0))

    // Save to database
    const authHeader = req.headers.get("Authorization")!
    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } })
    const { data: { user } } = await supabase.auth.getUser()

    const { data: record, error } = await supabase.from("market_gap_scans").insert({
      user_id: user!.id, latitude, longitude,
      location_name, radius_km: radius_km || 2,
      gap_categories: gapCategories,
      area_profile: { type: areaDensity, density_indicators: areaProfile },
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
