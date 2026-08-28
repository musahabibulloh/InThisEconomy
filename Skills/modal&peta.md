# Prompt Tambahan untuk AI Agent: Input Modal & Peta Kompetitor Bergaya Kartun

## Konteks

Ini penambahan fitur untuk **Modul 1 Jalur B** (pengguna belum punya ide) yang sudah dirancang di `prompt-agent-aplikasi-umkm.md`, dan mengikuti arah visual kartun + maskot di `prompt-agent-ui-ux-aplikasi-umkm.md`. Dua kebutuhan baru:

1. Pengguna bisa memasukkan **modal yang dimiliki**, dan sistem merekomendasikan ide bisnis yang sesuai dengan modal tersebut.
2. Layar hasil analisis menampilkan **peta interaktif** dengan lokasi kompetitor ditandai marker custom **berbentuk wajah beruang**.

---

## 1. Input modal di Jalur B

- Tambahkan field input modal (nominal Rupiah) di form Jalur B, sejajar dengan input titik lokasi (jadi Jalur B kini butuh 2 input: **lokasi** + **modal**).
- **UI**: input angka dengan format Rupiah otomatis saat diketik (misal "Rp 5.000.000"), ditambah quick-select preset supaya cepat diisi di mobile tanpa perlu ketik manual, contoh: `< Rp 1 juta`, `Rp 1–5 juta`, `Rp 5–20 juta`, `> Rp 20 juta`.
- Field ini **opsional tapi sangat direkomendasikan** — kalau dikosongkan, sistem tetap menampilkan semua kategori celah pasar tanpa filter modal (fallback ke perilaku lama).

## 2. Logika rekomendasi berbasis modal

- Proses scan kategori celah pasar (sudah ada di spesifikasi sebelumnya) diberi langkah tambahan: **setiap kategori bisnis yang jadi kandidat celah pasar harus punya data estimasi modal awal (rentang min–max)**.
- Sumber estimasi modal per kategori:
  - Opsi 1: data kurasi manual tim (tabel referensi modal awal per kategori usaha kecil — kuliner rumahan, jasa, retail kecil, dll).
  - Opsi 2: estimasi dari LLM berdasarkan pengetahuan umum kategori usaha, dengan catatan hasilnya diberi label "estimasi", bukan angka pasti.
  - Disarankan kombinasi: kurasi manual untuk kategori paling umum, fallback ke estimasi LLM untuk kategori yang belum ada datanya.
- **Aturan filter/urutan**:
  - Kategori dengan rentang modal yang **sesuai atau di bawah** modal user → ditampilkan paling atas, ditandai "Sesuai modal kamu".
  - Kategori yang modal minimalnya **sedikit di atas** modal user (misal selisih <30%) → tetap ditampilkan, ditandai "Modal sedikit kurang, tapi bisa dipertimbangkan".
  - Kategori yang modal minimalnya **jauh melebihi** modal user → tetap ditampilkan di bagian bawah/terpisah (jangan disembunyikan total, supaya user tetap dapat gambaran pasar), ditandai jelas "Butuh modal jauh lebih besar".
- Jangan biarkan filter modal menyembunyikan info penting lain (kepadatan kompetitor, dll) — filter modal ini lapisan tambahan di atas hasil analisis celah pasar yang sudah ada, bukan pengganti.

### Update skema data

| Perubahan | Detail |
|---|---|
| Tabel `market_gap_scans` | tambah kolom: `estimated_capital_min`, `estimated_capital_max`, `capital_source` (`manual` / `ai_estimate`) |
| Input sesi Jalur B | simpan `user_budget` yang diinput user pada request/log terkait, supaya bisa dipakai ulang tanpa input ulang di sesi berikutnya |
| Tabel referensi (baru) | `business_category_capital_reference`: kategori bisnis, rentang modal umum, sumber data — dipakai sebagai basis kurasi manual sebelum fallback ke estimasi AI |

---

## 3. Peta kompetitor dengan marker wajah beruang

Tambahkan peta interaktif di layar hasil analisis (berlaku untuk **Jalur A dan Jalur B**) yang menampilkan sebaran kompetitor di sekitar titik lokasi yang dipilih user.

### Perilaku peta
- Titik lokasi yang dipilih user sebagai kandidat lokasi usaha ditampilkan dengan **maskot utama aplikasi** (yang sudah dirancang di file UI/UX) berdiri di titik itu — supaya jelas membedakan "aku" vs "kompetitor" saat sekilas melihat peta.
- Setiap kompetitor yang ditemukan lewat Google Places API ditampilkan sebagai **marker custom berbentuk wajah beruang**, bukan pin default.
- **Tap marker** menampilkan kartu info singkat: nama bisnis, rating, jarak dari titik lokasi user.
- **Variasi ekspresi wajah beruang** (opsional, prioritas kedua setelah fungsi dasar peta jalan) dipakai untuk menyampaikan info tanpa perlu tap satu-satu, contoh:
  - Beruang tersenyum lebar → rating kompetitor tinggi (dianggap "kuat")
  - Beruang ekspresi biasa/netral → rating sedang
  - Beruang terlihat lesu/kurang meyakinkan → rating rendah (ini justru bagian dari "peluang diferensiasi" yang sudah dibahas — kompetitor rating rendah = celah kualitas)
- Peta harus tetap bisa di-zoom/geser normal, dan marker tidak boleh saling menumpuk membingungkan kalau kompetitor terlalu padat — pertimbangkan clustering (gabungkan beberapa marker jadi satu angka saat zoom out, pecah lagi saat zoom in).

### Kebutuhan teknis (Flutter)

| Kebutuhan | Opsi | Catatan biaya |
|---|---|---|
| Render peta dasar | `google_maps_flutter` | Google Maps SDK punya kuota gratis bulanan terpisah dari Places API — cek nominal saat implementasi, tetap dalam kategori "tier gratis" yang sudah disepakati. |
| Alternatif gratis tanpa API key Google | `flutter_map` + tile OpenStreetMap | 100% gratis, tanpa kuota bulanan, tapi styling default kurang seleluasa Google Maps dan perlu usaha lebih untuk membuatnya terasa konsisten dengan gaya kartun aplikasi. |
| Marker custom | Widget marker kustom (bukan `BitmapDescriptor` default) berisi asset wajah beruang | Siapkan asset PNG/SVG wajah beruang, minimal 2–3 variasi ekspresi, gaya vektor konsisten dengan maskot utama aplikasi (lihat panduan gaya ilustrasi di file UI/UX). |
| Clustering marker | Gunakan library clustering yang kompatibel dengan package peta yang dipilih | Perlu dicek kompatibilitasnya dengan `google_maps_flutter` atau `flutter_map`, tergantung mana yang dipakai. |

**Keputusan yang perlu diambil sebelum implementasi**: pilih antara `google_maps_flutter` (lebih matang, sedikit biaya di luar tier gratis kalau traffic besar) vs `flutter_map` + OpenStreetMap (100% gratis, tapi butuh kerja ekstra untuk custom styling). Sesuaikan dengan prioritas biaya vs kualitas visual.

---

## Ringkasan dampak ke layar hasil analisis

Layar hasil Modul 1 (Jalur A & B) kini punya elemen tambahan:
1. Peta dengan maskot (lokasi user) + marker wajah beruang (kompetitor).
2. *(Khusus Jalur B)* Badge kecocokan modal di tiap kategori celah pasar yang direkomendasikan.

Pastikan penambahan ini tidak membuat layar hasil jadi terlalu penuh — pertimbangkan peta sebagai section terpisah yang bisa di-scroll ke bawah dari ringkasan skor utama (peluang/persaingan/permintaan tetap jadi yang pertama dilihat), bukan menggantikan ringkasan skor yang sudah ada.