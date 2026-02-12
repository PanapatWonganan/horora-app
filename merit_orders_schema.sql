-- Merit Orders Schema for Supabase
-- Run this in Supabase SQL Editor

-- Create merit_locations table (สถานที่มงคล)
CREATE TABLE IF NOT EXISTS merit_locations (
  id TEXT PRIMARY KEY,
  name_th TEXT NOT NULL,
  name_en TEXT,
  description TEXT,
  belief TEXT,                    -- ความเชื่อ/ขอพรเรื่องอะไร
  address TEXT,
  image_url TEXT,
  is_active BOOLEAN DEFAULT true,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create merit_packages table (แพ็คเกจ)
CREATE TABLE IF NOT EXISTS merit_packages (
  id TEXT PRIMARY KEY,
  name_th TEXT NOT NULL,
  name_en TEXT,
  description TEXT,
  items TEXT[],                   -- รายการของที่ได้
  price DECIMAL NOT NULL,
  photo_count INT DEFAULT 3,      -- จำนวนรูปที่ส่งให้
  has_video BOOLEAN DEFAULT false,
  has_live BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create merit_orders table (คำสั่งซื้อ)
CREATE TABLE IF NOT EXISTS merit_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT UNIQUE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  location_id TEXT REFERENCES merit_locations(id),
  package_id TEXT REFERENCES merit_packages(id),

  -- ข้อมูลผู้ขอพร
  prayer_name TEXT NOT NULL,
  prayer_birthdate DATE,
  prayer_wish TEXT,
  prayer_phone TEXT,

  -- ราคาและการชำระเงิน
  price DECIMAL NOT NULL,
  slip_url TEXT,
  paid_at TIMESTAMPTZ,

  -- สถานะ
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'processing', 'completed', 'cancelled')),

  -- หลักฐานการไหว้
  proof_urls TEXT[],
  proof_video_url TEXT,
  completed_at TIMESTAMPTZ,
  admin_note TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_merit_orders_user_id ON merit_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_merit_orders_status ON merit_orders(status);
CREATE INDEX IF NOT EXISTS idx_merit_orders_created_at ON merit_orders(created_at DESC);

-- Enable RLS
ALTER TABLE merit_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE merit_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE merit_orders ENABLE ROW LEVEL SECURITY;

-- Policies for merit_locations (everyone can read)
CREATE POLICY "Anyone can view active locations" ON merit_locations
  FOR SELECT USING (is_active = true);

-- Policies for merit_packages (everyone can read)
CREATE POLICY "Anyone can view active packages" ON merit_packages
  FOR SELECT USING (is_active = true);

-- Policies for merit_orders
CREATE POLICY "Users can view their own orders" ON merit_orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create orders" ON merit_orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own pending orders" ON merit_orders
  FOR UPDATE USING (auth.uid() = user_id AND status = 'pending');

-- Function to generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.order_number := 'MRT' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for order number
DROP TRIGGER IF EXISTS trigger_generate_order_number ON merit_orders;
CREATE TRIGGER trigger_generate_order_number
  BEFORE INSERT ON merit_orders
  FOR EACH ROW
  EXECUTE FUNCTION generate_order_number();

-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updated_at
DROP TRIGGER IF EXISTS trigger_update_merit_orders_updated_at ON merit_orders;
CREATE TRIGGER trigger_update_merit_orders_updated_at
  BEFORE UPDATE ON merit_orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Insert default locations
INSERT INTO merit_locations (id, name_th, name_en, description, belief, sort_order) VALUES
('erawan', 'ศาลพระพรหม เอราวัณ', 'Erawan Shrine', 'ศาลพระพรหมที่มีชื่อเสียงที่สุดในประเทศไทย ตั้งอยู่หน้าโรงแรมแกรนด์ไฮแอท เอราวัณ', 'ขอพรทุกด้าน โชคลาภ ความสำเร็จ', 1),
('city_pillar', 'ศาลหลักเมือง', 'City Pillar Shrine', 'ศาลหลักเมืองกรุงเทพมหานคร สร้างขึ้นเมื่อ พ.ศ. 2325', 'ความสำเร็จ การงาน ความมั่นคง', 2),
('wat_rakang', 'วัดระฆังโฆสิตาราม', 'Wat Rakang', 'วัดเก่าแก่ริมแม่น้ำเจ้าพระยา มีระฆังศักดิ์สิทธิ์', 'การเงิน โชคลาภ ค้าขาย', 3),
('ganesha_central', 'พระพิฆเนศ เซ็นทรัลเวิลด์', 'Ganesha Central World', 'พระพิฆเนศองค์ใหญ่หน้าเซ็นทรัลเวิลด์', 'การศึกษา ศิลปะ ความสำเร็จ', 4),
('guanyin_yaowarat', 'เจ้าแม่กวนอิม เยาวราช', 'Guanyin Yaowarat', 'ศาลเจ้าแม่กวนอิมที่เก่าแก่ในย่านเยาวราช', 'สุขภาพ ลูกหลาน ครอบครัว', 5),
('wat_pho', 'วัดโพธิ์', 'Wat Pho', 'วัดที่มีพระพุทธไสยาสน์ที่ใหญ่ที่สุด', 'สุขภาพ ปัดเป่าโรคภัย', 6),
('wat_suthat', 'วัดสุทัศนเทพวราราม', 'Wat Suthat', 'วัดที่มีพระศรีศากยมุนี พระพุทธรูปสำคัญ', 'ความสงบ สติปัญญา', 7),
('vessavana', 'ท้าวเวสสุวรรณ วัดจุฬามณี', 'Vessavana Wat Chulamani', 'ท้าวเวสสุวรรณที่ศักดิ์สิทธิ์', 'ป้องกันภัย โชคลาภ ค้าขาย', 8)
ON CONFLICT (id) DO NOTHING;

-- Insert default packages
INSERT INTO merit_packages (id, name_th, name_en, description, items, price, photo_count, has_video, sort_order) VALUES
('basic', 'ไหว้มงคล', 'Basic', 'ชุดไหว้พื้นฐาน เหมาะสำหรับขอพรทั่วไป', ARRAY['ธูป 9 ดอก', 'เทียน 2 เล่ม', 'ดอกไม้สด'], 199, 3, false, 1),
('standard', 'ไหว้เสริมดวง', 'Standard', 'ชุดไหว้ครบครัน พร้อมผลไม้มงคล', ARRAY['ธูป 9 ดอก', 'เทียน 2 เล่ม', 'ดอกไม้สด', 'พวงมาลัย', 'ผลไม้ 5 อย่าง', 'น้ำแดง'], 399, 5, true, 2),
('premium', 'ไหว้ครบเครื่อง', 'Premium', 'ชุดไหว้พรีเมียม พร้อมทองคำเปลว', ARRAY['ธูป 9 ดอก', 'เทียน 2 เล่ม', 'ดอกไม้สด', 'พวงมาลัย', 'ผลไม้ 9 อย่าง', 'น้ำแดง', 'ทองคำเปลว', 'ของถวายพิเศษ'], 699, 10, true, 3),
('vip', 'VIP บูชาใหญ่', 'VIP', 'ชุดไหว้ VIP ครบทุกอย่าง พร้อม Live สด', ARRAY['ธูป 9 ดอก', 'เทียน 2 เล่ม', 'ดอกไม้สด', 'พวงมาลัยพิเศษ', 'ผลไม้ 9 อย่าง', 'น้ำแดง', 'ทองคำเปลว', 'ของถวายพิเศษ', 'รำถวาย (เฉพาะบางสถานที่)'], 1299, 15, true, 4)
ON CONFLICT (id) DO NOTHING;

-- Create storage bucket for merit orders (run in Supabase Dashboard > Storage)
-- Bucket name: merit-orders
-- Public: false
-- Allowed MIME types: image/jpeg, image/png, image/webp
