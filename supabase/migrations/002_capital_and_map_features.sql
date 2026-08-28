-- Migration: Add capital estimation fields + business category reference table
-- Supports: Budget-based filtering in Jalur B + competitor map enhancements

-- ============================================
-- 1. Add capital columns to market_gap_scans
-- ============================================
ALTER TABLE public.market_gap_scans
  ADD COLUMN IF NOT EXISTS user_budget BIGINT,
  ADD COLUMN IF NOT EXISTS estimated_capital_min BIGINT,
  ADD COLUMN IF NOT EXISTS estimated_capital_max BIGINT,
  ADD COLUMN IF NOT EXISTS capital_source TEXT CHECK (capital_source IN ('manual', 'ai_estimate'));

COMMENT ON COLUMN public.market_gap_scans.user_budget IS 'Modal yang dimiliki user (Rupiah), opsional';
COMMENT ON COLUMN public.market_gap_scans.estimated_capital_min IS 'Estimasi modal minimum dari scan';
COMMENT ON COLUMN public.market_gap_scans.estimated_capital_max IS 'Estimasi modal maximum dari scan';
COMMENT ON COLUMN public.market_gap_scans.capital_source IS 'Sumber estimasi: manual (kurasi) atau ai_estimate (LLM)';

-- ============================================
-- 2. Business Category Capital Reference (kurasi manual)
-- ============================================
CREATE TABLE IF NOT EXISTS public.business_category_capital_reference (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_key TEXT NOT NULL UNIQUE,
    category_label TEXT NOT NULL,
    capital_min BIGINT NOT NULL,
    capital_max BIGINT NOT NULL,
    source TEXT DEFAULT 'manual',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE public.business_category_capital_reference IS 'Referensi modal awal per kategori usaha — digunakan sebagai basis kurasi manual sebelum fallback ke estimasi AI';

-- Seed with common UMKM categories
INSERT INTO public.business_category_capital_reference (category_key, category_label, capital_min, capital_max, notes) VALUES
  ('restaurant',         'Restoran/Warung Makan',       5000000,   50000000, 'Warung sederhana s.d. resto kecil'),
  ('cafe',               'Kafe/Kedai Kopi',             10000000,  80000000, 'Kedai kopi kecil s.d. kafe menengah'),
  ('bakery',             'Toko Roti/Kue',               3000000,   30000000, 'Rumahan s.d. toko kecil'),
  ('laundry',            'Laundry',                     5000000,   40000000, 'Laundry kiloan rumahan s.d. express'),
  ('hair_salon',         'Salon/Barbershop',             3000000,   25000000, 'Barbershop kecil s.d. salon menengah'),
  ('convenience_store',  'Minimarket/Toko Kelontong',   10000000, 100000000, 'Kelontong kecil s.d. minimarket'),
  ('pharmacy',           'Apotek',                      50000000, 200000000, 'Apotek kecil s.d. menengah, perlu izin'),
  ('car_repair',         'Bengkel',                     10000000,  75000000, 'Bengkel motor kecil s.d. mobil'),
  ('gym',                'Gym/Fitness',                 30000000, 150000000, 'Home gym s.d. studio fitness'),
  ('pet_store',          'Pet Shop',                     5000000,  40000000, 'Petshop kecil s.d. grooming'),
  ('electronics_store',  'Toko Elektronik',             20000000, 100000000, 'Toko aksesoris s.d. elektronik umum'),
  ('clothing_store',     'Toko Pakaian',                 5000000,  50000000, 'Distro kecil s.d. boutique'),
  ('book_store',         'Toko Buku',                    5000000,  40000000, 'Toko buku kecil s.d. menengah'),
  ('florist',            'Toko Bunga',                   3000000,  20000000, 'Florist rumahan s.d. toko'),
  ('car_wash',           'Cuci Mobil/Motor',             5000000,  50000000, 'Cuci motor manual s.d. cuci mobil hidrolik')
ON CONFLICT (category_key) DO NOTHING;

-- RLS: Everyone can read the reference table (public data)
ALTER TABLE public.business_category_capital_reference ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read capital reference" ON public.business_category_capital_reference
    FOR SELECT USING (true);
