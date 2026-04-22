import 'package:get/get.dart';
import '../controllers/user_tagihan_controller.dart';
import '../../../../repositories/repository_factory.dart';

class UserTagihanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserTagihanController>(
      () => UserTagihanController(
        penghuniRepository: RepositoryFactory.instance.penghuniRepository,
        tagihanRepository: RepositoryFactory.instance.tagihanRepository,
        pembayaranRepository: RepositoryFactory.instance.pembayaranRepository,
        metodePembayaranRepository:
            RepositoryFactory.instance.metodePembayaranRepository,
        storageRepository: RepositoryFactory.instance.storageRepository,
      ),
    );
  }
}
