import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../controllers/metode_pembayaran_controller.dart';

class MetodePembayaranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MetodePembayaranController>(
      () => MetodePembayaranController(
        kostRepository: RepositoryFactory.instance.kostRepository,
        metodePembayaranRepository:
            RepositoryFactory.instance.metodePembayaranRepository,
      ),
    );
  }
}
