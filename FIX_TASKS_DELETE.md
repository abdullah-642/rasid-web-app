# إصلاح مشكلة حذف المهام في Supabase

## المشكلة
المهام لا تُحذف من قاعدة البيانات بشكل دائم لأن سياسة RLS للحذف غير موجودة.

## الحل

1. افتح لوحة التحكم في Supabase: https://tosgyerejbeihgflrqbn.supabase.co
2. انتقل إلى **SQL Editor**
3. انسخ والصق هذا الأمر:

```sql
create policy "Users can delete their own tasks" on public.tasks
  for delete using (auth.uid() = user_id);
```

4. اضغط **Run** لتنفيذ الأمر

## التحقق من الإصلاح
بعد تطبيق هذا التحديث، ستتمكن من:
- حذف مهمة واحدة بنجاح
- حذف جميع المهام بنجاح  
- عدم ظهور المهام المحذوفة بعد إعادة تسجيل الدخول

---

**ملف SQL**: `fix_tasks_delete_policy.sql`
