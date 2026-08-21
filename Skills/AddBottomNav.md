# Prompt untuk Antigravity — Tambah Bottom Navigation Beranimasi

> Cara pakai: isi bagian **[DALAM KURUNG]** sesuai aplikasimu, lalu tempel ke Antigravity. Bisa digabung dengan prompt redesign UI sebelumnya kalau mau dikerjakan sekaligus.

---

Kamu adalah design lead di studio kecil yang dikenal karena setiap project punya identitas visual yang tidak bisa disamakan dengan project lain. Sekarang aplikasi kasir ini hanya punya satu dashboard tunggal — semua fitur menumpuk di satu layar dan terasa sempit/kurang enak dilihat. Tugasmu: tambahkan **bottom navigation bar** sebagai navigasi utama, lengkap dengan animasi transisi yang halus dan terasa premium, bukan animasi bawaan komponen library yang dipakai semua orang.

## Konteks aplikasi
- Jenis usaha: **[misal: kedai kopi kecil / toko sembako / laundry / resto Padang / apotek]**
- Device utama: **[tablet / mobile / layar sentuh]**
- Stack: **[misal: React + Tailwind / Flutter / React Native / vanilla HTML-CSS-JS]**
- Halaman/menu yang perlu masuk ke navigasi (urutkan sesuai frekuensi pemakaian, jangan asal urut abjad): **[misal: Kasir, Riwayat Transaksi, Stok, Laporan, Pengaturan]**
- Menu mana yang paling sering dipakai kasir saat jam sibuk: **[misal: Kasir]** — ini harus paling mudah dijangkau, biasanya posisi tengah atau paling kiri tergantung kebiasaan genggam device.

## Yang harus dihindari (ciri khas "bottom nav AI-generated")
- Jangan 5 ikon simetris identik-jarak dengan label kecil di bawahnya tanpa hierarki apa pun — itu template Material Design default yang dipakai di semua tutorial.
- Jangan animasi "bounce" generik atau scale 1.0→1.1 di setiap ikon saat aktif — itu preset animasi paling umum dan terasa template.
- Jangan floating action button bulat gradient di tengah kalau tidak ada alasan fungsional kuat untuk itu.
- Jangan ikon outline generik dari icon pack default (Material Icons/Font Awesome polos) tanpa penyesuaian — sesuaikan bobot garis dan gaya ikon dengan karakter visual aplikasi ini.

## Prinsip desain
**Ambil bentuk dari alur kerja kasir, bukan dari komponen library.** Urutan dan penekanan visual tiap menu harus mencerminkan seberapa sering dipakai — menu yang paling sering disentuh (biasanya "Kasir"/transaksi baru) harus punya bobot visual paling besar, bukan diperlakukan sama rata dengan menu "Pengaturan" yang jarang dibuka.

**Animasi harus fungsional, bukan hiasan.** Setiap gerakan harus menjawab pertanyaan "kenapa ini bergerak": indikator aktif berpindah dengan smooth transition mengikuti tab yang dipilih, transisi konten antar halaman punya arah yang masuk akal (bukan fade generik di semua tempat), dan feedback saat tap terasa instan (di bawah ~150ms) supaya tidak menghambat kecepatan kasir. Hindari animasi dekoratif yang tidak menyampaikan status apa pun.

**Satu signature interaction.** Pilih satu momen animasi yang jadi ciri khas — misalnya cara indikator aktif "meluncur" ke tab yang dipilih dengan bentuk/warna yang unik untuk brand ini, atau cara ikon berubah morph saat aktif — lalu jaga semua animasi lain tetap sederhana di sekitarnya. Jangan taruh kejutan animasi di semua tempat sekaligus.

**Kontras dan target sentuh.** Tab aktif harus jelas beda dari yang tidak aktif walau dilihat sekilas dan dalam kondisi pencahayaan toko yang mungkin tidak ideal. Area sentuh tiap tab minimal nyaman untuk jari, tidak berdesakan.

**Sesuaikan dengan identitas visual aplikasi yang sudah/akan ada** — warna aktif, bentuk indikator, dan gaya ikon harus terasa satu keluarga dengan palet dan tipografi aplikasi, bukan komponen navigasi generik yang ditempel di atas desain manapun.

## Detail teknis yang diminta
1. Bottom nav tetap terlihat di semua halaman utama, tapi beri opsi auto-hide saat scroll ke bawah di halaman yang isinya panjang (misal riwayat transaksi) — jangan hilang saat kasir sedang di tengah transaksi aktif.
2. Tampilkan badge/indikator kecil kalau ada state yang perlu perhatian (misal keranjang belum kosong saat pindah dari tab Kasir) — desain badge yang senada, jangan merah bulat generik tanpa pertimbangan.
3. Pastikan transisi tetap smooth di device dengan performa terbatas — hindari efek berat yang bikin lag di tablet kasir murah.
4. Sertakan state disabled/loading kalau ada tab yang butuh data dimuat dulu.

## Proses kerja yang diminta
1. Tunjukkan dulu rencana singkat: struktur menu final, warna/indikator untuk state aktif, jenis animasi untuk transisi tab & transisi konten, dan signature interaction yang dipilih.
2. Cek ulang rencana itu — kalau terasa seperti jawaban default untuk "bottom nav pada umumnya", revisi dan jelaskan kenapa.
3. Baru implementasikan, sambil pastikan tidak merusak fungsi/alur transaksi yang sudah ada.
4. Tutup dengan ringkasan singkat: kenapa urutan menu dan gaya animasi yang dipilih cocok untuk alur kerja kasir ini.

## Batasan
- Hal yang tidak boleh diubah/rusak: **[misal: state keranjang aktif saat pindah tab, komponen printer struk, alur pembayaran]**