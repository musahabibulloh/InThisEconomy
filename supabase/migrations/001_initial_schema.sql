-- ValidasiIde Database Schema
-- Run this migration in Supabase SQL Editor to create all tables

-- ============================================
-- PROFILES (extends Supabase Auth users)
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own profiles" ON public.profiles
    FOR ALL USING (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- IDEA CHECKS (Modul 1 - Jalur A & B results)
-- ============================================
CREATE TABLE IF NOT EXISTS public.idea_checks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    input_type TEXT NOT NULL CHECK (input_type IN ('idea', 'location')),
    input_text TEXT,
    product_category TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    location_name TEXT,
    radius_km DOUBLE PRECISION DEFAULT 2.0,
    opportunity_score TEXT CHECK (opportunity_score IN ('Rendah', 'Sedang', 'Tinggi')),
    competition_score TEXT CHECK (competition_score IN ('Rendah', 'Sedang', 'Tinggi')),
    demand_score TEXT CHECK (demand_score IN ('Rendah', 'Sedang', 'Tinggi')),
    recommendation TEXT,
    competitors JSONB DEFAULT '[]',
    target_market JSONB DEFAULT '{}',
    trend_data JSONB DEFAULT '{}',
    differentiation_analysis TEXT,
    trend_risk TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.idea_checks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own idea_checks" ON public.idea_checks
    FOR ALL USING (auth.uid() = user_id);

CREATE INDEX idx_idea_checks_user_id ON public.idea_checks(user_id);
CREATE INDEX idx_idea_checks_created_at ON public.idea_checks(created_at DESC);

-- ============================================
-- MARKET GAP SCANS (Modul 1 - Jalur B)
-- ============================================
CREATE TABLE IF NOT EXISTS public.market_gap_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    idea_check_id UUID REFERENCES public.idea_checks(id) ON DELETE SET NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    location_name TEXT,
    radius_km DOUBLE PRECISION DEFAULT 2.0,
    gap_categories JSONB DEFAULT '[]',
    area_profile JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.market_gap_scans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own market_gap_scans" ON public.market_gap_scans
    FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- CHAT SESSIONS (Modul 2)
-- ============================================
CREATE TABLE IF NOT EXISTS public.chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT DEFAULT 'Sesi baru',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own chat_sessions" ON public.chat_sessions
    FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- CHAT MESSAGES (Modul 2)
-- ============================================
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own chat_messages" ON public.chat_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.chat_sessions
            WHERE id = chat_messages.session_id AND user_id = auth.uid()
        )
    );

CREATE INDEX idx_chat_messages_session ON public.chat_messages(session_id, created_at);

-- ============================================
-- PRODUCT PHOTOS (Modul 3 - independent)
-- ============================================
CREATE TABLE IF NOT EXISTS public.product_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    original_path TEXT NOT NULL,
    processed_paths JSONB DEFAULT '[]',
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'done', 'error')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.product_photos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own product_photos" ON public.product_photos
    FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- STORAGE BUCKET
-- ============================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-photos', 'product-photos', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Users can upload own photos" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'product-photos' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can view own photos" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'product-photos' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Public can view product photos" ON storage.objects
    FOR SELECT USING (bucket_id = 'product-photos');
