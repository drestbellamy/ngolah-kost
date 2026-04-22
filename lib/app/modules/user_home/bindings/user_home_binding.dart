import 'package:get/get.dart';
import '../controllers/user_home_controller.dart';
import '../../../core/controllers/notification_controller.dart';
import '../../../../repositories/repository_factory.dart';

class UserHomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize NotificationController if not already registered
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(), permanent: true);
    }

    Get.lazyPut<UserHomeController>(
      () => UserHomeController(
        authRepository: RepositoryFactory.instance.authRepository,
        penghuniRepository: RepositoryFactory.instance.penghuniRepository,
        tagihanRepository: RepositoryFactory.instance.tagihanRepository,
        pembayaranRepository: RepositoryFactory.instance.pembayaranRepository,
      ),
    );
  }
}
