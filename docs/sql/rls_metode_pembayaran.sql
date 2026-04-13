-- RLS setup for metode_pembayaran
-- Current app login uses custom RPC (not Supabase Auth session),
-- so direct policies that rely on auth.uid() will block all requests.
-- This script provides a compatibility setup first.

begin;

-- 1) Enable RLS on target tables.
alter table if exists public.metode_pembayaran enable row level security;
-- NOTE: Do not force-enable RLS on kost here, because that can block
-- existing kost CRUD flows unless all kost policies are prepared.

-- 2) Drop compatibility policies if already created before.
drop policy if exists metode_pembayaran_select_compat on public.metode_pembayaran;
drop policy if exists metode_pembayaran_insert_compat on public.metode_pembayaran;
drop policy if exists metode_pembayaran_update_compat on public.metode_pembayaran;
drop policy if exists metode_pembayaran_delete_compat on public.metode_pembayaran;

drop policy if exists kost_select_compat_for_metode_pembayaran on public.kost;

-- 3) Compatibility policies (needed by current Flutter app architecture).
create policy metode_pembayaran_select_compat
on public.metode_pembayaran
for select
to anon, authenticated
using (true);

create policy metode_pembayaran_insert_compat
on public.metode_pembayaran
for insert
to anon, authenticated
with check (true);

create policy metode_pembayaran_update_compat
on public.metode_pembayaran
for update
to anon, authenticated
using (true)
with check (true);

create policy metode_pembayaran_delete_compat
on public.metode_pembayaran
for delete
to anon, authenticated
using (true);

-- The list page joins kost name by kost_id.
-- This policy is useful only if RLS on kost is already enabled.
create policy kost_select_compat_for_metode_pembayaran
on public.kost
for select
to anon, authenticated
using (true);

commit;

-- Verify active policies:
-- select schemaname, tablename, policyname, permissive, roles, cmd
-- from pg_policies
-- where schemaname = 'public'
--   and tablename in ('metode_pembayaran', 'kost')
-- order by tablename, policyname;


-- ==============================================================
-- HARDENING PLAN (apply later, after app migrates to Supabase Auth)
-- ==============================================================
-- 1) Migrate login flow to supabase.auth.signInWithPassword.
-- 2) Ensure public.users.id == auth.uid() and role is stored there.
-- 3) Replace compatibility policies above with role-based policies.
-- 4) Restrict delete/update/insert to admin only.
--
-- Example admin check expression:
-- exists (
--   select 1
--   from public.users u
--   where u.id = auth.uid()
--     and lower(coalesce(u.role, '')) = 'admin'
-- )
