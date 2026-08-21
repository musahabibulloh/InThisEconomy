# Prompt untuk AI Agent: Aplikasi Pembelajaran & Validasi Ide UMKM

## Konteks & tujuan

Bangun aplikasi yang membantu calon maupun pelaku UMKM belajar dan memvalidasi ide bisnis **sebelum** menjual, bukan sekadar platform kursus. Pengguna dibimbing lewat proses berbasis data, bukan tebak-tebakan tren.

### Masalah yang diselesaikan
- UMKM ikut tren produk viral tanpa riset pasar.
- Menjual produk hanya karena melihat orang lain sukses.
- Tidak memahami target konsumen.
- Tidak tahu apakah produk punya permintaan nyata.
- Bingung menentukan harga dan modal awal.
- Terlambat sadar tren mulai menurun.
- Menghabiskan modal untuk produk yang sebenarnya tidak dibutuhkan pasar.

## Struktur aplikasi

Aplikasi terdiri dari **3 modul utama**, semua diakses dari satu Dashboard setelah login.

```
Login → Dashboard → [Modul 1: Cek ide bisnis | Modul 2: Konsultasi AI | Modul 3: Cek produk]
```

---

## Modul 1: Cek ide bisnis (fitur inti)

Modul ini punya **dua jalur masuk** yang berujung ke satu mesin analisis yang sama.

### Jalur A — pengguna sudah punya ide
- **Input**: teks bebas, contoh: "Saya ingin menjual dessert box di Jember."
- **Proses**: ekstrak entitas produk + lokasi dari teks input.
- **Proses teknis**:
  1. Ekstrak kategori/nama produk (misal "bakso") dan titik lokasi (lat/lng) dari input.
  2. Query Google Places API untuk kategori spesifik tersebut saja, di radius tertentu (misal 1–3 km) dari titik lokasi.
  3. Hitung jumlah kompetitor sejenis yang ditemukan — makin banyak kompetitor kategori yang sama di radius itu, makin tinggi skor **persaingan** dan makin rendah skor **peluang** untuk ide tersebut di lokasi itu.
  4. Contoh: user input "jualan bakso" di titik lokasi X → sistem cek berapa banyak penjual bakso lain dalam radius X → kalau sudah banyak, hasil peluang otomatis rendah/persaingan tinggi, meskipun bakso sendiri produk yang umum diminati.
  5. Tambahkan data pendukung: minat pencarian (Trends) untuk kategori tersebut secara umum, sebagai pembanding apakah permintaan produk itu sendiri tinggi atau rendah terlepas dari lokasi.
- **Sumber data**: Google Places API (kompetitor sejenis di titik lokasi yang sama dengan ide user), Google Trends (minat pencarian), opsional data marketplace (jumlah listing, range harga).

### Jalur B — pengguna belum punya ide
- **Input**: titik lokasi yang ingin dijadikan tempat usaha (bisa pilih di peta atau ketik alamat/wilayah).
- **Proses**: sistem mencari **celah pasar** dari Google Maps — kategori bisnis yang belum ada atau masih sangat sedikit di radius lokasi tersebut. Logikanya: makin sedikit/tidak ada pesaing kategori tertentu di wilayah itu, makin besar peluang kategori tersebut ditawarkan sebagai ide.
- **Proses teknis**:
  1. Ambil titik lokasi (lat/lng) dari input pengguna.
  2. Query Google Places API untuk berbagai kategori bisnis umum (kuliner, jasa, retail, dll) di radius tertentu (misal 1–3 km).
  3. Hitung jumlah hasil per kategori — kategori dengan hasil paling sedikit/nol jadi kandidat "celah pasar".
  4. Bandingkan juga dengan kepadatan penduduk/jenis area di sekitar (permukiman, kampus, perkantoran) sebagai indikator apakah wilayah itu ramai calon konsumen atau memang sepi karena sebab lain (bukan berarti kosong = otomatis peluang bagus).
  5. Susun daftar kategori celah pasar, urutkan berdasarkan kombinasi "kelangkaan pesaing" + "kepadatan area sekitar".
- **Sumber data**: Google Places API (jumlah & jenis bisnis existing per kategori di radius lokasi), data kepadatan area sebagai konteks tambahan.
- **Catatan penting**: minim pesaing tidak selalu berarti peluang bagus — bisa juga karena memang tidak ada permintaan di wilayah itu. Output harus tetap tampilkan ini sebagai "indikasi", bukan jaminan, dan tetap sarankan validasi lanjutan (survei mini) sebelum eksekusi.

### Mesin analisis (dipakai kedua jalur)

**Logika inti sama untuk Jalur A dan B**: keduanya menghitung kepadatan kompetitor di titik lokasi lewat Google Places API. Bedanya hanya cakupan query — Jalur A query satu kategori spesifik (ide yang disebut user), Jalur B query banyak kategori sekaligus untuk menemukan yang paling kosong.
- **Proses**: gabungkan sinyal kepadatan kompetitor, kualitas kompetitor (rating), tren pencarian, radius pasar, dan jenis area sekitar.
- **Output lengkap** — sistem memberikan gambaran atas 6 hal berikut:

  | Komponen output | Cara dihitung | Sumber data |
  |---|---|---|
  | **Target pasar potensial** | Profil area sekitar titik lokasi (permukiman, kampus, perkantoran, wisata) sebagai indikasi siapa calon pembeli | Google Places API (kategori tempat sekitar) |
  | **Tingkat persaingan** | Jumlah kompetitor kategori sejenis dalam radius, dikombinasikan dengan rata-rata rating mereka — banyak kompetitor tapi rating rendah bisa berarti persaingan "lemah" meski jumlahnya banyak | Google Places API (jumlah + rating kompetitor) |
  | **Perkiraan minat konsumen** | Volume pencarian kategori/produk secara umum (bukan spesifik lokasi) | Google Trends |
  | **Produk sejenis yang sudah banyak dijual** | Daftar nama bisnis kompetitor beserta rating masing-masing di radius lokasi | Google Places API |
  | **Peluang diferensiasi** | Turunan dari kombinasi rating kompetitor rendah + jumlah banyak (celah kualitas), atau dari kategori yang belum ada sama sekali (celah kategori) | Kombinasi Places API + LLM untuk merangkum celah dalam bahasa naratif |
  | **Risiko mengikuti tren** | Arah tren pencarian 6–12 bulan terakhir untuk kategori tersebut — naik, stabil, atau menurun | Google Trends (data historis) |

- **Ringkasan skor** (ditampilkan di atas tabel detail):
  ```
  Peluang: Sedang
  Persaingan: Tinggi
  Permintaan: Tinggi
  Rekomendasi: Cari diferensiasi produk atau target pasar yang lebih spesifik.
  ```
- **Nuansa penting**: persaingan tidak hanya dihitung dari jumlah kompetitor, tapi juga kualitasnya. Kompetitor banyak namun rating rendah tetap bisa menghasilkan skor "peluang diferensiasi" yang tinggi (celah kualitas), bukan otomatis skor peluang rendah.
- Untuk jalur B, output tambahan berupa **daftar kategori bisnis celah pasar** di lokasi tersebut beserta alasan (misal: "Belum ada penjual dessert box dalam radius 2 km, area padat perumahan dan kampus") dan **perkiraan modal awal** per kategori yang dipilih.

### Sub-tahap lanjutan (setelah hasil awal, opsional untuk versi berikutnya)
1. **Validasi pasar** — survei mini otomatis, data tren, peta kompetitor.
2. **Analisis konsumen** — persona konsumen otomatis, pemetaan kebutuhan vs keinginan.
3. **Peluang produk** — kalkulator harga (HPP + margin), indikator siklus tren (naik/puncak/turun).
4. **Strategi penjualan** — rencana peluncuran bertahap, rekomendasi kanal jualan, checklist modal minimum vs ideal.

Pengguna bisa kembali ke tahap sebelumnya kapan saja untuk merevisi ide.

---

## Modul 2: Konsultasi AI

- **Input**: pertanyaan bebas dari pengguna (chat).
- **Terhubung ke Modul 1**: chatbot membaca riwayat hasil analisis ide milik pengguna sebagai konteks, sehingga bisa menjawab spesifik (misal: "kenapa persaingan saya tinggi?" merujuk ke hasil analisis terakhir), bukan jawaban generik.
- **Data yang perlu disimpan dari Modul 1 untuk konteks ini**:
  - Ide/produk yang pernah dicek
  - Hasil skor (peluang, persaingan, permintaan)
  - Lokasi/target pasar yang dipilih
  - Timestamp setiap analisis
- **Implementasi**: saat sesi chat dibuka, sisipkan ringkasan histori ide pengguna ke dalam konteks/prompt sebelum model menjawab.

---

## Modul 3: Cek produk (tools foto)

- **Input**: upload foto produk.
- **Proses**: remove background, generate variasi foto produk (image generation).
- **Output**: foto siap pakai untuk marketplace/sosial media.
- **PENTING**: modul ini **independen** — tidak terhubung ke data riwayat ide atau modul lain. Bisa dikembangkan dan di-deploy terpisah tanpa dependensi ke sistem analisis ide.

---

## Arsitektur data (ringkas)

| Tabel/entitas | Isi | Dipakai oleh |
|---|---|---|
| `users` | akun, autentikasi | semua modul |
| `idea_checks` | ide/produk, lokasi, hasil skor, rekomendasi, timestamp | Modul 1, dibaca Modul 2 |
| `market_gap_scans` | hasil pencarian celah pasar per lokasi: kategori, jumlah kompetitor existing, skor kepadatan area, timestamp | Modul 1 (jalur B) |
| `chat_sessions` | riwayat percakapan konsultasi AI | Modul 2 |
| `product_photos` | foto asli & hasil olahan | Modul 3 (berdiri sendiri, tidak join ke tabel lain) |

---

## Stack teknis

- **Frontend**: Flutter (aplikasi mobile, target Android & iOS).
- **Backend & database**: Supabase (Postgres + Auth + Storage + Edge Functions).

### Pemetaan ke fitur Supabase

| Kebutuhan | Layanan Supabase | Catatan |
|---|---|---|
| Autentikasi (login/register) | **Supabase Auth** | Email/password minimal; bisa tambah login Google di iterasi berikutnya. |
| Tabel `users`, `idea_checks`, `market_gap_scans`, `chat_sessions` | **Supabase Postgres** | Aktifkan Row Level Security (RLS) — setiap user hanya boleh baca/tulis datanya sendiri. |
| Panggilan ke Google Places API & Google Trends | **Supabase Edge Functions** | Jangan panggil API eksternal langsung dari Flutter — API key Google harus disimpan di Edge Function (server-side), bukan di aplikasi mobile, supaya tidak bocor lewat reverse-engineering APK. |
| Panggilan ke LLM (mesin analisis naratif, chatbot Modul 2) | **Supabase Edge Functions** | Sama alasannya — API key LLM disimpan di server-side, Flutter hanya panggil endpoint Edge Function. |
| Foto produk asli & hasil olahan (Modul 3) | **Supabase Storage** | Buat bucket terpisah, misal `product-photos`, dengan policy akses per user. |
| Riwayat chat real-time (opsional) | **Supabase Realtime** | Tidak wajib untuk MVP; berguna kalau nanti mau tampilan chat streaming/live update antar device. |

### Alur teknis singkat per modul
- **Modul 1 (kedua jalur)**: Flutter kirim input (teks ide atau titik lokasi) → Edge Function memanggil Google Places API (+ Trends) → hasil disimpan ke `idea_checks`/`market_gap_scans` → Flutter menampilkan hasil dari tabel tersebut.
- **Modul 2**: Flutter kirim pertanyaan → Edge Function ambil ringkasan riwayat dari `idea_checks` milik user (join by `user_id`) → sisipkan ke prompt LLM → jawaban dikirim balik dan disimpan ke `chat_sessions`.
- **Modul 3**: Flutter upload foto ke Supabase Storage → Edge Function proses (remove bg/generate) → hasil disimpan kembali ke Storage, path-nya dicatat di tabel `product_photos`.

## Catatan integrasi eksternal & biaya

**Preferensi biaya**: gunakan layanan dengan **tier gratis bulanan** untuk tahap MVP (tidak harus 100% gratis selamanya, tapi hindari layanan yang wajib berbayar sejak request pertama).

- **Google Places API**: ada kuota gratis bulanan (cek nominal terbaru di Google Cloud Pricing saat implementasi) — cukup dipakai untuk tahap awal selama volume pengguna belum besar. Pantau penggunaan supaya tidak tembus kuota tanpa sadar.
- **Google Trends**: tidak ada API resmi berbayar maupun gratis dari Google langsung; gunakan library open-source gratis (mis. pytrends) yang mengakses data publik Trends.
- **Supabase**: pakai tier gratis (free plan) untuk MVP — cukup untuk Postgres, Auth, Storage, dan Edge Functions dalam skala kecil.
- **LLM (mesin analisis naratif & chatbot Modul 2)**: pilih provider yang punya tier gratis/trial credit untuk tahap awal (nominal dan syarat berbeda-beda tiap provider, cek saat implementasi karena sering berubah).
- **Remove background / generate foto (Modul 3)**: cari library/API dengan tier gratis (misal model open-source untuk remove background yang bisa dijalankan sendiri di Edge Function/server, supaya tidak bergantung API berbayar per-request).
- Data kompetitor dari Places API bisa under-estimate untuk UMKM rumahan yang hanya jualan online (Instagram/WA). Tampilkan hasil sebagai **perkiraan**, bukan data pasti — beri disclaimer di UI.

## Prioritas pengembangan (disarankan)
1. **MVP**: Modul 1 jalur A (Cek ide bisnis, input manual) + output dasar (peluang/persaingan/permintaan), dibangun di atas Flutter + Supabase (Auth, Postgres, satu Edge Function untuk Places API).
2. Modul 3 (Cek produk) — bisa dibangun paralel karena independen.
3. Modul 1 jalur B (Cari celah pasar dari Google Maps) — butuh integrasi Google Places API untuk scan multi-kategori per lokasi, jadi bisa lebih kompleks/mahal dibanding jalur A.
4. Modul 2 (Konsultasi AI) — dibangun setelah Modul 1 punya cukup data riwayat untuk dijadikan konteks.
5. Sub-tahap lanjutan Modul 1 (validasi pasar, analisis konsumen, peluang produk, strategi penjualan).

## Yang perlu diputuskan agent/tim sebelum mulai coding
- Sumber data pasti untuk minat konsumen (Trends vs marketplace vs kombinasi LLM).
- Model bisnis fitur di aplikasi (gratis vs berbayar per modul untuk pengguna akhir) — terpisah dari biaya infrastruktur/API yang sudah diarahkan ke tier gratis di atas.
- Provider LLM spesifik yang dipakai untuk mesin analisis naratif & chatbot — pilih yang punya tier gratis/trial saat implementasi.