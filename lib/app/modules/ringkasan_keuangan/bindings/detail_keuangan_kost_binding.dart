import 'package:get/get.dart';
import '../controllers/detail_keuangan_kost_controller.dart';

class DetailKeuanganKostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailKeuanganKostController>(
      () => DetailKeuanganKostController(),
    );
  }
}
