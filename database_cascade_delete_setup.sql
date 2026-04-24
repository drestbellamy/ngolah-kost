-- ============================================================
-- CASCADE DELETE SETUP untuk Kost Management App
-- ============================================================
-- Script ini akan mengubah foreign key constraints agar
-- otomatis menghapus data terkait saat kost dihapus
-- 
-- CARA PAKAI:
-- 1. Buka Supabase Dashboard
-- 2. Pergi ke SQL Editor
-- 3. Copy-paste script ini
-- 4. Klik "Run" atau tekan Ctrl+Enter
-- ============================================================

-- ============================================================
-- BACKUP CONSTRAINTS (Opsional - untuk rollback jika perlu)
-- ============================================================
-- Uncomment jika ingin backup constraint lama
-- SELECT 
--   conname AS constraint_name,
--   conrelid::regclass AS table_name,
--   confrelid::regclass AS referenced_table,
--   pg_get_constraintdef(oid) AS constraint_definition
-- FROM pg_constraint
-- WHERE contype = 'f' 
--   AND (confrelid::regclass::text = 'kost' 
--        OR confrelid::regclass::text = 'metode_pembayaran');


-- ============================================================
-- 1. METODE_PEMBAYARAN -> KOST (CASCADE)
-- ============================================================
-- Saat kost dihapus, semua metode pembayaran kost tersebut ikut terhapus

ALTER TABLE metode_pembayaran 
DROP CONSTRAINT IF EXISTS metode_pembayaran_kost_id_fkey;

ALTER TABLE metode_pembayaran 
ADD CONSTRAINT metode_pembayaran_kost_id_fkey 
FOREIGN KEY (kost_id) 
REFERENCES kost(id) 
ON DELETE CASCADE 
ON UPDATE CASCADE;

COMMENT ON CONSTRAINT metode_pembayaran_kost_id_fkey ON metode_pembayaran 
IS 'Cascade delete: Hapus metode pembayaran saat kost dihapus';


-- ============================================================
-- 2. PEMBAYARAN -> METODE_PEMBAYARAN (CASCADE)
-- ============================================================
-- Saat metode_pembayaran dihapus, semua pembayaran yang menggunakan
-- metode tersebut ikut terhapus

ALTER TABLE pembayaran 
DROP CONSTRAINT IF EXISTS pembayaran_metode_id_fkey;

ALTER TABLE pembayaran 
ADD CONSTRAINT pembayaran_metode_id_fkey 
FOREIGN KEY (metode_id) 
REFERENCES metode_pembayaran(id) 
ON DELETE CASCADE 
ON UPDATE CASCADE;

COMMENT ON CONSTRAINT pembayaran_metode_id_fkey ON pembayaran 
IS 'Cascade delete: Hapus pembayaran saat metode pembayaran dihapus';


-- ============================================================
-- 3. KAMAR -> KOST (CASCADE) - Jika ada tabel kamar
-- ============================================================
-- Saat kost dihapus, semua kamar di kost tersebut ikut terhapus

DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'kamar'
  ) THEN
    ALTER TABLE kamar 
    DROP CONSTRAINT IF EXISTS kamar_kost_id_fkey;
    
    ALTER TABLE kamar 
    ADD CONSTRAINT kamar_kost_id_fkey 
    FOREIGN KEY (kost_id) 
    REFERENCES kost(id) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE;
    
    COMMENT ON CONSTRAINT kamar_kost_id_fkey ON kamar 
    IS 'Cascade delete: Hapus kamar saat kost dihapus';
  END IF;
END $$;


-- ============================================================
-- 4. PENGELUARAN -> KOST (CASCADE) - Jika ada tabel pengeluaran
-- ============================================================
-- Saat kost dihapus, semua pengeluaran kost tersebut ikut terhapus

DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'pengeluaran'
  ) THEN
    ALTER TABLE pengeluaran 
    DROP CONSTRAINT IF EXISTS pengeluaran_kost_id_fkey;
    
    ALTER TABLE pengeluaran 
    ADD CONSTRAINT pengeluaran_kost_id_fkey 
    FOREIGN KEY (kost_id) 
    REFERENCES kost(id) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE;
    
    COMMENT ON CONSTRAINT pengeluaran_kost_id_fkey ON pengeluaran 
    IS 'Cascade delete: Hapus pengeluaran saat kost dihapus';
  END IF;
END $$;


-- ============================================================
-- 5. PENGUMUMAN -> KOST (CASCADE) - Jika ada tabel pengumuman
-- ============================================================
-- Saat kost dihapus, semua pengumuman kost tersebut ikut terhapus

DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'pengumuman'
  ) THEN
    ALTER TABLE pengumuman 
    DROP CONSTRAINT IF EXISTS pengumuman_kost_id_fkey;
    
    ALTER TABLE pengumuman 
    ADD CONSTRAINT pengumuman_kost_id_fkey 
    FOREIGN KEY (kost_id) 
    REFERENCES kost(id) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE;
    
    COMMENT ON CONSTRAINT pengumuman_kost_id_fkey ON pengumuman 
    IS 'Cascade delete: Hapus pengumuman saat kost dihapus';
  END IF;
END $$;


-- ============================================================
-- 6. PERATURAN -> KOST (CASCADE) - Jika ada tabel peraturan
-- ============================================================
-- Saat kost dihapus, semua peraturan kost tersebut ikut terhapus

DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'peraturan'
  ) THEN
    ALTER TABLE peraturan 
    DROP CONSTRAINT IF EXISTS peraturan_kost_id_fkey;
    
    ALTER TABLE peraturan 
    ADD CONSTRAINT peraturan_kost_id_fkey 
    FOREIGN KEY (kost_id) 
    REFERENCES kost(id) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE;
    
    COMMENT ON CONSTRAINT peraturan_kost_id_fkey ON peraturan 
    IS 'Cascade delete: Hapus peraturan saat kost dihapus';
  END IF;
END $$;


-- ============================================================
-- 7. TAGIHAN -> KOST atau KAMAR (CASCADE) - Jika ada tabel tagihan
-- ============================================================
-- Saat kost/kamar dihapus, semua tagihan ikut terhapus

DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'tagihan'
  ) THEN
    -- Jika tagihan punya kost_id
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'tagihan' AND column_name = 'kost_id'
    ) THEN
      ALTER TABLE tagihan 
      DROP CONSTRAINT IF EXISTS tagihan_kost_id_fkey;
      
      ALTER TABLE tagihan 
      ADD CONSTRAINT tagihan_kost_id_fkey 
      FOREIGN KEY (kost_id) 
      REFERENCES kost(id) 
      ON DELETE CASCADE 
      ON UPDATE CASCADE;
    END IF;
    
    -- Jika tagihan punya kamar_id
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'tagihan' AND column_name = 'kamar_id'
    ) THEN
      ALTER TABLE tagihan 
      DROP CONSTRAINT IF EXISTS tagihan_kamar_id_fkey;
      
      ALTER TABLE tagihan 
      ADD CONSTRAINT tagihan_kamar_id_fkey 
      FOREIGN KEY (kamar_id) 
      REFERENCES kamar(id) 
      ON DELETE CASCADE 
      ON UPDATE CASCADE;
    END IF;
  END IF;
END $$;


-- ============================================================
-- 8. PENGHUNI -> KAMAR (CASCADE) - Jika ada tabel penghuni
-- ============================================================
-- Saat kamar dihapus, data penghuni di kamar tersebut ikut terhapus

DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'penghuni'
  ) THEN
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'penghuni' AND column_name = 'kamar_id'
    ) THEN
      ALTER TABLE penghuni 
      DROP CONSTRAINT IF EXISTS penghuni_kamar_id_fkey;
      
      ALTER TABLE penghuni 
      ADD CONSTRAINT penghuni_kamar_id_fkey 
      FOREIGN KEY (kamar_id) 
      REFERENCES kamar(id) 
      ON DELETE CASCADE 
      ON UPDATE CASCADE;
      
      COMMENT ON CONSTRAINT penghuni_kamar_id_fkey ON penghuni 
      IS 'Cascade delete: Hapus data penghuni saat kamar dihapus';
    END IF;
  END IF;
END $$;


-- ============================================================
-- VERIFIKASI HASIL
-- ============================================================
-- Query untuk melihat semua foreign key constraints yang sudah diupdate

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
  AND (ccu.table_name = 'kost' OR ccu.table_name = 'metode_pembayaran' OR ccu.table_name = 'kamar')
ORDER BY tc.table_name, kcu.column_name;


-- ============================================================
-- SELESAI!
-- ============================================================
-- Sekarang saat Anda hapus kost, semua data terkait akan
-- otomatis terhapus tanpa error foreign key constraint.
-- 
-- TESTING:
-- 1. Coba hapus kost yang punya data pembayaran
-- 2. Seharusnya berhasil tanpa error
-- 3. Cek tabel pembayaran, metode_pembayaran, dll - data terkait sudah terhapus
-- ============================================================
