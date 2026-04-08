import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../services/supabase_service.dart';

class InformasiKamarController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  // Data kamar
  final kamarId = ''.obs;
  final nomorKamar = 'A-101'.obs;
  final namaKost = 'Green Valley Kost'.obs;
  final status = 'Terisi'.obs;
  final hargaPerBulan = 'Rp 1.500.000'.obs;
  final kapasitas = 2.obs;
  final terisi = 1.obs;

  // Data penghuni (bisa lebih dari satu)
  final daftarPenghuni = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Load data dari arguments jika ada
    if (Get.arguments != null) {
      final kamar = Get.arguments as Map<String, dynamic>;
      kamarId.value = kamar['id']?.toString() ?? '';
      nomorKamar.value = kamar['nomor'] ?? 'A-101';
      status.value = kamar['status'] ?? 'Terisi';
      hargaPerBulan.value = kamar['harga'] ?? 'Rp 1.500.000';
      kapasitas.value = kamar['kapasitas'] ?? 2;
      terisi.value = kamar['terisi'] ?? (status.value == 'Ditempati' ? 1 : 0);
      fetchPenghuniData();
    }
  }

  Future<void> fetchPenghuniData() async {
    if (kamarId.value.isEmpty) return;

    try {
      final response = await _supabaseService.getPenghuniByKamarId(
        kamarId.value,
      );
      final mapped = response.map((item) {
        final tanggalMasukDate = DateTime.tryParse(
          item['tanggal_masuk']?.toString() ?? '',
        );
        final tanggalKeluarDate = DateTime.tryParse(
          item['tanggal_keluar']?.toString() ?? '',
        );
        final durasi = item['durasi_kontrak'] ?? 0;
        final statusDb = (item['status']?.toString().toLowerCase() ?? 'aktif');

        return {
          'id': item['id']?.toString() ?? '',
          'nama': 'Penghuni',
          'telepon': '-',
          'username': '-',
          'statusKontrak': statusDb == 'aktif' ? 'Aktif' : 'Berakhir',
          'durasiKontrak': '$durasi Bulan',
          'siklusBayar': 'Bulanan (1 bulan)',
          'tanggalMulai': _formatDateId(tanggalMasukDate),
          'tanggalBerakhir': _formatDateId(tanggalKeluarDate),
          'hargaSewa': hargaPerBulan.value.replaceAll('/Bulan', ''),
          'isExpanded': false,
        };
      }).toList();

      daftarPenghuni.assignAll(mapped);
      terisi.value = daftarPenghuni.length;
      status.value = daftarPenghuni.isEmpty ? 'Kosong' : 'Ditempati';
    } catch (_) {
      // Keep existing UI data when fetch fails.
    }
  }

  String _formatDateId(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  void toggleExpand(int index) {
    var penghuni = Map<String, dynamic>.from(daftarPenghuni[index]);
    penghuni['isExpanded'] = !(penghuni['isExpanded'] as bool);
    daftarPenghuni[index] = penghuni;
  }

  void goBack() {
    Get.back();
  }

  void tambahPenghuni() async {
    final result = await Get.toNamed(
      '/tambah-penghuni',
      arguments: {
        'kamar_id': kamarId.value,
        'nomor': nomorKamar.value,
        'harga': hargaPerBulan.value,
      },
    );

    // Jika ada data yang dikembalikan dari form tambah penghuni
    if (result != null && result is Map<String, dynamic>) {
      await fetchPenghuniData();
      status.value = daftarPenghuni.isEmpty ? 'Kosong' : 'Ditempati';
    }
  }
}
