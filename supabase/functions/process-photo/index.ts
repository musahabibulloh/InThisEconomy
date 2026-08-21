import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const REMOVE_BG_API_KEY = Deno.env.get("REMOVE_BG_API_KEY")

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders })

  try {
    const { photo_id, storage_path } = await req.json()

    const authHeader = req.headers.get("Authorization")!
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")! // Use service role for storage ops
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Download original image from storage
    const { data: fileData, error: downloadError } = await supabase.storage
      .from("product-photos")
      .download(storage_path)

    if (downloadError) throw downloadError

    const processedPaths: Array<{ type: string; path: string }> = []

    // Remove background using remove.bg API
    if (REMOVE_BG_API_KEY) {
      const formData = new FormData()
      formData.append("image_file", fileData, "image.png")
      formData.append("size", "auto")

      const bgResp = await fetch("https://api.remove.bg/v1.0/removebg", {
        method: "POST",
        headers: { "X-Api-Key": REMOVE_BG_API_KEY },
        body: formData,
      })

      if (bgResp.ok) {
        const processedBlob = await bgResp.blob()
        const processedBytes = new Uint8Array(await processedBlob.arrayBuffer())
        const noBgPath = storage_path.replace(/\.[^.]+$/, "_no_bg.png")

        await supabase.storage.from("product-photos").upload(noBgPath, processedBytes, {
          contentType: "image/png",
          upsert: true,
        })

        processedPaths.push({ type: "no_bg", path: noBgPath })
      }
    }

    // Update database record
    await supabase.from("product_photos").update({
      processed_paths: processedPaths,
      status: processedPaths.length > 0 ? "done" : "error",
    }).eq("id", photo_id)

    return new Response(JSON.stringify({ success: true, processed_paths: processedPaths }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})
