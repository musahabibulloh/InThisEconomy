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

## Yang harus dihindari
- Jangan proses ini disebut/berperilaku sebagai "remove background" (jangan hasilkan background transparan/kosong) — hasil akhirnya harus tetap ada background baru yang terlihat profesional, bukan produk melayang tanpa latar.
- Jangan menyatukan dua flow ini jadi satu form membingungkan yang mencoba menangani upload foto dan generate dari teks sekaligus di layar yang sama — pisahkan jelas sebagai dua alur/tab/halaman berbeda.
- Jangan hasil generate langsung menggantikan/menimpa tanpa preview dulu — user harus selalu melihat hasil dan bisa menolak/generate ulang sebelum dipakai final.
- Jangan lupa menangani kasus produk tidak terdeteksi jelas di foto (misal foto blur/terlalu gelap) — beri feedback yang membantu, bukan diam-diam menghasilkan output buruk.

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
- Model/API AI yang dipakai untuk image processing & generation: **Google Gemini API, model Nano Banana 2 (`gemini-3.1-flash-image`)** — dipakai untuk kedua flow: Flow A (image editing, background diganti sementara produk asli dipertahankan) maupun Flow B (text-to-image generation dari prompt user). Gunakan API key/kredensial Google AI yang sama dengan yang dipakai fitur AI Chat Ite, tapi endpoint/model berbeda (model teks untuk chat, model gambar untuk fitur ini).
- Hal yang tidak boleh diubah: **[misal: struktur penyimpanan foto produk di database, batas kuota generate per user kalau ada]**