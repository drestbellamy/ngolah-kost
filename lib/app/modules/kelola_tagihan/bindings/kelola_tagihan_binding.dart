import 'package:get/get.dart';
import '../controllers/kelola_tagihan_controller.dart';
import '../../../../repositories/repository_factory.dart';

class KelolaTagihanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaTagihanController>(
      () => KelolaTagihanController(
        tagihanRepository: RepositoryFactory.instance.tagihanRepository,
        pembayaranRepository: RepositoryFactory.instance.pembayaranRepository,
        penghuniRepository: RepositoryFactory.instance.penghuniRepository,
      ),
    );
  }
}
