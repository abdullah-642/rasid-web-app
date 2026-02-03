-- Create the business expenses table if not exists (insurance policy)
create table if not exists public.business_expenses (
  id uuid default gen_random_uuid() primary key,
  budget_id uuid references public.business_budgets(id) on delete cascade not null,
  amount double precision not null,
  platform text not null,
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Force reload schema cache
NOTIFY pgrst, 'reload schema';
