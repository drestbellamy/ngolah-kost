-- ============================================================
-- FIX CASCADE DELETE untuk Tabel PEMASUKAN
-- ============================================================
-- Script ini menambahkan CASCADE DELETE untuk tabel pemasukan
-- yang terlewat di script sebelumnya
-- ============================================================

-- ============================================================
-- 1. PEMASUKAN -> KOST (CASCADE)
-- ============================================================
-- Saat kost dihapus, semua pemasukan kost tersebut ikut terhapus

ALTER TABLE pemasukan 
DROP CONSTRAINT IF EXISTS pemasukan_kost_id_fkey;

ALTER TABLE pemasukan 
ADD CONSTRAINT pemasukan_kost_id_fkey 
FOREIGN KEY (kost_id) 
REFERENCES kost(id) 
ON DELETE CASCADE 
ON UPDATE CASCADE;

COMMENT ON CONSTRAINT pemasukan_kost_id_fkey ON pemasukan 
IS 'Cascade delete: Hapus pemasukan saat kost dihapus';


-- ============================================================
-- 2. PEMASUKAN -> PEMBAYARAN (CASCADE)
-- ============================================================
-- Saat pembayaran dihapus, pemasukan yang terkait ikut terhapus

ALTER TABLE pemasukan 
DROP CONSTRAINT IF EXISTS pemasukan_pembayaran_id_fkey;

ALTER TABLE pemasukan 
ADD CONSTRAINT pemasukan_pembayaran_id_fkey 
FOREIGN KEY (pembayaran_id) 
REFERENCES pembayaran(id) 
ON DELETE CASCADE 
ON UPDATE CASCADE;

COMMENT ON CONSTRAINT pemasukan_pembayaran_id_fkey ON pemasukan 
IS 'Cascade delete: Hapus pemasukan saat pembayaran dihapus';


-- ============================================================
-- VERIFIKASI HASIL
-- ============================================================
-- Cek apakah constraint pemasukan sudah CASCADE

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
  AND tc.table_name = 'pemasukan'
ORDER BY kcu.column_name;


-- ============================================================
-- SELESAI!
-- ============================================================
-- Sekarang tabel pemasukan sudah di-cascade.
-- Coba hapus kost lagi, seharusnya berhasil!
-- ============================================================
