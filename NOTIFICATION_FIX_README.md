# Fix: Badge Notifikasi Tidak Hilang Setelah Restart

## 🐛 Masalah

Badge merah notifikasi di navbar INFO tidak hilang setelah:
1. User membuka halaman Info (badge hilang sementara)
2. User close aplikasi
3. User buka aplikasi lagi (badge muncul lagi ❌)

## 🔍 Root Cause

### Masalah di Database Schema:
- Tabel `user_notification_status` hanya punya kolom `last_seen_info`
- Kolom ini digunakan untuk menyimpan **satu ID** (pengumuman ATAU peraturan)
- Ketika ada pengumuman baru DAN peraturan baru, hanya satu yang tersimpan
- Saat restart, sistem mendeteksi ada item yang belum "seen" → badge muncul lagi

### Masalah di Code:
```dart
// ❌ SEBELUM: Hanya simpan satu ID
await supabase.from('user_notification_status').upsert({
  'user_id': userId,
  'last_seen_info': lastSeenPengumumanId.value ?? lastSeenPeraturanId.value,
});
```

## ✅ Solusi

### 1. Update Database Schema

Menambahkan dua kolom terpisah:
- `last_seen_pengumuman` → untuk tracking pengumuman
- `last_seen_peraturan` → untuk tracking peraturan

**Jalankan SQL Migration:**
```bash
# File: database_migration_notification_fix.sql
```

SQL akan:
- ✅ Menambahkan kolom `last_seen_pengumuman`
- ✅ Menambahkan kolom `last_seen_peraturan`
- ✅ Migrasi data dari `last_seen_info` (jika ada)
- ✅ Menambahkan index untuk performa
- ✅ Menambahkan foreign key constraint

### 2. Update Code

**File: `lib/app/core/controllers/notification_controller.dart`**

#### A. Load Last Seen IDs
```dart
// ✅ SESUDAH: Load kedua ID terpisah
Future<void> loadLastSeenIds() async {
  final data = await supabase
      .from('user_notification_status')
      .select('last_seen_tagihan, last_seen_pengumuman, last_seen_peraturan')
      .eq('user_id', userId)
      .maybeSingle();

  if (data != null) {
    lastSeenPengumumanId.value = data['last_seen_pengumuman']?.toString();
    lastSeenPeraturanId.value = data['last_seen_peraturan']?.toString();
  }
}
```

#### B. Mark Info as Seen
```dart
// ✅ SESUDAH: Simpan kedua ID terpisah
Future<void> markInfoAsSeen() async {
  // Get latest IDs
  String? latestPengumumanId = ...;
  String? latestPeraturanId = ...;

  // Save BOTH IDs
  await supabase.from('user_notification_status').upsert({
    'user_id': userId,
    'last_seen_pengumuman': latestPengumumanId,
    'last_seen_peraturan': latestPeraturanId,
  });
}
```

## 📋 Cara Testing

### Test 1: Badge Hilang Setelah Buka Info
1. Login sebagai user
2. Lihat badge merah di navbar Info (misal angka "2")
3. Klik navbar Info
4. ✅ Badge hilang

### Test 2: Badge Tetap Hilang Setelah Restart
1. Lanjut dari Test 1
2. Close aplikasi (force close)
3. Buka aplikasi lagi
4. Login sebagai user yang sama
5. ✅ Badge TIDAK muncul lagi (tetap hilang)

### Test 3: Badge Muncul untuk Item Baru
1. Admin tambah pengumuman baru
2. User refresh atau restart app
3. ✅ Badge muncul dengan angka "1"
4. User klik navbar Info
5. ✅ Badge hilang
6. Restart app
7. ✅ Badge tetap hilang

### Test 4: Multiple Items
1. Admin tambah 2 pengumuman dan 1 peraturan
2. User login
3. ✅ Badge muncul dengan angka "3"
4. User klik navbar Info
5. ✅ Badge hilang
6. Restart app
7. ✅ Badge tetap hilang

## 🔄 Flow Lengkap

### Saat Login:
```
1. NotificationController.onInit()
   └─> loadLastSeenIds()
       └─> Load last_seen_pengumuman & last_seen_peraturan dari DB

2. checkInfoNotification()
   └─> Query semua pengumuman & peraturan
   └─> Count items yang ID-nya > last_seen_pengumuman
   └─> Count items yang ID-nya > last_seen_peraturan
   └─> infoNotificationCount = total count
   └─> hasInfoNotification = count > 0
```

### Saat Buka Halaman Info:
```
1. UserInfoController.onInit()
   └─> Future.delayed(100ms)
       └─> _markInfoAsSeen()

2. _markInfoAsSeen()
   └─> Get latest pengumuman ID
   └─> Get latest peraturan ID
   └─> Save BOTH IDs to database
   └─> hasInfoNotification = false
   └─> infoNotificationCount = 0
```

### Saat Restart App:
```
1. Login
   └─> loadLastSeenIds()
       └─> Load last_seen_pengumuman = "123"
       └─> Load last_seen_peraturan = "456"

2. checkInfoNotification()
   └─> Query pengumuman (latest ID = "123")
   └─> No new items (123 == 123) ✅
   └─> Query peraturan (latest ID = "456")
   └─> No new items (456 == 456) ✅
   └─> infoNotificationCount = 0
   └─> hasInfoNotification = false
   └─> Badge TIDAK muncul ✅
```

## 📊 Database Schema

### Before:
```sql
CREATE TABLE user_notification_status (
  user_id UUID PRIMARY KEY,
  last_seen_tagihan TEXT,
  last_seen_info TEXT,  -- ❌ Hanya satu kolom
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### After:
```sql
CREATE TABLE user_notification_status (
  user_id UUID PRIMARY KEY,
  last_seen_tagihan TEXT,
  last_seen_pengumuman TEXT,  -- ✅ Terpisah
  last_seen_peraturan TEXT,   -- ✅ Terpisah
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## 🎯 Benefits

1. ✅ **Akurat**: Tracking terpisah untuk pengumuman dan peraturan
2. ✅ **Persistent**: Badge status tersimpan dengan benar di database
3. ✅ **Reliable**: Tidak ada false positive setelah restart
4. ✅ **Scalable**: Mudah menambah tracking untuk tipe notifikasi lain
5. ✅ **Debuggable**: Log yang jelas untuk troubleshooting

## 🚀 Deployment Steps

1. **Backup Database** (penting!)
   ```sql
   -- Backup tabel
   CREATE TABLE user_notification_status_backup AS 
   SELECT * FROM user_notification_status;
   ```

2. **Run Migration**
   ```sql
   -- Jalankan file: database_migration_notification_fix.sql
   ```

3. **Verify Migration**
   ```sql
   -- Check kolom baru ada
   SELECT column_name FROM information_schema.columns
   WHERE table_name = 'user_notification_status';
   ```

4. **Deploy Code**
   - Push perubahan ke repository
   - Build dan deploy aplikasi

5. **Test**
   - Test dengan user yang sudah pernah buka Info
   - Test dengan user baru
   - Test restart aplikasi

## 📝 Notes

- Migration SQL aman dijalankan multiple kali (idempotent)
- Data existing akan dimigrasi otomatis
- Backward compatible (tidak break existing data)
- Menambahkan logging untuk debugging

## 🔗 Related Files

- `lib/app/core/controllers/notification_controller.dart`
- `lib/app/modules/user_info/controllers/user_info_controller.dart`
- `database_migration_notification_fix.sql`
