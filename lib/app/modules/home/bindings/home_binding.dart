import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../controllers/home_controller.dart';
import '../../riwayat_notifikasi/controllers/riwayat_notifikasi_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure RiwayatNotifikasiController is registered for notification badge
    if (!Get.isRegistered<RiwayatNotifikasiController>()) {
      Get.lazyPut<RiwayatNotifikasiController>(
        () => RiwayatNotifikasiController(),
        fenix: true, // Keep alive for notification tracking
      );
    }

    Get.lazyPut<HomeController>(
      () => HomeController(
        dashboardRepository: RepositoryFactory.instance.dashboardRepository,
      ),
    );
  }
}
