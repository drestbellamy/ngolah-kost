import 'package:get/get.dart';

class InformasiKamarController extends GetxController {
  // Data kamar
  final nomorKamar = 'A-101'.obs;
  final namaKost = 'Green Valley Kost'.obs;
  final status = 'Terisi'.obs;
  final hargaPerBulan = 'Rp 1.500.000'.obs;
  final kapasitas = 2.obs;
  final terisi = 1.obs;

  // Data penghuni (bisa lebih dari satu)
  final daftarPenghuni = <Map<String, dynamic>>[
    {
      'nama': 'Ahmad Wijaya',
      'telepon': '081234567890',
      'username': '@ahmadwijaya',
      'statusKontrak': 'Berakhir',
      'durasiKontrak': '12 Bulan',
      'siklusBayar': 'Bulanan (1 bulan)',
      'tanggalMulai': '15 Januari 2024',
      'tanggalBerakhir': '15 Januari 2025',
      'hargaSewa': 'Rp 1.500.000',
      'isExpanded': false,
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Load data dari arguments jika ada
    if (Get.arguments != null) {
      final kamar = Get.arguments as Map<String, dynamic>;
      nomorKamar.value = kamar['nomor'] ?? 'A-101';
      status.value = kamar['status'] ?? 'Terisi';
      hargaPerBulan.value = kamar['harga'] ?? 'Rp 1.500.000';
      kapasitas.value = kamar['kapasitas'] ?? 2;
      terisi.value = kamar['terisi'] ?? (status.value == 'Ditempati' ? 1 : 0);
    }
  }

  void toggleExpand(int index) {
    var penghuni = Map<String, dynamic>.from(daftarPenghuni[index]);
    penghuni['isExpanded'] = !(penghuni['isExpanded'] as bool);
    daftarPenghuni[index] = penghuni;
  }

  void goBack() {
    Get.back();
  }

  void tambahPenghuni() async {
    final result = await Get.toNamed(
      '/tambah-penghuni',
      arguments: {'nomor': nomorKamar.value, 'harga': hargaPerBulan.value},
    );

    // Jika ada data yang dikembalikan dari form tambah penghuni
    if (result != null && result is Map<String, dynamic>) {
      daftarPenghuni.add(result);
      terisi.value = daftarPenghuni.length;

      // Update status kamar jika tadinya kosong
      if (status.value == 'Kosong') {
        status.value = 'Terisi';
      }
    }
  }
}
