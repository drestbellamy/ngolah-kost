import 'dart:io';

void main() async {
  // List of files that need responsive implementation
  final filesToUpdate = [
    'lib/app/modules/user_tagihan/views/user_tagihan_view.dart',
    'lib/app/modules/kamar/views/informasi_kamar_view.dart',
    'lib/app/modules/kamar/views/tambah_penghuni_view.dart',
    'lib/app/modules/kelola_pengumuman/views/kelola_pengumuman_view.dart',
    'lib/app/modules/kelola_peraturan/views/kelola_peraturan_view.dart',
    'lib/app/modules/kelola_tagihan/views/kelola_tagihan_view.dart',
    'lib/app/modules/kost/views/add_kost_view.dart',
    'lib/app/modules/kost/views/edit_kost_view.dart',
    'lib/app/modules/kost/views/map_picker_view.dart',
    'lib/app/modules/kost_map/views/kost_map_view.dart',
    'lib/app/modules/metode_pembayaran/views/metode_pembayaran_view.dart',
    'lib/app/modules/metode_pembayaran/views/tambah_metode_pembayaran_view.dart',
    'lib/app/modules/penghuni/views/penghuni_detail_view.dart',
    'lib/app/modules/profil/views/profil_view.dart',
    'lib/app/modules/ringkasan_keuangan/views/detail_keuangan_kost_view.dart',
    'lib/app/modules/ringkasan_keuangan/views/ringkasan_keuangan_view.dart',
  ];

  print('=== BATCH RESPONSIVE IMPLEMENTATION ===\n');
  print('Processing ${filesToUpdate.length} files...\n');

  int successCount = 0;
  int skipCount = 0;
  int errorCount = 0;

  for (var filePath in filesToUpdate) {
    final file = File(filePath);
    final fileName = filePath.split('/').last;

    if (!file.existsSync()) {
      print('❌ $fileName - File not found');
      errorCount++;
      continue;
    }

    try {
      var content = file.readAsStringSync();
      var originalContent = content;
      bool modified = false;

      // 1. Add responsive_utils import if not present
      if (!content.contains("import '../../../core/utils/responsive_utils.dart'") &&
          !content.contains("import '../../../../core/utils/responsive_utils.dart'")) {
        // Find the last import statement
        final importRegex = RegExp(r"import [^;]+;");
        final matches = importRegex.allMatches(content);
        if (matches.isNotEmpty) {
          final lastImport = matches.last;
          final insertPosition = lastImport.end;
          
          // Determine correct path based on file location
          String importPath;
          if (filePath.contains('/views/')) {
            final depth = '/views/'.allMatches(filePath).length;
            importPath = depth == 1 
                ? "import '../../../core/utils/responsive_utils.dart';"
                : "import '../../../../core/utils/responsive_utils.dart';";
          } else {
            importPath = "import '../../../core/utils/responsive_utils.dart';";
          }
          
          content = content.substring(0, insertPosition) + 
                   '\n$importPath' + 
                   content.substring(insertPosition);
          modified = true;
        }
      }

      // 2. Replace const EdgeInsets.all with context.allPadding (only in build methods)
      content = content.replaceAllMapped(
        RegExp(r'const EdgeInsets\.all\((\d+)\)'),
        (match) {
          modified = true;
          return 'context.allPadding(${match.group(1)})';
        },
      );

      // 3. Replace const EdgeInsets.symmetric with context.symmetricPadding
      content = content.replaceAllMapped(
        RegExp(r'const EdgeInsets\.symmetric\(horizontal:\s*(\d+)\)'),
        (match) {
          modified = true;
          return 'context.horizontalPadding(${match.group(1)})';
        },
      );

      content = content.replaceAllMapped(
        RegExp(r'const EdgeInsets\.symmetric\(vertical:\s*(\d+)\)'),
        (match) {
          modified = true;
          return 'context.verticalPadding(${match.group(1)})';
        },
      );

      // 4. Replace const SizedBox with context.spacing
      content = content.replaceAllMapped(
        RegExp(r'const SizedBox\(height:\s*(\d+)\)'),
        (match) {
          modified = true;
          return 'SizedBox(height: context.spacing(${match.group(1)}))';
        },
      );

      content = content.replaceAllMapped(
        RegExp(r'const SizedBox\(width:\s*(\d+)\)'),
        (match) {
          modified = true;
          return 'SizedBox(width: context.spacing(${match.group(1)}))';
        },
      );

      // 5. Replace BorderRadius.circular with context.borderRadius
      content = content.replaceAllMapped(
        RegExp(r'BorderRadius\.circular\((\d+)\)'),
        (match) {
          modified = true;
          return 'BorderRadius.circular(context.borderRadius(${match.group(1)}))';
        },
      );

      // 6. Replace .withOpacity with .withValues
      content = content.replaceAllMapped(
        RegExp(r'\.withOpacity\(([^)]+)\)'),
        (match) {
          modified = true;
          return '.withValues(alpha: ${match.group(1)})';
        },
      );

      // 7. Replace fontSize with context.fontSize (in TextStyle)
      content = content.replaceAllMapped(
        RegExp(r'fontSize:\s*(\d+)(?!.*context)'),
        (match) {
          modified = true;
          return 'fontSize: context.fontSize(${match.group(1)})';
        },
      );

      // 8. Replace Icon size with context.iconSize
      content = content.replaceAllMapped(
        RegExp(r'(Icon\([^,]+,\s*size:\s*)(\d+)(?!.*context)'),
        (match) {
          modified = true;
          return '${match.group(1)}context.iconSize(${match.group(2)})';
        },
      );

      // 9. Replace button height with context.buttonHeight
      content = content.replaceAllMapped(
        RegExp(r'(?<!context\.)height:\s*(44|48|56)(?!\))'),
        (match) {
          modified = true;
          return 'height: context.buttonHeight(${match.group(1)})';
        },
      );

      if (modified && content != originalContent) {
        file.writeAsStringSync(content);
        print('✅ $fileName - Updated successfully');
        successCount++;
      } else {
        print('⏭️  $fileName - No changes needed');
        skipCount++;
      }
    } catch (e) {
      print('❌ $fileName - Error: $e');
      errorCount++;
    }
  }

  print('\n=== SUMMARY ===');
  print('✅ Successfully updated: $successCount files');
  print('⏭️  Skipped (no changes): $skipCount files');
  print('❌ Errors: $errorCount files');
  print('\nTotal processed: ${successCount + skipCount + errorCount}/${filesToUpdate.length}');
  
  if (successCount > 0) {
    print('\n⚠️  IMPORTANT: Run "flutter analyze" to check for context errors!');
    print('If you see "Undefined name \'context\'" errors, those methods need BuildContext parameter.');
  }
}
