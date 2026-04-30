import 'dart:io';

void main() async {
  final file = File('lib/app/modules/kamar/views/informasi_kamar_view.dart');
  String content = await file.readAsString();

  // Fix _buildInfoRow calls - add context parameter
  content = content.replaceAllMapped(
    RegExp(r'_buildInfoRow\(\s*icon:', multiLine: true),
    (match) => '_buildInfoRow(\n            context: context,\n            icon:',
  );

  // Fix _buildSummaryBox calls - add context parameter
  content = content.replaceAllMapped(
    RegExp(r'_buildSummaryBox\(\s*icon:', multiLine: true),
    (match) => '_buildSummaryBox(\n            context: context,\n            icon:',
  );

  await file.writeAsString(content);
  print('✅ Fixed context errors in informasi_kamar_view.dart');
}
