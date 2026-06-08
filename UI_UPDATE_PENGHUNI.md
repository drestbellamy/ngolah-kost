# UI Update: Kelola Penghuni - Match Kelola Tagihan Design

## 📋 Changes Made

Updated halaman **Kelola Penghuni** agar sesuai dengan design **Kelola Tagihan** berdasarkan gambar yang diberikan.

---

## 🎨 UI Changes

### Before (Old Design):
```
┌─────────────────────────────────────┐
│  [Header dengan Search Bar di dalam]│
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ [Chips Filter Kost] [Sort Button]   │  ← Horizontal scroll chips
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ [List Penghuni]                     │
└─────────────────────────────────────┘
```

### After (New Design - Match Kelola Tagihan):
```
┌─────────────────────────────────────┐
│  [Header - Kelola Penghuni]         │
│  35 penghuni                        │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  🔍 Cari penghuni, kamar, atau kost │  ← Search bar keluar dari header
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  🏢 Semua Kost (35) ▼               │  ← Dropdown filter kost
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ [List Penghuni]                     │
└─────────────────────────────────────┘
```

---

## ✅ Specific Changes

### 1. **Header Section**
**Before:**
- Search bar berada di dalam header (background gradient)
- Header lebih tinggi karena ada search bar

**After:**
- Header hanya menampilkan title dan subtitle
- Search bar dipindah keluar header
- Header lebih compact

### 2. **Search Bar Position**
**Before:**
```dart
// Di dalam header Padding
TextField(
  decoration: InputDecoration(
    fillColor: Colors.white, // White in green background
  ),
)
```

**After:**
```dart
// Setelah header, padding terpisah
Padding(
  padding: context.horizontalPadding(16),
  child: TextField(
    decoration: InputDecoration(
      hintText: 'Cari penghuni, kamar, atau kost...',
      prefixIcon: Icon(Icons.search),
      fillColor: Colors.white,
    ),
  ),
),
```

### 3. **Filter Kost**
**Before:**
- Horizontal scrollable chips
- Multiple chips visible
- Sort button di samping

```dart
ListView.separated(
  scrollDirection: Axis.horizontal,
  itemBuilder: (context, index) => _buildFilterChip(...),
)
```

**After:**
- Single dropdown selector
- Icon apartment di kiri
- Count di dalam dropdown items

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
  child: DropdownButton<String>(
    value: selectedKost,
    items: kostOptions.map((kost) {
      final count = controller.getPenghuniCountByKost(kost);
      return DropdownMenuItem(
        value: kost,
        child: Text('$kost ($count)'),
      );
    }).toList(),
    onChanged: (newValue) => controller.filterByKost(newValue!),
  ),
)
```

### 4. **Removed Components**
- ❌ `_buildFilterChip()` method
- ❌ `_buildSortButton()` method
- ❌ Horizontal scrollable chip list
- ❌ Sort button

---

## 🎯 Benefits

### User Experience:
1. **Cleaner Header** - Tidak terlalu crowded
2. **Better Visibility** - Search bar lebih jelas di white background
3. **Easier Selection** - Dropdown lebih mudah digunakan dari pada scroll chips
4. **Consistent Design** - Sama dengan Kelola Tagihan

### Developer Experience:
1. **Less Code** - Hapus 2 builder methods yang complex
2. **Simpler Logic** - Dropdown lebih simple dari chips
3. **Easier Maintenance** - Consistent design pattern

---

## 📱 UI Layout Breakdown

### Header (Green Gradient):
```dart
- Title: "Kelola Penghuni" (24sp, Bold, White)
- Subtitle: "35 penghuni" (14sp, Light Green)
- Background: Gradient green dengan decorative circles
```

### Search Bar (White Card):
```dart
- Background: White
- Icon: Search (gray)
- Hint: "Cari penghuni, kamar, atau kost..."
- Border: None (filled style)
- Border Radius: 12px
- Padding: 16px horizontal
```

### Filter Dropdown (White Card):
```dart
- Background: White
- Icon: Apartment (green) di kiri
- Dropdown: Full width
- Items: "Kost Name (count)"
- Border: 1px solid gray
- Border Radius: 12px
- Padding: 16px horizontal, 12px vertical
```

### List:
```dart
- Same as before
- Card-based layout
- Shadow and rounded corners
```

---

## 🔧 Technical Details

### Removed Code:
```dart
// ❌ Removed: Horizontal chips
ListView.separated(
  scrollDirection: Axis.horizontal,
  itemCount: controller.kostFilterOptions.length,
  itemBuilder: (context, index) => _buildFilterChip(...),
)

// ❌ Removed: Filter chip builder
Widget _buildFilterChip(String label, int count, bool isSelected, bool hasPenghuni) { ... }

// ❌ Removed: Sort button
Widget _buildSortButton() { ... }
```

### Added Code:
```dart
// ✅ Added: Dropdown filter
DropdownButtonHideUnderline(
  child: DropdownButton<String>(
    value: selectedKost,
    isExpanded: true,
    icon: const Icon(Icons.keyboard_arrow_down),
    items: kostOptions.map((String kost) {
      final count = controller.getPenghuniCountByKost(kost);
      return DropdownMenuItem<String>(
        value: kost,
        child: Text('$kost ($count)'),
      );
    }).toList(),
    onChanged: (String? newValue) {
      if (newValue != null) {
        controller.filterByKost(newValue);
      }
    },
  ),
)
```

---

## ✅ Testing Checklist

- [ ] Header menampilkan title dan count dengan benar
- [ ] Search bar berfungsi filter penghuni
- [ ] Dropdown menampilkan semua kost options
- [ ] Dropdown menampilkan count per kost
- [ ] Filter kost berfungsi dengan benar
- [ ] List penghuni ter-filter sesuai selection
- [ ] Empty state menampilkan pesan yang sesuai
- [ ] Responsive di berbagai ukuran layar

---

## 📊 Comparison

| Aspect | Before | After |
|--------|--------|-------|
| Search Position | Inside header | Below header |
| Filter Style | Horizontal chips | Dropdown |
| Sort Button | Visible | Removed |
| Header Height | Taller | Shorter |
| Complexity | Higher | Lower |
| Code Lines | ~150 lines | ~50 lines |
| User Interaction | Scroll + Tap | Tap only |

---

## 🎉 Result

Halaman **Kelola Penghuni** sekarang memiliki UI yang **konsisten** dengan **Kelola Tagihan**:
- ✅ Search bar sama
- ✅ Filter dropdown sama
- ✅ Layout structure sama
- ✅ Design language sama

**File Changed:** `lib/app/modules/penghuni/views/penghuni_view.dart`

---

**Status:** ✅ Completed
**Design:** Match dengan Kelola Tagihan
**Testing:** Ready for testing
