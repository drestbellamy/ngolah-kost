import 'package:get/get.dart';
import '../controllers/admin_pengajuan_pindah_controller.dart';
import '../../../../repositories/pengajuan_pindah_repository.dart';
import '../../../../repositories/repository_factory.dart';

class AdminPengajuanPindahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminPengajuanPindahController>(
      () => AdminPengajuanPindahController(
        repository: RepositoryFactory.instance.pengajuanPindahRepository,
      ),
    );
  }
}
