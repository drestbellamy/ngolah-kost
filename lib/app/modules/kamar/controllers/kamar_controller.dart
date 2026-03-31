import 'package:get/get.dart';

class KamarController extends GetxController {
  var selectedTab = 'Semua Kamar'.obs;

  // Observable list of kamar
  final RxList<Map<String, dynamic>> allKamar = <Map<String, dynamic>>[
    {
      'no': 'A-101',
      'penghuni': 'John Doe',
      'harga': '1500000',
      'status': 'Ditempati',
    },
    {'no': 'A-102', 'penghuni': null, 'harga': '1500000', 'status': 'Kosong'},
    {
      'no': 'A-103',
      'penghuni': 'Jane Smith',
      'harga': '1500000',
      'status': 'Ditempati',
    },
    {'no': 'B-201', 'penghuni': null, 'harga': '1800000', 'status': 'Kosong'},
  ].obs;

  List<Map<String, dynamic>> get filteredKamar {
    if (selectedTab.value == 'Kosong') {
      return allKamar.where((k) => k['status'] == 'Kosong').toList();
    } else if (selectedTab.value == 'Ditempati') {
      return allKamar.where((k) => k['status'] == 'Ditempati').toList();
    }
    return allKamar;
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void addKamar(String no, String harga) {
    allKamar.add({
      'no': no,
      'penghuni': null, // default is null
      'harga': harga,
      'status': 'Kosong', // default status
    });
  }

  void editKamar(String oldNo, String newNo, String harga) {
    int index = allKamar.indexWhere((k) => k['no'] == oldNo);
    if (index != -1) {
      var item = allKamar[index];
      item['no'] = newNo;
      item['harga'] = harga;
      allKamar[index] = item; // Memaksa re-render
      // Memberitahu getx bahwa allKamar berubah
      allKamar.refresh();
    }
  }

  void deleteKamar(String no) {
    allKamar.removeWhere((k) => k['no'] == no);
  }

  // Format harga
  String formatRupiah(String amount) {
    int parsedAmount =
        int.tryParse(amount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    String result = parsedAmount.toString();
    String formatted = '';
    for (int i = 0; i < result.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formatted = '.$formatted';
      }
      formatted = result[result.length - 1 - i] + formatted;
    }
    return 'Rp $formatted';
  }

  int get totalRuangan => allKamar.length;
  int get totalDitempati =>
      allKamar.where((k) => k['status'] == 'Ditempati').length;
  int get totalKosong => allKamar.where((k) => k['status'] == 'Kosong').length;

  @override
  void onInit() {
    super.onInit();
  }
}
