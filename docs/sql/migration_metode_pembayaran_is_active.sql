-- Migration: add is_active column for metode_pembayaran
-- Goal: make toggle status persist to database.

begin;

alter table public.metode_pembayaran
add column if not exists is_active boolean;

-- Backfill existing rows to active by default.
update public.metode_pembayaran
set is_active = true
where is_active is null;

alter table public.metode_pembayaran
alter column is_active set default true;

alter table public.metode_pembayaran
alter column is_active set not null;

commit;

-- Optional check:
-- select column_name, data_type, is_nullable, column_default
-- from information_schema.columns
-- where table_schema = 'public'
--   and table_name = 'metode_pembayaran'
--   and column_name = 'is_active';
