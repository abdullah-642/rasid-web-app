-- Enable RLS
alter table business_budgets enable row level security;
alter table business_expenses enable row level security;

-- Drop existing policies to ensure clean slate
drop policy if exists "Users can view own business budgets" on business_budgets;
drop policy if exists "Users can insert own business budgets" on business_budgets;
drop policy if exists "Users can update own business budgets" on business_budgets;
drop policy if exists "Users can delete own business budgets" on business_budgets;

drop policy if exists "Users can view own business expenses" on business_expenses;
drop policy if exists "Users can insert own business expenses" on business_expenses;
drop policy if exists "Users can update own business expenses" on business_expenses;
drop policy if exists "Users can delete own business expenses" on business_expenses;

-- Budgets Policies
create policy "Users can view own business budgets" 
on business_budgets for select 
using (auth.uid() = user_id);

create policy "Users can insert own business budgets" 
on business_budgets for insert 
with check (auth.uid() = user_id);

create policy "Users can update own business budgets" 
on business_budgets for update 
using (auth.uid() = user_id);

create policy "Users can delete own business budgets" 
on business_budgets for delete 
using (auth.uid() = user_id);

-- Expenses Policies (linked via budget)
create policy "Users can view own business expenses" 
on business_expenses for select 
using (
  exists (
    select 1 from business_budgets 
    where business_budgets.id = business_expenses.budget_id 
    and business_budgets.user_id = auth.uid()
  )
);

create policy "Users can insert own business expenses" 
on business_expenses for insert 
with check (
  exists (
    select 1 from business_budgets 
    where business_budgets.id = budget_id 
    and business_budgets.user_id = auth.uid()
  )
);

create policy "Users can update own business expenses" 
on business_expenses for update 
using (
  exists (
    select 1 from business_budgets 
    where business_budgets.id = business_expenses.budget_id 
    and business_budgets.user_id = auth.uid()
  )
);

create policy "Users can delete own business expenses" 
on business_expenses for delete 
using (
  exists (
    select 1 from business_budgets 
    where business_budgets.id = business_expenses.budget_id 
    and business_budgets.user_id = auth.uid()
  )
);

-- Force schema reload
NOTIFY pgrst, 'reload config';
