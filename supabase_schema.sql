-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create Budgets Table
create table if not exists public.budgets (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  name text not null,
  total_amount numeric not null,
  type text check (type in ('personal', 'business')) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create Transactions Table
create table if not exists public.transactions (
  id uuid primary key default uuid_generate_v4(),
  budget_id uuid references public.budgets on delete cascade not null,
  user_id uuid references auth.users not null,
  title text not null,
  amount numeric not null,
  category text,
  date timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create Tasks Table
create table if not exists public.tasks (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  title text not null,
  due_date timestamp with time zone not null,
  priority text check (priority in ('High', 'Medium', 'Low')) not null,
  is_completed boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS Policies (Row Level Security)
alter table public.budgets enable row level security;
alter table public.transactions enable row level security;
alter table public.tasks enable row level security;

-- Budgets Policies
create policy "Users can view their own budgets" on public.budgets
  for select using (auth.uid() = user_id);
create policy "Users can insert their own budgets" on public.budgets
  for insert with check (auth.uid() = user_id);
create policy "Users can update their own budgets" on public.budgets
  for update using (auth.uid() = user_id);
create policy "Users can delete their own budgets" on public.budgets
  for delete using (auth.uid() = user_id);

-- Transactions Policies
create policy "Users can view their own transactions" on public.transactions
  for select using (auth.uid() = user_id);
create policy "Users can insert their own transactions" on public.transactions
  for insert with check (auth.uid() = user_id);

-- Tasks Policies
create policy "Users can view their own tasks" on public.tasks
  for select using (auth.uid() = user_id);
create policy "Users can insert their own tasks" on public.tasks
  for insert with check (auth.uid() = user_id);
create policy "Users can update their own tasks" on public.tasks
  for update using (auth.uid() = user_id);
