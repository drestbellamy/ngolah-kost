import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../services/supabase_service.dart';

class DetailKeuanganKostController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();

  final kostId = ''.obs;
  final kostName = ''.obs;
  final kostAddress = ''.obs;

  final pemasukanList = <Map<String, dynamic>>[].obs;
  final pengeluaranList = <Map<String, dynamic>>[].obs;

  // Chart data
  final pemasukanChartData = <double>[].obs;
  final pengeluaranChartData = <double>[].obs;
  final chartLabels = <String>[].obs;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();

    // Get data from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      kostId.value = args['kostId'] ?? '';
      kostName.value = args['kostName'] ?? '';
      kostAddress.value = args['kostAddress'] ?? '';
    }

    if (kostId.value.isNotEmpty) {
      loadKeuanganData();
    }
  }

  Future<void> loadKeuanganData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await Future.wait([
        loadPembayaranData(),
        loadPengeluaranData(),
        loadChartData(),
      ]);
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: ${e.toString()}';
      print('Error loading keuangan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPembayaranData() async {
    try {
      final data = await _supabaseService.getPemasukanByKostId(kostId.value);
      pemasukanList.value = data;
      print('Loaded ${data.length} pemasukan records');
    } catch (e) {
      print('Error loading pemasukan: $e');
      pemasukanList.clear();
    }
  }

  Future<void> loadPengeluaranData() async {
    try {
      final data = await _supabaseService.getPengeluaranByKostId(kostId.value);
      pengeluaranList.value = data;
      print('Loaded ${data.length} pengeluaran records');
    } catch (e) {
      print('Error loading pengeluaran: $e');
      pengeluaranList.clear();
    }
  }

  Future<void> loadChartData() async {
    try {
      final pemasukanData = await _supabaseService.getPemasukanByKostId(
        kostId.value,
      );
      final pengeluaranData = await _supabaseService.getPengeluaranByKostId(
        kostId.value,
      );

      // Group data by month for last 6 months
      final now = DateTime.now();
      final months = <DateTime>[];
      for (var i = 5; i >= 0; i--) {
        months.add(DateTime(now.year, now.month - i, 1));
      }

      final pemasukanByMonth = <double>[];
      final pengeluaranByMonth = <double>[];
      final labels = <String>[];

      for (final month in months) {
        // Calculate pemasukan for this month
        final pemasukanTotal = pemasukanData.fold<double>(0.0, (sum, item) {
          final tanggal = _parseDate(item['tanggal']);
          if (tanggal != null &&
              tanggal.year == month.year &&
              tanggal.month == month.month) {
            final jumlah = item['jumlah'];
            if (jumlah is int) return sum + jumlah.toDouble();
            if (jumlah is double) return sum + jumlah;
            return sum + (double.tryParse(jumlah?.toString() ?? '0') ?? 0.0);
          }
          return sum;
        });

        // Calculate pengeluaran for this month
        final pengeluaranTotal = pengeluaranData.fold<double>(0.0, (sum, item) {
          final tanggal = _parseDate(item['tanggal']);
          if (tanggal != null &&
              tanggal.year == month.year &&
              tanggal.month == month.month) {
            final jumlah = item['jumlah'];
            if (jumlah is int) return sum + jumlah.toDouble();
            if (jumlah is double) return sum + jumlah;
            return sum + (double.tryParse(jumlah?.toString() ?? '0') ?? 0.0);
          }
          return sum;
        });

        pemasukanByMonth.add(pemasukanTotal / 1000000); // Convert to millions
        pengeluaranByMonth.add(pengeluaranTotal / 1000000);
        labels.add(_getMonthName(month.month));
      }

      pemasukanChartData.value = pemasukanByMonth;
      pengeluaranChartData.value = pengeluaranByMonth;
      chartLabels.value = labels;
    } catch (e) {
      pemasukanChartData.clear();
      pengeluaranChartData.clear();
      chartLabels.clear();
    }
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is DateTime) return dateValue;
    try {
      return DateTime.parse(dateValue.toString());
    } catch (_) {
      return null;
    }
  }

  void addPengeluaran(Map<String, dynamic> data) async {
    try {
      final amount = double.tryParse(data['amount']) ?? 0;
      final date = data['date'] as DateTime;
      final title = data['title'] as String;
      final description = data['description'] as String;

      // Simpan ke database
      await _supabaseService.createPengeluaran(
        kostId: kostId.value,
        nama: title,
        jumlah: amount,
        tanggal: date,
        deskripsi: description,
      );

      // Reload data
      await loadPengeluaranData();
      await loadChartData();

      Get.snackbar(
        'Berhasil',
        'Pengeluaran berhasil ditambahkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menambahkan pengeluaran: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void editPengeluaran(int index, Map<String, dynamic> data) async {
    try {
      final amount = double.tryParse(data['amount']) ?? 0;
      final date = data['date'] as DateTime;
      final title = data['title'] as String;
      final description = data['description'] as String;

      // Get ID from list
      final pengeluaranId = pengeluaranList[index]['id']?.toString() ?? '';
      if (pengeluaranId.isEmpty) {
        throw Exception('ID pengeluaran tidak ditemukan');
      }

      // Update di database
      await _supabaseService.updatePengeluaran(
        id: pengeluaranId,
        nama: title,
        jumlah: amount,
        tanggal: date,
        deskripsi: description,
      );

      // Reload data
      await loadPengeluaranData();
      await loadChartData();

      Get.snackbar(
        'Berhasil',
        'Pengeluaran berhasil diupdate',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal mengupdate pengeluaran: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void deletePengeluaran(int index) async {
    try {
      // Get ID from list
      final pengeluaranId = pengeluaranList[index]['id']?.toString() ?? '';
      if (pengeluaranId.isEmpty) {
        throw Exception('ID pengeluaran tidak ditemukan');
      }

      // Delete dari database
      await _supabaseService.deletePengeluaran(pengeluaranId);

      // Reload data
      await loadPengeluaranData();
      await loadChartData();

      Get.snackbar(
        'Berhasil',
        'Pengeluaran berhasil dihapus',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menghapus pengeluaran: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)} Jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return amount.toStringAsFixed(0);
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  String formatDate(dynamic dateValue) {
    final date = _parseDate(dateValue);
    if (date == null) return '-';
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }
}
