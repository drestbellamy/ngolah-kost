import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../../repositories/penghuni_repository.dart';
import '../../../../repositories/pembayaran_repository.dart';
import '../../../../repositories/tagihan_repository.dart';
import '../../../../repositories/metode_pembayaran_repository.dart';
import '../../../../repositories/repository_factory.dart';

class UserHistoryPembayaranController extends GetxController {
  final PenghuniRepository _penghuniRepo;
  final PembayaranRepository _pembayaranRepo;
  final TagihanRepository _tagihanRepo;
  final MetodePembayaranRepository _metodeRepo;
  final authController = Get.find<AuthController>();

  UserHistoryPembayaranController({
    PenghuniRepository? penghuniRepository,
    PembayaranRepository? pembayaranRepository,
    TagihanRepository? tagihanRepository,
    MetodePembayaranRepository? metodePembayaranRepository,
  }) : _penghuniRepo =
           penghuniRepository ?? RepositoryFactory.instance.penghuniRepository,
       _pembayaranRepo =
           pembayaranRepository ??
           RepositoryFactory.instance.pembayaranRepository,
       _tagihanRepo =
           tagihanRepository ?? RepositoryFactory.instance.tagihanRepository,
       _metodeRepo =
           metodePembayaranRepository ??
           RepositoryFactory.instance.metodePembayaranRepository;

  final paymentHistory = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final selectedFilter = 0.obs; // 0: Semua, 1: Lunas, 2: Pending

  @override
  void onInit() {
    super.onInit();
    loadPaymentHistory();
  }

  // Filtered payment history based on selected filter
  List<Map<String, dynamic>> get filteredPaymentHistory {
    if (selectedFilter.value == 0) {
      return paymentHistory; // Semua
    } else if (selectedFilter.value == 1) {
      // Lunas/Terverifikasi
      return paymentHistory
          .where(
            (p) => p['rawStatus'] == 'lunas' || p['rawStatus'] == 'verified',
          )
          .toList();
    } else {
      // Pending
      return paymentHistory.where((p) => p['rawStatus'] == 'pending').toList();
    }
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
  }

  Future<void> loadPaymentHistory() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = authController.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('User tidak ditemukan');
      }

      print('Loading payment history for userId: $userId'); // Debug

      // Get penghuni data first
      final penghuniData = await _penghuniRepo.getPenghuniByUserId(userId);
      if (penghuniData == null) {
        throw Exception('Data penghuni tidak ditemukan');
      }

      final penghuniId = penghuniData['id']?.toString() ?? '';
      final nomorKamar = penghuniData['nomor_kamar']?.toString() ?? '';
      final hargaBulanan = _toInt(penghuniData['harga']);

      print('Penghuni ID: $penghuniId, Nomor Kamar: $nomorKamar'); // Debug

      if (penghuniId.isEmpty) {
        throw Exception('ID penghuni tidak valid');
      }

      // Get pembayaran data from database
      final pembayaranList = await _pembayaranRepo.getPembayaranByPenghuniId(
        penghuniId,
      );
      print('Pembayaran data fetched: ${pembayaranList.length} items'); // Debug

      // Convert to payment history format
      final List<Map<String, dynamic>> history = [];
      for (final item in pembayaranList) {
        final status = item['status']?.toString() ?? 'pending';
        final jumlah = item['jumlah'] as int? ?? 0;
        final tanggal = item['tanggal']?.toString() ?? '';
        final metodeId = item['metode_id']?.toString() ?? '';
        final tagihanId = item['tagihan_id']?.toString() ?? '';

        // Get tagihan info for month/year
        String monthName = 'Pembayaran';
        if (tagihanId.isNotEmpty) {
          try {
            final tagihanData = await _tagihanRepo.getTagihanById(tagihanId);
            if (tagihanData != null) {
              final bulan = tagihanData['bulan'] as int? ?? 0;
              final tahun = tagihanData['tahun'] as int? ?? 0;
              if (bulan > 0 && tahun > 0) {
                final periodeDate = DateTime(tahun, bulan, 1);
                final jumlahTagihan = _toInt(tagihanData['jumlah']);
                final coveredMonths = _estimateCoveredMonthsByAmount(
                  jumlahTagihan,
                  hargaBulanan,
                );
                monthName = _formatPeriodeLabel(periodeDate, coveredMonths);
              }
            }
          } catch (e) {
            print('Error getting tagihan: $e');
          }
        }

        // Get metode pembayaran name
        String metodeName = 'Transfer Bank';
        if (metodeId.isNotEmpty) {
          try {
            final metodeData = await _metodeRepo.getMetodePembayaranById(
              metodeId,
            );
            if (metodeData != null) {
              metodeName = metodeData['nama']?.toString() ?? 'Transfer Bank';
            }
          } catch (e) {
            print('Error getting metode: $e');
          }
        }

        // Parse date
        String formattedDate = '';
        try {
          final date = DateTime.parse(tanggal);
          formattedDate = DateFormat('dd MMM yyyy', 'id_ID').format(date);
        } catch (e) {
          formattedDate = DateFormat(
            'dd MMM yyyy',
            'id_ID',
          ).format(DateTime.now());
        }

        // Map status
        String displayStatus = 'Menunggu Verifikasi';
        if (status == 'lunas' || status == 'verified') {
          displayStatus = 'Terverifikasi';
        } else if (status == 'ditolak' || status == 'rejected') {
          displayStatus = 'Ditolak';
        }

        history.add({
          'id': item['id']?.toString() ?? '',
          'month': monthName,
          'method': metodeName,
          'amount': NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(jumlah),
          'date': formattedDate,
          'status': displayStatus,
          'rawStatus': status,
          'rawAmount': jumlah,
          'buktiPembayaran': item['bukti_pembayaran']?.toString() ?? '',
        });
      }

      // Sort by date (newest first)
      history.sort((a, b) {
        try {
          final dateA = DateFormat('dd MMM yyyy', 'id_ID').parse(a['date']);
          final dateB = DateFormat('dd MMM yyyy', 'id_ID').parse(b['date']);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      print('Payment history converted: ${history.length} items'); // Debug
      paymentHistory.assignAll(history);
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error loading payment history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate total payment based on filter
  String get totalPayment {
    final filtered = filteredPaymentHistory;
    final total = filtered.fold<int>(0, (sum, payment) {
      return sum + (payment['rawAmount'] as int? ?? 0);
    });
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(total);
  }

  // Get payment count based on filter
  int get paymentCount => filteredPaymentHistory.length;

  Future<void> refreshData() async {
    await loadPaymentHistory();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();

    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return 0;

    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9-]'), '');
    return int.tryParse(digitsOnly) ?? 0;
  }

  int _estimateCoveredMonthsByAmount(int jumlahTagihan, int hargaBulanan) {
    if (hargaBulanan <= 0 || jumlahTagihan <= 0) return 1;

    final div = jumlahTagihan ~/ hargaBulanan;
    final remainder = jumlahTagihan % hargaBulanan;
    final covered = remainder > 0 ? div + 1 : div;
    return covered <= 0 ? 1 : covered;
  }

  String _formatPeriodeLabel(DateTime start, int coveredMonths) {
    if (coveredMonths <= 1) {
      return DateFormat('MMMM yyyy', 'id_ID').format(start);
    }

    final end = DateTime(start.year, start.month + coveredMonths - 1, 1);
    final startLabel = DateFormat('MMM', 'id_ID').format(start);
    final endLabel = DateFormat('MMM yyyy', 'id_ID').format(end);
    return '$startLabel - $endLabel';
  }
}
