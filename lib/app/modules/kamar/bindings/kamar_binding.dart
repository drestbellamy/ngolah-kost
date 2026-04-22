import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../controllers/kamar_controller.dart';

class KamarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KamarController>(
      () => KamarController(
        kamarRepository: RepositoryFactory.instance.kamarRepository,
        penghuniRepository: RepositoryFactory.instance.penghuniRepository,
      ),
    );
  }
}
