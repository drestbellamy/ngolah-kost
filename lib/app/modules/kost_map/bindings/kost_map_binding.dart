import 'package:get/get.dart';
import '../controllers/kost_map_controller.dart';

class KostMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KostMapController>(() => KostMapController());
  }
}
