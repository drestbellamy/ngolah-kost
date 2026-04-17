import 'package:get/get.dart';
import '../../../../services/supabase_service.dart';
import '../models/ringkasan_keuangan_model.dart';

class RingkasanKeuanganController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  final kostList = <RingkasanKeuanganModel>[].obs;
  final totalPemasukan = 0.0.obs;
  final totalPengeluaran = 0.0.obs;
  final totalLabaBersih = 0.0.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadKeuanganData();
  }

  Future<void> loadKeuanganData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final kosts = await _supabaseService.getKostList();
      final List<RingkasanKeuanganModel> tempList = [];

      for (final kost in kosts) {
        final ringkasan = await _supabaseService.getRingkasanKeuanganByKostId(
          kost.id,
        );

        tempList.add(
          RingkasanKeuanganModel(
            kostId: kost.id,
            kostName: kost.name.trim().isEmpty ? 'Kost' : kost.name.trim(),
            kostAddress: kost.address.trim().isEmpty
                ? '-'
                : kost.address.trim(),
            pemasukan: ringkasan['pemasukan'] ?? 0.0,
            pengeluaran: ringkasan['pengeluaran'] ?? 0.0,
            labaBersih: ringkasan['labaBersih'] ?? 0.0,
          ),
        );
      }

      kostList.value = tempList;
      calculateTotals();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data keuangan: ${e.toString()}';
      kostList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void calculateTotals() {
    totalPemasukan.value = kostList.fold(
      0.0,
      (sum, item) => sum + item.pemasukan,
    );
    totalPengeluaran.value = kostList.fold(
      0.0,
      (sum, item) => sum + item.pengeluaran,
    );
    totalLabaBersih.value = kostList.fold(
      0.0,
      (sum, item) => sum + item.labaBersih,
    );
  }

  String formatCurrency(double amount) {
    final absAmount = amount.abs();
    String formatted;

    if (absAmount >= 1000000) {
      formatted = 'Rp ${(absAmount / 1000000).toStringAsFixed(1)} Jt';
    } else if (absAmount >= 1000) {
      formatted = 'Rp ${(absAmount / 1000).toStringAsFixed(0)} Rb';
    } else {
      formatted = 'Rp ${absAmount.toStringAsFixed(0)}';
    }

    return amount < 0 ? '-$formatted' : formatted;
  }
}
