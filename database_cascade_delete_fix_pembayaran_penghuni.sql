-- ============================================================
-- FIX CASCADE DELETE untuk PEMBAYARAN -> PENGHUNI
-- ============================================================
-- Script ini menambahkan CASCADE DELETE untuk relasi
-- pembayaran -> penghuni yang terlewat
-- ============================================================

-- ============================================================
-- PEMBAYARAN -> PENGHUNI (CASCADE)
-- ============================================================
-- Saat penghuni dihapus, semua pembayaran penghuni tersebut ikut terhapus

ALTER TABLE pembayaran 
DROP CONSTRAINT IF EXISTS pembayaran_penghuni_id_fkey;

ALTER TABLE pembayaran 
ADD CONSTRAINT pembayaran_penghuni_id_fkey 
FOREIGN KEY (penghuni_id) 
REFERENCES penghuni(id) 
ON DELETE CASCADE 
ON UPDATE CASCADE;

COMMENT ON CONSTRAINT pembayaran_penghuni_id_fkey ON pembayaran 
IS 'Cascade delete: Hapus pembayaran saat penghuni dihapus';


-- ============================================================
-- VERIFIKASI HASIL
-- ============================================================
-- Cek semua foreign key di tabel pembayaran

SELECT 
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  rc.delete_rule,
  rc.update_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
JOIN information_schema.referential_constraints AS rc
  ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'pembayaran'
ORDER BY kcu.column_name;


-- ============================================================
-- SELESAI!
-- ============================================================
-- Sekarang saat hapus kamar, alurnya:
-- 1. Hapus KAMAR
-- 2. Hapus PENGHUNI di kamar tersebut (CASCADE)
-- 3. Hapus PEMBAYARAN penghuni tersebut (CASCADE)
-- 4. Hapus PEMASUKAN dari pembayaran tersebut (CASCADE)
-- ============================================================
