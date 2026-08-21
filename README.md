# ValidasiIde — Aplikasi Validasi Ide Bisnis UMKM

Aplikasi mobile (Flutter) yang membantu calon & pelaku UMKM memvalidasi ide bisnis **sebelum** menjual, menggunakan data nyata dari Google Maps, tren pencarian, dan analisis AI.

## ✨ Fitur Utama

### Modul 1: Cek Ide Bisnis
- **Jalur A** — Punya ide → analisis kompetitor, tren, & peluang
- **Jalur B** — Belum punya ide → scan celah pasar di lokasi tertentu
- Skor Peluang / Persaingan / Permintaan
- Data kompetitor terdekat + rating
- Analisis diferensiasi & risiko tren
- Disclaimer bahwa data bersifat perkiraan

### Modul 2: Konsultasi AI
- Chat dengan AI yang paham konteks riwayat analisis idemu
- Saran spesifik berdasarkan data, bukan jawaban generik

### Modul 3: Cek Produk
- Upload foto → hapus background → foto siap marketplace
- Independen dari modul lain

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Android & iOS) |
| Backend | Supabase (Postgres + Auth + Storage + Edge Functions) |
| External APIs | Google Places API, SerpApi (Trends), Gemini 2.0 Flash |
| Photo Processing | remove.bg API |

## 🚀 Quick Start

### Prerequisites
- Flutter SDK ≥ 3.x
- Supabase project (free tier)
- API keys: Google Cloud (Places API), SerpApi, Gemini, remove.bg

### 1. Setup Supabase

1. Buat project di [supabase.com](https://supabase.com)
2. Jalankan SQL migration di SQL Editor:
   ```
   supabase/migrations/001_initial_schema.sql
   ```
3. Set Edge Function secrets:
   ```bash
   supabase secrets set GOOGLE_PLACES_API_KEY=xxx SERPAPI_KEY=xxx GEMINI_API_KEY=xxx REMOVE_BG_API_KEY=xxx
   ```
4. Deploy Edge Functions:
   ```bash
   supabase functions deploy analyze-idea
   supabase functions deploy scan-market-gaps
   supabase functions deploy ai-chat
   supabase functions deploy process-photo
   ```

### 2. Run Flutter App

```bash
# Install dependencies
flutter pub get

# Run with Supabase config
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## 📁 Project Structure

```
lib/
├── main.dart                         # Entry point
├── app.dart                          # Root MaterialApp
├── core/
│   ├── config/
│   │   ├── app_colors.dart           # Color palette
│   │   ├── app_theme.dart            # Material 3 dark theme
│   │   └── supabase_config.dart      # Supabase initialization
│   ├── router/
│   │   └── app_router.dart           # GoRouter with auth guards
│   └── widgets/
│       ├── glass_card.dart           # Glassmorphism card
│       ├── gradient_button.dart      # Gradient CTA button
│       └── score_badge.dart          # Score display badge
├── features/
│   ├── auth/                         # Login & Register
│   ├── dashboard/                    # Main dashboard hub
│   ├── idea_check/                   # Modul 1: Cek Ide Bisnis
│   ├── market_gap/                   # Modul 1B: Cari Celah Pasar
│   ├── ai_chat/                      # Modul 2: Konsultasi AI
│   └── product_photo/                # Modul 3: Cek Produk

supabase/
├── functions/
│   ├── analyze-idea/index.ts         # Places + Trends + Gemini analysis
│   ├── scan-market-gaps/index.ts     # Multi-category gap scanner
│   ├── ai-chat/index.ts              # Context-aware AI chat
│   └── process-photo/index.ts        # Background removal
└── migrations/
    └── 001_initial_schema.sql        # Full DB schema + RLS
```

## 💰 Biaya (MVP)

| Service | Free Tier |
|---|---|
| Supabase | 500MB DB, 1GB Storage, 500K Edge Function invocations |
| Google Places API | 5,000 calls/month (Pro SKU) |
| SerpApi | 100 searches/month |
| Gemini 2.0 Flash | 15 RPM, 1M tokens/day |
| remove.bg | 50 images/month |

## 📝 License

Private — All rights reserved.
