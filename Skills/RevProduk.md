# Prompt untuk Antigravity — Perbaikan Fitur "Perbagus Produk / Foto Produk"

> Koreksi alur fitur ini dari implementasi sebelumnya. Tempel ke Antigravity untuk memperbaiki logic dan UI fitur ini, tetap konsisten dengan gaya visual (glass tema terang) dan maskot Ite yang sudah ditentukan sebelumnya.

---

Fitur **"Perbagus Produk/Foto Produk"** di aplikasi ini **bukan** fitur remove background biasa. Perbaiki pemahaman dan implementasinya sesuai alur berikut, karena versi sebelumnya salah arah.

## Alur fitur yang benar

Fitur ini punya **dua jalur (flow)** tergantung kondisi user:

### Flow A — User sudah punya foto produk
1. User mengambil foto langsung dari kamera **atau** memilih dari galeri foto yang sudah ada.
2. Sistem memproses foto tersebut dan **mempercantik background di belakang produk** menjadi tampilan profesional — bukan menghapus background jadi transparan/putih polos, tapi mengganti/memperindah background dengan latar yang sesuai konteks produk (misal produk makanan dapat background meja kayu dengan pencahayaan hangat, produk fashion dapat background studio/lifestyle, dst — AI yang menentukan atau user bisa pilih gaya).
3. Objek produk aslinya (yang difoto user) tetap dipertahankan apa adanya — yang berubah/ditingkatkan adalah **latar belakangnya**, bukan produknya.
4. User melihat hasil sebelum-sesudah, bisa pilih untuk generate ulang dengan gaya background lain kalau kurang cocok, lalu simpan/pakai hasilnya.

### Flow B — User belum punya foto produk sama sekali
1. User yang belum sempat/tidak punya foto produk bisa memakai jalur ini: **generate foto produk sepenuhnya lewat AI**, berdasarkan **prompt teks** yang ditulis user (deskripsi produknya, misal: "kue coklat dengan topping stroberi di atas piring putih").
2. Sistem men-generate gambar produk dari deskripsi tersebut menggunakan AI image generation — hasilnya adalah foto produk baru yang belum pernah ada secara fisik, bukan hasil edit dari foto asli.
3. Beri panduan singkat di UI untuk membantu user menulis prompt yang bagus (contoh prompt, atau field terpisah untuk detail seperti jenis produk, gaya foto yang diinginkan, warna dominan) — supaya user awam yang tidak terbiasa menulis prompt AI tetap bisa dapat hasil bagus.
4. Sama seperti Flow A, tampilkan hasil generate, izinkan generate ulang/variasi kalau belum sesuai, lalu simpan/pakai hasilnya.

## Perbaikan UI yang dibutuhkan

**Pintu masuk fitur harus jelas memisahkan dua flow ini sejak awal**, bukan langsung minta upload foto seolah-olah cuma ada satu jalur. Begitu user membuka fitur ini, tampilkan pilihan yang jelas: "Punya foto produk? Percantik background-nya" vs "Belum punya foto? Buat foto produk pakai AI" — dua pilihan ini harus sama-sama menonjol, jangan salah satu terasa jadi opsi utama dan satunya cuma link kecil di pojok.

**Flow A (percantik background):**
- Tombol/aksi untuk ambil foto langsung dari kamera dan pilih dari galeri, ditampilkan berdampingan sebagai dua opsi yang sama mudahnya diakses.
- Setelah foto masuk, tampilkan preview foto asli dulu sebelum diproses, supaya user yakin foto yang benar yang terupload.
- Kalau ada pilihan gaya/tema background (misal: minimalis, kayu natural, studio putih, lifestyle), tampilkan sebagai pilihan visual (thumbnail kecil tiap gaya), bukan dropdown teks polos — supaya user gampang membayangkan hasilnya sebelum generate.
- Tampilkan hasil dengan perbandingan jelas antara foto asli dan hasil background baru (misal slider before-after, atau side-by-side), supaya user bisa menilai hasilnya.

**Flow B (generate dari prompt):**
- Sediakan field input prompt yang cukup lega untuk menulis deskripsi, dengan placeholder contoh yang relevan dengan jenis usaha user (kalau sistem tahu jenis usahanya dari data akun, pakai itu untuk contoh yang lebih personal).
- Beri opsi field tambahan terstruktur (jenis produk, gaya foto, suasana) sebagai bantuan bagi user yang kesulitan menulis prompt bebas — ini opsional, bukan wajib, tapi harus terlihat sebagai bantuan yang mudah ditemukan.
- Tampilkan indikator proses generate yang jelas (loading state) karena generate AI biasanya butuh beberapa detik, jangan biarkan layar terlihat diam tanpa feedback.
- Setelah hasil muncul, beri opsi "generate ulang"/"coba variasi lain" yang mudah dijangkau, karena hasil generate pertama tidak selalu sesuai harapan user.

**Konsistensi dengan Ite.** Karena icon fitur ini sebelumnya digambarkan sebagai "Ite memegang kamera memfoto", pastikan pose itu tetap relevan dipakai sebagai icon menu untuk fitur ini secara keseluruhan (mewakili kedua flow, karena intinya sama-sama soal "menghasilkan foto produk yang bagus"). Kalau ingin membedakan visual kedua flow di dalam fitur, boleh tambah elemen kecil pembeda (misal ikon kamera untuk Flow A, ikon percakapan/pensil untuk Flow B yang berbasis prompt teks) tapi tetap dalam gaya ilustrasi Ite yang sama, jangan icon generik terpisah dari karakter Ite.

## Pipeline teknis Flow A (versi hemat biaya — tanpa API berbayar)

Untuk menekan biaya di tahap awal, Flow A dibangun dengan pipeline 3 langkah berikut, bukan langsung memanggil satu API image-editing berbayar:

**Langkah 1 — Hapus background dari foto asli.**
Gunakan `rembg` (open-source, self-hosted lewat Docker/HTTP server, gratis tanpa batas) dengan model **rembg-enhance atau BiRefNet** (bukan u2net dasar) karena alpha matting-nya lebih halus di tepi objek — penting untuk produk dengan detail rumit (misal kain, kemasan mengkilap, tekstur berbulu). Hasil langkah ini adalah PNG produk dengan background transparan.

**Langkah 2 — Generate background baru.**
Gunakan **Cloudflare Workers AI** (model FLUX.1 Schnell atau Stable Diffusion XL, gratis hingga kuota neuron harian) untuk generate gambar background sesuai gaya yang dipilih user (studio, kayu natural, lifestyle, dst — sesuai pilihan visual yang sudah dirancang di UI). Batasi pilihan gaya ke background yang pencahayaannya relatif flat/merata (studio, gradient polos, tekstur natural sederhana) — background dengan pencahayaan dramatis/kompleks (misal sudut matahari sore, banyak sumber cahaya) lebih sulit di-composite secara meyakinkan di langkah berikut.

**Langkah 3 — Gabungkan (composite) objek dengan background baru.**
Ini langkah paling kritis untuk kualitas hasil akhir — jangan sekadar menempel layer PNG transparan di atas background begitu saja, karena hasilnya akan terlihat "ditempel", bukan "difoto di situ". Tambahkan proses berikut:
- **Sintesis bayangan (drop shadow):** buat bayangan lembut di bawah objek secara sintetis berdasarkan siluet objek (bukan mengandalkan bayangan asli dari foto sumber, karena arahnya kemungkinan tidak sesuai dengan background baru).
- **Color/tone matching:** samakan sedikit brightness, saturasi, dan white balance objek dengan tone keseluruhan background, supaya objek tidak terlihat "lebih terang/gelap sendiri" dibanding sekelilingnya.
- **Edge feathering halus:** beri sedikit blur mikro di tepi objek (1-2px) untuk menghindari garis tepi yang terlalu tajam/patah yang jadi ciri khas hasil cutout-composite amatir.
- Posisikan objek secara proporsional di frame (tidak terlalu mepet tepi, beri ruang komposisi yang wajar untuk foto produk).

**Fallback ke API berbayar (opsional, untuk kualitas premium).**
Sediakan opsi di pengaturan/backend untuk beralih ke Gemini API (Nano Banana 2) sebagai pipeline alternatif kalau nanti dibutuhkan kualitas lebih tinggi (terutama untuk background lifestyle kompleks yang sulit di-composite manual) — desain kode supaya provider image-processing ini bisa di-swap tanpa mengubah struktur UI/flow, jadi upgrade di masa depan tidak perlu bongkar ulang fitur.

## Yang harus dihindari
- Jangan proses ini disebut/berperilaku sebagai "remove background" secara final (hasil akhirnya harus tetap ada background baru yang terlihat profesional, bukan produk melayang tanpa latar) — meskipun secara internal langkah 1 pipeline Flow A memang menghapus background sementara, itu hanya tahap antara, bukan hasil akhir yang ditampilkan ke user.
- Jangan sekadar menempel cutout produk di atas background baru tanpa sintesis bayangan/color matching — hasilnya akan terlihat jelas "ditempel", merusak kesan "profesional" yang jadi inti fitur ini.
- Jangan menyatukan dua flow ini jadi satu form membingungkan yang mencoba menangani upload foto dan generate dari teks sekaligus di layar yang sama — pisahkan jelas sebagai dua alur/tab/halaman berbeda.
- Jangan hasil generate langsung menggantikan/menimpa tanpa preview dulu — user harus selalu melihat hasil dan bisa menolak/generate ulang sebelum dipakai final.
- Jangan lupa menangani kasus produk tidak terdeteksi jelas di foto (misal foto blur/terlalu gelap, background terlalu mirip warna produk sehingga cutout gagal rapi) — beri feedback yang membantu, bukan diam-diam menghasilkan output buruk.

## Detail teknis yang diminta
1. Pisahkan logic backend/API call untuk Flow A (image-to-image, background enhancement dengan produk asli dipertahankan) dan Flow B (text-to-image generation) karena keduanya butuh pendekatan model AI yang berbeda.
2. Simpan riwayat hasil generate (baik Flow A maupun B) supaya user bisa membuka kembali hasil sebelumnya tanpa generate ulang dari nol.
3. Batasi ukuran/format file upload untuk Flow A dan validasi sebelum dikirim ke proses AI, dengan pesan error yang jelas kalau format tidak didukung.
4. Sesuaikan komponen upload, pilihan gaya, dan hasil generate dengan gaya glass tema terang yang sudah ditentukan untuk seluruh aplikasi.

## Proses kerja yang diminta
1. Tunjukkan dulu wireframe/alur singkat untuk kedua flow ini (bagaimana user berpindah dari pintu masuk fitur ke masing-masing flow, sampai ke hasil akhir) sebelum coding.
2. Cek ulang: apakah kedua flow ini benar-benar terasa terpisah jelas dari sisi user, dan apakah istilah "remove background" sudah benar-benar hilang dari semua teks/label di fitur ini?
3. Baru implementasikan sesuai alur yang sudah dikonfirmasi.

## Batasan
- Model/API AI yang dipakai untuk image processing & generation (versi hemat biaya):
  - **Flow A** (percantik background): pipeline 3 langkah gratis — `rembg`/BiRefNet (self-hosted, background removal) → **Cloudflare Workers AI** (FLUX.1 Schnell/SDXL, generate background baru) → proses compositing custom (shadow synthesis, color matching, edge feathering) di backend.
  - **Flow B** (generate dari prompt): boleh pakai **Cloudflare Workers AI** (FLUX.1 Schnell) untuk versi gratis, atau **Google Gemini API, model Nano Banana 2 (`gemini-3.1-flash-image`)** untuk kualitas lebih tinggi — pilih sesuai budget tahap ini.
  - Sediakan fallback opsional ke Gemini API (Nano Banana 2) untuk kedua flow, terutama Flow A ketika hasil compositing manual kurang meyakinkan (background lifestyle kompleks). Desain arsitektur provider image-processing agar mudah di-swap (interface/abstraction terpisah dari logic UI) supaya pindah dari pipeline gratis ke Gemini nanti tidak perlu bongkar ulang fitur.
  - Kalau fitur chat Ite tetap pakai Gemini API, gunakan API key/kredensial Google AI yang sama untuk fallback Gemini di fitur ini (model teks untuk chat, model gambar untuk fitur ini) — tapi ini terpisah dari pipeline utama Cloudflare Workers AI yang tidak butuh kredensial Google.
- Hal yang tidak boleh diubah: **[misal: struktur penyimpanan foto produk di database, batas kuota generate per user kalau ada]**