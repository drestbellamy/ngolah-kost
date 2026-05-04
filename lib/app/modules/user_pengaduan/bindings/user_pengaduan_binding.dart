import 'package:get/get.dart';
import '../controllers/user_pengaduan_controller.dart';

class UserPengaduanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserPengaduanController>(() => UserPengaduanController());
  }
}
