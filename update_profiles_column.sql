-- Add telegram_chat_id column to profiles table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'profiles'
        AND column_name = 'telegram_chat_id'
    ) THEN
        ALTER TABLE public.profiles ADD COLUMN telegram_chat_id text;
    END IF;
END $$;

-- Ensure RLS policies allow update (if not already set)
-- You can re-run these safely
create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );
