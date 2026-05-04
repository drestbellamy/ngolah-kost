import 'package:get/get.dart';
import '../../../../repositories/pengaduan_repository.dart';
import '../controllers/kelola_pengaduan_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaPengaduanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KelolaPengaduanController>(
      () => KelolaPengaduanController(
        pengaduanRepository: PengaduanRepository(Supabase.instance.client),
      ),
    );
  }
}
