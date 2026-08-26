# Prompt untuk Antigravity — Lapisan Prompt Enhancement untuk Generate Foto Produk

> Prompt independen, khusus membahas satu masalah: mengurangi halusinasi hasil generate gambar dari Cloudflare Workers AI saat prompt user terlalu singkat. Bisa ditempel sendiri atau digabung dengan prompt fitur foto produk sebelumnya.

---

## Masalah

Fitur generate foto produk dari prompt teks (memakai Cloudflare Workers AI, model FLUX/SDXL) sering menghasilkan gambar yang **berhalusinasi atau tidak sesuai** ketika prompt dari user terlalu singkat. Contoh: user hanya menulis "buatkan saya foto produk sepatu bernama brand Adidas" — hasilnya sering melenceng dari yang dimaksud, karena model open-source seperti FLUX/SDXL butuh deskripsi detail (sudut kamera, pencahayaan, komposisi, gaya) untuk hasil yang konsisten, berbeda dari model komersial yang lebih toleran terhadap prompt singkat/ambigu.

## Solusi yang diminta

Tambahkan **satu langkah "prompt enhancement"** di antara input user dan pemanggilan API image generation, supaya prompt singkat user tidak langsung dikirim mentah-mentah ke Cloudflare Workers AI.

### Alur yang diminta

1. User mengetik prompt singkat di UI (seperti biasa, tidak ada perubahan di sisi input).
2. **Sebelum dikirim ke Cloudflare Workers AI**, prompt mentah tersebut dikirim dulu ke **model teks ringan/murah** (misal Gemini Flash, atau model teks lain yang sudah dipakai di aplikasi) dengan instruksi sistem untuk memperluas prompt itu menjadi deskripsi detail siap pakai untuk image generation, mencakup:
   - Jenis & detail visual produk yang disebut user.
   - Sudut pengambilan foto (misal "product shot, 3/4 angle" atau "flat lay dari atas" tergantung jenis produk).
   - Pencahayaan (misal "soft studio lighting", "pencahayaan alami hangat").
   - Komposisi & framing (misal "centered, clean composition, ruang kosong di sekitar objek").
   - Gaya background sesuai pilihan yang sudah dipilih user di UI (kalau ada pilihan gaya terpisah).
3. Hasil prompt yang sudah diperluas itu baru dikirim ke Cloudflare Workers AI untuk generate gambar.
4. Proses enhancement ini **berjalan otomatis di backend**, tidak perlu ditampilkan sebagai langkah terpisah yang mengganggu alur user — cukup masuk dalam loading state yang sudah ada.

### Penanganan khusus: prompt yang menyebut nama brand pihak lain

Kalau prompt user menyebut nama brand tertentu (misal "sepatu Adidas", "tas Louis Vuitton"), tangani secara khusus di tahap enhancement ini:
- Model image generation open-source sering **gagal mereproduksi logo/desain brand secara akurat** — hasilnya malah terlihat aneh atau salah, bukan mendekati produk asli, dan justru memperparah kesan halusinasi.
- Instruksikan model teks enhancement untuk **menerjemahkan maksud user menjadi deskripsi visual generik** yang relevan dengan ciri khas kategori produk tersebut (misal "sepatu sneaker olahraga modern dengan garis-garis di sisi", bukan "logo Adidas") — tanpa menyertakan nama brand secara eksplisit ke prompt yang dikirim ke image generator.
- Ini membuat hasil gambar tetap masuk akal secara visual, alih-alih mencoba dan gagal meniru elemen brand yang tidak akurat.

### Fitur pendukung di UI (opsional tapi disarankan)

- Sediakan bagian **"detail lanjutan"** yang bisa dibuka (collapsible), menampilkan hasil prompt yang sudah diperbagus oleh sistem — supaya user yang ingin menyesuaikan manual sebelum generate ulang bisa melakukannya. Default-nya tetap tersembunyi, supaya user awam tidak terbebani istilah teknis.
- **Cache/simpan hasil prompt enhancement** bersama riwayat hasil gambar, supaya kalau user generate ulang dari prompt yang sama, sistem tidak perlu memanggil model teks lagi untuk enhancement — menghemat biaya dan mempercepat proses.

## Yang harus dihindari
- Jangan biarkan prompt mentah user langsung dikirim ke Cloudflare Workers AI tanpa lewat enhancement — ini akar masalah halusinasi yang ingin diperbaiki.
- Jangan proses enhancement membuat waktu tunggu user terasa jauh lebih lama tanpa indikasi — tetap satu loading state yang mulus, bukan dua tahap loading terpisah yang bikin user bingung.
- Jangan hasil enhancement mengubah maksud inti produk yang diminta user (misal user minta "kue coklat" jangan sampai hasil enhancement malah mengarah ke jenis kue lain) — enhancement hanya menambah detail teknis foto, bukan mengganti substansi permintaan user.
- Jangan sertakan nama brand pihak lain secara eksplisit ke prompt final yang dikirim ke image generator, sesuai penjelasan di atas.

## Detail teknis yang diminta
1. Buat fungsi/service terpisah untuk enhancement ini (misal `enhanceProductPrompt()`), supaya logic-nya terpisah dari pemanggilan API image generation dan gampang diuji/diganti modelnya nanti.
2. Tentukan timeout & fallback: kalau pemanggilan model enhancement gagal/timeout, tetap lanjutkan proses generate dengan prompt asli user (jangan sampai seluruh fitur gagal total hanya karena langkah enhancement bermasalah).
3. Batasi panjang hasil enhancement (misal maksimum sekian karakter/token) supaya tetap sesuai batas input yang diterima Cloudflare Workers AI.
4. Log/simpan prompt asli user dan hasil enhancement-nya secara terpisah di database riwayat, untuk keperluan debugging kalau hasil gambar masih sering meleset di kemudian hari.

## Batasan
- Model teks yang dipakai untuk enhancement: **[misal: Gemini Flash, atau model teks lain yang sudah dipakai di fitur chat Ite]**
- Hal yang tidak 
boleh diubah: **[misal: struktur input prompt di UI, alur generate dan penyimpanan hasil yang sudah ada]**