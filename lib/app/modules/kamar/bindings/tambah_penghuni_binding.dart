import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../controllers/tambah_penghuni_controller.dart';

class TambahPenghuniBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahPenghuniController>(
      () => TambahPenghuniController(
        authRepository: RepositoryFactory.instance.authRepository,
        penghuniRepository: RepositoryFactory.instance.penghuniRepository,
        tagihanRepository: RepositoryFactory.instance.tagihanRepository,
        kamarRepository: RepositoryFactory.instance.kamarRepository,
      ),
    );
  }
}
