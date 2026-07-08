-- SQL Schema to create Gammiris prices tables in Supabase

-- 1. Create table for District Prices
CREATE TABLE IF NOT EXISTS public.gammiris_district_prices (
    district TEXT PRIMARY KEY,
    district_sinhala TEXT NOT NULL,
    black DOUBLE PRECISION NOT NULL,
    white DOUBLE PRECISION NOT NULL,
    green DOUBLE PRECISION NOT NULL,
    mixed DOUBLE PRECISION NOT NULL,
    trend TEXT NOT NULL DEFAULT 'stable',
    change DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.gammiris_district_prices ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (Read-Only)
CREATE POLICY "Allow public read access" ON public.gammiris_district_prices
    FOR SELECT USING (true);

-- 2. Create table for Weekly Trends
CREATE TABLE IF NOT EXISTS public.gammiris_weekly_trends (
    week TEXT PRIMARY KEY,
    black DOUBLE PRECISION NOT NULL,
    white DOUBLE PRECISION NOT NULL,
    green DOUBLE PRECISION NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.gammiris_weekly_trends ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (Read-Only)
CREATE POLICY "Allow public read access" ON public.gammiris_weekly_trends
    FOR SELECT USING (true);

-- 3. Populate default fallback values matching the current design
INSERT INTO public.gammiris_district_prices (district, district_sinhala, black, white, green, mixed, trend, change)
VALUES
    ('Matale', 'මාතලේ', 1850, 2400, 980, 1450, 'up', 4.2),
    ('Kandy', 'මහනුවර', 1920, 2550, 1020, 1520, 'up', 2.8),
    ('Kurunegala', 'කුරුණෑගල', 1780, 2300, 940, 1390, 'stable', 0.5),
    ('Kegalle', 'කෑගල්ල', 1840, 2420, 970, 1430, 'up', 3.1),
    ('Ratnapura', 'රත්නපුර', 1760, 2280, 920, 1370, 'down', -1.5),
    ('Gampaha', 'ගම්පහ', 1900, 2500, 1000, 1490, 'up', 1.9),
    ('Colombo', 'කොළඹ', 1980, 2620, 1050, 1560, 'up', 5.1),
    ('Galle', 'ගාල්ල', 1820, 2360, 960, 1410, 'down', -0.8),
    ('Hambantota', 'හම්බන්තොට', 1750, 2250, 910, 1360, 'stable', 0.2),
    ('Badulla', 'බදුල්ල', 1810, 2340, 950, 1400, 'up', 2.2)
ON CONFLICT (district) DO UPDATE 
SET 
    black = EXCLUDED.black, 
    white = EXCLUDED.white, 
    green = EXCLUDED.green, 
    mixed = EXCLUDED.mixed, 
    trend = EXCLUDED.trend, 
    change = EXCLUDED.change,
    updated_at = now();

INSERT INTO public.gammiris_weekly_trends (week, black, white, green)
VALUES
    ('May W1', 1620, 2100, 860),
    ('May W2', 1680, 2180, 890),
    ('May W3', 1720, 2240, 910),
    ('May W4', 1690, 2200, 900),
    ('Jun W1', 1750, 2280, 930),
    ('Jun W2', 1800, 2350, 955),
    ('Jun W3', 1830, 2390, 970),
    ('Jun W4', 1870, 2450, 990),
    ('Jul W1', 1920, 2550, 1020)
ON CONFLICT (week) DO UPDATE 
SET 
    black = EXCLUDED.black, 
    white = EXCLUDED.white, 
    green = EXCLUDED.green,
    updated_at = now();
