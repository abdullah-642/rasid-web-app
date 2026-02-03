-- Fix tasks table RLS: Add DELETE policy
create policy "Users can delete their own tasks" on public.tasks
  for delete using (auth.uid() = user_id);
