-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  phone TEXT,
  birth_date DATE,
  birth_time TIME,
  birth_place TEXT,
  zodiac_sign TEXT,
  avatar_url TEXT,
  is_premium BOOLEAN DEFAULT false,
  subscription_end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create horoscope_history table
CREATE TABLE IF NOT EXISTS public.horoscope_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  zodiac_sign TEXT NOT NULL,
  date DATE NOT NULL,
  content TEXT,
  love_score INTEGER CHECK (love_score >= 0 AND love_score <= 5),
  career_score INTEGER CHECK (career_score >= 0 AND career_score <= 5),
  health_score INTEGER CHECK (health_score >= 0 AND health_score <= 5),
  lucky_number TEXT,
  lucky_color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create tarot_readings table
CREATE TABLE IF NOT EXISTS public.tarot_readings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  spread_type TEXT NOT NULL, -- 'single', 'three_card', 'celtic_cross'
  question TEXT,
  cards JSONB NOT NULL, -- Array of card objects
  interpretation TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create compatibility_checks table
CREATE TABLE IF NOT EXISTS public.compatibility_checks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  person1_name TEXT NOT NULL,
  person1_zodiac TEXT NOT NULL,
  person1_birth_date DATE,
  person2_name TEXT NOT NULL,
  person2_zodiac TEXT NOT NULL,
  person2_birth_date DATE,
  compatibility_score INTEGER CHECK (compatibility_score >= 0 AND compatibility_score <= 100),
  love_compatibility INTEGER,
  friendship_compatibility INTEGER,
  work_compatibility INTEGER,
  analysis TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create chat_sessions table
CREATE TABLE IF NOT EXISTS public.chat_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  last_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create favorites table
CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('horoscope', 'tarot', 'compatibility')),
  reference_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, type, reference_id)
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create function to handle user profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name)
  VALUES (
    NEW.id, 
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic profile creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_sessions_updated_at BEFORE UPDATE ON public.chat_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.horoscope_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tarot_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.compatibility_checks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Horoscope history policies
CREATE POLICY "Users can view own horoscope history" ON public.horoscope_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own horoscope history" ON public.horoscope_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own horoscope history" ON public.horoscope_history
  FOR DELETE USING (auth.uid() = user_id);

-- Tarot readings policies
CREATE POLICY "Users can view own tarot readings" ON public.tarot_readings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tarot readings" ON public.tarot_readings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own tarot readings" ON public.tarot_readings
  FOR DELETE USING (auth.uid() = user_id);

-- Compatibility checks policies
CREATE POLICY "Users can view own compatibility checks" ON public.compatibility_checks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own compatibility checks" ON public.compatibility_checks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own compatibility checks" ON public.compatibility_checks
  FOR DELETE USING (auth.uid() = user_id);

-- Chat sessions policies
CREATE POLICY "Users can view own chat sessions" ON public.chat_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat sessions" ON public.chat_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own chat sessions" ON public.chat_sessions
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat sessions" ON public.chat_sessions
  FOR DELETE USING (auth.uid() = user_id);

-- Chat messages policies
CREATE POLICY "Users can view own chat messages" ON public.chat_messages
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat messages" ON public.chat_messages
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Favorites policies
CREATE POLICY "Users can view own favorites" ON public.favorites
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites" ON public.favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites" ON public.favorites
  FOR DELETE USING (auth.uid() = user_id);

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_horoscope_history_user_date ON public.horoscope_history(user_id, date);
CREATE INDEX IF NOT EXISTS idx_tarot_readings_user ON public.tarot_readings(user_id);
CREATE INDEX IF NOT EXISTS idx_compatibility_checks_user ON public.compatibility_checks(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_user ON public.chat_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_session ON public.chat_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, is_read);

-- Insert sample zodiac signs (optional)
CREATE TABLE IF NOT EXISTS public.zodiac_signs (
  id SERIAL PRIMARY KEY,
  name_en TEXT NOT NULL,
  name_th TEXT NOT NULL,
  symbol TEXT NOT NULL,
  element TEXT NOT NULL,
  date_range TEXT NOT NULL,
  ruling_planet TEXT NOT NULL
);

INSERT INTO public.zodiac_signs (name_en, name_th, symbol, element, date_range, ruling_planet) VALUES
  ('Aries', 'ราศีเมษ', '♈', 'Fire', 'Mar 21 - Apr 19', 'Mars'),
  ('Taurus', 'ราศีพฤษภ', '♉', 'Earth', 'Apr 20 - May 20', 'Venus'),
  ('Gemini', 'ราศีเมถุน', '♊', 'Air', 'May 21 - Jun 20', 'Mercury'),
  ('Cancer', 'ราศีกรกฎ', '♋', 'Water', 'Jun 21 - Jul 22', 'Moon'),
  ('Leo', 'ราศีสิงห์', '♌', 'Fire', 'Jul 23 - Aug 22', 'Sun'),
  ('Virgo', 'ราศีกันย์', '♍', 'Earth', 'Aug 23 - Sep 22', 'Mercury'),
  ('Libra', 'ราศีตุลย์', '♎', 'Air', 'Sep 23 - Oct 22', 'Venus'),
  ('Scorpio', 'ราศีพิจิก', '♏', 'Water', 'Oct 23 - Nov 21', 'Pluto'),
  ('Sagittarius', 'ราศีธนู', '♐', 'Fire', 'Nov 22 - Dec 21', 'Jupiter'),
  ('Capricorn', 'ราศีมังกร', '♑', 'Earth', 'Dec 22 - Jan 19', 'Saturn'),
  ('Aquarius', 'ราศีกุมภ์', '♒', 'Air', 'Jan 20 - Feb 18', 'Uranus'),
  ('Pisces', 'ราศีมีน', '♓', 'Water', 'Feb 19 - Mar 20', 'Neptune')
ON CONFLICT DO NOTHING;