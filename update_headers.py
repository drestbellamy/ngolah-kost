import re
from pathlib import Path

# Ringkasan Keuangan View
fpath1 = Path('lib/app/modules/ringkasan_keuangan/views/ringkasan_keuangan_view.dart')
content1 = fpath1.read_text('utf-8')

new_header1 = '''CustomHeader(
              title: 'Kelola Keuangan',
              subtitle: 'Pilih kost untuk melihat detail',
              showBackButton: true,
            ),'''

content1 = re.sub(
    r'Container\(\n\s*width: double\.infinity,\n\s*decoration:[\s\S]*?(?=\n\s*// Scrollable Content)',
    new_header1,
    content1
)

if 'CustomHeader' not in content1:
    content1 = content1.replace(
        '''import '../controllers/ringkasan_keuangan_controller.dart';''',
        '''import '../../../core/widgets/custom_header.dart';\nimport '../controllers/ringkasan_keuangan_controller.dart';'''
    )

fpath1.write_text(content1, 'utf-8')

# Detail Keuangan Kost View
fpath2 = Path('lib/app/modules/ringkasan_keuangan/views/detail_keuangan_kost_view.dart')
content2 = fpath2.read_text('utf-8')

new_header2 = '''Obx(() => CustomHeader(
              title: controller.kostName.value,
              subtitle: 'Detail keuangan kost',
              showBackButton: true,
            )),'''

content2 = re.sub(
    r'Container\(\n\s*width: double\.infinity,\n\s*decoration:[\s\S]*?(?=\n\s*// Content)',
    new_header2,
    content2
)

if 'CustomHeader' not in content2:
    content2 = content2.replace(
        '''import '../controllers/detail_keuangan_kost_controller.dart';''',
        '''import '../../../core/widgets/custom_header.dart';\nimport '../controllers/detail_keuangan_kost_controller.dart';'''
    )

fpath2.write_text(content2, 'utf-8')

print('Headers updated')
