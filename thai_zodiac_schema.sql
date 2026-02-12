-- Update existing profiles table to use Thai zodiac instead of Western zodiac
ALTER TABLE public.profiles 
DROP COLUMN IF EXISTS zodiac_sign,
ADD COLUMN thai_animal TEXT, -- ชวด, ฉลู, ขาล...
ADD COLUMN thai_year_name TEXT, -- ปีชวด, ปีฉลู...
ADD COLUMN thai_element TEXT, -- ทอง, น้ำ, ไม้, ไฟ, ดิน
ADD COLUMN thai_element_full TEXT; -- ธาตุทอง, ธาตุน้ำ...

-- Update horoscope_history table
ALTER TABLE public.horoscope_history 
DROP COLUMN IF EXISTS zodiac_sign,
ADD COLUMN thai_animal TEXT NOT NULL DEFAULT 'ชวด';

-- Drop old zodiac_signs table and create Thai zodiac reference
DROP TABLE IF EXISTS public.zodiac_signs;

-- Create Thai zodiac animals reference table
CREATE TABLE IF NOT EXISTS public.thai_zodiac_animals (
  id SERIAL PRIMARY KEY,
  animal_name TEXT NOT NULL UNIQUE, -- ชวด, ฉลู, ขาล...
  thai_name TEXT NOT NULL, -- ปีชวด, ปีฉลู...
  english_name TEXT NOT NULL,
  characteristics TEXT NOT NULL,
  compatibility TEXT,
  lucky_numbers INTEGER[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create Thai elements reference table  
CREATE TABLE IF NOT EXISTS public.thai_elements (
  id SERIAL PRIMARY KEY,
  element_name TEXT NOT NULL UNIQUE, -- ทอง, น้ำ, ไม้, ไฟ, ดิน
  element_full TEXT NOT NULL, -- ธาตุทอง, ธาตุน้ำ...
  lucky_colors TEXT[],
  characteristics TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert Thai zodiac animals data
INSERT INTO public.thai_zodiac_animals (animal_name, thai_name, english_name, characteristics, compatibility, lucky_numbers) VALUES
  ('ชวด', 'ปีชวด', 'Year of Rat', 'ขยัน อดทน รอบคอบ มีไหวพริบ เก็บเงินเก่ง', 'เข้ากันดีกับปีฉลู ปีมะโรง', ARRAY[1,6,11,16]),
  ('ฉลู', 'ปีฉลู', 'Year of Ox', 'อดทน มั่นคง เชื่อถือได้ ทำงานหนัก รักความมั่นคง', 'เข้ากันดีกับปีชวด ปีมะเส็ง', ARRAY[2,7,12,17]),
  ('ขาล', 'ปีขาล', 'Year of Tiger', 'กล้าหาญ มีความเป็นผู้นำ อิสระ ชอบการผจญภัย', 'เข้ากันดีกับปีมะเมีย ปีจอ', ARRAY[3,8,13,18]),
  ('เถาะ', 'ปีเถาะ', 'Year of Rabbit', 'อ่อนโยน มีมารยาท รักสันติ ชอบความงาม', 'เข้ากันดีกับปีมะแม ปีกุน', ARRAY[4,9,14,19]),
  ('มะโรง', 'ปีมะโรง', 'Year of Dragon', 'ทะเยอทะยาน มีพลัง มั่นใจ ชอบเป็นที่สนใจ', 'เข้ากันดีกับปีชวด ปีวอก', ARRAY[5,10,15,20]),
  ('มะเส็ง', 'ปีมะเส็ง', 'Year of Snake', 'ลึกซึ้ง ปัญญาดี ชอบการเรียนรู้ มีสัญชาตญาณ', 'เข้ากันดีกับปีฉลู ปีระกา', ARRAY[1,6,11,21]),
  ('มะเมีย', 'ปีมะเมีย', 'Year of Horse', 'กระฉับกระเฉง รักเสรีภาพ ตรงไปตรงมา ชอบเดินทาง', 'เข้ากันดีกับปีขาล ปีจอ', ARRAY[2,7,12,22]),
  ('มะแม', 'ปีมะแม', 'Year of Goat', 'อ่อนโยน ศิลปิน ชอบความงาม มีจิตใจนุ่มนวล', 'เข้ากันดีกับปีเถาะ ปีกุน', ARRAY[3,8,13,23]),
  ('วอก', 'ปีวอก', 'Year of Monkey', 'ฉลาด เก่ง มีไหวพริบ ชอบเปลี่ยนแปลง มีจิตใจเปิดกว้าง', 'เข้ากันดีกับปีชวด ปีมะโรง', ARRAY[4,9,14,24]),
  ('ระกา', 'ปีระกา', 'Year of Rooster', 'ตรงไปตรงมา รักความสะอาด มีระเบียบแบบแผน ชอบความสวยงาม', 'เข้ากันดีกับปีฉลู ปีมะเส็ง', ARRAY[5,10,15,25]),
  ('จอ', 'ปีจอ', 'Year of Dog', 'ซื่อสัตย์ จริงใจ มีความรับผิดชอบสูง รักครอบครัว', 'เข้ากันดีกับปีเถาะ ปีมะเมีย', ARRAY[1,6,16,26]),
  ('กุน', 'ปีกุน', 'Year of Pig', 'ใจกว้าง เอื้อเฟื้อ มีน้ำใจ รักความสุขสบาย', 'เข้ากันดีกับปีเถาะ ปีมะแม', ARRAY[2,7,17,27])
ON CONFLICT (animal_name) DO NOTHING;

-- Insert Thai elements data
INSERT INTO public.thai_elements (element_name, element_full, lucky_colors, characteristics) VALUES
  ('ทอง', 'ธาตุทอง', ARRAY['ทอง','เงิน','ขาว','เทา'], 'มีความมั่นคง รักความปลอดภัย มีเกียรติยศ'),
  ('น้ำ', 'ธาตุน้ำ', ARRAY['น้ำเงิน','ดำ','เทาเข้ม'], 'มีปัญญา ลึกซึ้ง อ่อนโยน เปลี่ยนแปลงได้'),
  ('ไม้', 'ธาตุไม้', ARRAY['เขียว','เขียวเข้ม','เขียวอ่อน'], 'เจริญเติบโต มีชีวิตชีวา รักธรรมชาติ'),
  ('ไฟ', 'ธาตุไฟ', ARRAY['แดง','ส้ม','ชมพู','ม่วงแดง'], 'มีพลัง กระตือรือร้น ร้อนแรง มีความหลงใหล'),
  ('ดิน', 'ธาตุดิน', ARRAY['เหลือง','น้ำตาล','ครีม','เบจ'], 'มั่นคง อดทน เป็นที่พึ่ง รักความมั่นคง')
ON CONFLICT (element_name) DO NOTHING;

-- Create function to calculate Thai zodiac from birth year
CREATE OR REPLACE FUNCTION public.calculate_thai_zodiac(birth_year INTEGER)
RETURNS TABLE(animal TEXT, thai_name TEXT, element TEXT, element_full TEXT) AS $$
DECLARE
  animals TEXT[] := ARRAY['วอก','ระกา','จอ','กุน','ชวด','ฉลู','ขาล','เถาะ','มะโรง','มะเส็ง','มะเมีย','มะแม'];
  elements TEXT[] := ARRAY['ทอง','ทอง','น้ำ','น้ำ','ไม้','ไม้','ไฟ','ไฟ','ดิน','ดิน'];
  animal_index INTEGER;
  element_index INTEGER;
  selected_animal TEXT;
  selected_element TEXT;
BEGIN
  animal_index := (birth_year % 12) + 1;
  element_index := (birth_year % 10) + 1;
  
  selected_animal := animals[animal_index];
  selected_element := elements[element_index];
  
  RETURN QUERY
  SELECT 
    selected_animal,
    'ปี' || selected_animal,
    selected_element,
    'ธาตุ' || selected_element;
END;
$$ LANGUAGE plpgsql;

-- Update existing profiles with Thai zodiac (if birth_date exists)
UPDATE public.profiles 
SET 
  thai_animal = tz.animal,
  thai_year_name = tz.thai_name,
  thai_element = tz.element,
  thai_element_full = tz.element_full
FROM public.calculate_thai_zodiac(EXTRACT(YEAR FROM birth_date)::INTEGER) AS tz
WHERE profiles.birth_date IS NOT NULL;

-- Create trigger to automatically calculate Thai zodiac when birth_date is updated
CREATE OR REPLACE FUNCTION public.update_thai_zodiac()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.birth_date IS NOT NULL AND NEW.birth_date != OLD.birth_date THEN
    SELECT animal, thai_name, element, element_full
    INTO NEW.thai_animal, NEW.thai_year_name, NEW.thai_element, NEW.thai_element_full
    FROM public.calculate_thai_zodiac(EXTRACT(YEAR FROM NEW.birth_date)::INTEGER);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profile_thai_zodiac
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_thai_zodiac();

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_thai_animal ON public.profiles(thai_animal);
CREATE INDEX IF NOT EXISTS idx_profiles_thai_element ON public.profiles(thai_element);
CREATE INDEX IF NOT EXISTS idx_horoscope_history_thai_animal ON public.horoscope_history(thai_animal);