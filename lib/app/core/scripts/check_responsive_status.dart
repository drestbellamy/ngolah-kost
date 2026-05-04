import 'dart:io';

void main() {
  final viewFiles = [
    'lib/app/modules/home/views/home_view.dart',
    'lib/app/modules/kamar/views/informasi_kamar_view.dart',
    'lib/app/modules/kamar/views/kamar_view.dart',
    'lib/app/modules/kamar/views/tambah_penghuni_view.dart',
    'lib/app/modules/kelola_pengumuman/views/kelola_pengumuman_view.dart',
    'lib/app/modules/kelola_peraturan/views/kelola_peraturan_view.dart',
    'lib/app/modules/kelola_tagihan/views/kelola_tagihan_view.dart',
    'lib/app/modules/kost/views/add_kost_view.dart',
    'lib/app/modules/kost/views/edit_kost_view.dart',
    'lib/app/modules/kost/views/kost_view.dart',
    'lib/app/modules/kost/views/map_picker_view.dart',
    'lib/app/modules/kost_map/views/kost_map_view.dart',
    'lib/app/modules/landing/views/landing2_view.dart',
    'lib/app/modules/landing/views/landing3_view.dart',
    'lib/app/modules/landing/views/landing_view.dart',
    'lib/app/modules/login/views/login_view.dart',
    'lib/app/modules/metode_pembayaran/views/metode_pembayaran_view.dart',
    'lib/app/modules/metode_pembayaran/views/tambah_metode_pembayaran_view.dart',
    'lib/app/modules/penghuni/views/penghuni_detail_view.dart',
    'lib/app/modules/penghuni/views/penghuni_view.dart',
    'lib/app/modules/profil/views/profil_view.dart',
    'lib/app/modules/ringkasan_keuangan/views/detail_keuangan_kost_view.dart',
    'lib/app/modules/ringkasan_keuangan/views/ringkasan_keuangan_view.dart',
    'lib/app/modules/user_history_pembayaran/views/user_history_pembayaran_view.dart',
    'lib/app/modules/user_home/views/user_home_view.dart',
    'lib/app/modules/user_info/views/user_info_view.dart',
    'lib/app/modules/user_profil/views/user_profil_view.dart',
    'lib/app/modules/user_tagihan/views/user_tagihan_view.dart',
  ];

  print('=== RESPONSIVE STATUS CHECK ===\n');
  
  int fullyResponsive = 0;
  int partiallyResponsive = 0;
  int notResponsive = 0;
  
  List<String> fullyResponsiveFiles = [];
  List<String> partiallyResponsiveFiles = [];
  List<String> notResponsiveFiles = [];

  for (var filePath in viewFiles) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('❌ File not found: $filePath');
      continue;
    }

    final content = file.readAsStringSync();
    final fileName = filePath.split('/').last;

    // Check for responsive patterns
    final hasFontSize = content.contains('context.fontSize');
    final hasSpacing = content.contains('context.spacing') || content.contains('context.allPadding') || content.contains('context.symmetricPadding');
    final hasBorderRadius = content.contains('context.borderRadius');
    final hasIconSize = content.contains('context.iconSize');
    
    // Check for hardcoded values that should be responsive
    final hasHardcodedFontSize = RegExp(r'fontSize:\s*\d+(?!.*context)').hasMatch(content);
    final hasHardcodedPadding = RegExp(r'EdgeInsets\.(all|symmetric|only)\([^)]*\d+').hasMatch(content);
    final hasHardcodedSpacing = RegExp(r'SizedBox\((height|width):\s*\d+').hasMatch(content);
    
    // Determine status
    if (hasFontSize && hasSpacing && hasBorderRadius) {
      fullyResponsive++;
      fullyResponsiveFiles.add(fileName);
      print('✅ $fileName - FULLY RESPONSIVE');
    } else if (hasSpacing || hasFontSize || hasBorderRadius) {
      partiallyResponsive++;
      partiallyResponsiveFiles.add(fileName);
      print('⚠️  $fileName - PARTIALLY RESPONSIVE');
      if (!hasFontSize && hasHardcodedFontSize) print('   - Missing: context.fontSize');
      if (!hasSpacing && (hasHardcodedPadding || hasHardcodedSpacing)) print('   - Missing: context.spacing/padding');
      if (!hasBorderRadius) print('   - Missing: context.borderRadius');
    } else {
      notResponsive++;
      notResponsiveFiles.add(fileName);
      print('❌ $fileName - NOT RESPONSIVE');
    }
  }

  print('\n=== SUMMARY ===');
  print('Total Files: ${viewFiles.length}');
  print('✅ Fully Responsive: $fullyResponsive (${(fullyResponsive / viewFiles.length * 100).toStringAsFixed(1)}%)');
  print('⚠️  Partially Responsive: $partiallyResponsive (${(partiallyResponsive / viewFiles.length * 100).toStringAsFixed(1)}%)');
  print('❌ Not Responsive: $notResponsive (${(notResponsive / viewFiles.length * 100).toStringAsFixed(1)}%)');

  if (notResponsiveFiles.isNotEmpty) {
    print('\n=== FILES NEEDING RESPONSIVE IMPLEMENTATION ===');
    for (var file in notResponsiveFiles) {
      print('- $file');
    }
  }

  if (partiallyResponsiveFiles.isNotEmpty) {
    print('\n=== FILES NEEDING COMPLETION ===');
    for (var file in partiallyResponsiveFiles) {
      print('- $file');
    }
  }
}
