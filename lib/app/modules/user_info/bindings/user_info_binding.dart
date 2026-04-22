import 'package:get/get.dart';
import '../controllers/user_info_controller.dart';
import '../../../../repositories/repository_factory.dart';

class UserInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserInfoController>(
      () => UserInfoController(
        penghuniRepository: RepositoryFactory.instance.penghuniRepository,
        pengumumanRepository: RepositoryFactory.instance.pengumumanRepository,
        peraturanRepository: RepositoryFactory.instance.peraturanRepository,
      ),
    );
  }
}
