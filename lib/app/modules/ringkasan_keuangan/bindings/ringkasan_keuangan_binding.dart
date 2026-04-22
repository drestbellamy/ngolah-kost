import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../controllers/ringkasan_keuangan_controller.dart';

class RingkasanKeuanganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RingkasanKeuanganController>(
      () => RingkasanKeuanganController(
        kostRepository: RepositoryFactory.instance.kostRepository,
        keuanganRepository: RepositoryFactory.instance.keuanganRepository,
      ),
    );
  }
}
