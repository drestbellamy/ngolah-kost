import 'package:get/get.dart';
import '../controllers/user_history_pembayaran_controller.dart';
import '../../../../repositories/repository_factory.dart';

class UserHistoryPembayaranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserHistoryPembayaranController>(
      () => UserHistoryPembayaranController(
        penghuniRepository: RepositoryFactory.instance.penghuniRepository,
        pembayaranRepository: RepositoryFactory.instance.pembayaranRepository,
        tagihanRepository: RepositoryFactory.instance.tagihanRepository,
        metodePembayaranRepository:
            RepositoryFactory.instance.metodePembayaranRepository,
      ),
    );
  }
}
