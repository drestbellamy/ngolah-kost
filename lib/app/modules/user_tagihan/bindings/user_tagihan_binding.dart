import 'package:get/get.dart';
import '../controllers/user_tagihan_controller.dart';

class UserTagihanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserTagihanController>(() => UserTagihanController());
  }
}
