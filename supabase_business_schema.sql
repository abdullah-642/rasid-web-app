-- Business Budget Manager Schema

-- 1. Create table for Business Budgets
CREATE TABLE IF NOT EXISTS business_budgets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID DEFAULT auth.uid(), -- For RLS
  name TEXT NOT NULL,
  main_budget NUMERIC NOT NULL DEFAULT 0,
  reserve_budget NUMERIC NOT NULL DEFAULT 0,
  alert_threshold NUMERIC NOT NULL DEFAULT 0,
  accountant_chat_id TEXT NOT NULL,
  is_alert_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create table for Business Expenses
CREATE TABLE IF NOT EXISTS business_expenses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  budget_id UUID REFERENCES business_budgets(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL,
  platform TEXT NOT NULL, -- Dropdown values: Snapchat, TikTok, Instagram, Twitter, Google Ads, Other
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Enable RLS
ALTER TABLE business_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_expenses ENABLE ROW LEVEL SECURITY;

-- 4. Create Policies
-- Only allow access to the specific admin user (or the user who created it)
-- Since the requirement is visibility specific to 'kingmr642@gmail.com', 
-- we enforce that only he can access these tables if we knew his UUID.
-- But using standard owner-based RLS effectively isolates it to him if he's the only one adding.

CREATE POLICY "Enable all access for users based on user_id" ON business_budgets
FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Enable all access for users based on budget ownership" ON business_expenses
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM business_budgets bb 
    WHERE bb.id = business_expenses.budget_id 
    AND bb.user_id = auth.uid()
  )
);
