import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../controllers/kost_controller.dart';

class KostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KostController>(
      () => KostController(
        kostRepository: RepositoryFactory.instance.kostRepository,
      ),
    );
  }
}
