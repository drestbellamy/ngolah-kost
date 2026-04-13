    -- Storage setup for QRIS image upload (metode_pembayaran)
    -- Compatibility mode: allow anon + authenticated, since app is not using Supabase Auth session yet.

    begin;

    insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    values (
    'metode-pembayaran-qris',
    'metode-pembayaran-qris',
    true,
    5242880,
    array['image/png', 'image/jpeg', 'image/jpg', 'image/webp']
    )
    on conflict (id) do update
    set
    public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

    -- Recreate policies so script is idempotent.
    drop policy if exists qris_bucket_read_compat on storage.objects;
    drop policy if exists qris_bucket_insert_compat on storage.objects;
    drop policy if exists qris_bucket_update_compat on storage.objects;
    drop policy if exists qris_bucket_delete_compat on storage.objects;

    create policy qris_bucket_read_compat
    on storage.objects
    for select
    to anon, authenticated
    using (bucket_id = 'metode-pembayaran-qris');

    create policy qris_bucket_insert_compat
    on storage.objects
    for insert
    to anon, authenticated
    with check (bucket_id = 'metode-pembayaran-qris');

    create policy qris_bucket_update_compat
    on storage.objects
    for update
    to anon, authenticated
    using (bucket_id = 'metode-pembayaran-qris')
    with check (bucket_id = 'metode-pembayaran-qris');

    create policy qris_bucket_delete_compat
    on storage.objects
    for delete
    to anon, authenticated
    using (bucket_id = 'metode-pembayaran-qris');

    commit;

    -- Optional check:
    -- select id, name, public, file_size_limit
    -- from storage.buckets
    -- where id = 'metode-pembayaran-qris';
    --
    -- select policyname, cmd, roles
    -- from pg_policies
    -- where schemaname = 'storage'
    --   and tablename = 'objects'
    --   and policyname like 'qris_bucket_%';
