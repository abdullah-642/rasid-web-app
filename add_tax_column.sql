-- Add tax_amount column to business_expenses
ALTER TABLE public.business_expenses 
ADD COLUMN IF NOT EXISTS tax_amount NUMERIC DEFAULT 0;

-- Refresh schema cache
NOTIFY pgrst, 'reload config';
