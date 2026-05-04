import 'dart:io';

/// Script otomatis untuk mengupdate file dengan responsive values
/// Run: dart auto_responsive_update.dart

void main() async {
  print('🚀 Starting Automatic Responsive Update...\n');
  
  final filesToUpdate = [
    'lib/app/modules/penghuni/views/penghuni_detail_view.dart',
    'lib/app/modules/profil/views/profil_view.dart',
    'lib/app/modules/metode_pembayaran/views/metode_pembayaran_view.dart',
    'lib/app/modules/metode_pembayaran/views/tambah_metode_pembayaran_view.dart',
    'lib/app/modules/ringkasan_keuangan/views/ringkasan_keuangan_view.dart',
    'lib/app/modules/ringkasan_keuangan/views/detail_keuangan_kost_view.dart',
    'lib/app/modules/kelola_tagihan/views/kelola_tagihan_view.dart',
    'lib/app/modules/kelola_peraturan/views/kelola_peraturan_view.dart',
    'lib/app/modules/kelola_pengumuman/views/kelola_pengumuman_view.dart',
    'lib/app/modules/kost/views/add_kost_view.dart',
    'lib/app/modules/kost/views/edit_kost_view.dart',
    'lib/app/modules/kost/views/map_picker_view.dart',
    'lib/app/modules/kost_map/views/kost_map_view.dart',
    'lib/app/modules/kamar/views/informasi_kamar_view.dart',
    'lib/app/modules/kamar/views/tambah_penghuni_view.dart',
  ];

  int successCount = 0;
  int errorCount = 0;

  for (final filePath in filesToUpdate) {
    try {
      print('📝 Processing: $filePath');
      final file = File(filePath);
      
      if (!file.existsSync()) {
        print('   ⚠️  File not found, skipping...\n');
        errorCount++;
        continue;
      }

      String content = await file.readAsString();
      String originalContent = content;

      // 1. Update EdgeInsets.all
      content = content.replaceAllMapped(
        RegExp(r'const EdgeInsets\.all\((\d+)\)'),
        (match) => 'context.allPadding(${match.group(1)})',
      );

      // 2. Update EdgeInsets.symmetric with both params
      content = content.replaceAllMapped(
        RegExp(r'const EdgeInsets\.symmetric\(\s*horizontal:\s*(\d+),\s*vertical:\s*(\d+)\s*\)'),
        (match) => 'context.symmetricPadding(horizontal: ${match.group(1)}, vertical: ${match.group(2)})',
      );

      // 3. Update EdgeInsets.symmetric with horizontal only
      content = content.replaceAllMapped(
        RegExp(r'const EdgeInsets\.symmetric\(\s*horizontal:\s*(\d+)\s*\)'),
        (match) => 'context.horizontalPadding(${match.group(1)})',
      );

      // 4. Update EdgeInsets.symmetric with vertical only
      content = content.replaceAllMapped(
        RegExp(r'const EdgeInsets\.symmetric\(\s*vertical:\s*(\d+)\s*\)'),
        (match) => 'context.verticalPadding(${match.group(1)})',
      );

      // 5. Update SizedBox height
      content = content.replaceAllMapped(
        RegExp(r'const SizedBox\(height:\s*(\d+)\)'),
        (match) => 'SizedBox(height: context.spacing(${match.group(1)}))',
      );

      // 6. Update SizedBox width
      content = content.replaceAllMapped(
        RegExp(r'const SizedBox\(width:\s*(\d+)\)'),
        (match) => 'SizedBox(width: context.spacing(${match.group(1)}))',
      );

      // 7. Update BorderRadius.circular
      content = content.replaceAllMapped(
        RegExp(r'BorderRadius\.circular\((\d+)\)'),
        (match) => 'BorderRadius.circular(context.borderRadius(${match.group(1)}))',
      );

      // 8. Update deprecated withOpacity
      content = content.replaceAll('.withOpacity(', '.withValues(alpha: ');

      // Check if any changes were made
      if (content != originalContent) {
        await file.writeAsString(content);
        print('   ✅ Updated successfully\n');
        successCount++;
      } else {
        print('   ℹ️  No changes needed\n');
        successCount++;
      }

    } catch (e) {
      print('   ❌ Error: $e\n');
      errorCount++;
    }
  }

  print('\n' + '=' * 50);
  print('📊 SUMMARY');
  print('=' * 50);
  print('✅ Success: $successCount files');
  print('❌ Errors: $errorCount files');
  print('📁 Total: ${filesToUpdate.length} files');
  print('\n⚠️  IMPORTANT: Manual updates still needed for:');
  print('   - fontSize: X → fontSize: context.fontSize(X)');
  print('   - size: X (icons) → size: context.iconSize(X)');
  print('   - height: X (buttons) → height: context.buttonHeight(X)');
  print('   - Add BuildContext to methods if needed');
  print('\n🔍 Run: flutter analyze');
  print('🧪 Test on multiple devices');
  print('\n✨ Done!\n');
}
