# Prompt UI/UX untuk AI Agent: Desain Tampilan Aplikasi UMKM

## Konteks

Aplikasi mobile (Flutter) yang membimbing calon/pelaku UMKM memvalidasi ide bisnis dengan data (Google Maps, tren pencarian), bukan sekadar platform kursus. Fungsional sudah selesai dibangun — dokumen ini khusus untuk **memperbaiki UI/UX**, bukan menambah fitur baru.

## Audiens & nada desain

- **Pengguna**: calon/pelaku UMKM di Indonesia — rentang usia luas, tidak semua melek teknologi tinggi. Banyak yang baru pertama kali pakai aplikasi berbasis data/analisis.
- **Arah desain baru: kartun dengan maskot, playful total** — ini perombakan total dari arah sebelumnya (yang bernada "mentor bisnis serius"). Sekarang aplikasi harus terasa seperti punya **teman/pemandu berkarakter** yang menemani proses validasi ide bisnis, mirip peran maskot burung di Duolingo: hadir di banyak titik, punya ekspresi, dan jadi "wajah" aplikasi.
- **Playful total** berarti bukan cuma visualnya yang kartun — cara aplikasi "bicara" (microcopy, notifikasi, pesan error, pesan kosong) juga ikut playful dan berkarakter, bukan sekadar teks formal yang dikasih ilustrasi lucu di sampingnya.
- **Yang tetap harus dijaga** meski playful: hasil analisis (skor peluang, persaingan, dll) tetap harus **mudah dibaca dan tidak ambigu** — kartun boleh membungkus, tapi jangan sampai mengaburkan angka/level yang jadi dasar keputusan user mengeluarkan modal.
- **Yang harus dihindari**: kesan kartun generik/template AI (maskot bulat polos dengan mata besar tanpa kepribadian, warna pastel tanpa arah). Maskot dan gaya visual harus terasa dirancang khusus untuk aplikasi ini — terinspirasi dari dunia UMKM/pasar (misalnya maskot berkarakter "pedagang kecil yang cerdik", atau elemen visual dari pasar tradisional/warung yang diolah jadi gaya kartun), bukan maskot generik yang bisa dipakai aplikasi apa saja.

## Maskot & karakter

Ini elemen sentral dari arah desain baru — perlu dirancang serius meski hasilnya playful:

1. **Konsep karakter**: tentukan siapa maskot ini (nama, bentuk, kepribadian singkat) yang relevan dengan dunia UMKM — misalnya karakter yang terinspirasi dari pedagang/pengrajin lokal, bukan hewan generik tanpa alasan.
2. **Ekspresi & pose**: siapkan variasi ekspresi untuk berbagai situasi — semangat (menyambut, merayakan hasil bagus), berpikir (loading/proses analisis), khawatir tapi tetap suportif (hasil peluang rendah/persaingan tinggi — maskot tetap positif dan mengarahkan, bukan mengejek/menakuti), menyemangati (empty state, ajakan mulai cek ide).
3. **Titik kemunculan maskot**: 
   - Onboarding (memperkenalkan diri & aplikasi)
   - Layar hasil analisis Modul 1 (bereaksi sesuai skor peluang)
   - Empty state di semua modul (Konsultasi AI belum ada riwayat, dsb)
   - Loading/proses (saat menunggu hasil analisis atau olah foto)
   - Chatbot Modul 2 — maskot ini bisa jadi "wujud" dari chatbot itu sendiri, bukan entitas terpisah
4. **Konsistensi**: maskot harus terasa satu kesatuan gaya visual dengan ilustrasi/ikon lain di aplikasi (bukan maskot kartun ditempel di atas UI yang gayanya beda sendiri).

## Yang perlu disiapkan agent sebelum mendesain (token sistem)

Sebelum membuat layar apa pun, susun dulu:

1. **Palet warna** — 4–6 warna bernama dengan kode hex, cerah dan hangat sesuai gaya kartun (bukan palet korporat/muted), termasuk warna untuk status (peluang tinggi/sedang/rendah, persaingan tinggi/rendah) yang tetap konsisten dengan identitas visual keseluruhan, bukan sekadar merah/kuning/hijau generik semaphore.
2. **Tipografi** — pilih font yang mendukung kesan playful (bentuk lebih bulat/tebal/friendly untuk judul), dipadukan dengan font body yang tetap nyaman dibaca panjang untuk hasil analisis. Pastikan mendukung karakter Bahasa Indonesia dengan baik dan tetap terbaca di ukuran kecil (mobile).
3. **Gaya ilustrasi** — tentukan gaya vektor kartun yang konsisten (outline tebal/tipis, warna flat/gradasi, proporsi karakter) yang dipakai di maskot, ikon, dan ilustrasi empty state/error state.
4. **Konsep layout** — bagaimana pola umum layar disusun (navigasi bawah vs atas, kartu vs list, dsb), dengan ruang yang cukup untuk elemen ilustrasi/maskot tanpa mengorbankan keterbacaan data.
5. **Elemen signature** — bagaimana maskot dan gaya kartun ini menyatu dengan cara unik menampilkan skor peluang/persaingan (misalnya maskot "memegang" indikator level, bukan progress bar generik yang cuma ditempeli maskot di sampingnya).

Setelah menyusun rencana ini, agent harus mengecek ulang: apakah pilihan ini benar-benar spesifik untuk aplikasi UMKM ini, atau hanya jawaban default kartun yang bisa dipakai untuk aplikasi apa saja? Revisi bagian yang masih terasa generik sebelum lanjut membangun.

## Kebutuhan desain per layar

### Login & onboarding
- Perkenalkan **maskot & nilai aplikasi** dalam 1 layar singkat (bukan sekadar form login) — maskot menyapa dan menjelaskan singkat kenapa aplikasi ini ada, dengan gaya bicara playful, bukan tagline korporat.
- Form login sederhana, target tap besar (ramah untuk pengguna yang kurang terbiasa pakai HP untuk hal teknis), tapi tetap dibungkus gaya visual kartun (ilustrasi latar, tombol dengan karakter bentuk khas, bukan form generik polos).

### Dashboard (hub ke 3 modul)
- Tampilkan 3 modul (Cek ide bisnis, Konsultasi AI, Cek produk) dengan hierarki visual yang jelas mana yang jadi fitur utama (Cek ide bisnis) vs pendukung — gunakan ilustrasi kartun berbeda per modul supaya masing-masing punya identitas visual sendiri yang mudah dikenali sekilas.
- Kalau user sudah punya riwayat cek ide sebelumnya, tampilkan ringkasan singkat di dashboard dengan maskot memberi komentar singkat (misalnya menyapa dan mengingatkan progres), bukan kosong atau sekadar kartu data datar.

### Modul 1 — Cek ide bisnis
- **Pemilihan jalur** (sudah punya ide / belum punya ide) harus jelas dan tidak membingungkan — bisa dibantu maskot yang "bertanya" ke user untuk menentukan jalur mana yang cocok, sehingga pemilihan terasa seperti percakapan, bukan dua tombol abstrak.
- **Input lokasi**: gunakan peta interaktif untuk pemilihan titik lokasi (bukan hanya field teks), karena ini krusial untuk akurasi hasil analisis. Maskot bisa muncul kecil di sudut peta sambil memandu.
- **Layar hasil**: ini layar terpenting di seluruh aplikasi. Harus menampilkan 6 komponen (target pasar, persaingan, minat konsumen, produk sejenis, peluang diferensiasi, risiko tren) dengan cara yang **cepat dipahami sekilas** (scannable) dan playful, tapi **tidak boleh mengorbankan kejelasan angka/level** karena ini dasar keputusan modal user. Pertimbangkan:
  - Skor/level (tinggi-sedang-rendah) ditampilkan visual dengan bantuan ekspresi maskot yang sesuai (semangat kalau peluang tinggi, tetap suportif & mengarahkan kalau peluang rendah — jangan sampai maskot terkesan mengejek/menyindir hasil buruk).
  - Daftar kompetitor sejenis ditampilkan ringkas dengan opsi "lihat semua".
  - Rekomendasi/diferensiasi ditonjolkan sebagai bagian paling actionable, disampaikan seolah maskot memberi saran langsung ke user, bukan ditaruh di akhir sebagai catatan kecil.
  - Beri disclaimer bahwa ini "perkiraan berbasis data yang tersedia" — tetap disampaikan dengan nada ringan lewat maskot, bukan seperti penafian hukum yang menakutkan.

### Modul 2 — Konsultasi AI
- Maskot **menjadi wujud chatbot itu sendiri** — bukan sekadar ikon chat generik. Desain bubble chat, avatar, dan gaya bicara mengikuti kepribadian maskot yang sudah ditentukan.
- Desain chat yang terasa personal karena tahu riwayat ide user — pertimbangkan menampilkan referensi singkat ke ide yang sedang dibahas di dalam chat (misal chip/label kecil menunjukkan konteks ide mana yang sedang dirujuk).
- Empty state saat user belum punya riwayat: maskot mengarahkan ke Modul 1 dulu dengan ajakan playful, bukan sekadar kotak chat kosong.

### Modul 3 — Cek produk (tools foto)
- Alur upload → proses → hasil harus terasa cepat dan jelas progressnya — loading state bisa memakai animasi maskot "bekerja" (misalnya sedang mengedit foto) supaya menunggu terasa lebih hidup, bukan spinner generik.
- Tampilkan perbandingan foto asli vs hasil olahan secara berdampingan agar user langsung lihat manfaatnya, dengan maskot memberi reaksi puas terhadap hasilnya.

## Prinsip interaksi & motion

- Karena arah desain sekarang playful, animasi maskot boleh lebih ekspresif dari UI pada umumnya — reaksi muncul, loading, transisi hasil analisis semua bisa jadi momen kecil yang menghibur. Tetap jaga satu prinsip: animasi tidak boleh memperlambat user mengakses angka/keputusan penting (misalnya animasi selebrasi jangan menghalangi user membaca skor secepat mungkin).
- Prioritaskan kenyamanan penggunaan satu tangan (thumb-friendly) karena target pengguna memakai di mobile, sering sambil berdiri di warung/lokasi usaha.

## Aksesibilitas & kualitas dasar

- Kontras warna cukup untuk dibaca di luar ruangan (banyak UMKM cek aplikasi ini sambil survei lokasi langsung, bukan cuma di dalam ruangan).
- Ukuran target tap minimal sesuai standar mobile (±48dp).
- Mendukung pembesaran teks/skala font sistem tanpa merusak layout.
- Rasakan hierarki tetap jelas walau di perangkat layar kecil.

## Konten & bahasa dalam UI

- Semua teks di aplikasi (tombol, notifikasi, pesan error/kosong) ditulis seolah **maskot yang berbicara** — playful, hangat, dan berkarakter, bukan teks sistem formal yang dikasih ilustrasi lucu di sampingnya.
- Gunakan Bahasa Indonesia sehari-hari, bukan istilah bisnis/teknis yang kaku ("tingkat okupansi pasar" → "seberapa ramai persaingan di sini").
- Kalimat aktif dan penuh energi, jelas apa yang terjadi saat tombol ditekan (misalnya "Yuk cek peluangnya!" lebih hidup dari "Submit" atau "Lanjutkan", tapi tetap harus jelas fungsinya).
- Pesan error/kosong tetap dijelaskan dengan arah tindakan yang jelas, dibungkus nada playful maskot — bukan sekadar "terjadi kesalahan", tapi juga bukan playful sampai membingungkan apa yang harus dilakukan user selanjutnya. Playful tidak boleh mengorbankan kejelasan instruksi.

## Output yang diharapkan dari agent

1. **Konsep maskot**: nama, bentuk, kepribadian, dan variasi ekspresi/pose untuk tiap situasi (semangat, berpikir, suportif saat hasil kurang bagus, menyemangati).
2. Rencana token desain (warna, tipografi, gaya ilustrasi, layout, signature element) beserta alasan kenapa relevan dengan aplikasi UMKM ini dan konsisten dengan maskot — ditinjau ulang sebelum eksekusi supaya tidak generik.
3. Desain/wireframe tiap layar utama: Login, Dashboard, Modul 1 (input dua jalur + layar hasil), Modul 2 (chat berwujud maskot), Modul 3 (upload/hasil foto), lengkap dengan kemunculan maskot di tiap layar.
4. Contoh microcopy playful untuk momen-momen kunci (sambutan onboarding, hasil analisis tinggi/rendah, empty state, error state).
5. Implementasi ke Flutter (theme, widget reusable, termasuk komponen maskot yang bisa dipakai ulang dengan variasi ekspresi) yang konsisten dengan token desain di atas.