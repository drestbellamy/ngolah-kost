import 'package:get/get.dart';
import '../controllers/kelola_peraturan_controller.dart';

class KelolaPeraturanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaPeraturanController>(() => KelolaPeraturanController());
  }
}
