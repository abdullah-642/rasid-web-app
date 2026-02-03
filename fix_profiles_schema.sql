-- Add 'updated_at' column if it doesn't exist
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- Just in case `telegram_chat_id` wasn't added before
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS telegram_chat_id TEXT;

-- Notify Supabase to reload schema cache
NOTIFY pgrst, 'reload config';
