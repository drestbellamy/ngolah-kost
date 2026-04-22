import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../controllers/kelola_pengumuman_controller.dart';

class KelolaPengumumanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaPengumumanController>(
      () => KelolaPengumumanController(
        kostRepository: RepositoryFactory.instance.kostRepository,
        pengumumanRepository: RepositoryFactory.instance.pengumumanRepository,
      ),
    );
  }
}
