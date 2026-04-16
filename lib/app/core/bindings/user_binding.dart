import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize NotificationController for user pages
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }
  }
}
