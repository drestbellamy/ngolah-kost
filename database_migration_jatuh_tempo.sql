-- Migration: Add tanggal_jatuh_tempo and batas_pembayaran to tagihan table
-- Date: 2026-04-16

-- 1. Add new columns to tagihan table
ALTER TABLE tagihan 
ADD COLUMN IF NOT EXISTS tanggal_jatuh_tempo DATE,
ADD COLUMN IF NOT EXISTS batas_pembayaran DATE;

-- 2. Create function to calculate due dates based on move-in date
CREATE OR REPLACE FUNCTION calculate_due_dates(
  p_tanggal_masuk DATE,
  p_bulan INT,
  p_tahun INT,
  OUT tanggal_jatuh_tempo DATE,
  OUT batas_pembayaran DATE
) AS $$
DECLARE
  v_tanggal_masuk_day INT;
  v_jatuh_tempo DATE;
  v_batas_bayar DATE;
BEGIN
  -- Get day of month from move-in date
  v_tanggal_masuk_day := EXTRACT(DAY FROM p_tanggal_masuk);
  
  -- Calculate jatuh tempo (same day in the billing month)
  -- Example: masuk 1 April → tagihan bulan 5 (Mei) → jatuh tempo 1 Mei
  BEGIN
    v_jatuh_tempo := make_date(p_tahun, p_bulan, v_tanggal_masuk_day);
  EXCEPTION
    WHEN OTHERS THEN
      -- If day doesn't exist in month (e.g., 31 in Feb), use last day of month
      v_jatuh_tempo := (make_date(p_tahun, p_bulan, 1) + INTERVAL '1 month - 1 day')::DATE;
  END;
  
  -- Calculate batas pembayaran (last day of previous month)
  -- Example: jatuh tempo 1 Mei → batas bayar 30 April
  v_batas_bayar := v_jatuh_tempo - INTERVAL '1 day';
  
  tanggal_jatuh_tempo := v_jatuh_tempo;
  batas_pembayaran := v_batas_bayar;
END;
$$ LANGUAGE plpgsql;

-- 3. Update existing tagihan records with calculated due dates
DO $$
DECLARE
  rec RECORD;
  v_tanggal_masuk DATE;
  v_due_dates RECORD;
BEGIN
  FOR rec IN SELECT t.id, t.penghuni_id, t.bulan, t.tahun, p.tanggal_masuk
             FROM tagihan t
             JOIN penghuni p ON t.penghuni_id = p.id
             WHERE t.tanggal_jatuh_tempo IS NULL
  LOOP
    SELECT * INTO v_due_dates
    FROM calculate_due_dates(rec.tanggal_masuk::DATE, rec.bulan, rec.tahun);
    
    UPDATE tagihan
    SET tanggal_jatuh_tempo = v_due_dates.tanggal_jatuh_tempo,
        batas_pembayaran = v_due_dates.batas_pembayaran
    WHERE id = rec.id;
  END LOOP;
END $$;

-- 4. Create function to check if payment is late
CREATE OR REPLACE FUNCTION is_payment_late(
  p_tanggal_jatuh_tempo DATE,
  p_status TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
  -- Payment is late if:
  -- 1. Status is not 'lunas'
  -- 2. Current date is past jatuh tempo
  RETURN (p_status != 'lunas' AND CURRENT_DATE > p_tanggal_jatuh_tempo);
END;
$$ LANGUAGE plpgsql;

-- 5. Create view for tagihan with late status
CREATE OR REPLACE VIEW tagihan_with_status AS
SELECT 
  t.*,
  CASE 
    WHEN t.status = 'lunas' THEN 'lunas'
    WHEN t.status = 'menunggu_verifikasi' THEN 'menunggu_verifikasi'
    WHEN CURRENT_DATE > t.tanggal_jatuh_tempo THEN 'terlambat'
    WHEN CURRENT_DATE > t.batas_pembayaran THEN 'mendekati_jatuh_tempo'
    ELSE 'belum_dibayar'
  END as status_display,
  CASE 
    WHEN CURRENT_DATE > t.tanggal_jatuh_tempo AND t.status != 'lunas' 
    THEN CURRENT_DATE - t.tanggal_jatuh_tempo 
    ELSE 0 
  END as hari_terlambat
FROM tagihan t;

-- 6. Create trigger to auto-calculate due dates on insert
CREATE OR REPLACE FUNCTION trigger_calculate_due_dates()
RETURNS TRIGGER AS $$
DECLARE
  v_tanggal_masuk DATE;
  v_due_dates RECORD;
BEGIN
  -- Get penghuni's tanggal_masuk
  SELECT tanggal_masuk INTO v_tanggal_masuk
  FROM penghuni
  WHERE id = NEW.penghuni_id;
  
  -- Calculate due dates
  SELECT * INTO v_due_dates
  FROM calculate_due_dates(v_tanggal_masuk, NEW.bulan, NEW.tahun);
  
  -- Set the calculated dates
  NEW.tanggal_jatuh_tempo := v_due_dates.tanggal_jatuh_tempo;
  NEW.batas_pembayaran := v_due_dates.batas_pembayaran;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists and create new one
DROP TRIGGER IF EXISTS trg_calculate_due_dates ON tagihan;
CREATE TRIGGER trg_calculate_due_dates
  BEFORE INSERT ON tagihan
  FOR EACH ROW
  EXECUTE FUNCTION trigger_calculate_due_dates();

-- 7. Comments for documentation
COMMENT ON COLUMN tagihan.tanggal_jatuh_tempo IS 'Tanggal jatuh tempo pembayaran (same day as tanggal_masuk in billing month)';
COMMENT ON COLUMN tagihan.batas_pembayaran IS 'Batas akhir pembayaran (1 day before tanggal_jatuh_tempo)';
COMMENT ON FUNCTION calculate_due_dates IS 'Calculate due dates based on move-in date and billing period';
COMMENT ON FUNCTION is_payment_late IS 'Check if payment is late based on due date and status';
