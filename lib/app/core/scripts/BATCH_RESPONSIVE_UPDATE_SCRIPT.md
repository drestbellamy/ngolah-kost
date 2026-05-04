# Batch Responsive Update - Remaining 14 Files

## Status: 18/33 Complete (55%)

### Completed This Session
1. ✅ landing_view.dart
2. ✅ landing3_view.dart  
3. ✅ penghuni_view.dart (COMPLETED)

### Files to Update (14 remaining)

#### Priority 2 (3 files)
1. penghuni_detail_view.dart
2. profil_view.dart
3. metode_pembayaran_view.dart
4. tambah_metode_pembayaran_view.dart

#### Priority 3 (5 files)
5. ringkasan_keuangan_view.dart
6. detail_keuangan_kost_view.dart
7. kelola_tagihan_view.dart
8. kelola_peraturan_view.dart
9. kelola_pengumuman_view.dart

#### Priority 4 (6 files)
10. add_kost_view.dart
11. edit_kost_view.dart
12. map_picker_view.dart
13. kost_map_view.dart
14. informasi_kamar_view.dart
15. tambah_penghuni_view.dart

## Standard Replacements

### Find & Replace Patterns

```regex
# Padding
const EdgeInsets\.all\((\d+)\)
→ context.allPadding($1)

const EdgeInsets\.symmetric\(horizontal: (\d+), vertical: (\d+)\)
→ context.symmetricPadding(horizontal: $1, vertical: $2)

const EdgeInsets\.symmetric\(horizontal: (\d+)\)
→ context.horizontalPadding($1)

const EdgeInsets\.symmetric\(vertical: (\d+)\)
→ context.verticalPadding($1)

# SizedBox
const SizedBox\(height: (\d+)\)
→ SizedBox(height: context.spacing($1))

const SizedBox\(width: (\d+)\)
→ SizedBox(width: context.spacing($1))

# BorderRadius
BorderRadius\.circular\((\d+)\)
→ BorderRadius.circular(context.borderRadius($1))

# Deprecated
\.withOpacity\(
→ .withValues(alpha: 
```

### Manual Updates Required
- fontSize: X → fontSize: context.fontSize(X)
- size: X (icons) → size: context.iconSize(X)
- height: X (buttons) → height: context.buttonHeight(X)
- Add BuildContext to methods or wrap with Builder

## Estimated Time
- 14 files × 10 minutes = ~2.5 hours
- With testing: ~3 hours

