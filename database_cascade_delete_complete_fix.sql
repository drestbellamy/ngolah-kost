-- ============================================================
-- COMPLETE CASCADE DELETE FIX - ALL IN ONE
-- ============================================================
-- Script ini akan mengubah SEMUA foreign key yang relevan
-- ke CASCADE DELETE sekaligus
-- 
-- CARA PAKAI:
-- 1. Buka Supabase Dashboard → SQL Editor
-- 2. Copy-paste script ini
-- 3. Klik "Run"
-- 4. Selesai! Semua foreign key sudah CASCADE
-- ============================================================

BEGIN;

-- ============================================================
-- 1. KOST RELATED
-- ============================================================

-- kamar -> kost
ALTER TABLE kamar 
DROP CONSTRAINT IF EXISTS kamar_kost_id_fkey;
ALTER TABLE kamar 
ADD CONSTRAINT kamar_kost_id_fkey 
FOREIGN KEY (kost_id) REFERENCES kost(id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- metode_pembayaran -> kost
ALTER TABLE metode_pembayaran 
DROP CONSTRAINT IF EXISTS metode_pembayaran_kost_id_fkey;
ALTER TABLE metode_pembayaran 
ADD CONSTRAINT metode_pembayaran_kost_id_fkey 
FOREIGN KEY (kost_id) REFERENCES kost(id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- pengeluaran -> kost
ALTER TABLE pengeluaran 
DROP CONSTRAINT IF EXISTS pengeluaran_kost_id_fkey;
ALTER TABLE pengeluaran 
ADD CONSTRAINT pengeluaran_kost_id_fkey 
FOREIGN KEY (kost_id) REFERENCES kost(id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- pengumuman -> kost
ALTER TABLE pengumuman 
DROP CONSTRAINT IF EXISTS pengumuman_kost_id_fkey;
ALTER TABLE pengumuman 
ADD CONSTRAINT pengumuman_kost_id_fkey 
FOREIGN KEY (kost_id) REFERENCES kost(id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- peraturan -> kost
ALTER TABLE peraturan 
DROP CONSTRAINT IF EXISTS peraturan_kost_id_fkey;
ALTER TABLE peraturan 
ADD CONSTRAINT peraturan_kost_id_fkey 
FOREIGN KEY (kost_id) REFERENCES kost(id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- pemasukan -> kost
ALTER TABLE pemasukan 
DROP CONSTRAINT IF EXISTS pemasukan_kost_id_fkey;
ALTER TABLE pemasukan 
ADD CONSTRAINT pemasukan_kost_id_fkey 
FOREIGN KEY (kost_id) REFERENCES kost(id) 
ON DELETE CASCADE ON UPDATE CASCADE;


-- ============================================================
-- 2. KAMAR RELATED
-- ============================================================

-- penghuni -> kamar
ALTER TABLE penghuni 
DROP CONSTRAINT IF EXISTS penghuni_kamar_id_fkey;
ALTER TABLE penghuni 
ADD CONSTRAINT penghuni_kamar_id_fkey 
FOREIGN KEY (kamar_id) REFERENCES kamar(id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- tagihan -> kamar (jika ada)
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tagihan' AND column_name = 'kamar_id'
  ) THEN
    ALTER TABLE tagihan 
    DROP CONSTRAINT IF EXISTS tagihan_kamar_id_fkey;
    ALTER TABLE tagihan 
    ADD CONSTRAINT tagihan_kamar_id_fkey 
    FOREIGN KEY (kamar_id) REFERENCES kamar(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;
  END IF;
END $$;


-- ============================================================
-- 3. PENGHUNI RELATED
-- ============================================================

-- pembayaran -> penghuni
ALTER TABLE pembayaran 
DROP CONSTRAINT IF EXISTS pembayaran_penghuni_id_fkey;
ALTER TABLE pembayaran 
ADD CONSTRAINT pembayaran_penghuni_id_fkey 
FOREIGN KEY (penghuni_id) REFERENCES penghuni(id) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- pemasukan -> penghuni
ALTER TABLE pemasukan 
DROP CONSTRAINT IF EXISTS pemasukan_penghuni_id_fkey;
ALTER TABLE pemasukan 
ADD CONSTRAINT pemasukan_penghuni_id_fkey 
FOREIGN KEY (penghuni_id) REFERENCES penghuni(id) 
ON DELETE CASCADE ON UPDATE CASCADE;


-- ============================================================
-- 4. METODE_PEMBAYARAN RELATED
-- ============================================================

-- pembayaran -> metode_pembayaran
ALTER TABLE pembayaran 
DROP CONSTRAINT IF EXISTS pembayaran_metode_id_fkey;
ALTER TABLE pembayaran 
ADD CONSTRAINT pembayaran_metode_id_fkey 
FOREIGN KEY (metode_id) REFERENCES metode_pembayaran(id) 
ON DELETE CASCADE ON UPDATE CASCADE;


-- ============================================================
-- 5. PEMBAYARAN RELATED
-- ============================================================

-- pemasukan -> pembayaran
ALTER TABLE pemasukan 
DROP CONSTRAINT IF EXISTS pemasukan_pembayaran_id_fkey;
ALTER TABLE pemasukan 
ADD CONSTRAINT pemasukan_pembayaran_id_fkey 
FOREIGN KEY (pembayaran_id) REFERENCES pembayaran(id) 
ON DELETE CASCADE ON UPDATE CASCADE;


COMMIT;


-- ============================================================
-- VERIFIKASI HASIL
-- ============================================================

SELECT 
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  rc.delete_rule,
  rc.update_rule,
  CASE 
    WHEN rc.delete_rule = 'CASCADE' THEN '✅ OK'
    ELSE '⚠️ ' || rc.delete_rule
  END AS status
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
  AND tc.table_schema = 'public'
  AND ccu.table_name IN ('kost', 'kamar', 'penghuni', 'metode_pembayaran', 'pembayaran')
ORDER BY 
  CASE 
    WHEN rc.delete_rule = 'CASCADE' THEN 2
    ELSE 1
  END,
  tc.table_name, 
  kcu.column_name;


-- ============================================================
-- SELESAI!
-- ============================================================
-- Semua foreign key sudah CASCADE!
-- 
-- Test dengan:
-- 1. Hapus kost → semua data terkait terhapus
-- 2. Hapus kamar → penghuni & pembayaran terhapus
-- 3. Hapus penghuni → pembayaran & pemasukan terhapus
-- ============================================================
