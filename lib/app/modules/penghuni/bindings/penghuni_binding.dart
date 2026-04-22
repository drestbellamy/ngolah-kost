import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../controllers/penghuni_controller.dart';

class PenghuniBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PenghuniController>(
      () => PenghuniController(
        kostRepository: RepositoryFactory.instance.kostRepository,
        kamarRepository: RepositoryFactory.instance.kamarRepository,
        penghuniRepository: RepositoryFactory.instance.penghuniRepository,
      ),
    );
  }
}
