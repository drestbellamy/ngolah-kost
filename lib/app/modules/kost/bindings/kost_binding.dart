import 'package:get/get.dart';
import '../controllers/kost_controller.dart';

class KostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KostController>(() => KostController());
  }
}
