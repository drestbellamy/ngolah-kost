import 'package:get/get.dart';
import '../models/ringkasan_keuangan_model.dart';

class RingkasanKeuanganController extends GetxController {
  final kostList = <RingkasanKeuanganModel>[].obs;
  final totalPemasukan = 0.0.obs;
  final totalPengeluaran = 0.0.obs;
  final totalLabaBersih = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  void loadDummyData() {
    kostList.value = [
      RingkasanKeuanganModel(
        kostId: '1',
        kostName: 'Green Valley Kost',
        kostAddress: 'Jl. Sudirman No. 123, Jakarta',
        pemasukan: 1500000,
        pengeluaran: 1100000,
        labaBersih: 450000,
      ),
      RingkasanKeuanganModel(
        kostId: '2',
        kostName: 'Sunrise Boarding House',
        kostAddress: 'Jl. Gatot Subroto No. 45, Jakarta',
        pemasukan: 0,
        pengeluaran: 1000000,
        labaBersih: -1000000,
      ),
      RingkasanKeuanganModel(
        kostId: '3',
        kostName: 'Peaceful Haven Kost',
        kostAddress: 'Jl. Thamrin No. 67, Jakarta',
        pemasukan: 0,
        pengeluaran: 250000,
        labaBersih: -250000,
      ),
      RingkasanKeuanganModel(
        kostId: '4',
        kostName: 'Urban Residence',
        kostAddress: 'Jl. HR Rasuna Said No. 89, Jakarta',
        pemasukan: 1700000,
        pengeluaran: 180000,
        labaBersih: 1500000,
      ),
      RingkasanKeuanganModel(
        kostId: '5',
        kostName: 'Cozy Corner Kost',
        kostAddress: 'Jl. Kuningan No. 34, Jakarta',
        pemasukan: 0,
        pengeluaran: 150000,
        labaBersih: -1500000,
      ),
    ];

    calculateTotals();
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
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }
}
