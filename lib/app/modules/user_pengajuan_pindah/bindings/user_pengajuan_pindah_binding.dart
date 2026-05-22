import 'package:get/get.dart';
import '../controllers/user_pengajuan_pindah_controller.dart';

class UserPengajuanPindahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserPengajuanPindahController>(
      () => UserPengajuanPindahController(),
    );
  }
}
