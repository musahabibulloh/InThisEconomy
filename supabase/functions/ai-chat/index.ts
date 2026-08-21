import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders })

  try {
    const { session_id, message } = await req.json()

    const authHeader = req.headers.get("Authorization")!
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user } } = await supabase.auth.getUser()

    // Fetch user's idea check history for context
    const { data: ideaHistory } = await supabase
      .from("idea_checks")
      .select("product_category, location_name, opportunity_score, competition_score, demand_score, recommendation, created_at")
      .eq("user_id", user!.id)
      .order("created_at", { ascending: false })
      .limit(5)

    // Fetch recent chat messages for conversation context
    const { data: recentMessages } = await supabase
      .from("chat_messages")
      .select("role, content")
      .eq("session_id", session_id)
      .order("created_at", { ascending: true })
      .limit(20)

    // Build context
    const ideaContext = ideaHistory && ideaHistory.length > 0
      ? ideaHistory.map((h: any) =>
          `- ${h.product_category || "Ide"} di ${h.location_name || "?"}: Peluang=${h.opportunity_score}, Persaingan=${h.competition_score}, Permintaan=${h.demand_score}. Rekomendasi: ${h.recommendation || "-"}`
        ).join("\n")
      : "Belum ada riwayat analisis ide."

    const chatHistory = (recentMessages || []).map((m: any) =>
      ({ role: m.role === "user" ? "user" : "model", parts: [{ text: m.content }] })
    )

    const systemPrompt = `Kamu adalah konsultan bisnis UMKM Indonesia yang ramah dan berpengetahuan luas.
Kamu memiliki akses ke riwayat analisis ide bisnis pengguna ini:

${ideaContext}

Jawab pertanyaan pengguna secara spesifik berdasarkan data riwayat di atas jika relevan.
Jika pertanyaan tidak terkait riwayat, berikan jawaban umum yang tetap bermanfaat untuk UMKM.
Jawab dalam bahasa Indonesia, ringkas tapi informatif (maksimal 3 paragraf).
Jangan pernah menyebut bahwa kamu adalah AI atau chatbot — berperilaku seperti konsultan profesional.`

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`

    const contents = [
      { role: "user", parts: [{ text: systemPrompt }] },
      { role: "model", parts: [{ text: "Saya siap membantu Anda dengan analisis bisnis UMKM." }] },
      ...chatHistory,
      { role: "user", parts: [{ text: message }] },
    ]

    const resp = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents,
        generationConfig: { temperature: 0.8, maxOutputTokens: 1024 },
      }),
    })

    const data = await resp.json()
    const aiResponse = data.candidates?.[0]?.content?.parts?.[0]?.text || "Maaf, saya tidak bisa memproses pertanyaan saat ini."

    return new Response(JSON.stringify({ response: aiResponse }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})
