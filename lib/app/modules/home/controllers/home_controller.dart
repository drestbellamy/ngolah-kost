import 'package:get/get.dart';
import '../../kelola_pengumuman/bindings/kelola_pengumuman_binding.dart';
import '../../kelola_pengumuman/views/kelola_pengumuman_view.dart';
import '../../ringkasan_keuangan/bindings/ringkasan_keuangan_binding.dart';
import '../../ringkasan_keuangan/views/ringkasan_keuangan_view.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/dashboard_repository.dart';
import '../views/widgets/ringkasan_keuangan_widget.dart';
import '../../../core/utils/toast_helper.dart';

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
      ToastHelper.showError(
        'Gagal memuat data dashboard: $e',
        title: 'Error',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToKelolaTagihan() async {
    await Get.toNamed('/kelola-tagihan');
    refreshAllData();
  }

  void navigateToMetodePembayaran() async {
    await Get.toNamed('/metode-pembayaran');
    refreshAllData();
  }

  void navigateToKelolaKeuangan() async {
    try {
      print("Menu Kelola Keuangan ditekan - mencoba navigasi langsung...");
      await Get.to(
        () => const RingkasanKeuanganView(),
        binding: RingkasanKeuanganBinding(),
      );
      refreshAllData();
    } catch (e) {
      ToastHelper.showError('Gagal membuka halaman: $e', title: 'Error Navigasi');
      print("Navigasi error: $e");
    }
  }

  void navigateToKelolaPengumuman() async {
    try {
      print("Menu Kelola Pengumuman ditekan - mencoba navigasi langsung...");
      await Get.to(
        () => const KelolaPengumumanView(),
        binding: KelolaPengumumanBinding(),
      );
      refreshAllData();
    } catch (e) {
      ToastHelper.showError('Gagal membuka halaman: $e', title: 'Error Navigasi');
      print("Navigasi error: $e");
    }
  }

  void navigateToKelolaPeraturan() async {
    await Get.toNamed('/kelola-peraturan');
    refreshAllData();
  }

  void navigateToKelolaPengaduan() async {
    await Get.toNamed('/kelola-pengaduan');
    refreshAllData();
  }

  void navigateToVerifikasi() async {
    await Get.toNamed('/kelola-tagihan');
    refreshAllData();
  }

  void refreshAllData() {
    loadDashboardData();
    
    // Refresh the Ringkasan Keuangan widget if it's already in the widget tree
    if (Get.isRegistered<RingkasanKeuanganWidgetController>()) {
      Get.find<RingkasanKeuanganWidgetController>().loadRingkasanKeuangan();
    }
  }
}
