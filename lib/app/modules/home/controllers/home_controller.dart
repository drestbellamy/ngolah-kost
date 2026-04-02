import 'package:get/get.dart';

class HomeController extends GetxController {
  // Dashboard data
  final totalKost = 8.obs;
  final totalKamar = 64.obs;
  final kamarKosong = 12.obs;
  final totalPenghuni = 52.obs;
  final tagihanBelumBayar = 8.obs;
  final menungguVerifikasi = 3.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void navigateToKelolaTagihan() {
    Get.toNamed('/kelola-tagihan');
  }

  void navigateToKelolaPengumuman() {
    Get.toNamed('/kelola-pengumuman');
  }

  void navigateToKelolaPeraturan() {
    Get.toNamed('/kelola-peraturan');
  }

  void navigateToVerifikasi() {
    // Navigate to verification page
    Get.snackbar(
      'Info',
      'Navigasi ke halaman verifikasi pembayaran',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
