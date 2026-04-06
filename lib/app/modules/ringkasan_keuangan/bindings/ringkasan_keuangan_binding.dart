import 'package:get/get.dart';
import '../controllers/ringkasan_keuangan_controller.dart';

class RingkasanKeuanganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RingkasanKeuanganController>(
      () => RingkasanKeuanganController(),
    );
  }
}
