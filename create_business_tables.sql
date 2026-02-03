-- Create table for business budgets
CREATE TABLE IF NOT EXISTS public.business_budgets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    name TEXT NOT NULL,
    main_budget NUMERIC DEFAULT 0,
    reserve_budget NUMERIC DEFAULT 0,
    alert_threshold NUMERIC DEFAULT 0,
    accountant_chat_id TEXT,
    is_alert_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Enable RLS
ALTER TABLE public.business_budgets ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own business budgets" ON public.business_budgets
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own business budgets" ON public.business_budgets
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own business budgets" ON public.business_budgets
    FOR UPDATE USING (auth.uid() = user_id);

-- Create table for business expenses
CREATE TABLE IF NOT EXISTS public.business_expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    budget_id UUID REFERENCES public.business_budgets(id) ON DELETE CASCADE NOT NULL,
    amount NUMERIC NOT NULL,
    platform TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Enable RLS
ALTER TABLE public.business_expenses ENABLE ROW LEVEL SECURITY;

-- Create policies for expenses
CREATE POLICY "Users can view own business expenses" ON public.business_expenses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.business_budgets bb 
            WHERE bb.id = business_expenses.budget_id 
            AND bb.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own business expenses" ON public.business_expenses
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.business_budgets bb 
            WHERE bb.id = budget_id 
            AND bb.user_id = auth.uid()
        )
    );

-- Refresh schema cache
NOTIFY pgrst, 'reload config';
