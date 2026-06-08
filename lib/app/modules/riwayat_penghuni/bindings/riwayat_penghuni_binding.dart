import 'package:get/get.dart';
import '../controllers/riwayat_penghuni_controller.dart';

class RiwayatPenghuniBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatPenghuniController>(
      () => RiwayatPenghuniController(),
    );
  }
}
