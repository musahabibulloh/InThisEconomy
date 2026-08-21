# Prompt untuk Antigravity — Redesign Halaman Login: "In This Economy" (ITE)

> Pelengkap dari prompt-prompt sebelumnya (redesign UI, bottom navigation, glass tema terang, icon maskot Ite, persona AI chat Ite). Tempel ke Antigravity untuk mengubah halaman login.

---

Ubah nama aplikasi menjadi **"In This Economy"**, dengan singkatan **ITE** — nama ini terhubung langsung dengan maskot beruang Ite yang sudah jadi karakter AI chat di aplikasi (jadi nama aplikasi dan nama maskot sengaja senada, itu bagian dari identitas brand-nya, bukan kebetulan). Redesign halaman login supaya mencerminkan identitas baru ini dengan baik, karena halaman login adalah kesan pertama yang dilihat user.

## Yang harus diubah

1. **Nama aplikasi:** ganti jadi "In This Economy" sebagai judul utama, dengan "ITE" bisa ditampilkan sebagai wordmark singkat/logo teks (misal di logo kecil, tab browser/title bar, atau sebagai aksen di samping nama lengkap) — tentukan sendiri komposisi mana yang tampil sebagai judul utama vs mana yang jadi elemen sekunder, supaya tidak terasa dua nama bertabrakan.
2. **Ilustrasi utama:** Ite (beruang maskot) sedang memegang uang — pose ini harus terasa relevan dengan makna nama aplikasi (nada "in this economy" biasanya sedikit jenaka/relatable soal kondisi ekonomi/usaha kecil yang harus pintar berhitung), jadi ekspresi Ite di sini boleh punya sedikit karakter humor-relatable, bukan sekadar pose netral memegang uang.
3. **Ikuti gaya dasar Ite yang sudah ditentukan sebelumnya** (proporsi tubuh, ketebalan garis, warna badan, gaya wajah) — pose baru ini harus terasa jelas sebagai karakter yang sama dengan Ite di icon-icon fitur lain, hanya beda pose dan properti (uang, bukan bola lampu/kaca pembesar/kamera).
4. **Uang yang dipegang** digambar dengan gaya yang senada (ketebalan garis, tingkat kebulatan sudut) dengan gaya Ite — bukan clip-art uang generik yang ditempel. Boleh berupa lembaran uang kertas bertumpuk/dikepit, atau koin, sesuaikan mana yang lebih enak dikomposisikan dengan pose beruang.

## Prinsip desain untuk halaman login

**Nama & maskot harus jadi satu kesatuan visual**, bukan logo teks dan ilustrasi yang ditaruh terpisah tanpa hubungan. Pertimbangkan komposisi di mana Ite dan tulisan "In This Economy"/"ITE" terasa satu unit — misalnya Ite ditempatkan berdekatan/tumpang tindih ringan dengan wordmark, bukan ilustrasi besar di atas dan judul kecil terpisah jauh di bawah seperti template landing page pada umumnya.

**Tetap konsisten dengan gaya glass tema terang** yang sudah ditentukan untuk seluruh aplikasi — form login (input username/password, tombol masuk) pakai permukaan kaca semi-transparan di atas background terang, bukan form solid putih polos yang berbeda gaya dari halaman lain.

**Hindari layout login generik.** Jangan pola login page template AI yang paling umum: ilustrasi generik di kiri/atas + form putih polos kanan/bawah tanpa hubungan visual satu sama lain. Buat komposisi yang terasa dirancang khusus untuk kombinasi nama+maskot ini — beri ruang yang cukup untuk Ite jadi fokus utama karena dia yang membawa identitas aplikasi ini, bukan sekadar dekorasi kecil di pojok.

**Copywriting ikut nada nama aplikasi.** Teks pendukung di halaman login (tagline kecil di bawah nama, atau placeholder/microcopy di form) boleh punya sentuhan nada yang senada dengan "In This Economy" — relatable untuk pemilik usaha kecil, tanpa jadi berlebihan atau mengganggu fungsi form.

## Yang harus dihindari
- Jangan dua identitas (nama lengkap "In This Economy" dan singkatan "ITE") ditampilkan berulang-ulang di banyak tempat pada satu layar sampai terasa membingungkan — pilih satu jadi dominan, satu jadi pendukung.
- Jangan pose Ite memegang uang terasa acak/tidak berhubungan dengan tema — pastikan komposisi mendukung kesan bahwa aplikasi ini soal mengelola usaha kecil dengan cerdas di kondisi ekonomi apa pun.
- Jangan mengubah gaya menggambar Ite sedikit pun dari yang sudah ditentukan di icon-icon fitur lain — halaman login harus terasa dari studio yang sama, bukan ilustrasi terpisah dengan gaya berbeda.
- Jangan form login jadi kurang jelas/kurang kontras karena terlalu fokus mempercantik ilustrasi maskot — fungsi login (input, tombol masuk, lupa password) tetap harus paling mudah ditemukan dan digunakan.

## Detail teknis yang diminta
1. Update semua referensi nama aplikasi lama menjadi "In This Economy"/"ITE" di seluruh tempat yang relevan di halaman login (title, header, favicon/title bar kalau memungkinkan).
2. Ilustrasi Ite memegang uang dibuat sebagai SVG mengikuti struktur/gaya yang sama dengan set icon Ite sebelumnya, supaya konsisten dan gampang di-maintain.
3. Pastikan layout tetap responsive dan form tetap mudah dipakai di device yang dipakai kasir sehari-hari.
4. Sesuaikan warna aksen tombol masuk dan elemen interaktif dengan token warna yang sudah ditentukan di desain aplikasi secara keseluruhan.

## Proses kerja yang diminta
1. Tunjukkan dulu rencana komposisi login (sketsa/wireframe ringkas): posisi Ite, wordmark "In This Economy"/"ITE", form, dan tagline kalau ada — sebelum coding.
2. Cek ulang: apakah komposisi ini terasa dirancang khusus untuk brand ini, atau masih terasa seperti "ilustrasi + form" template pada umumnya? Revisi kalau perlu.
3. Baru implementasikan, pastikan konsisten dengan gaya glass terang dan gaya Ite yang sudah dipakai di bagian lain aplikasi.

## Halaman Register — samakan identitasnya dengan login

Terapkan identitas "In This Economy"/ITE yang sama ke halaman register, jangan sampai halaman register terasa jadi halaman terpisah dengan gaya berbeda dari login (ini yang sering luput — desainer fokus mempercantik login tapi lupa register-nya masih pakai style lama).

**Jangan copy-paste komposisi login apa adanya ke register.** Kalau ilustrasi Ite memegang uang di login besar dan jadi fokus utama, di register beri sedikit variasi supaya user tetap sadar ini halaman berbeda — bisa dengan pose Ite yang sedikit berbeda (misal Ite menyambut/melambai, menyesuaikan konteks "user baru bergabung"), atau posisi ilustrasi diperkecil/digeser supaya form register yang biasanya field-nya lebih banyak (nama, email, nama usaha, password, dst.) tetap jadi fokus utama dan tidak sesak.

**Prioritaskan kejelasan form saat field lebih banyak.** Karena form register biasanya lebih panjang dari login, pastikan gaya kaca (glass) tidak membuat banyak input jadi terasa "menumpuk" secara visual — beri jarak/grouping yang jelas antar field (misal kelompok data pribadi vs data usaha, kalau ada), dan pastikan ilustrasi Ite tidak mendorong form sampai perlu scroll berlebihan di layar kecil.

**Konsistensi microcopy.** Kalau di login ada tagline/nada bicara relatable khas "In This Economy", lanjutkan nada yang sama di register (misal ajakan singkat untuk mulai kelola usaha, bukan teks form generik "Silakan isi data di bawah ini").

**Transisi antar login-register.** Kalau ada link/tombol pindah antara halaman login dan register ("Belum punya akun? Daftar" / "Sudah punya akun? Masuk"), desain transisinya (kalau pakai animasi) terasa halus dan menunjukkan bahwa kedua halaman ini satu keluarga desain, konsisten dengan prinsip animasi fungsional yang sudah ditentukan di bagian bottom navigation sebelumnya.

### Yang harus dihindari khusus register
- Jangan halaman register jadi terasa "form generik ditempel di background polos" sementara login sudah dipercantik penuh — keduanya harus terasa satu paket desain.
- Jangan Ite di register pakai pose/ilustrasi yang persis sama ukuran & posisi dengan login tanpa penyesuaian apa pun — beri sedikit pembeda supaya user tetap bisa membedakan halaman mana yang sedang dibuka sekilas pandang.
- Jangan form jadi sempit/berdesakan karena ilustrasi maskot terlalu dominan menutup ruang — untuk register, keseimbangan bisa digeser sedikit lebih ke arah form karena field-nya lebih banyak.

## Batasan
- Hal yang tidak boleh diubah: **[misal: logic autentikasi, validasi form, endpoint API login/register]**