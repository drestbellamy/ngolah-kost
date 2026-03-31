import 'package:get/get.dart';

class InformasiKamarController extends GetxController {
  // Data kamar
  final nomorKamar = 'A-102'.obs;
  final namaKost = 'Green Valley Kost'.obs;
  final status = 'Terisi'.obs;
  final hargaPerBulan = 'Rp 1.500.000'.obs;
  
  // Data penghuni
  final namaPenghuni = 'Arkana'.obs;
  final telepon = '082232200231'.obs;
  final tanggalMasuk = '27 Maret 2026'.obs;
  
  // Data kontrak
  final statusKontrak = 'Aktif'.obs;
  final durasiKontrak = '6 Bulan'.obs;
  final sistemPembayaran = '2 Bulan Sekali'.obs;
  final periodeKontrak = '27 Maret 2026 - 27 September 2026'.obs;
  final totalTagihan = '3x pembayaran'.obs;
  final perTagihan = 'Rp 3.000.000'.obs;
  final totalNilaiKontrak = 'Rp 9.000.000'.obs;

  @override
  void onInit() {
    super.onInit();
    // Load data dari arguments jika ada
    if (Get.arguments != null) {
      final kamar = Get.arguments as Map<String, dynamic>;
      nomorKamar.value = kamar['nomor'] ?? 'A-102';
      status.value = kamar['status'] ?? 'Terisi';
      hargaPerBulan.value = kamar['harga'] ?? 'Rp 1.500.000';
      
      // Jika ada data penghuni
      if (kamar['penghuni'] != null) {
        namaPenghuni.value = kamar['penghuni'];
      }
    }
  }

  void goBack() {
    Get.back();
  }

  void tambahPenghuni() {
    Get.toNamed('/tambah-penghuni', arguments: {
      'nomor': nomorKamar.value,
      'harga': hargaPerBulan.value,
    });
  }
}
