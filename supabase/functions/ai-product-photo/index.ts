import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { Image, decode } from "https://deno.land/x/imagescript@1.2.15/mod.ts"

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!
const REMBG_URL = Deno.env.get("REMBG_URL") || "http://mock-rembg-server"
const CLOUDFLARE_API_TOKEN = Deno.env.get("CLOUDFLARE_API_TOKEN")
const CLOUDFLARE_ACCOUNT_ID = Deno.env.get("CLOUDFLARE_ACCOUNT_ID")

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

// ---------------------------------------------------------
// PROMPT ENHANCEMENT (Gemini Flash)
// ---------------------------------------------------------
async function enhanceProductPrompt(prompt: string, style: string): Promise<string> {
  const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`;
  
  const systemPrompt = `You are an expert prompt engineer for an image generation model. 
The user wants to generate a product photo. They might give a very short prompt. 
Your job is to expand their prompt into a highly detailed visual description suitable for Stable Diffusion (lighting, camera angle, composition, textures).
CRITICAL RULES:
1. If the user mentions a specific third-party brand (like 'Adidas', 'Nike', 'Louis Vuitton', 'Starbucks'), DO NOT include the brand name in your output. Instead, describe the product generically (e.g., 'modern athletic sneaker with side stripes').
2. Do not change the core product the user is asking for.
3. Keep the output under 400 characters. Return ONLY the prompt text, nothing else.
4. Strongly incorporate this requested style/context: ${style || 'none'}.
Example Input: "buatkan foto sepatu nike"
Example Output: "A professional product shot of a sleek modern athletic sneaker, soft studio lighting, centered clean composition, plain background, photorealistic, 8k resolution, highly detailed"`;

  try {
    const resp = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ role: "user", parts: [{ text: `Original user prompt: ${prompt}` }] }],
        systemInstruction: { parts: [{ text: systemPrompt }] },
        generationConfig: { temperature: 0.3, maxOutputTokens: 150 },
      }),
    });

    if (!resp.ok) return prompt; // fallback to original

    const data = await resp.json();
    if (data.error) return prompt; // fallback to original

    const enhanced = data.candidates?.[0]?.content?.parts?.[0]?.text;
    return enhanced ? enhanced.trim() : prompt;
  } catch (err) {
    console.error("Enhancement exception:", err);
    return prompt; // fallback to original on timeout/error
  }
}

// ---------------------------------------------------------
// PIPELINE GRATIS (Remove.bg + Cloudflare Workers AI)
// ---------------------------------------------------------
async function processFreePipeline(flow: string, prompt: string, imageBase64: string, style: string) {
  const REMOVE_BG_API_KEY = Deno.env.get("REMOVE_BG_API_KEY");
  const CLOUDFLARE_ACCOUNT_ID = Deno.env.get("CLOUDFLARE_ACCOUNT_ID");
  const CLOUDFLARE_API_TOKEN = Deno.env.get("CLOUDFLARE_API_TOKEN");

  if (flow === "A") {
    console.log("Menjalankan Pipeline (Gratis) untuk Flow A...");
    // 1. Remove background (Remove.bg API)
    console.log(`Langkah 1: Menghapus background via Remove.bg`);
    const removeBgResp = await fetch("https://api.remove.bg/v1.0/removebg", {
      method: "POST",
      headers: {
        "X-Api-Key": REMOVE_BG_API_KEY || "",
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        image_file_b64: imageBase64,
        size: "auto"
      })
    });
    
    if (!removeBgResp.ok) {
       console.error("Remove.bg Error:", await removeBgResp.text());
       throw new Error("Gagal menghapus background dengan Remove.bg");
    }

    // Remove.bg mengembalikan raw PNG binary, jadi kita harus membacanya sebagai arrayBuffer
    const arrayBuffer = await removeBgResp.arrayBuffer();
    const bytes = new Uint8Array(arrayBuffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
        binary += String.fromCharCode(bytes[i]);
    }
    const transparentImageBase64 = btoa(binary);

    // 2. Generate new background (Cloudflare Workers AI - Text-to-Image)
    console.log(`Langkah 2: Generate background style '${style}' via Cloudflare`);
    
    // Memberikan arahan prompt dasar yang kuat berdasarkan template yang dipilih user
    let baseContext = "";
    if (style === "Meja Kayu") {
       baseContext = "Empty rustic wooden table top, softly blurred warm room background, natural lighting, bokeh, wooden texture";
    } else if (style === "Studio Putih") {
       baseContext = "Pure white studio background, clean white platform, minimalist, bright softbox lighting, high end commercial photography, completely empty center";
    } else if (style === "Alam Terbuka") {
       baseContext = "Empty stone or wooden surface outdoors, lush green nature background, bright sunlight, cinematic depth of field, fresh atmosphere";
    } else if (style === "Kafe Estetik") {
       baseContext = "Empty aesthetic marble cafe table, blurred cozy coffee shop background, warm ambient lighting, cinematic bokeh";
    } else {
       baseContext = `Style: ${style}, empty center`;
    }

    const rawPrompt = `${baseContext}, perfect for product placement, no objects in the center, photorealistic, 8k resolution, highly detailed`;
    const enhancedBgPrompt = await enhanceProductPrompt(rawPrompt, style);
    
    const cloudflareUrl = `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/bytedance/stable-diffusion-xl-lightning`;
    const cfResp = await fetch(cloudflareUrl, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${CLOUDFLARE_API_TOKEN}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ prompt: enhancedBgPrompt })
    });

    if (!cfResp.ok) throw new Error("Gagal generate background dari Cloudflare");

    let backgroundBase64 = "";
    const contentType = cfResp.headers.get("content-type") || "";
    if (contentType.includes("application/json")) {
       const cfData = await cfResp.json();
       backgroundBase64 = cfData.result?.image || cfData.result;
    } else {
       const arrayBuffer = await cfResp.arrayBuffer();
       const bytes = new Uint8Array(arrayBuffer);
       let binary = '';
       for (let i = 0; i < bytes.byteLength; i++) {
           binary += String.fromCharCode(bytes[i]);
       }
       backgroundBase64 = btoa(binary);
    }

    // 3. Composite (Overlay product on background)
    console.log(`Langkah 3: Menggabungkan foreground dan background...`);
    try {
      const fgBytes = Uint8Array.from(atob(transparentImageBase64), c => c.charCodeAt(0));
      const bgBytes = Uint8Array.from(atob(backgroundBase64), c => c.charCodeAt(0));

      const fgImg = await decode(fgBytes) as Image;
      const bgImg = await decode(bgBytes) as Image;

      // Resize background to match foreground size (to avoid stretching the product)
      // Actually it's better to scale foreground to fit in background
      bgImg.resize(1024, 1024);
      
      // Calculate scaling for foreground so it fits nicely in the center (e.g. 70% of canvas)
      const scaleFactor = Math.min(700 / fgImg.width, 700 / fgImg.height);
      const newFgWidth = Math.round(fgImg.width * scaleFactor);
      const newFgHeight = Math.round(fgImg.height * scaleFactor);
      fgImg.resize(newFgWidth, newFgHeight);

      // Center the foreground
      const x = Math.round((bgImg.width - fgImg.width) / 2);
      const y = Math.round((bgImg.height - fgImg.height) / 2) + 50; // slightly lower than perfect center

      bgImg.composite(fgImg, x, y);

      const finalBytes = await bgImg.encodeJPEG(85);
      let finalBinary = '';
      for (let i = 0; i < finalBytes.byteLength; i++) {
          finalBinary += String.fromCharCode(finalBytes[i]);
      }
      return `data:image/jpeg;base64,${btoa(finalBinary)}`;
    } catch (e) {
      console.error("Compositing error:", e);
      // Fallback: just return the transparent image if compositing fails
      return `data:image/png;base64,${transparentImageBase64}`; 
    }

  } else if (flow === "B") {
    console.log("Menjalankan Pipeline Gratis untuk Flow B (Cloudflare Workers AI - Text-to-Image)...");
    
    // 1. Lakukan Prompt Enhancement sebelum dikirim ke Cloudflare
    console.log("Enhancing prompt dengan Gemini...");
    const enhancedPrompt = await enhanceProductPrompt(prompt, style);
    console.log(`[Prompt Original]: ${prompt}`);
    console.log(`[Prompt Enhanced]: ${enhancedPrompt}`);

    // Menggunakan Stable Diffusion XL Lightning (biasanya lebih stabil dan cepat di Cloudflare AI)
    const cloudflareUrl = `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/ai/run/@cf/bytedance/stable-diffusion-xl-lightning`;
    
    const cfResp = await fetch(cloudflareUrl, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${CLOUDFLARE_API_TOKEN}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        prompt: enhancedPrompt
      })
    });

    if (!cfResp.ok) {
      const errText = await cfResp.text();
      console.error("Cloudflare AI Error:", errText);
      throw new Error(`Cloudflare AI Error: ${cfResp.status} - ${errText}`);
    }
    
    // Cloudflare returns an object containing the base64 image in result.image or raw binary bytes
    const contentType = cfResp.headers.get("content-type") || "";
    if (contentType.includes("application/json")) {
       const cfData = await cfResp.json();
       return `data:image/jpeg;base64,${cfData.result?.image || cfData.result}`;
    } else {
       // Atau mengembalikan raw image bytes (binary)
       const arrayBuffer = await cfResp.arrayBuffer();
       const bytes = new Uint8Array(arrayBuffer);
       let binary = '';
       for (let i = 0; i < bytes.byteLength; i++) {
           binary += String.fromCharCode(bytes[i]);
       }
       const base64String = btoa(binary);
       return `data:image/jpeg;base64,${base64String}`;
    }
  }
  throw new Error("Invalid flow");
}

// ---------------------------------------------------------
// PIPELINE PREMIUM (Gemini API)
// ---------------------------------------------------------
async function processPremiumPipeline(flow: string, prompt: string, imageBase64: string, style: string) {
  const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-image:generateContent?key=${GEMINI_API_KEY}`
  let contents = [];

  if (flow === "A") {
    contents = [
      { 
        role: "user", 
        parts: [
          { text: `Enhance the background of this product photo to match the style: ${style}. Keep the original product exactly intact, only replace the background.` },
          { inlineData: { mimeType: "image/jpeg", data: imageBase64 } }
        ] 
      }
    ]
  } else if (flow === "B") {
    contents = [
      { 
        role: "user", 
        parts: [{ text: `Generate a photorealistic product image based on this description: ${prompt}. Additional style/context: ${style || 'none'}` }] 
      }
    ]
  } else {
    throw new Error("Invalid flow specified. Must be 'A' or 'B'.");
  }

  const resp = await fetch(geminiUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents,
      generationConfig: { temperature: 0.7 },
    }),
  })

  const data = await resp.json()
  
  if (data.error) {
    console.log("Gemini API Error:", data.error.message);
    const mockImage = flow === "A" 
        ? "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&q=80" 
        : "https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80";
    return mockImage;
  }

  return data.candidates?.[0]?.content?.parts?.[0]?.text || "";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders })

  try {
    // Default provider adalah 'free' (hemat biaya), bisa di-override jadi 'premium' (Gemini) dari request
    const { flow, prompt, image_base64, style, provider = "free" } = await req.json()

    let finalImageUrl = "";

    if (provider === "premium") {
      finalImageUrl = await processPremiumPipeline(flow, prompt, image_base64, style);
    } else {
      finalImageUrl = await processFreePipeline(flow, prompt, image_base64, style);
    }
    
    return new Response(JSON.stringify({ image_url: finalImageUrl, status: "success" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})
