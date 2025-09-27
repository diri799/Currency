-- lib/core/supabase/database_schema.sql
-- Supabase database schema for CurrenSee app

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  default_base_currency TEXT DEFAULT 'USD',
  default_target_currency TEXT DEFAULT 'NGN',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Conversion history table
CREATE TABLE IF NOT EXISTS public.conversion_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  from_currency TEXT NOT NULL,
  to_currency TEXT NOT NULL,
  amount DECIMAL(15,6) NOT NULL,
  rate DECIMAL(15,6) NOT NULL,
  result DECIMAL(15,6) NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Rate alerts table
CREATE TABLE IF NOT EXISTS public.rate_alerts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  from_currency TEXT NOT NULL,
  to_currency TEXT NOT NULL,
  target_rate DECIMAL(15,6) NOT NULL,
  alert_type TEXT CHECK (alert_type IN ('above', 'below', 'change')) DEFAULT 'above',
  is_active BOOLEAN DEFAULT true,
  last_triggered TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User preferences table
CREATE TABLE IF NOT EXISTS public.user_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  theme_mode TEXT CHECK (theme_mode IN ('light', 'dark', 'system')) DEFAULT 'system',
  language TEXT DEFAULT 'en',
  notifications_enabled BOOLEAN DEFAULT true,
  rate_alerts_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Exchange rates cache table
CREATE TABLE IF NOT EXISTS public.exchange_rates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  from_currency TEXT NOT NULL,
  to_currency TEXT NOT NULL,
  rate DECIMAL(15,6) NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  source TEXT DEFAULT 'api',
  UNIQUE(from_currency, to_currency, timestamp)
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_conversion_history_user_id ON public.conversion_history(user_id);
CREATE INDEX IF NOT EXISTS idx_conversion_history_timestamp ON public.conversion_history(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_rate_alerts_user_id ON public.rate_alerts(user_id);
CREATE INDEX IF NOT EXISTS idx_rate_alerts_active ON public.rate_alerts(is_active);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_currencies ON public.exchange_rates(from_currency, to_currency);
CREATE INDEX IF NOT EXISTS idx_exchange_rates_timestamp ON public.exchange_rates(timestamp DESC);

-- Row Level Security (RLS) policies

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversion_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rate_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exchange_rates ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Conversion history policies
CREATE POLICY "Users can view own conversion history" ON public.conversion_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversion history" ON public.conversion_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own conversion history" ON public.conversion_history
  FOR DELETE USING (auth.uid() = user_id);

-- Rate alerts policies
CREATE POLICY "Users can view own rate alerts" ON public.rate_alerts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own rate alerts" ON public.rate_alerts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own rate alerts" ON public.rate_alerts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own rate alerts" ON public.rate_alerts
  FOR DELETE USING (auth.uid() = user_id);

-- User preferences policies
CREATE POLICY "Users can view own preferences" ON public.user_preferences
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences" ON public.user_preferences
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences" ON public.user_preferences
  FOR UPDATE USING (auth.uid() = user_id);

-- Exchange rates policies (read-only for all authenticated users)
CREATE POLICY "Authenticated users can view exchange rates" ON public.exchange_rates
  FOR SELECT USING (auth.role() = 'authenticated');

-- Functions and triggers

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rate_alerts_updated_at BEFORE UPDATE ON public.rate_alerts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to handle new user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
  
  INSERT INTO public.user_preferences (user_id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Trigger for new user registration
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Function to clean old exchange rates (keep last 7 days)
CREATE OR REPLACE FUNCTION clean_old_exchange_rates()
RETURNS void AS $$
BEGIN
  DELETE FROM public.exchange_rates
  WHERE timestamp < NOW() - INTERVAL '7 days';
END;
$$ language 'plpgsql';

-- Create a scheduled job to clean old rates (requires pg_cron extension)
-- SELECT cron.schedule('clean-old-rates', '0 2 * * *', 'SELECT clean_old_exchange_rates();');
