import 'package:get/get.dart';
import '../../kelola_pengumuman/bindings/kelola_pengumuman_binding.dart';
import '../../kelola_pengumuman/views/kelola_pengumuman_view.dart';

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
    try {
      print("Menu Kelola Pengumuman ditekan - mencoba navigasi langsung...");
      Get.to(
        () => const KelolaPengumumanView(),
        binding: KelolaPengumumanBinding(),
      );
    } catch (e) {
      Get.snackbar('Error Navigasi', 'Gagal membuka halaman: $e');
      print("Navigasi error: $e");
    }
  }

  void navigateToKelolaPeraturan() {
    Get.toNamed('/kelola-peraturan');
  }

  void navigateToMetodePembayaran() {
    Get.toNamed('/metode-pembayaran');
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
