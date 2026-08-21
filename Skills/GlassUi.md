# Tambahan Arah Desain — Glassmorphism Tema Terang

> Ini pelengkap untuk prompt redesign UI & bottom navigation sebelumnya. Tempel bagian ini setelah prompt utama (atau gabungkan jadi satu pesan) ke Antigravity supaya arah gaya visualnya konsisten.

---

## Arah gaya visual: Glassmorphism, tema terang

Aplikasi ini harus pakai gaya **glass/glassmorphism** — permukaan semi-transparan dengan efek blur di baliknya (frosted glass), bukan kartu solid biasa. Tapi ini **bukan** glassmorphism gelap ala dashboard futuristik (hitam pekat + neon) yang biasa dipakai template AI. Base tema harus **terang/putih**, terasa bersih, lapang, dan mudah dibaca di kondisi toko yang terang.

### Prinsip glass terang yang benar (hindari yang generik)

**Background dasar terang dengan nuansa warna, bukan putih polos rata.** Jangan `#FFFFFF` datar di semua tempat — itu terasa kosong dan tidak ada karakter. Pakai gradasi lembut dari warna dasar yang sesuai identitas bisnis (misal cream ke putih, atau abu-abu kebiruan sangat muda ke putih) sebagai kanvas di belakang elemen kaca, supaya efek blur-nya benar-benar terlihat (glass butuh sesuatu di baliknya untuk "diburamkan").

**Kartu/panel kaca:** permukaan putih semi-transparan (kira-kira 60–80% opacity) + `backdrop-blur`, dengan border tipis (1px) putih semi-transparan yang sedikit lebih terang dari fill-nya untuk kesan tepi kaca kena cahaya. Tambahkan shadow yang sangat halus dan menyebar (soft, diffused), bukan shadow tajam gelap — shadow gelap tajam merusak kesan ringan dari kaca.

**Kontras teks tetap harus aman.** Ini yang paling sering gagal di glass tema terang: teks abu-abu di atas kaca putih transparan sering jadi susah dibaca. Pastikan teks penting (harga, total, nama produk) pakai warna gelap solid dengan kontras cukup, bukan ikut-ikutan transparan. Boleh tambah lapisan solid tipis di belakang teks kalau backgroundnya ramai (misal ada gambar produk).

**Depth lewat lapisan, bukan lewat gelap.** Karena tidak boleh gelap, buat kedalaman/hierarki visual lewat: tingkat blur yang beda antar lapisan (elemen lebih dekat = blur lebih tajam terlihat, elemen jauh = lebih blur), variasi opacity, dan sedikit elevasi/shadow — bukan lewat mengubah warna jadi hitam untuk menandakan "elemen ini di atas".

**Aksen warna, jangan monokrom putih semua.** Supaya tidak terasa hambar/generik, pilih 1–2 warna aksen dari identitas bisnis untuk tombol utama, indikator aktif di bottom nav, dan status penting (berhasil/gagal bayar) — warna solid pekat yang kontras jelas dengan kaca putih di sekelilingnya, bukan pastel yang ikut memudar.

**Jangan berlebihan.** Efek glass paling efektif dipakai selektif — untuk nav bar, modal, kartu yang mengambang di atas konten (misal ringkasan keranjang) — bukan untuk literally semua elemen termasuk tombol kecil dan teks label. Kalau semua kaca, tidak ada yang terasa "mengambang", semua terasa flat lagi.

### Yang harus dihindari
- Jangan glass gelap (hitam/abu gelap + neon) — itu bukan yang diminta.
- Jangan `background: rgba(255,255,255,0.1)` polos tanpa border/shadow — hasilnya cuma putih pudar, bukan kesan kaca.
- Jangan taruh blur besar di elemen yang berisi teks kecil (angka harga, nomor struk) — blur bisa bikin tepi teks terasa tidak tajam kalau salah taruh layer.
- Jangan lupa fallback: kalau device/browser tidak mendukung `backdrop-filter`, pastikan tetap terlihat baik dengan warna solid semi-transparan biasa.

### Terapkan ke elemen berikut
- [ ] Bottom navigation bar (kaca mengambang di atas konten, bukan menyatu rata dengan tepi layar)
- [ ] Kartu produk di grid utama
- [ ] Panel keranjang/order aktif
- [ ] Modal pembayaran & konfirmasi
- [ ] Card ringkasan di dashboard laporan

Sesuaikan juga animasi bottom navigation yang sudah diminta sebelumnya: indikator aktif dan transisi tab harus terasa selaras dengan material kaca ini — misalnya highlight aktif berupa lapisan kaca yang lebih solid/kurang blur yang "meluncur" di antara tab, bukan sekadar garis bawah datar.