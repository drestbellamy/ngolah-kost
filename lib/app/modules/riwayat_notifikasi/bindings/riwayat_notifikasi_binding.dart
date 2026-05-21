import 'package:get/get.dart';
import '../controllers/riwayat_notifikasi_controller.dart';

class RiwayatNotifikasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatNotifikasiController>(
      () => RiwayatNotifikasiController(),
    );
  }
}
