import 'package:get/get.dart';
import '../controllers/user_history_pembayaran_controller.dart';

class UserHistoryPembayaranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserHistoryPembayaranController>(
      () => UserHistoryPembayaranController(),
    );
  }
}
