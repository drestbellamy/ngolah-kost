# Ngolah Kost - Aplikasi Manajemen Kos

Aplikasi manajemen kos (boarding house) yang digunakan oleh pemilik kos/admin untuk mengelola properti kos mereka.

## Fitur Utama

- **Home**: Dashboard dengan ringkasan informasi kos
- **Kost**: Manajemen rumah kos (tambah, edit, hapus)
- **Penghuni**: Manajemen data penghuni kos
- **Profile**: Profil admin/pemilik kos
- **Kelola Tagihan**: Manajemen tagihan penghuni
- **Kelola Pengumuman**: Manajemen pengumuman untuk penghuni
- **Kelola Peraturan**: Manajemen peraturan kos

## Teknologi

- **Flutter**: Framework UI
- **GetX**: State management, routing, dan dependency injection
- **Dart**: Bahasa pemrograman

## Struktur Project

```
lib/
├── app/
│   ├── core/
│   │   └── constants/
│   │       └── colors.dart
│   ├── modules/
│   │   ├── landing/
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── login/
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── home/
│   │   ├── kost/
│   │   ├── penghuni/
│   │   ├── profil/
│   │   ├── kelola_tagihan/
│   │   ├── kelola_pengumuman/
│   │   └── kelola_peraturan/
│   └── routes/
│       ├── app_pages.dart
│       └── app_routes.dart
└── main.dart
```

## Cara Menjalankan

1. Install dependencies:
```bash
flutter pub get
```

2. Jalankan aplikasi:
```bash
flutter run
```

## Login Credentials

- Username: `admin`
- Password: `admin`

## Status Development

- ✅ Landing Page
- ✅ Login Page
- ⏳ Home Page (In Progress)
- ⏳ Kost Management
- ⏳ Penghuni Management
- ⏳ Profile Page
- ⏳ Kelola Tagihan
- ⏳ Kelola Pengumuman
- ⏳ Kelola Peraturan
