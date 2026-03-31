import 'package:get/get.dart';
import '../controllers/tambah_penghuni_controller.dart';

class TambahPenghuniBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahPenghuniController>(
      () => TambahPenghuniController(),
    );
  }
}
