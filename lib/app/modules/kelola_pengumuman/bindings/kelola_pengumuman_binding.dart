import 'package:get/get.dart';
import '../controllers/kelola_pengumuman_controller.dart';

class KelolaPengumumanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaPengumumanController>(() => KelolaPengumumanController());
  }
}
