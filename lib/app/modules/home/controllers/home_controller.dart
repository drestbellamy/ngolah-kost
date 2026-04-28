import 'package:get/get.dart';
import '../../kelola_pengumuman/bindings/kelola_pengumuman_binding.dart';
import '../../kelola_pengumuman/views/kelola_pengumuman_view.dart';
import '../../ringkasan_keuangan/bindings/ringkasan_keuangan_binding.dart';
import '../../ringkasan_keuangan/views/ringkasan_keuangan_view.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/dashboard_repository.dart';

class HomeController extends GetxController {
  final DashboardRepository _dashboardRepo;

  HomeController({DashboardRepository? dashboardRepository})
    : _dashboardRepo =
          dashboardRepository ?? RepositoryFactory.instance.dashboardRepository;

  // Dashboard data
  final totalKost = 0.obs;
  final totalKamar = 0.obs;
  final kamarKosong = 0.obs;
  final totalPenghuni = 0.obs;
  final tagihanBelumBayar = 0.obs;
  final menungguVerifikasi = 0.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      final stats = await _dashboardRepo.getAdminDashboardStats();

      totalKost.value = stats['totalKost'] ?? 0;
      totalKamar.value = stats['totalKamar'] ?? 0;
      kamarKosong.value = stats['kamarKosong'] ?? 0;
      totalPenghuni.value = stats['totalPenghuni'] ?? 0;
      tagihanBelumBayar.value = stats['tagihanBelumBayar'] ?? 0;
      menungguVerifikasi.value = stats['menungguVerifikasi'] ?? 0;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data dashboard: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToKelolaTagihan() {
    Get.toNamed('/kelola-tagihan');
  }

  void navigateToMetodePembayaran() {
    Get.toNamed('/metode-pembayaran');
  }

  void navigateToKelolaKeuangan() {
    try {
      print("Menu Kelola Keuangan ditekan - mencoba navigasi langsung...");
      Get.to(
        () => const RingkasanKeuanganView(),
        binding: RingkasanKeuanganBinding(),
      );
    } catch (e) {
      Get.snackbar('Error Navigasi', 'Gagal membuka halaman: $e');
      print("Navigasi error: $e");
    }
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

  void navigateToVerifikasi() {
    Get.toNamed('/kelola-tagihan');
  }
}
