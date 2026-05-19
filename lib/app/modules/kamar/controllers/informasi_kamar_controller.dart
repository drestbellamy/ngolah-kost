import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/penghuni_repository.dart';
import '../../../../repositories/tagihan_repository.dart';
import '../../penghuni/models/penghuni_model.dart';

class InformasiKamarController extends GetxController {
  final PenghuniRepository _penghuniRepo;
  final TagihanRepository _tagihanRepo;

  InformasiKamarController({
    PenghuniRepository? penghuniRepository,
    TagihanRepository? tagihanRepository,
  }) : _penghuniRepo =
           penghuniRepository ?? RepositoryFactory.instance.penghuniRepository,
       _tagihanRepo =
           tagihanRepository ?? RepositoryFactory.instance.tagihanRepository;

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
      final sewaBulanan = _parseCurrencyToInt(hargaPerBulan.value);
      final mapped = await Future.wait(
        response.map((item) async {
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
          final statusDb =
              (item['status']?.toString().toLowerCase() ?? 'aktif');
          final namaUser = (user['nama'] ?? item['nama'] ?? 'Penghuni')
              .toString();
          final teleponUser = (user['no_tlpn'] ?? item['no_tlpn'] ?? '-')
              .toString();
          final usernameUser = (user['username'] ?? item['username'] ?? '-')
              .toString();

          // Format additional data
          final jenisKelamin = item['jenis_kelamin']?.toString() ?? '';
          final tanggalLahirDate = DateTime.tryParse(
            item['tanggal_lahir']?.toString() ?? '',
          );
          final alamatAsal = item['alamat_asal']?.toString() ?? '';
          final namaKontakDarurat =
              item['nama_kontak_darurat']?.toString() ?? '';
          final teleponKontakDarurat =
              item['telepon_kontak_darurat']?.toString() ?? '';
          final hubunganKontakDarurat =
              item['hubungan_kontak_darurat']?.toString() ?? '';

          final penghuniId = item['id']?.toString() ?? '';
          final paidMonths = await _getPaidMonths(
            penghuniId: penghuniId,
            sewaBulanan: sewaBulanan,
            fallbackSiklus: siklusBulan,
            durasiKontrak: _toInt(durasi),
          );

          return {
            'id': item['id']?.toString() ?? '',
            'nama': namaUser.isEmpty ? 'Penghuni' : namaUser,
            'telepon': teleponUser.isEmpty ? '-' : teleponUser,
            'username': usernameUser.isEmpty ? '-' : '@$usernameUser',
            'statusKontrak': statusDb == 'aktif' ? 'Aktif' : 'Berakhir',
            'durasiKontrak': '$durasi Bulan',
            'sudahBayarBulan': '$paidMonths Bulan',
            'tanggalMulai': _formatDateId(tanggalMasukDate),
            'tanggalBerakhir': _formatDateId(tanggalKeluarDate),
            'hargaSewa': hargaPerBulan.value.replaceAll('/Bulan', ''),
            // Additional data
            'jenisKelamin': jenisKelamin.isEmpty ? null : jenisKelamin,
            'tanggalLahir': tanggalLahirDate != null
                ? _formatDateId(tanggalLahirDate)
                : null,
            'alamatAsal': alamatAsal.isEmpty ? null : alamatAsal,
            'namaKontakDarurat': namaKontakDarurat.isEmpty
                ? null
                : namaKontakDarurat,
            'teleponKontakDarurat': teleponKontakDarurat.isEmpty
                ? null
                : teleponKontakDarurat,
            'hubunganKontakDarurat': hubunganKontakDarurat.isEmpty
                ? null
                : hubunganKontakDarurat,
            'isExpanded': false,
          };
        }).toList(),
      );

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

  int _parseCurrencyToInt(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  Future<int> _getPaidMonths({
    required String penghuniId,
    required int sewaBulanan,
    required int fallbackSiklus,
    required int durasiKontrak,
  }) async {
    if (penghuniId.trim().isEmpty) return 0;
    try {
      final rows = await _tagihanRepo.getTagihanByPenghuniId(penghuniId);
      var total = 0;

      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw);
        final status = (row['status'] ?? '').toString().toLowerCase().trim();
        if (status != 'lunas') continue;

        final siklus = _resolveTagihanSiklusBulan(
          row,
          sewaBulanan: sewaBulanan,
          fallbackSiklus: fallbackSiklus,
        );

        if (siklus > 0) {
          total += siklus;
        }
      }

      if (durasiKontrak > 0 && total > durasiKontrak) {
        return durasiKontrak;
      }

      return total;
    } catch (_) {
      return 0;
    }
  }

  int _resolveTagihanSiklusBulan(
    Map<String, dynamic> row, {
    required int sewaBulanan,
    required int fallbackSiklus,
  }) {
    final jumlahTagihan = _toDouble(row['jumlah']);
    if (sewaBulanan <= 0 || jumlahTagihan <= 0) {
      return fallbackSiklus <= 0 ? 1 : fallbackSiklus;
    }

    final ratio = jumlahTagihan / sewaBulanan;
    final rounded = ratio.round();
    if (rounded > 0 && (ratio - rounded).abs() <= 0.15) {
      return rounded;
    }

    return fallbackSiklus <= 0 ? 1 : fallbackSiklus;
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
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

  void goToPenghuniList() {
    Get.toNamed(Routes.penghuni);
  }

  Future<void> goToPenghuniDetail(Map<String, dynamic> penghuniItem) async {
    final penghuniId = (penghuniItem['id'] ?? '').toString();
    if (penghuniId.trim().isEmpty) return;

    try {
      final row = await _penghuniRepo.getPenghuniDetailById(penghuniId);
      if (row == null) {
        ToastHelper.showError('Data penghuni tidak ditemukan.');
        return;
      }

      final fallbackNama = (penghuniItem['nama'] ?? 'Penghuni').toString();
      final fallbackUsername = (penghuniItem['username'] ?? '')
          .toString()
          .trim();
      final fallbackTelepon = (penghuniItem['telepon'] ?? '-').toString();
      final fallbackNomorKamar = (penghuniItem['nomorKamar'] ?? '-').toString();
      final fallbackNamaKost = (penghuniItem['namaKost'] ?? '-').toString();

      final durasi = _toInt(row['durasi_kontrak']);
      final siklusRaw = _toInt(row['sistem_pembayaran_bulan']);
      final siklus = siklusRaw <= 0 ? 1 : siklusRaw;
      final harga = _toDouble(row['harga']);

      final nama = (row['nama'] ?? '').toString().trim();
      final telepon = (row['no_tlpn'] ?? '').toString().trim();
      final nomorKamar = (row['nomor_kamar'] ?? '').toString().trim();
      final namaKost = (row['nama_kost'] ?? '').toString().trim();

      final penghuni = PenghuniModel(
        id: penghuniId,
        nama: nama.isEmpty ? fallbackNama : nama,
        username: fallbackUsername.isEmpty ? null : fallbackUsername,
        noTelepon: telepon.isEmpty ? fallbackTelepon : telepon,
        nomorKamar: nomorKamar.isEmpty ? fallbackNomorKamar : nomorKamar,
        namaKost: namaKost.isEmpty ? fallbackNamaKost : namaKost,
        sewaBulanan: harga,
        tanggalMasuk: _formatDateFlexible(row['tanggal_masuk']),
        durasiKontrak: durasi,
        sistemPembayaran: _formatSistemPembayaran(siklus),
        tanggalBerakhir: _formatDateFlexible(row['tanggal_keluar']),
        totalNilaiKontrak: harga * durasi,
        jenisKelamin: row['jenis_kelamin']?.toString(),
        tanggalLahir: _formatDateFlexible(row['tanggal_lahir']),
        alamatAsal: row['alamat_asal']?.toString(),
        namaKontakDarurat: row['nama_kontak_darurat']?.toString(),
        teleponKontakDarurat: row['telepon_kontak_darurat']?.toString(),
        hubunganKontakDarurat: row['hubungan_kontak_darurat']?.toString(),
      );

      Get.toNamed(Routes.penghuniDetail, arguments: penghuni);
    } catch (_) {
      ToastHelper.showError('Gagal membuka detail penghuni.');
    }
  }

  String _formatDateFlexible(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) return _formatDateId(value);
    final parsed = DateTime.tryParse(value.toString());
    return _formatDateId(parsed);
  }

  String _formatSistemPembayaran(int bulan) {
    if (bulan <= 1) return 'Bulanan (1 bulan)';
    if (bulan == 3) return '3 Bulanan';
    if (bulan == 6) return '6 Bulanan';
    if (bulan == 12) return 'Tahunan (1 tahun)';
    if (bulan == 24) return '2 Tahunan';
    return '$bulan Bulanan';
  }
}
