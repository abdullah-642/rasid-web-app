-- Attempt to drop the existing foreign key constraint if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'business_expenses_budget_id_fkey') THEN
        ALTER TABLE business_expenses DROP CONSTRAINT business_expenses_budget_id_fkey;
    END IF;
END $$;

-- Re-add the constraint with ON DELETE CASCADE
ALTER TABLE business_expenses
ADD CONSTRAINT business_expenses_budget_id_fkey
FOREIGN KEY (budget_id)
REFERENCES business_budgets(id)
ON DELETE CASCADE;
