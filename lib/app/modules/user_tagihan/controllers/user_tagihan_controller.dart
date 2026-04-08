import 'package:get/get.dart';
import '../../../data/models/tagihan_user_model.dart';
import 'package:intl/intl.dart';

class UserTagihanController extends GetxController {
  final RxList<TagihanUserModel> semuaTagihan = <TagihanUserModel>[].obs;

  final RxList<TagihanUserModel> tagihanTerpilih = <TagihanUserModel>[].obs;

  final RxString metodePembayaran = 'Transfer Bank'.obs;

  @override
  void onInit() {
    super.onInit();
    _generateDummyData();
  }

  void _generateDummyData() {
    List<TagihanUserModel> dummy = [];
    double baseBiaya = 1500000.0;
    DateTime contractStart = DateTime(2026, 1, 1);

    for (int i = 0; i < 6; i++) {
      DateTime periodeStart = DateTime(
        contractStart.year,
        contractStart.month + (i * 2),
        1,
      );
      DateTime jatuhTempo = DateTime(periodeStart.year, periodeStart.month, 20);

      String namaBulan = DateFormat('MMMM yyyy', 'id_ID').format(periodeStart);

      dummy.add(
        TagihanUserModel(
          id: 'TGH-2026-${i + 1}',
          nomorKamar: 'Kamar A-101',
          periodePenagihan: namaBulan,
          jatuhTempo: jatuhTempo,
          totalBayar: baseBiaya,
          status: 'Belum Dibayar',
        ),
      );
    }

    semuaTagihan.assignAll(dummy);
  }

  List<TagihanUserModel> get tagihanBelumDibayar =>
      semuaTagihan.where((t) => t.status == 'Belum Dibayar').toList();

  double get totalBayarTerpilih {
    return tagihanTerpilih.fold(0.0, (sum, item) => sum + item.totalBayar);
  }

  void toggleTagihan(TagihanUserModel tagihan) {
    if (tagihanTerpilih.contains(tagihan)) {
      tagihanTerpilih.remove(tagihan);
    } else {
      tagihanTerpilih.add(tagihan);
    }
  }
}
