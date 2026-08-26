// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const FOURSQUARE_API_KEY = Deno.env.get("FOURSQUARE_API_KEY")!
const SERPAPI_KEY = Deno.env.get("SERPAPI_KEY")!
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

interface PlaceResult {
  name: string
  rating: number
  address: string
  place_id: string
  latitude: number
  longitude: number
}

// Search Google Maps via SerpApi for nearby competitors (Much more accurate for Indonesian UMKM)
async function searchNearbyCompetitors(
  category: string, lat: number, lng: number, radiusMeters: number
): Promise<PlaceResult[]> {
  // Use a zoom level roughly corresponding to the radius. 14z is good for ~2km
  const url = `https://serpapi.com/search.json?engine=google_local&q=${encodeURIComponent(category)}&ll=@${lat},${lng},14z&hl=id&gl=id&api_key=${SERPAPI_KEY}`

  try {
    const resp = await fetch(url)
    if (!resp.ok) return [];
    
    const data = await resp.json()
    const places = data.local_results || []

    return places.slice(0, 20).map((p: any) => ({
      name: p.title || "Unknown",
      rating: p.rating || 0, // Google Maps rating is already 1-5
      address: p.address || "",
      place_id: p.place_id || "",
      latitude: p.gps_coordinates?.latitude || 0,
      longitude: p.gps_coordinates?.longitude || 0,
    }))
  } catch (e) {
    console.error("Error fetching competitors from SerpApi:", e);
    return [];
  }
}

// Search nearby area types (for target market profiling)
async function profileArea(lat: number, lng: number, radiusMeters: number): Promise<any> {
  const areaTypes = ["university", "school", "mall", "tourist", "hospital", "office"]
  const results: Record<string, number> = {}

  for (const type of areaTypes) {
    const url = `https://api.foursquare.com/v3/places/search?ll=${lat},${lng}&radius=${radiusMeters}&query=${type}&limit=5`
    const resp = await fetch(url, {
      method: "GET",
      headers: {
        "Accept": "application/json",
        "Authorization": FOURSQUARE_API_KEY,
      }
    })

    if (resp.ok) {
       const data = await resp.json()
       results[type] = (data.results || []).length
    } else {
       results[type] = 0;
    }
  }

  return results
}

// Get Google Trends data via SerpApi
async function getTrendData(keyword: string): Promise<any> {
  const url = `https://serpapi.com/search.json?engine=google_trends&q=${encodeURIComponent(keyword)}&geo=ID&date=today+12-m&api_key=${SERPAPI_KEY}`

  try {
    const resp = await fetch(url)
    const data = await resp.json()
    const timelineData = data.interest_over_time?.timeline_data || []
    const values = timelineData.map((d: any) => ({
      date: d.date,
      value: d.values?.[0]?.extracted_value || 0,
    }))

    // Determine trend direction
    if (values.length >= 4) {
      const recentAvg = values.slice(-3).reduce((s: number, v: any) => s + v.value, 0) / 3
      const olderAvg = values.slice(0, 3).reduce((s: number, v: any) => s + v.value, 0) / 3
      const direction = recentAvg > olderAvg * 1.15 ? "naik" : recentAvg < olderAvg * 0.85 ? "turun" : "stabil"
      return { direction, data_points: values }
    }
    return { direction: "tidak cukup data", data_points: values }
  } catch {
    return { direction: "tidak tersedia", data_points: [] }
  }
}

// Generate narrative analysis via Gemini
async function generateAnalysis(context: any): Promise<any> {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=${GEMINI_API_KEY}`

  const prompt = `Kamu adalah konsultan bisnis UMKM Indonesia. Analisis data berikut dan berikan output dalam bahasa Indonesia:

Data:
- Produk/Ide: ${context.product}
- Lokasi: ${context.location}
- Jumlah kompetitor sejenis dalam radius ${context.radius_km} km: ${context.competitor_count}
- Rata-rata rating kompetitor: ${context.avg_rating?.toFixed(1) || 'N/A'}
- Tren pencarian: ${context.trend_direction}
- Profil area sekitar: ${JSON.stringify(context.area_profile)}

Berikan analisis dalam format JSON (tanpa markdown code block):
{
  "opportunity_score": "Rendah|Sedang|Tinggi",
  "competition_score": "Rendah|Sedang|Tinggi",
  "demand_score": "Rendah|Sedang|Tinggi",
  "recommendation": "rekomendasi singkat 2-3 kalimat",
  "target_market_description": "deskripsi target pasar potensial berdasarkan profil area",
  "differentiation_analysis": "analisis peluang diferensiasi, termasuk celah kualitas jika ada",
  "trend_risk": "analisis risiko mengikuti tren berdasarkan data tren pencarian"
}

Pertimbangkan nuansa: kompetitor banyak tapi rating rendah = celah kualitas (peluang diferensiasi tinggi).`

  const resp = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { temperature: 0.7, maxOutputTokens: 4096, responseMimeType: "application/json" },
    }),
  })

  const data = await resp.json()
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text || ""

  try {
    const cleaned = text.replace(/```json\n?/gi, "")
                        .replace(/```\n?/g, "")
                        .replace(/`/g, '"') // Fix hallucinated backticks
                        .trim()
    return JSON.parse(cleaned)
  } catch (err) {
    console.error("Failed to parse Gemini response:", err, text);
    // Attempt an aggressive manual parsing as a last resort
    const extract = (key: string) => {
      const match = text.match(new RegExp(`"${key}"\\s*:\\s*"([^"]+)"`)) || 
                    text.match(new RegExp(`${key}\\s*:\\s*"([^"]+)"`));
      return match ? match[1] : "Data tidak tersedia";
    }
    
    return {
      opportunity_score: extract("opportunity_score") !== "Data tidak tersedia" ? extract("opportunity_score") : "Sedang",
      competition_score: extract("competition_score") !== "Data tidak tersedia" ? extract("competition_score") : "Sedang",
      demand_score: extract("demand_score") !== "Data tidak tersedia" ? extract("demand_score") : "Sedang",
      recommendation: extract("recommendation") !== "Data tidak tersedia" ? extract("recommendation") : "Sistem AI sedang sibuk atau format data tidak valid. Silakan coba lagi.",
      target_market_description: extract("target_market_description"),
      differentiation_analysis: extract("differentiation_analysis"),
      trend_risk: extract("trend_risk"),
    }
  }
}

// Map Indonesian product category to Google Places type
function mapCategoryToPlaceType(category: string): string {
  const lower = category.toLowerCase()
  const mapping: Record<string, string> = {
    "bakso": "restaurant", "mie ayam": "restaurant", "nasi goreng": "restaurant",
    "warung": "restaurant", "kafe": "cafe", "kopi": "cafe", "coffee": "cafe",
    "dessert": "bakery", "roti": "bakery", "kue": "bakery",
    "boba": "cafe", "minuman": "cafe", "laundry": "laundry",
    "salon": "hair_salon", "barbershop": "hair_salon",
    "toko": "store", "minimarket": "convenience_store",
    "bengkel": "car_repair", "apotek": "pharmacy",
  }
  for (const [key, value] of Object.entries(mapping)) {
    if (lower.includes(key)) return value
  }
  return "store" // default
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    const { input_text, latitude, longitude, location_name, radius_km } = await req.json()

    // Extract product category from input text using Gemini
    const extractUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=${GEMINI_API_KEY}`
    const extractResp = await fetch(extractUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: `Dari teks berikut, ekstrak SATU kata kunci produk/jasa utama dalam bahasa Indonesia (tanpa lokasi, tanpa penjelasan, hanya 1-2 kata produk): "${input_text}"` }] }],
        generationConfig: { temperature: 0, maxOutputTokens: 20 },
      }),
    })
    const extractData = await extractResp.json()
    const productCategory = extractData.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || input_text

    const radiusMeters = (radius_km || 2) * 1000

    // Parallel API calls
    const [competitors, areaProfile, trendData] = await Promise.all([
      searchNearbyCompetitors(productCategory, latitude, longitude, radiusMeters),
      profileArea(latitude, longitude, radiusMeters),
      getTrendData(productCategory),
    ])

    const avgRating = competitors.length > 0
      ? competitors.reduce((s, c) => s + c.rating, 0) / competitors.length
      : 0

    // Generate narrative analysis
    const analysis = await generateAnalysis({
      product: productCategory,
      location: location_name || `${latitude}, ${longitude}`,
      radius_km: radius_km || 2,
      competitor_count: competitors.length,
      avg_rating: avgRating,
      trend_direction: trendData.direction,
      area_profile: areaProfile,
    })

    // Create Supabase client with user's auth
    const authHeader = req.headers.get("Authorization")!
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    )

    // Get user ID
    const { data: { user } } = await supabase.auth.getUser()

    // Save to database
    const { data: record, error } = await supabase.from("idea_checks").insert({
      user_id: user!.id,
      input_type: "idea",
      input_text: input_text,
      product_category: productCategory,
      latitude, longitude,
      location_name: location_name,
      radius_km: radius_km || 2,
      opportunity_score: analysis.opportunity_score,
      competition_score: analysis.competition_score,
      demand_score: analysis.demand_score,
      recommendation: analysis.recommendation,
      competitors: competitors,
      target_market: { description: analysis.target_market_description, area_types: areaProfile },
      trend_data: trendData,
      differentiation_analysis: analysis.differentiation_analysis,
      trend_risk: analysis.trend_risk,
    }).select().single()

    if (error) throw error

    return new Response(JSON.stringify(record), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})
