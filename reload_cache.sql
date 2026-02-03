-- Force Supabase to refresh its schema cache
-- This is required after adding new columns so the API can see them
NOTIFY pgrst, 'reload config';
