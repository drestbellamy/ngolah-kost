import 'package:get/get.dart';
import '../controllers/user_profil_controller.dart';
import '../../../../repositories/repository_factory.dart';

class UserProfilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserProfilController>(
      () => UserProfilController(
        authRepository: RepositoryFactory.instance.authRepository,
        penghuniRepository: RepositoryFactory.instance.penghuniRepository,
        storageRepository: RepositoryFactory.instance.storageRepository,
      ),
    );
  }
}
