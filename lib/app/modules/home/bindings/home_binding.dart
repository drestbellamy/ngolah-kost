import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        dashboardRepository: RepositoryFactory.instance.dashboardRepository,
      ),
    );
  }
}
