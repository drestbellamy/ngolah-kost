-- ============================================================
-- ROLLBACK CASCADE DELETE - Kembali ke RESTRICT (Default)
-- ============================================================
-- Script ini untuk mengembalikan foreign key constraints
-- ke mode RESTRICT (default) jika Anda ingin undo CASCADE DELETE
-- 
-- CARA PAKAI:
-- 1. Buka Supabase Dashboard
-- 2. Pergi ke SQL Editor
-- 3. Copy-paste script ini
-- 4. Klik "Run" atau tekan Ctrl+Enter
-- ============================================================

-- ============================================================
-- 1. METODE_PEMBAYARAN -> KOST (RESTRICT)
-- ============================================================

ALTER TABLE metode_pembayaran 
DROP CONSTRAINT IF EXISTS metode_pembayaran_kost_id_fkey;

ALTER TABLE metode_pembayaran 
ADD CONSTRAINT metode_pembayaran_kost_id_fkey 
FOREIGN KEY (kost_id) 
REFERENCES kost(id) 
ON DELETE RESTRICT 
ON UPDATE CASCADE;


-- ============================================================
-- 2. PEMBAYARAN -> METODE_PEMBAYARAN (RESTRICT)
-- ============================================================

ALTER TABLE pembayaran 
DROP CONSTRAINT IF EXISTS pembayaran_metode_id_fkey;

ALTER TABLE pembayaran 
ADD CONSTRAINT pembayaran_metode_id_fkey 
FOREIGN KEY (metode_id) 
REFERENCES metode_pembayaran(id) 
ON DELETE RESTRICT 
ON UPDATE CASCADE;


-- ============================================================
-- 3. KAMAR -> KOST (RESTRICT)
-- ============================================================

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
    ON DELETE RESTRICT 
    ON UPDATE CASCADE;
  END IF;
END $$;


-- ============================================================
-- 4. PENGELUARAN -> KOST (RESTRICT)
-- ============================================================

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
    ON DELETE RESTRICT 
    ON UPDATE CASCADE;
  END IF;
END $$;


-- ============================================================
-- 5. PENGUMUMAN -> KOST (RESTRICT)
-- ============================================================

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
    ON DELETE RESTRICT 
    ON UPDATE CASCADE;
  END IF;
END $$;


-- ============================================================
-- 6. PERATURAN -> KOST (RESTRICT)
-- ============================================================

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
    ON DELETE RESTRICT 
    ON UPDATE CASCADE;
  END IF;
END $$;


-- ============================================================
-- 7. TAGIHAN -> KOST/KAMAR (RESTRICT)
-- ============================================================

DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name = 'tagihan'
  ) THEN
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
      ON DELETE RESTRICT 
      ON UPDATE CASCADE;
    END IF;
    
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
      ON DELETE RESTRICT 
      ON UPDATE CASCADE;
    END IF;
  END IF;
END $$;


-- ============================================================
-- 8. PENGHUNI -> KAMAR (RESTRICT)
-- ============================================================

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
      ON DELETE RESTRICT 
      ON UPDATE CASCADE;
    END IF;
  END IF;
END $$;


-- ============================================================
-- VERIFIKASI HASIL
-- ============================================================

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
-- SELESAI! Constraints sudah kembali ke RESTRICT
-- ============================================================
