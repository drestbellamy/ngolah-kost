import 'package:get/get.dart';
import '../controllers/kelola_tagihan_controller.dart';

class KelolaTagihanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaTagihanController>(() => KelolaTagihanController());
  }
}
