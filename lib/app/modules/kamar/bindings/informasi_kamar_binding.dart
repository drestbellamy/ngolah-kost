import 'package:get/get.dart';
import '../controllers/informasi_kamar_controller.dart';

class InformasiKamarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InformasiKamarController>(() => InformasiKamarController());
  }
}
