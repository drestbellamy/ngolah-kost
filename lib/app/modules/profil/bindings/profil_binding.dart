import 'package:get/get.dart';
import '../controllers/profil_controller.dart';
import '../../../../repositories/repository_factory.dart';

class ProfilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfilController>(
      () => ProfilController(
        authRepository: RepositoryFactory.instance.authRepository,
        storageRepository: RepositoryFactory.instance.storageRepository,
      ),
    );
  }
}
