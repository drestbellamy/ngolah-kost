# 🗑️ CASCADE DELETE Setup untuk Kost Management App

## 📋 Daftar Isi
- [Apa itu CASCADE DELETE?](#apa-itu-cascade-delete)
- [Kenapa Perlu CASCADE DELETE?](#kenapa-perlu-cascade-delete)
- [Cara Install](#cara-install)
- [Testing](#testing)
- [Rollback](#rollback)
- [FAQ](#faq)

---

## 🤔 Apa itu CASCADE DELETE?

CASCADE DELETE adalah fitur database yang **otomatis menghapus data terkait** saat data induk dihapus.

### Contoh:
```
SEBELUM CASCADE:
Hapus Kost "Raja Kost" → ❌ ERROR
(karena masih ada pembayaran yang referensi ke kost ini)

SETELAH CASCADE:
Hapus Kost "Raja Kost" → ✅ BERHASIL
  ↓ (otomatis terhapus)
  - Metode pembayaran Raja Kost
  - Pembayaran yang pakai metode Raja Kost
  - Kamar-kamar Raja Kost
  - Penghuni di Raja Kost
  - Pengumuman Raja Kost
  - dll.
```

---

## 🎯 Kenapa Perlu CASCADE DELETE?

### ❌ Masalah Sekarang:
- Tidak bisa hapus kost yang sudah punya data pembayaran
- Muncul error: `foreign key constraint violated`
- Harus hapus manual satu-satu (ribet!)

### ✅ Setelah CASCADE DELETE:
- Hapus kost langsung berhasil
- Data terkait otomatis terhapus
- Database tetap bersih, tidak ada "orphaned data"
- Sesuai best practice

---

## 🚀 Cara Install

### ⭐ RECOMMENDED: Gunakan Script Complete (All-in-One)

1. Buka file **`database_cascade_delete_complete_fix.sql`**
2. Copy semua isinya
3. Login ke [Supabase](https://supabase.com) → Pilih project → **SQL Editor**
4. Paste script dan klik **Run** (atau tekan `Ctrl + Enter`)
5. ✅ Selesai! Semua foreign key sudah CASCADE

### Alternatif: Step-by-Step (Jika Ingin Manual)

**Step 1:** Jalankan `database_cascade_delete_setup.sql` (setup awal)
**Step 2:** Jalankan `database_cascade_delete_fix_pemasukan.sql` (fix pemasukan)
**Step 3:** Jalankan `database_cascade_delete_fix_pembayaran_penghuni.sql` (fix pembayaran-penghuni)

### Verifikasi Hasil

Setelah script selesai, akan muncul tabel hasil verifikasi. Semua harus menunjukkan `✅ OK`:

**Contoh hasil yang benar:**
```
table_name        | column_name    | foreign_table_name | delete_rule | status
------------------|----------------|-------------------|-------------|--------
kamar             | kost_id        | kost              | CASCADE     | ✅ OK
metode_pembayaran | kost_id        | kost              | CASCADE     | ✅ OK
pembayaran        | metode_id      | metode_pembayaran | CASCADE     | ✅ OK
pembayaran        | penghuni_id    | penghuni          | CASCADE     | ✅ OK
pemasukan         | pembayaran_id  | pembayaran        | CASCADE     | ✅ OK
pemasukan         | kost_id        | kost              | CASCADE     | ✅ OK
pengeluaran       | kost_id        | kost              | CASCADE     | ✅ OK
penghuni          | kamar_id       | kamar             | CASCADE     | ✅ OK
pengumuman        | kost_id        | kost              | CASCADE     | ✅ OK
peraturan         | kost_id        | kost              | CASCADE     | ✅ OK
```

Jika ada yang masih `⚠️ NO ACTION` atau `⚠️ RESTRICT`, jalankan ulang script complete fix.

---

## 🧪 Testing

### Test 1: Hapus Kost yang Punya Data
```sql
-- Sebelumnya ini akan ERROR
DELETE FROM kost WHERE nama = 'Raja Kost';
-- Sekarang harusnya BERHASIL ✅
```

### Test 2: Hapus Kamar yang Punya Penghuni
```sql
-- Hapus kamar yang ada penghuninya
DELETE FROM kamar WHERE nama = 'Kamar B1';
-- Sekarang harusnya BERHASIL ✅
-- Penghuni & pembayaran otomatis terhapus
```

### Test 3: Cek Data Terkait Sudah Terhapus
```sql
-- Cek metode pembayaran Raja Kost (harusnya kosong)
SELECT * FROM metode_pembayaran WHERE kost_id = 'id_raja_kost';

-- Cek pembayaran Raja Kost (harusnya kosong)
SELECT * FROM pembayaran 
WHERE metode_id IN (
  SELECT id FROM metode_pembayaran WHERE kost_id = 'id_raja_kost'
);
```

### Test 4: Pastikan Kost/Kamar Lain Tidak Terpengaruh
```sql
-- Kost lain harusnya masih ada
SELECT * FROM kost WHERE nama != 'Raja Kost';

-- Pembayaran kost lain harusnya masih ada
SELECT * FROM pembayaran;
```

---

## 🔄 Rollback (Jika Perlu Undo)

Jika Anda ingin mengembalikan ke setting semula (RESTRICT):

1. Buka file `database_cascade_delete_rollback.sql`
2. Copy semua isinya
3. Paste ke SQL Editor di Supabase
4. Klik **Run**

**⚠️ Warning:** Setelah rollback, Anda akan kembali tidak bisa hapus kost yang punya data pembayaran.

---

## ❓ FAQ

### Q: Apakah CASCADE DELETE aman?
**A:** Ya, sangat aman dan merupakan **best practice** untuk aplikasi seperti ini. Saat owner hapus kost, memang semua data terkait harus ikut terhapus.

### Q: Bagaimana jika saya butuh history pembayaran?
**A:** Ada 2 opsi:
1. **Export data** sebelum hapus kost (untuk backup)
2. **Gunakan Soft Delete** (tambah kolom `deleted_at` instead of hard delete)

### Q: Apakah pembayaran di kost lain terpengaruh?
**A:** **TIDAK!** CASCADE hanya menghapus data yang **terkait langsung** dengan kost yang dihapus. Kost lain 100% aman.

### Q: Bagaimana cara cek apakah CASCADE sudah aktif?
**A:** Jalankan query ini di SQL Editor:
```sql
SELECT 
  tc.table_name,
  ccu.table_name AS foreign_table_name,
  rc.delete_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND ccu.table_name = 'kost';
```
Hasilnya harus `delete_rule = CASCADE`

### Q: Apakah perlu restart aplikasi Flutter?
**A:** **TIDAK!** Ini perubahan di database, tidak perlu restart aplikasi.

### Q: Bagaimana jika ada tabel baru di masa depan?
**A:** Tambahkan constraint CASCADE saat membuat tabel baru:
```sql
CREATE TABLE tabel_baru (
  id UUID PRIMARY KEY,
  kost_id UUID REFERENCES kost(id) ON DELETE CASCADE,
  -- kolom lainnya...
);
```

---

## 📊 Tabel yang Terpengaruh

Script ini akan mengubah constraint di tabel-tabel berikut:

| Tabel | Foreign Key | Referensi | Efek |
|-------|-------------|-----------|------|
| `kamar` | `kost_id` | `kost(id)` | Hapus saat kost dihapus |
| `metode_pembayaran` | `kost_id` | `kost(id)` | Hapus saat kost dihapus |
| `penghuni` | `kamar_id` | `kamar(id)` | Hapus saat kamar dihapus |
| `pembayaran` | `metode_id` | `metode_pembayaran(id)` | Hapus saat metode dihapus |
| `pembayaran` | `penghuni_id` | `penghuni(id)` | Hapus saat penghuni dihapus |
| `pemasukan` | `kost_id` | `kost(id)` | Hapus saat kost dihapus |
| `pemasukan` | `pembayaran_id` | `pembayaran(id)` | Hapus saat pembayaran dihapus |
| `pemasukan` | `penghuni_id` | `penghuni(id)` | Hapus saat penghuni dihapus |
| `pengeluaran` | `kost_id` | `kost(id)` | Hapus saat kost dihapus |
| `pengumuman` | `kost_id` | `kost(id)` | Hapus saat kost dihapus |
| `peraturan` | `kost_id` | `kost(id)` | Hapus saat kost dihapus |
| `tagihan` | `kost_id` / `kamar_id` | `kost(id)` / `kamar(id)` | Hapus saat kost/kamar dihapus |

---

## 🎉 Selesai!

Setelah menjalankan script ini, Anda bisa hapus kost dengan bebas tanpa khawatir error foreign key constraint lagi!

**Happy Coding! 🚀**

---

## 📞 Support

Jika ada masalah atau pertanyaan, silakan:
1. Cek bagian [FAQ](#faq) di atas
2. Cek hasil verifikasi query di SQL Editor
3. Pastikan script dijalankan tanpa error

---

**Last Updated:** April 2026
**Version:** 1.0.0
