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

    const isFirstMessage = (recentMessages || []).length === 0;

    const systemPrompt = `Kamu adalah Ite, asisten AI berbentuk beruang madu yang ramah dan pintar. Kamu adalah teman konsultasi untuk pemilik UMKM.
Kamu bisa membantu soal: ide bisnis, analisis pasar, perbaikan produk, dan pertanyaan seputar jualan.

Gaya bicaramu santai, hangat, pakai bahasa Indonesia sehari-hari (seperti 'aku', 'kamu', 'kak'), dan boleh selipkan sedikit humor ringan khas beruang. Hindari jargon bisnis yang rumit.
Batasan: Tetap fokus membantu urusan bisnis UMKM. Jika ditanya hal lain, arahkan kembali dengan sopan.

Riwayat analisis ide bisnis pengguna saat ini:
${ideaContext}

${isFirstMessage 
  ? "PENTING: Ini adalah pesan pertama di sesi ini. Awali jawabanmu dengan menyapa dan memperkenalkan dirimu singkat sebagai Ite si beruang konsultan (misal: 'Halo Kak! Aku Ite, beruang konsultan bisnismu...'). Buat senatural mungkin, lalu langsung jawab pertanyaannya." 
  : "PENTING: Ini bukan pesan pertama. JANGAN memperkenalkan diri lagi. Langsung jawab pertanyaan pengguna dengan gaya bicaramu yang khas."}

Jawab pertanyaan secara ringkas, jelas, dan aplikatif (maks 3 paragraf).`;

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=${GEMINI_API_KEY}`

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
    if (data.error) {
      return new Response(JSON.stringify({ response: `Gemini Error: ${data.error.message}` }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }
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
