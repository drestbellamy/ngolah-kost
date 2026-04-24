-- ============================================================
-- CEK SEMUA FOREIGN KEY CONSTRAINTS
-- ============================================================
-- Script ini untuk melihat SEMUA foreign key di database
-- dan mengidentifikasi mana yang masih RESTRICT/NO ACTION
-- ============================================================

-- ============================================================
-- 1. CEK SEMUA FOREIGN KEY (OVERVIEW)
-- ============================================================

SELECT 
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  rc.delete_rule,
  rc.update_rule,
  CASE 
    WHEN rc.delete_rule = 'CASCADE' THEN '✅ OK'
    WHEN rc.delete_rule = 'NO ACTION' THEN '⚠️ NO ACTION'
    WHEN rc.delete_rule = 'RESTRICT' THEN '⚠️ RESTRICT'
    WHEN rc.delete_rule = 'SET NULL' THEN '⚠️ SET NULL'
    ELSE '❓ UNKNOWN'
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
ORDER BY 
  CASE 
    WHEN rc.delete_rule = 'CASCADE' THEN 2
    ELSE 1
  END,
  tc.table_name, 
  kcu.column_name;


-- ============================================================
-- 2. CEK FOREIGN KEY YANG BELUM CASCADE (PRIORITAS TINGGI)
-- ============================================================

SELECT 
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  rc.delete_rule,
  '⚠️ PERLU DIUBAH KE CASCADE' AS action_needed
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
  AND rc.delete_rule != 'CASCADE'
  AND ccu.table_name IN ('kost', 'kamar', 'penghuni', 'metode_pembayaran', 'pembayaran')
ORDER BY tc.table_name, kcu.column_name;


-- ============================================================
-- 3. CEK CHAIN CASCADE (KOST -> ... -> PEMBAYARAN)
-- ============================================================
-- Melihat alur cascade dari kost sampai ke tabel-tabel terkait

SELECT 
  'kost → ' || tc.table_name AS cascade_chain,
  kcu.column_name,
  rc.delete_rule,
  CASE 
    WHEN rc.delete_rule = 'CASCADE' THEN '✅'
    ELSE '❌'
  END AS ok
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'kost'

UNION ALL

SELECT 
  'kamar → ' || tc.table_name AS cascade_chain,
  kcu.column_name,
  rc.delete_rule,
  CASE 
    WHEN rc.delete_rule = 'CASCADE' THEN '✅'
    ELSE '❌'
  END AS ok
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'kamar'

UNION ALL

SELECT 
  'penghuni → ' || tc.table_name AS cascade_chain,
  kcu.column_name,
  rc.delete_rule,
  CASE 
    WHEN rc.delete_rule = 'CASCADE' THEN '✅'
    ELSE '❌'
  END AS ok
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'penghuni'

UNION ALL

SELECT 
  'metode_pembayaran → ' || tc.table_name AS cascade_chain,
  kcu.column_name,
  rc.delete_rule,
  CASE 
    WHEN rc.delete_rule = 'CASCADE' THEN '✅'
    ELSE '❌'
  END AS ok
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'metode_pembayaran'

UNION ALL

SELECT 
  'pembayaran → ' || tc.table_name AS cascade_chain,
  kcu.column_name,
  rc.delete_rule,
  CASE 
    WHEN rc.delete_rule = 'CASCADE' THEN '✅'
    ELSE '❌'
  END AS ok
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'pembayaran'

ORDER BY cascade_chain;


-- ============================================================
-- SELESAI!
-- ============================================================
-- Gunakan hasil query ini untuk mengidentifikasi
-- foreign key mana saja yang masih perlu diubah ke CASCADE
-- ============================================================
