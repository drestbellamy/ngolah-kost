# Batch Add Responsive Imports - Command List

## Files Needing Responsive Import (14 files)

Execute these commands to add responsive imports to all remaining view files:

### Financial Management Views (3 files)

```bash
# ringkasan_keuangan_view.dart
# Add after line 6 (after last import)
# import '../../../core/utils/responsive_utils.dart';

# detail_keuangan_kost_view.dart  
# Add after line 7 (after last import)
# import '../../../core/utils/responsive_utils.dart';

# kelola_tagihan_view.dart
# Add after line 6 (after last import)
# import '../../../core/utils/responsive_utils.dart';
```

### Content Management Views (2 files)

```bash
# kelola_peraturan_view.dart
# Add after line 5 (after last import)
# import '../../../core/utils/responsive_utils.dart';

# kelola_pengumuman_view.dart
# Add after line 5 (after last import)
# import '../../../core/utils/responsive_utils.dart';
```

### Room & Tenant Management (3 files)

```bash
# informasi_kamar_view.dart
# Add after line 5 (after last import)
# import '../../../core/utils/responsive_utils.dart';

# tambah_penghuni_view.dart
# Add after line 7 (after last import)
# import '../../../core/utils/responsive_utils.dart';

# penghuni_detail_view.dart
# Add after line 10 (after last import)
# import '../../../core/utils/responsive_utils.dart';
```

### Kost Management (4 files)

```bash
# add_kost_view.dart
# Add after line 7 (after last import)
# import '../../../core/utils/responsive_utils.dart';

# edit_kost_view.dart
# Add after line 7 (after last import)
# import '../../../core/utils/responsive_utils.dart';

# map_picker_view.dart
# Add after line 8 (after last import)
# import '../../../core/utils/responsive_utils.dart';

# kost_map_view.dart
# Add after line 15 (after last import)
# import '../../../core/utils/responsive_utils.dart';
```

### Other Views (2 files)

```bash
# landing2_view.dart (original)
# Add after line 5 (after last import)
# import '../../../core/utils/responsive_utils.dart';

# tambah_metode_pembayaran_view.dart
# Add after line (check imports)
# import '../../../core/utils/responsive_utils.dart';

# user_history_pembayaran_view.dart
# Add after line (check imports)
# import '../../../core/utils/responsive_utils.dart';
```

## Quick PowerShell Script to Add Imports

Save this as `add_responsive_imports.ps1`:

```powershell
$files = @(
    "lib/app/modules/ringkasan_keuangan/views/ringkasan_keuangan_view.dart",
    "lib/app/modules/ringkasan_keuangan/views/detail_keuangan_kost_view.dart",
    "lib/app/modules/kelola_tagihan/views/kelola_tagihan_view.dart",
    "lib/app/modules/kelola_peraturan/views/kelola_peraturan_view.dart",
    "lib/app/modules/kelola_pengumuman/views/kelola_pengumuman_view.dart",
    "lib/app/modules/kamar/views/informasi_kamar_view.dart",
    "lib/app/modules/kamar/views/tambah_penghuni_view.dart",
    "lib/app/modules/penghuni/views/penghuni_detail_view.dart",
    "lib/app/modules/kost/views/add_kost_view.dart",
    "lib/app/modules/kost/views/edit_kost_view.dart",
    "lib/app/modules/kost/views/map_picker_view.dart",
    "lib/app/modules/kost_map/views/kost_map_view.dart",
    "lib/app/modules/landing/views/landing2_view.dart"
)

$importLine = "import '../../../core/utils/responsive_utils.dart';"

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Check if import already exists
        if ($content -notmatch "responsive_utils") {
            # Find the last import line
            $lines = Get-Content $file
            $lastImportIndex = -1
            
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match "^import ") {
                    $lastImportIndex = $i
                }
            }
            
            if ($lastImportIndex -ge 0) {
                # Insert after last import
                $newLines = $lines[0..$lastImportIndex] + $importLine + $lines[($lastImportIndex + 1)..($lines.Count - 1)]
                $newLines | Set-Content $file
                Write-Host "✓ Added import to: $file" -ForegroundColor Green
            }
        } else {
            Write-Host "○ Already has import: $file" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✗ File not found: $file" -ForegroundColor Red
    }
}

Write-Host "`nDone! Check the files and commit changes." -ForegroundColor Cyan
```

## After Adding Imports

For each file, you need to replace:

1. **Padding & Spacing:**
   - `const EdgeInsets.all(X)` → `context.allPadding(X)`
   - `const EdgeInsets.symmetric(...)` → `context.symmetricPadding(...)`
   - `const SizedBox(height: X)` → `SizedBox(height: context.spacing(X))`

2. **Typography:**
   - `fontSize: X` → `fontSize: context.fontSize(X)`

3. **Icons & Buttons:**
   - `size: X` → `size: context.iconSize(X)`
   - Button heights → `height: context.buttonHeight(X)`

4. **Border Radius:**
   - `BorderRadius.circular(X)` → `BorderRadius.circular(context.borderRadius(X))`

5. **Deprecated Methods:**
   - `.withOpacity(X)` → `.withValues(alpha: X)`

6. **Add BuildContext:**
   - Use `Builder` widget when context is not available

## Priority Order

1. **High Priority** (User-facing, frequently used):
   - kelola_tagihan_view.dart
   - ringkasan_keuangan_view.dart
   - detail_keuangan_kost_view.dart
   - penghuni_detail_view.dart

2. **Medium Priority** (Admin features):
   - kelola_peraturan_view.dart
   - kelola_pengumuman_view.dart
   - informasi_kamar_view.dart
   - tambah_penghuni_view.dart

3. **Low Priority** (Less frequently used):
   - add_kost_view.dart
   - edit_kost_view.dart
   - map_picker_view.dart
   - kost_map_view.dart
   - landing2_view.dart

## Testing Checklist

After updating each file:
- [ ] No compilation errors
- [ ] Test on iPhone SE (320px)
- [ ] Test on iPhone 12 (375px)
- [ ] Test on iPhone 14 Pro Max (428px)
- [ ] Test on iPad (768px+)
- [ ] No overflow errors
- [ ] Text is readable
- [ ] Buttons are tappable
- [ ] Spacing looks balanced

---

Last Updated: 2026-04-30
