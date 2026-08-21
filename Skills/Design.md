# Prompt UI/UX untuk AI Agent: Desain Tampilan Aplikasi UMKM

## Konteks

Aplikasi mobile (Flutter) yang membimbing calon/pelaku UMKM memvalidasi ide bisnis dengan data (Google Maps, tren pencarian), bukan sekadar platform kursus. Fungsional sudah selesai dibangun — dokumen ini khusus untuk **memperbaiki UI/UX**, bukan menambah fitur baru.

## Audiens & nada desain

- **Pengguna**: calon/pelaku UMKM di Indonesia — rentang usia luas, tidak semua melek teknologi tinggi. Banyak yang baru pertama kali pakai aplikasi berbasis data/analisis.
- **Nada yang ingin dibangun**: seperti **mentor bisnis yang bisa dipercaya** — tenang, jelas, tidak menggurui, tidak terasa seperti aplikasi korporat/perbankan yang kaku. Aplikasi ini soal *membantu orang mengambil keputusan yang lebih baik*, bukan sekadar menampilkan data mentah.
- **Yang harus dihindari**: kesan generik/template AI. Jangan pakai default yang sudah terlalu sering dipakai:
  - Krem hangat + serif kontras tinggi + aksen terracotta.
  - Latar nyaris hitam + satu aksen hijau/vermillion terang.
  - Layout ala koran dengan garis tipis dan kolom padat.
  
  Ambil arah yang lahir dari subjeknya sendiri: dunia UMKM, pasar, warung, produk buatan tangan — bukan dari estetika SaaS/fintech generik.

## Yang perlu disiapkan agent sebelum mendesain (token sistem)

Sebelum membuat layar apa pun, susun dulu:

1. **Palet warna** — 4–6 warna bernama dengan kode hex, termasuk warna untuk status (peluang tinggi/sedang/rendah, persaingan tinggi/rendah) yang tetap konsisten dengan identitas visual keseluruhan, bukan sekadar merah/kuning/hijau generik semaphore.
2. **Tipografi** — pilih 2 peran minimal: font display berkarakter (dipakai terbatas, misalnya judul layar/skor besar) dan font body yang nyaman dibaca panjang (deskripsi, hasil analisis). Pastikan mendukung karakter Bahasa Indonesia dengan baik dan tetap terbaca di ukuran kecil (mobile).
3. **Konsep layout** — bagaimana pola umum layar disusun (navigasi bawah vs atas, kartu vs list, dsb) yang konsisten di semua modul.
4. **Elemen signature** — satu elemen visual unik yang jadi ciri khas aplikasi ini dan mudah diingat, relevan dengan subjek (misalnya cara menampilkan skor peluang/persaingan yang khas, bukan progress bar generik).

Setelah menyusun rencana ini, agent harus mengecek ulang: apakah pilihan ini benar-benar spesifik untuk aplikasi UMKM ini, atau hanya jawaban default yang bisa dipakai untuk aplikasi apa saja? Revisi bagian yang masih terasa generik sebelum lanjut membangun.

## Kebutuhan desain per layar

### Login & onboarding
- Perkenalkan **nilai aplikasi** dalam 1 layar singkat (bukan sekadar form login) — misalnya kalimat singkat yang menjelaskan "aplikasi ini bantu kamu validasi ide sebelum keluar modal", bukan tagline generik.
- Form login sederhana, target tap besar (ramah untuk pengguna yang kurang terbiasa pakai HP untuk hal teknis).

### Dashboard (hub ke 3 modul)
- Tampilkan 3 modul (Cek ide bisnis, Konsultasi AI, Cek produk) dengan hierarki visual yang jelas mana yang jadi fitur utama (Cek ide bisnis) vs pendukung.
- Kalau user sudah punya riwayat cek ide sebelumnya, tampilkan ringkasan singkat di dashboard (bukan kosong), supaya dashboard terasa hidup dan personal.

### Modul 1 — Cek ide bisnis
- **Pemilihan jalur** (sudah punya ide / belum punya ide) harus jelas dan tidak membingungkan — dua jalur ini secara konsep beda tapi hasil akhirnya mirip, desain harus bantu user paham bedanya sejak awal tanpa perlu baca paragraf panjang.
- **Input lokasi**: gunakan peta interaktif untuk pemilihan titik lokasi (bukan hanya field teks), karena ini krusial untuk akurasi hasil analisis.
- **Layar hasil**: ini layar terpenting di seluruh aplikasi. Harus menampilkan 6 komponen (target pasar, persaingan, minat konsumen, produk sejenis, peluang diferensiasi, risiko tren) dengan cara yang **cepat dipahami sekilas** (scannable), bukan blok teks panjang. Pertimbangkan:
  - Skor/level (tinggi-sedang-rendah) ditampilkan visual, bukan cuma teks.
  - Daftar kompetitor sejenis ditampilkan ringkas dengan opsi "lihat semua".
  - Rekomendasi/diferensiasi ditonjolkan sebagai bagian paling actionable, bukan ditaruh di akhir sebagai catatan kecil.
  - Beri disclaimer bahwa ini "perkiraan berbasis data yang tersedia" — desain disclaimer supaya terasa jujur, bukan seperti penafian hukum yang menakutkan.

### Modul 2 — Konsultasi AI
- Desain chat yang terasa personal karena tahu riwayat ide user — pertimbangkan menampilkan referensi singkat ke ide yang sedang dibahas di dalam chat (misal chip/label kecil menunjukkan konteks ide mana yang sedang dirujuk).
- Empty state saat user belum punya riwayat: arahkan ke Modul 1 dulu, bukan sekadar kotak chat kosong.

### Modul 3 — Cek produk (tools foto)
- Alur upload → proses → hasil harus terasa cepat dan jelas progressnya (loading state yang informatif, bukan spinner generik tanpa konteks).
- Tampilkan perbandingan foto asli vs hasil olahan secara berdampingan agar user langsung lihat manfaatnya.

## Prinsip interaksi & motion

- Animasi dipakai secukupnya dan bertujuan — misalnya transisi halus saat skor hasil analisis muncul, bukan animasi dekoratif di semua tempat (justru membuat aplikasi terasa "dibuat AI" kalau berlebihan).
- Prioritaskan kenyamanan penggunaan satu tangan (thumb-friendly) karena target pengguna memakai di mobile, sering sambil berdiri di warung/lokasi usaha.

## Aksesibilitas & kualitas dasar

- Kontras warna cukup untuk dibaca di luar ruangan (banyak UMKM cek aplikasi ini sambil survei lokasi langsung, bukan cuma di dalam ruangan).
- Ukuran target tap minimal sesuai standar mobile (±48dp).
- Mendukung pembesaran teks/skala font sistem tanpa merusak layout.
- Rasakan hierarki tetap jelas walau di perangkat layar kecil.

## Konten & bahasa dalam UI

- Gunakan Bahasa Indonesia sehari-hari, bukan istilah bisnis/teknis yang kaku ("tingkat okupansi pasar" → "seberapa ramai persaingan di sini").
- Kalimat aktif, jelas apa yang terjadi saat tombol ditekan (misalnya "Cek peluang di sini" lebih baik dari "Submit" atau "Lanjutkan").
- Pesan error/kosong dijelaskan dengan arah tindakan, bukan sekadar "terjadi kesalahan" — misalnya kalau lokasi gagal dideteksi, jelaskan apa yang bisa user lakukan selanjutnya.

## Output yang diharapkan dari agent

1. Rencana token desain (warna, tipografi, layout, signature element) beserta alasan kenapa relevan dengan aplikasi UMKM ini — ditinjau ulang sebelum eksekusi supaya tidak generik.
2. Desain/wireframe tiap layar utama: Login, Dashboard, Modul 1 (input dua jalur + layar hasil), Modul 2 (chat), Modul 3 (upload/hasil foto).
3. Implementasi ke Flutter (theme, widget reusable) yang konsisten dengan token desain di atas.