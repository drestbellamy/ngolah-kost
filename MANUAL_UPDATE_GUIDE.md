# Panduan Update Manual Responsive

## ✅ Status Saat Ini
- **0 errors** - Aplikasi berjalan dengan baik
- **10 files** sudah responsive
- **18 files** perlu update manual

## 🎯 Strategi Update yang Aman

### Langkah-langkah untuk Setiap File:

#### 1. Buka File
```bash
code lib/app/modules/[module]/views/[file].dart
```

#### 2. Tambah Import (jika belum ada)
```dart
import '../../../core/utils/responsive_utils.dart';
```

#### 3. Update HANYA di dalam `build()` method

**✅ AMAN - Di dalam build() method:**
```dart
@override
Widget build(BuildContext context) {
  return Container(
    padding: context.allPadding(20),  // ✅ OK - context ada
    child: Text(
      'Hello',
      style: TextStyle(fontSize: context.fontSize(16)),  // ✅ OK
    ),
  );
}
```

**❌ TIDAK AMAN - Di helper method:**
```dart
Widget _buildCard() {  // ❌ Tidak ada BuildContext parameter
  return Container(
    padding: context.allPadding(20),  // ❌ ERROR - context tidak ada!
  );
}
```

**✅ SOLUSI untuk Helper Method:**
```dart
// Option 1: Tambah parameter
Widget _buildCard(BuildContext context) {  // ✅ Tambah parameter
  return Container(
    padding: context.allPadding(20),  // ✅ OK sekarang
  );
}

// Lalu update semua pemanggilan:
_buildCard(context)  // Tambah context

// Option 2: Gunakan Builder
Widget _buildCard() {
  return Builder(
    builder: (context) => Container(  // ✅ context dari Builder
      padding: context.allPadding(20),
    ),
  );
}
```

#### 4. Replacements yang Aman

**Padding & Spacing:**
```dart
// Before
const EdgeInsets.all(20)
const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
const SizedBox(height: 16)

// After
context.allPadding(20)
context.symmetricPadding(horizontal: 24, vertical: 16)
SizedBox(height: context.spacing(16))
```

**Border Radius:**
```dart
// Before
BorderRadius.circular(12)

// After
BorderRadius.circular(context.borderRadius(12))
```

**Font Size:**
```dart
// Before
TextStyle(fontSize: 16)

// After
TextStyle(fontSize: context.fontSize(16))
```

**Icon Size:**
```dart
// Before
Icon(Icons.check, size: 24)

// After
Icon(Icons.check, size: context.iconSize(24))
```

**Deprecated Method:**
```dart
// Before
Colors.black.withOpacity(0.5)

// After
Colors.black.withValues(alpha: 0.5)
```

#### 5. Test Setelah Update
```bash
flutter analyze
```

Jika ada error "Undefined name 'context'", berarti ada yang salah - revert dan coba lagi.

---

## 📋 Daftar File yang Perlu Diupdate

### Priority 1: User Views (Paling Penting)

#### A. user_tagihan (+ 9 widget files)
```
lib/app/modules/user_tagihan/views/user_tagihan_view.dart
lib/app/modules/user_tagihan/views/widgets/tagihan_total_card.dart ✅ DONE
lib/app/modules/user_tagihan/views/widgets/tagihan_list_section.dart
lib/app/modules/user_tagihan/views/widgets/tagihan_card.dart
lib/app/modules/user_tagihan/views/widgets/payment_method_section.dart
lib/app/modules/user_tagihan/views/widgets/payment_method_option.dart
lib/app/modules/user_tagihan/views/widgets/upload_bottom_sheet.dart
lib/app/modules/user_tagihan/views/widgets/qris_info.dart
lib/app/modules/user_tagihan/views/widgets/transfer_bank_info.dart
lib/app/modules/user_tagihan/views/widgets/tunai_info.dart
```

#### B. user_history_pembayaran (+ 4 widget files)
```
lib/app/modules/user_history_pembayaran/views/user_history_pembayaran_view.dart
lib/app/modules/user_history_pembayaran/views/widgets/total_payment_card.dart
lib/app/modules/user_history_pembayaran/views/widgets/filter_tabs.dart
lib/app/modules/user_history_pembayaran/views/widgets/payment_card.dart
lib/app/modules/user_history_pembayaran/views/widgets/payment_history_list.dart
```

#### C. user_info (+ 4 widget files)
```
lib/app/modules/user_info/views/user_info_view.dart
lib/app/modules/user_info/views/widgets/tab_selector.dart
lib/app/modules/user_info/views/widgets/pengumuman_card.dart
lib/app/modules/user_info/views/widgets/peraturan_card.dart
lib/app/modules/user_info/views/widgets/info_content_section.dart
```

### Priority 2: Admin Views

```
lib/app/modules/penghuni/views/penghuni_detail_view.dart
lib/app/modules/profil/views/profil_view.dart
lib/app/modules/metode_pembayaran/views/metode_pembayaran_view.dart
lib/app/modules/metode_pembayaran/views/tambah_metode_pembayaran_view.dart
```

### Priority 3: Management Views

```
lib/app/modules/kelola_pengumuman/views/kelola_pengumuman_view.dart
lib/app/modules/kelola_peraturan/views/kelola_peraturan_view.dart
lib/app/modules/kelola_tagihan/views/kelola_tagihan_view.dart
lib/app/modules/ringkasan_keuangan/views/ringkasan_keuangan_view.dart
lib/app/modules/ringkasan_keuangan/views/detail_keuangan_kost_view.dart
lib/app/modules/kost/views/add_kost_view.dart
lib/app/modules/kost/views/edit_kost_view.dart
lib/app/modules/kost/views/map_picker_view.dart
lib/app/modules/kost_map/views/kost_map_view.dart
lib/app/modules/kamar/views/informasi_kamar_view.dart
lib/app/modules/kamar/views/tambah_penghuni_view.dart
```

---

## ⚠️ Hal yang Harus Dihindari

### 1. Jangan Update Const Widgets
```dart
// ❌ JANGAN
const Text('Hello', style: TextStyle(fontSize: context.fontSize(16)))

// ✅ LAKUKAN
Text('Hello', style: TextStyle(fontSize: context.fontSize(16)))
// (hapus const)
```

### 2. Jangan Update di Luar build()
```dart
// ❌ JANGAN - Di class level
class MyWidget extends StatelessWidget {
  final padding = context.allPadding(20);  // ❌ ERROR
}

// ✅ LAKUKAN - Di dalam build()
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final padding = context.allPadding(20);  // ✅ OK
  }
}
```

### 3. Jangan Update Helper Method Tanpa Context
```dart
// ❌ JANGAN
Widget _buildCard() {
  return Container(padding: context.allPadding(20));  // ❌ ERROR
}

// ✅ LAKUKAN
Widget _buildCard(BuildContext context) {
  return Container(padding: context.allPadding(20));  // ✅ OK
}
```

---

## 🔍 Debugging Tips

### Error: "Undefined name 'context'"
**Penyebab:** Menggunakan context di tempat yang tidak punya akses ke BuildContext

**Solusi:**
1. Cek apakah di dalam `build()` method
2. Jika di helper method, tambah parameter `BuildContext context`
3. Atau gunakan `Builder` widget

### Error: "Methods can't be invoked in constant expressions"
**Penyebab:** Menggunakan context method di const widget

**Solusi:**
1. Hapus keyword `const`
2. Atau jangan gunakan responsive method di widget tersebut

### Error: "Invalid constant value"
**Penyebab:** Sama seperti di atas

**Solusi:** Hapus `const`

---

## ✅ Checklist Per File

Untuk setiap file yang diupdate:

- [ ] Tambah import responsive_utils.dart
- [ ] Update padding/spacing di build() method
- [ ] Update fontSize di build() method
- [ ] Update borderRadius di build() method
- [ ] Update iconSize di build() method
- [ ] Replace .withOpacity dengan .withValues
- [ ] Hapus const dari widget yang diupdate
- [ ] Run `flutter analyze`
- [ ] Pastikan 0 errors
- [ ] Test di emulator (optional)
- [ ] Commit changes

---

## 📊 Progress Tracking

Gunakan file ini untuk track progress:

```
✅ = Done
⏳ = In Progress
❌ = Not Started

Priority 1:
✅ tagihan_total_card.dart
❌ tagihan_list_section.dart
❌ tagihan_card.dart
... (dst)
```

---

## 🎯 Target

**Goal:** 100% responsive (28/28 files)
**Current:** 35.7% (10/28 files)
**Remaining:** 18 files
**Estimated Time:** 3-4 hours (10 min per file)

---

## 💡 Tips

1. **Kerjakan satu file per satu** - Jangan terburu-buru
2. **Test setelah setiap file** - Jangan tunggu sampai selesai semua
3. **Commit frequently** - Mudah revert jika ada masalah
4. **Fokus pada build() method** - Jangan sentuh helper methods dulu
5. **Gunakan Find & Replace** - Tapi hati-hati dengan const widgets

---

**Good luck! 🚀**
