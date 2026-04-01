import 'package:get/get.dart';

class KelolaPengumumanController extends GetxController {
  final List<String> kostOptions = [
    'Green Valley Kost',
    'Sunrise Boarding House',
    'Bintang Kost',
    'Melati Kost',
  ];

  final RxList<Map<String, dynamic>> pengumumanList = <Map<String, dynamic>>[
    {
      'id': '1',
      'kostName': 'Green Valley Kost',
      'title': 'Pemeliharaan Air',
      'description':
          'Air akan dimatikan sementara pada tanggal 22 Maret 2026 pukul 08:00 - 12:00 untuk pemeliharaan rutin sistem water heater di semua kamar.',
      'date': '18 Maret 2026',
    },
    {
      'id': '2',
      'kostName': 'Green Valley Kost',
      'title': 'Libur Lebaran 2026',
      'description':
          'Kantor pengelola kost akan tutup pada tanggal 30 Maret - 3 April 2026. Untuk keadaan darurat, hubungi nomor emergency.',
      'date': '18 Maret 2026',
    },
    {
      'id': '3',
      'kostName': 'Sunrise Boarding House',
      'title': 'Perbaikan WiFi Selesai',
      'description':
          'Perbaikan jaringan WiFi di lantai 2 dan 3 telah selesai. Kecepatan internet sekarang sudah kembali normal.',
      'date': '12 Maret 2026',
    },
  ].obs;

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void addPengumuman(String kostName, String title, String description) {
    pengumumanList.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'kostName': kostName,
      'title': title,
      'description': description,
      'date': _formatDate(DateTime.now()),
    });
  }

  void editPengumuman(
    String id,
    String kostName,
    String title,
    String description,
  ) {
    int index = pengumumanList.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      var item = pengumumanList[index];
      item['kostName'] = kostName;
      item['title'] = title;
      item['description'] = description;
      pengumumanList[index] = item;
      pengumumanList.refresh();
    }
  }

  void deletePengumuman(String id) {
    pengumumanList.removeWhere((p) => p['id'] == id);
  }
}
