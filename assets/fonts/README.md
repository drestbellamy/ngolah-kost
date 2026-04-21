# Font Setup Instructions

## Font yang Digunakan

Aplikasi ini menggunakan:
- **Roboto (via Google Fonts)** - untuk Header dan Sub Judul (pengganti Helvetica)
- **SF Pro (file lokal)** - untuk Deskripsi dan Body Text

## Setup SF Pro Font

### 1. Struktur Folder yang Dibutuhkan

Buat struktur folder berikut dan letakkan file SF Pro Anda:

```
assets/fonts/SFPro/
├── SF-Pro-Display-Regular.otf
├── SF-Pro-Display-Bold.otf
├── SF-Pro-Display-Medium.otf
├── SF-Pro-Display-Semibold.otf
└── SF-Pro-Display-Light.otf
```

### 2. File SF Pro yang Dibutuhkan

Dari download SF Pro di Apple Developer, cari file-file ini:
- `SF-Pro-Display-Regular.otf` (weight 400)
- `SF-Pro-Display-Light.otf` (weight 300)
- `SF-Pro-Display-Medium.otf` (weight 500)
- `SF-Pro-Display-Semibold.otf` (weight 600)
- `SF-Pro-Display-Bold.otf` (weight 700)

Copy file-file tersebut ke folder `assets/fonts/SFPro/`

### 3. Install Dependencies

Jalankan command berikut untuk install Google Fonts:

```bash
flutter pub get
```

### 4. Test Font

Setelah setup, restart aplikasi Anda. Font akan otomatis diterapkan:
- Header & Sub Judul → Roboto (mirip Helvetica)
- Deskripsi & Body Text → SF Pro

## Cara Menggunakan Font di Widget

Font sudah dikonfigurasi di theme, jadi Anda tinggal gunakan:

```dart
// Header
Text('Header', style: Theme.of(context).textTheme.headlineLarge)

// Sub Judul
Text('Sub Judul', style: Theme.of(context).textTheme.titleMedium)

// Deskripsi
Text('Deskripsi', style: Theme.of(context).textTheme.bodyMedium)
```

## Troubleshooting

Jika font SF Pro tidak muncul:
1. Pastikan file .otf ada di folder `assets/fonts/SFPro/`
2. Pastikan nama file sesuai dengan yang di `pubspec.yaml`
3. Jalankan `flutter clean` kemudian `flutter pub get`
4. Restart aplikasi (hot reload tidak cukup untuk font changes)
