import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/penghuni_repository.dart';

class InformasiKamarController extends GetxController {
  final PenghuniRepository _penghuniRepo;

  InformasiKamarController({PenghuniRepository? penghuniRepository})
    : _penghuniRepo =
          penghuniRepository ?? RepositoryFactory.instance.penghuniRepository;

  // Data kamar
  final kamarId = ''.obs;
  final nomorKamar = 'A-101'.obs;
  final namaKost = ''.obs;
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
      namaKost.value = kamar['namaKost']?.toString() ?? '-';
      status.value = kamar['status'] ?? 'Terisi';
      hargaPerBulan.value = kamar['harga'] ?? 'Rp 1.500.000';
      kapasitas.value = kamar['kapasitas'] ?? 2;
      terisi.value = kamar['terisi'] ?? (status.value == 'Kosong' ? 0 : 1);
      fetchPenghuniData();
    }
  }

  String _statusByOccupancy(int currentTerisi, int currentKapasitas) {
    if (currentTerisi <= 0) return 'Kosong';
    if (currentTerisi >= currentKapasitas) return 'Penuh';
    return 'Terisi Sebagian';
  }

  Future<void> fetchPenghuniData() async {
    if (kamarId.value.isEmpty) return;

    try {
      final response = await _penghuniRepo.getPenghuniByKamarId(
        kamarId.value,
        onlyActive: true,
      );
      final mapped = response.map((item) {
        final user = item['users'] is Map
            ? Map<String, dynamic>.from(item['users'] as Map)
            : <String, dynamic>{};

        final tanggalMasukDate = DateTime.tryParse(
          item['tanggal_masuk']?.toString() ?? '',
        );
        final tanggalKeluarDate = DateTime.tryParse(
          item['tanggal_keluar']?.toString() ?? '',
        );
        final durasi = item['durasi_kontrak'] ?? 0;
        final siklusBulanRaw = _toInt(item['sistem_pembayaran_bulan']);
        final siklusBulan = siklusBulanRaw <= 0 ? 1 : siklusBulanRaw;
        final statusDb = (item['status']?.toString().toLowerCase() ?? 'aktif');
        final namaUser = (user['nama'] ?? item['nama'] ?? 'Penghuni')
            .toString();
        final teleponUser = (user['no_tlpn'] ?? item['no_tlpn'] ?? '-')
            .toString();
        final usernameUser = (user['username'] ?? item['username'] ?? '-')
            .toString();

        return {
          'id': item['id']?.toString() ?? '',
          'nama': namaUser.isEmpty ? 'Penghuni' : namaUser,
          'telepon': teleponUser.isEmpty ? '-' : teleponUser,
          'username': usernameUser.isEmpty ? '-' : '@$usernameUser',
          'statusKontrak': statusDb == 'aktif' ? 'Aktif' : 'Berakhir',
          'durasiKontrak': '$durasi Bulan',
          'siklusBayar': _formatSistemPembayaran(siklusBulan),
          'tanggalMulai': _formatDateId(tanggalMasukDate),
          'tanggalBerakhir': _formatDateId(tanggalKeluarDate),
          'hargaSewa': hargaPerBulan.value.replaceAll('/Bulan', ''),
          'isExpanded': false,
        };
      }).toList();

      daftarPenghuni.assignAll(mapped);
      terisi.value = daftarPenghuni.length;
      status.value = _statusByOccupancy(terisi.value, kapasitas.value);
    } catch (_) {
      // Keep existing UI data when fetch fails.
    }
  }

  String _formatDateId(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatSistemPembayaran(int bulan) {
    if (bulan <= 1) return 'Bulanan (1 bulan)';
    if (bulan == 3) return '3 Bulanan';
    if (bulan == 6) return '6 Bulanan';
    if (bulan == 12) return 'Tahunan (1 tahun)';
    if (bulan == 24) return '2 Tahunan';
    return '$bulan Bulanan';
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
        'namaKost': namaKost.value,
        'nomor': nomorKamar.value,
        'harga': hargaPerBulan.value,
      },
    );

    // Jika ada data yang dikembalikan dari form tambah penghuni
    if (result != null && result is Map<String, dynamic>) {
      await fetchPenghuniData();
      status.value = _statusByOccupancy(terisi.value, kapasitas.value);
    }
  }
}
