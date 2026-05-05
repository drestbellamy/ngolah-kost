# Manual Responsive Updates - Remaining Tasks

## ✅ COMPLETED (Automatic)
Script telah berhasil mengupdate 15 files dengan:
- ✅ EdgeInsets.all() → context.allPadding()
- ✅ EdgeInsets.symmetric() → context.symmetricPadding()
- ✅ SizedBox(height/width) → context.spacing()
- ✅ BorderRadius.circular() → context.borderRadius()
- ✅ .withOpacity() → .withValues(alpha:)

## ⏳ MANUAL UPDATES NEEDED

### 1. fontSize Updates
Cari dan ganti manual di setiap file:

```dart
// Pattern to find
fontSize: 24
fontSize: 20
fontSize: 18
fontSize: 16
fontSize: 14
fontSize: 12
fontSize: 10

// Replace with
fontSize: context.fontSize(24)
fontSize: context.fontSize(20)
fontSize: context.fontSize(18)
fontSize: context.fontSize(16)
fontSize: context.fontSize(14)
fontSize: context.fontSize(12)
fontSize: context.fontSize(10)
```

### 2. Icon Size Updates
Cari pattern `size:` di dalam Icon widgets:

```dart
// Pattern to find
Icon(Icons.xxx, size: 24)
Icon(Icons.xxx, size: 20)
Icon(Icons.xxx, size: 16)

// Replace with
Icon(Icons.xxx, size: context.iconSize(24))
Icon(Icons.xxx, size: context.iconSize(20))
Icon(Icons.xxx, size: context.iconSize(16))
```

### 3. Button Height Updates
Cari pattern `height:` di button containers:

```dart
// Pattern to find
height: 56
height: 48
height: 44

// Replace with
height: context.buttonHeight(56)
height: context.buttonHeight(48)
height: context.buttonHeight(44)
```

### 4. BuildContext Issues
Jika ada error "context not found", tambahkan BuildContext:

```dart
// Option 1: Add parameter
Widget _buildCard(BuildContext context) { ... }

// Option 2: Use Builder
Builder(builder: (context) => Container(...))
```

## 📋 FILES TO MANUALLY UPDATE

1. ⏳ penghuni_detail_view.dart
2. ⏳ profil_view.dart
3. ⏳ metode_pembayaran_view.dart
4. ⏳ tambah_metode_pembayaran_view.dart
5. ⏳ ringkasan_keuangan_view.dart
6. ⏳ detail_keuangan_kost_view.dart
7. ⏳ kelola_tagihan_view.dart
8. ⏳ kelola_peraturan_view.dart
9. ⏳ kelola_pengumuman_view.dart
10. ⏳ add_kost_view.dart
11. ⏳ edit_kost_view.dart
12. ⏳ map_picker_view.dart
13. ⏳ kost_map_view.dart
14. ⏳ informasi_kamar_view.dart
15. ⏳ tambah_penghuni_view.dart

## 🔍 QUICK FIND & REPLACE

### VS Code Regex Find & Replace (Ctrl+H)

#### For fontSize:
```regex
Find: fontSize:\s*(\d+)(?!.*context)
Replace: fontSize: context.fontSize($1)
```

#### For Icon size:
```regex
Find: (Icon\([^,]+,\s*size:\s*)(\d+)(?!.*context)
Replace: $1context.iconSize($2)
```

#### For Button height:
```regex
Find: height:\s*(\d+)(?!.*context)
Replace: height: context.buttonHeight($1)
```

## ⚠️ IMPORTANT NOTES

1. **Test after each file** - Run `flutter analyze`
2. **Check BuildContext** - Make sure context is available
3. **Review changes** - Some replacements might need manual adjustment
4. **Commit frequently** - Commit after each successful file

## 🧪 TESTING

After all updates:
```bash
# Analyze code
flutter analyze

# Run on device
flutter run -d <device-id>

# Test on multiple sizes
# - iPhone SE (320px)
# - iPhone 12 (375px)
# - iPhone 14 Pro Max (428px)
# - iPad (768px+)
```

## 📊 PROGRESS TRACKING

Update this as you complete each file:
- [ ] penghuni_detail_view.dart
- [ ] profil_view.dart
- [ ] metode_pembayaran_view.dart
- [ ] tambah_metode_pembayaran_view.dart
- [ ] ringkasan_keuangan_view.dart
- [ ] detail_keuangan_kost_view.dart
- [ ] kelola_tagihan_view.dart
- [ ] kelola_peraturan_view.dart
- [ ] kelola_pengumuman_view.dart
- [ ] add_kost_view.dart
- [ ] edit_kost_view.dart
- [ ] map_picker_view.dart
- [ ] kost_map_view.dart
- [ ] informasi_kamar_view.dart
- [ ] tambah_penghuni_view.dart

## ✨ COMPLETION

When all files are done:
1. Run `flutter analyze` - should have no errors
2. Test on all device sizes
3. Update RESPONSIVE_FINAL_STATUS.md
4. Commit with message: "feat: complete responsive design for all 33 files"

