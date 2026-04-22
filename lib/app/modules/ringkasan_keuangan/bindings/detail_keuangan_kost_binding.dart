import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../controllers/detail_keuangan_kost_controller.dart';

class DetailKeuanganKostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailKeuanganKostController>(
      () => DetailKeuanganKostController(
        keuanganRepository: RepositoryFactory.instance.keuanganRepository,
      ),
    );
  }
}
