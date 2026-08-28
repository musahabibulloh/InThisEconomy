const SERPAPI_KEY = "bd59821bc7fa4a8e3c15bd89197211b49311272ec9252c81c0f1e802e1eeefd9"
const url = `https://serpapi.com/search.json?engine=google_maps&q=laundry&ll=@-7.76,110.4,14z&hl=id&gl=id&api_key=${SERPAPI_KEY}`

fetch(url)
  .then(res => res.json())
  .then(data => {
    const places = data.local_results || []
    if (places.length > 0) {
      console.log(JSON.stringify(places.slice(0, 2), null, 2))
    } else {
      console.log("No places found")
    }
  })
