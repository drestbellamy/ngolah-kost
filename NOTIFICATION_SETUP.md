# Setup Notifikasi Badge untuk Navbar

## Fitur
- Badge merah (dot) muncul pada icon Tagihan jika ada tagihan baru yang belum dilihat
- Badge merah (dot) muncul pada icon Info jika ada pengumuman/peraturan baru yang belum dilihat
- Badge hilang otomatis setelah user membuka halaman tersebut
- Notifikasi di-refresh setiap kali user kembali ke halaman Home

## Setup Database

### 1. Jalankan SQL Migration
Buka Supabase Dashboard → SQL Editor, lalu jalankan script berikut:

```sql
-- Create table for tracking user notification status
CREATE TABLE IF NOT EXISTS user_notification_status (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  last_seen_tagihan TIMESTAMP WITH TIME ZONE,
  last_seen_info TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_notification_status_user_id ON user_notification_status(user_id);

-- Note: RLS is disabled since you're not using Supabase Auth
-- Make sure to handle security at the application level
```

**PENTING**: Karena tidak menggunakan Supabase Auth, RLS (Row Level Security) tidak diaktifkan. Pastikan keamanan ditangani di level aplikasi dengan selalu menggunakan `user_id` dari `AuthController.currentUser.id`.

### 2. Verifikasi Tabel
Pastikan tabel `user_notification_status` sudah terbuat dengan struktur:
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key ke users table)
- `last_seen_tagihan` (Timestamp)
- `last_seen_info` (Timestamp)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

## Cara Kerja

### Tagihan Badge
1. Badge muncul jika ada tagihan dengan status `pending` yang dibuat setelah `last_seen_tagihan`
2. Badge hilang saat user membuka halaman Tagihan
3. Timestamp `last_seen_tagihan` di-update otomatis

### Info Badge
1. Badge muncul jika ada pengumuman atau peraturan yang dibuat setelah `last_seen_info`
2. Badge hilang saat user membuka halaman Info
3. Timestamp `last_seen_info` di-update otomatis

### Refresh Notifikasi
- Notifikasi di-check ulang setiap kali user membuka halaman Home
- Ini memastikan badge selalu up-to-date dengan data terbaru

## Testing

### Test Tagihan Badge
1. Login sebagai user
2. Buka halaman Home - badge Tagihan seharusnya muncul jika ada tagihan pending
3. Klik icon Tagihan - badge seharusnya hilang
4. Kembali ke Home - badge tidak muncul lagi (kecuali ada tagihan baru)

### Test Info Badge
1. Login sebagai admin, tambahkan pengumuman atau peraturan baru
2. Login sebagai user, buka halaman Home - badge Info seharusnya muncul
3. Klik icon Info - badge seharusnya hilang
4. Kembali ke Home - badge tidak muncul lagi (kecuali ada info baru)

## Troubleshooting

### Badge tidak muncul
- Pastikan tabel `user_notification_status` sudah dibuat
- Pastikan RLS policies sudah di-enable
- Check console log untuk error messages

### Badge tidak hilang setelah dibuka
- Pastikan `markTagihanAsSeen()` atau `markInfoAsSeen()` dipanggil di controller
- Check apakah NotificationController sudah ter-register di GetX

### Badge muncul terus meskipun tidak ada data baru
- Check timestamp di tabel `user_notification_status`
- Pastikan `created_at` di tabel tagihan/pengumuman/peraturan sudah benar
