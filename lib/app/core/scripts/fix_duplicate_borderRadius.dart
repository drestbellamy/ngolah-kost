import 'dart:io';

void main() {
  final files = [
    'lib/app/modules/kost/views/map_picker_view.dart',
    'lib/app/modules/profil/views/profil_view.dart',
  ];

  print('Fixing duplicate borderRadius calls...\n');

  for (var filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('❌ File not found: $filePath');
      continue;
    }

    var content = file.readAsStringSync();
    
    // Fix duplicate context.borderRadius calls
    // Pattern: borderRadius: BorderRadius.circular(context.borderRadius(X)),
    //          borderRadius: BorderRadius.circular(context.borderRadius(X)),
    //          borderRadius: BorderRadius.circular(context.borderRadius(X)),
    
    // Replace triple duplicates
    content = content.replaceAllMapped(
      RegExp(r'(borderRadius: BorderRadius\.circular\(context\.borderRadius\(\d+\)\)),\s*\1,\s*\1'),
      (match) => match.group(1)!,
    );
    
    // Replace double duplicates
    content = content.replaceAllMapped(
      RegExp(r'(borderRadius: BorderRadius\.circular\(context\.borderRadius\(\d+\)\)),\s*\1'),
      (match) => match.group(1)!,
    );

    // Fix duplicate BorderRadius.only
    content = content.replaceAllMapped(
      RegExp(r'(borderRadius: BorderRadius\.only\([^)]+\)),\s*\1'),
      (match) => match.group(1)!,
    );

    // Fix duplicate const BorderRadius.only
    content = content.replaceAllMapped(
      RegExp(r'(borderRadius: const BorderRadius\.only\([^)]+\)),\s*\1'),
      (match) => match.group(1)!,
    );

    // Fix duplicate icon size
    content = content.replaceAllMapped(
      RegExp(r'(size: context\.iconSize\(\d+\)),\s*\1'),
      (match) => match.group(1)!,
    );

    file.writeAsStringSync(content);
    print('✅ ${filePath.split('/').last}');
  }

  print('\nDone!');
}
