# Tambahan Prompt — Icon Maskot "Ite" untuk Tiap Fitur

> Ini pelengkap dari prompt-prompt sebelumnya (redesign UI, bottom navigation, glass tema terang). Tempel bagian ini ke Antigravity untuk menghasilkan set icon maskot yang konsisten satu sama lain.

---

## Konteks maskot

Aplikasi ini punya maskot bernama **Ite**, seekor beruang, yang jadi identitas AI chat/konsultasi di aplikasi. Ite juga dipakai dalam variasi pose di beberapa fitur lain sebagai icon menu, supaya ada benang merah karakter di seluruh aplikasi — bukan icon lepas-lepas tanpa hubungan.

Buatkan **satu set icon maskot Ite** untuk 4 fitur berikut, sebagai SVG icon (bukan foto/ilustrasi kompleks) yang cocok dipakai di ukuran kecil (nav bar, kartu menu, ± 24–48px) sekaligus tetap terbaca jelas saat diperbesar sebagai ilustrasi header fitur.

## Daftar icon yang dibutuhkan

1. **AI Chat / Konsultasi** — Ite versi standar/wajah utama, ekspresi ramah dan siap membantu (ini yang jadi "wajah default" Ite, dipakai juga sebagai avatar chat).
2. **Cek Ide Bisnis** — Ite dengan pose berpikir (tangan di dagu / dahi mengernyit mikir), ditambah elemen bola lampu menyala di dekat kepala sebagai simbol ide sudah ditemukan.
3. **Cari Celah Pasar** — Ite memegang/mengintip lewat kaca pembesar, pose seperti sedang meneliti/mencari sesuatu secara detail.
4. **Perbagus Produk/Foto Produk** — Ite memegang kamera di depan wajah/tangan, pose seperti sedang memotret.

## Prinsip desain supaya konsisten & tidak generik

**Satu gaya ilustrasi untuk semua pose.** Tentukan dulu gaya dasar Ite sekali di awal — proporsi tubuh (misal kepala besar gaya chibi/cute, atau proporsi lebih realistis-simpel), ketebalan garis (stroke width konsisten di semua icon), sudut mata, cara menggambar hidung/moncong beruang, dan palet warna tubuh (misal cokelat hangat sesuai warna beruang, atau warna custom sesuai brand) — lalu terapkan persis sama di keempat icon, yang berubah hanya pose dan elemen tambahannya (bola lampu, kaca pembesar, kamera).

**Elemen tambahan (bola lampu, kaca pembesar, kamera) punya gaya yang senada dengan Ite**, bukan clip-art generik yang ditempel begitu saja. Ketebalan garis, tingkat kebulatan sudut, dan level detail elemen tambahan harus sama dengan gaya menggambar Ite, supaya terlihat seperti satu ilustrasi utuh, bukan icon beruang + icon stok terpisah yang digabung paksa.

**Warna ikonik yang dikenali.** Pakai warna badan Ite yang sama persis di keempat icon (jadi orang langsung tahu "oh ini Ite" walau posenya beda), dengan aksen warna berbeda tipis per fitur kalau perlu membedakan kategori menu — tapi badan/wajah Ite tetap jadi elemen paling dikenali.

**Sesuaikan dengan tema glass terang yang sudah ditentukan sebelumnya.** Icon harus tetap terbaca jelas di atas permukaan kaca semi-transparan — pertimbangkan outline/stroke yang cukup tebal atau sedikit background solid lembut di belakang icon kalau kontrasnya kurang saat ditaruh di atas kartu kaca.

**Ekspresi wajah harus jelas beda tiap pose**, karena itu yang bikin icon terasa hidup dan gampang dibedakan sekilas: ramah & terbuka (chat), fokus berpikir lalu "aha" (ide bisnis), waspada & teliti (cari celah pasar), antusias/senang (foto produk) — jangan pakai wajah default yang sama untuk semua pose hanya beda properti di tangan.

## Yang harus dihindari
- Jangan pakai bear mascot generik ala stok icon (beruang bulat generik gaya Duolingo/mascot umum) — desain proporsi dan wajah yang unik untuk Ite spesifik, lalu pakai konsisten.
- Jangan bola lampu/kaca pembesar/kamera dari icon pack default tanpa penyesuaian gaya — harus terlihat digambar oleh "tangan" yang sama dengan Ite.
- Jangan detail berlebihan yang hilang saat icon diperkecil ke ukuran nav bar — sederhanakan siluet supaya tetap terbaca di ukuran kecil.
- Jangan warna beda-beda drastis antar icon sampai terasa seperti 4 karakter berbeda, bukan 1 maskot yang sama.

## Detail teknis yang diminta
1. Format: SVG, dengan struktur yang rapi (grouped path per elemen: badan, wajah, properti tambahan) supaya gampang dianimasikan/diwarnai ulang nanti kalau perlu.
2. Sediakan versi icon ukuran kecil (untuk nav/menu, siluet disederhanakan) dan versi lebih detail (untuk header/hero fitur) kalau kompleksitas posenya butuh itu — terutama untuk kaca pembesar dan kamera yang detailnya lebih ramai.
3. Pastikan warna icon mengikuti CSS variable/token warna yang sudah dipakai di desain aplikasi (supaya kalau tema warna berubah nanti, icon ikut menyesuaikan), bukan hardcode hex di dalam SVG.
4. Tempatkan icon fitur 2–4 sebagai icon menu/kartu fitur, dan icon fitur 1 (Ite versi standar) sebagai icon di bottom navigation untuk menu AI Chat sekaligus avatar di halaman chat itu sendiri.

## Proses kerja yang diminta
1. Tunjukkan dulu deskripsi gaya dasar Ite (proporsi, warna, ketebalan garis, gaya wajah) sebelum membuat keempat icon, supaya konsistensinya bisa dicek dulu.
2. Buat keempat icon mengikuti gaya dasar itu, dengan pose dan elemen tambahan sesuai daftar di atas.
3. Cek ulang: apakah keempat icon terlihat jelas berasal dari satu karakter yang sama? Kalau ada yang terasa beda gaya, revisi.
4. Terapkan ke lokasi masing-masing (bottom nav, kartu menu) sesuai style glass terang yang sudah ditentukan.