# Kelola Pengumuman Widgets

Folder ini berisi widget-widget yang digunakan di halaman Kelola Pengumuman untuk clean code dan reusability.

## Widget List

### 1. `gedung_card_widget.dart`
Widget untuk menampilkan card gedung kost di halaman pilih gedung.

**Props:**
- `gedung`: GedungKostModel data
- `totalPengumuman`: Jumlah pengumuman untuk gedung ini
- `onTap`: Callback ketika card diklik

**Features:**
- Icon gedung
- Nama dan alamat gedung
- Badge jumlah kamar
- Badge jumlah pengumuman dengan color coding
- Chevron icon

### 2. `pengumuman_card_widget.dart`
Widget untuk menampilkan card pengumuman individual.

**Props:**
- `item`: PengumumanModel data
- `onTap`: Callback untuk melihat detail
- `onEdit`: Callback untuk edit
- `onDelete`: Callback untuk hapus

**Features:**
- Judul dan deskripsi pengumuman
- Button edit dan delete
- Info kost dan tanggal
- Truncate text dengan ellipsis

### 3. `empty_state_widget.dart`
Widget untuk menampilkan empty state ketika belum ada pengumuman.

**Props:**
- `message`: Pesan yang ditampilkan (optional, ada default)

**Features:**
- Container putih dengan border
- Text centered
- Customizable message

### 4. `error_state_widget.dart`
Widget untuk menampilkan error state.

**Props:**
- `message`: Pesan error yang ditampilkan

**Features:**
- Container putih dengan border
- Text merah centered
- Error styling

### 5. `info_banner_widget.dart`
Widget untuk menampilkan info banner di dialog.

**Props:**
- `namaGedung`: Nama gedung (optional)

**Features:**
- Background biru muda
- Icon info
- Dynamic message berdasarkan namaGedung

### 6. `form_helpers.dart` ⭐ NEW!
Helper class untuk menghilangkan duplicate code di dialog-dialog.

**Static Methods:**
- `inputDecoration(String hint)` - Input decoration yang konsisten
- `validateJudul(String? value)` - Validator untuk judul (min 5 karakter)
- `validateDeskripsi(String? value)` - Validator untuk deskripsi (min 10 karakter)
- `showFormException(Object error, String fallbackMessage)` - Error handling yang konsisten

**Benefits:**
- ✅ Menghilangkan duplicate code
- ✅ Konsistensi styling di semua form
- ✅ Mudah untuk update validation rules
- ✅ Single source of truth

---

## Dialogs

### 7. `detail_pengumuman_dialog.dart`
Dialog untuk menampilkan detail lengkap pengumuman.

**Props:**
- `item`: PengumumanModel data

**Static Method:**
```dart
DetailPengumumanDialog.show(pengumumanModel);
```

**Features:**
- Info banner
- Display judul dan deskripsi
- Info kost dan tanggal
- Button tutup

### 8. `add_pengumuman_dialog.dart`
Dialog untuk menambah pengumuman baru.

**Static Method:**
```dart
AddPengumumanDialog.show();
```

**Features:**
- Form dengan validation (menggunakan FormHelpers)
- Input judul (max 80 karakter, min 5)
- Input deskripsi (max 500 karakter, min 10)
- Info banner
- Loading state saat menyimpan
- Error handling (menggunakan FormHelpers)

### 9. `edit_pengumuman_dialog.dart`
Dialog untuk mengedit pengumuman yang sudah ada.

**Props:**
- `item`: PengumumanModel data

**Static Method:**
```dart
EditPengumumanDialog.show(pengumumanModel);
```

**Features:**
- Form pre-filled dengan data existing
- Validation menggunakan FormHelpers
- Info banner
- Loading state saat menyimpan
- Error handling (menggunakan FormHelpers)

### 10. `delete_pengumuman_dialog.dart`
Dialog konfirmasi untuk menghapus pengumuman.

**Props:**
- `pengumumanId`: ID pengumuman yang akan dihapus

**Static Method:**
```dart
DeletePengumumanDialog.show(pengumumanId);
```

**Features:**
- Confirmation message
- Button cancel dan delete
- Loading state saat menghapus
- Error handling (menggunakan FormHelpers)
- Destructive action styling (red button)

---

## Usage Example

### Cards & States
```dart
import 'widgets/gedung_card_widget.dart';
import 'widgets/pengumuman_card_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/error_state_widget.dart';

// Gedung Card
GedungCardWidget(
  gedung: gedungModel,
  totalPengumuman: 5,
  onTap: () => controller.pilihGedungKost(gedung),
)

// Pengumuman Card
PengumumanCardWidget(
  item: pengumumanModel,
  onTap: () => DetailPengumumanDialog.show(item),
  onEdit: () => EditPengumumanDialog.show(item),
  onDelete: () => DeletePengumumanDialog.show(item.id),
)

// Empty State
const EmptyStateWidget()

// Error State
ErrorStateWidget(message: 'Terjadi kesalahan')
```

### Dialogs
```dart
import 'widgets/detail_pengumuman_dialog.dart';
import 'widgets/add_pengumuman_dialog.dart';
import 'widgets/edit_pengumuman_dialog.dart';
import 'widgets/delete_pengumuman_dialog.dart';

// Show Detail
DetailPengumumanDialog.show(pengumumanModel);

// Show Add
AddPengumumanDialog.show();

// Show Edit
EditPengumumanDialog.show(pengumumanModel);

// Show Delete
DeletePengumumanDialog.show(pengumumanId);
```

### Using FormHelpers
```dart
import 'widgets/form_helpers.dart';

// Input decoration
TextFormField(
  decoration: FormHelpers.inputDecoration('Hint text'),
  validator: FormHelpers.validateJudul,
)

// Error handling
try {
  // some operation
} catch (e) {
  FormHelpers.showFormException(e, 'Fallback error message');
}
```

---

## Benefits

✅ **Clean Code** - File view utama bisa dikurangi dari 1154 baris  
✅ **No Duplicate Code** - FormHelpers menghilangkan duplikasi  
✅ **Reusable** - Widget dan dialog bisa digunakan di tempat lain  
✅ **Maintainable** - Mudah untuk update styling dan logic  
✅ **Testable** - Setiap widget/dialog bisa di-test terpisah  
✅ **Organized** - Setiap widget punya tanggung jawab yang jelas  
✅ **Consistent** - Semua dialog menggunakan pattern yang sama  
✅ **DRY Principle** - Don't Repeat Yourself

---

## File Structure

```
lib/app/modules/kelola_pengumuman/views/
├── kelola_pengumuman_view.dart (bisa dikurangi drastis)
└── widgets/
    ├── gedung_card_widget.dart
    ├── pengumuman_card_widget.dart
    ├── empty_state_widget.dart
    ├── error_state_widget.dart
    ├── info_banner_widget.dart
    ├── form_helpers.dart ⭐ NEW!
    ├── detail_pengumuman_dialog.dart
    ├── add_pengumuman_dialog.dart
    ├── edit_pengumuman_dialog.dart
    ├── delete_pengumuman_dialog.dart
    └── README.md
```

---

## Code Comparison

### Before (Duplicate Code)
```dart
// add_pengumuman_dialog.dart
InputDecoration _inputDecoration(String hint) { ... } // 15 lines
void _showFormException(Object error, String fallbackMessage) { ... } // 10 lines

// edit_pengumuman_dialog.dart
InputDecoration _inputDecoration(String hint) { ... } // 15 lines (DUPLICATE!)
void _showFormException(Object error, String fallbackMessage) { ... } // 10 lines (DUPLICATE!)

// delete_pengumuman_dialog.dart
void _showFormException(Object error, String fallbackMessage) { ... } // 10 lines (DUPLICATE!)
```

### After (No Duplicate)
```dart
// form_helpers.dart
static InputDecoration inputDecoration(String hint) { ... } // 15 lines (SINGLE SOURCE!)
static void showFormException(Object error, String fallbackMessage) { ... } // 10 lines (SINGLE SOURCE!)

// All dialogs just use:
FormHelpers.inputDecoration('hint')
FormHelpers.showFormException(e, 'message')
```

**Lines Saved:** ~50+ lines of duplicate code eliminated! 🎉

---

## Next Steps

Untuk menggunakan widget-widget ini di `kelola_pengumuman_view.dart`:
1. Import semua widget
2. Replace method `_buildGedungCard()` → `GedungCardWidget`
3. Replace method `_buildPengumumanCard()` → `PengumumanCardWidget`
4. Replace method `_buildEmptyCard()` → `EmptyStateWidget`
5. Replace method `_buildErrorCard()` → `ErrorStateWidget`
6. Replace semua `_show*Dialog()` methods dengan static methods dari widget dialog

**File view utama akan jauh lebih ringkas dan fokus pada layout saja!** 🎊
