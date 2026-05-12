import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/toast_helper.dart';
import 'package:intl/intl.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/keuangan_repository.dart';

class DetailKeuanganKostController extends GetxController {
  final KeuanganRepository _keuanganRepo;

  DetailKeuanganKostController({KeuanganRepository? keuanganRepository})
    : _keuanganRepo =
          keuanganRepository ?? RepositoryFactory.instance.keuanganRepository;

  final kostId = ''.obs;
  final kostName = ''.obs;
  final kostAddress = ''.obs;

  final allPemasukanList = <Map<String, dynamic>>[].obs;
  final allPengeluaranList = <Map<String, dynamic>>[].obs;

  final pemasukanList = <Map<String, dynamic>>[].obs;
  final pengeluaranList = <Map<String, dynamic>>[].obs;

  final selectedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  // Financial summary
  final totalPemasukan = 0.0.obs;
  final totalPengeluaran = 0.0.obs;
  final labaBersih = 0.0.obs;

  // Chart data
  final pemasukanChartData = <double>[].obs;
  final pengeluaranChartData = <double>[].obs;
  final chartLabels = <String>[].obs;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  // PageView controller for swipeable cards
  final pageController = PageController();
  final currentPage = 0.obs;

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

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> loadKeuanganData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // TODO: Sinkronisasi pemasukan dari pembayaran verified (untuk data historis)
      // Method sinkronisasiPemasukanFromPembayaran belum ada di KeuanganRepository
      // Akan ditambahkan di fase berikutnya

      await Future.wait([
        loadPembayaranData(),
        loadPengeluaranData(),
        loadChartData(),
      ]);

      filterDataByMonth();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: ${e.toString()}';
      print('Error loading keuangan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk sinkronisasi manual
  Future<void> sinkronisasiPemasukan() async {
    try {
      isLoading.value = true;
      // TODO: Method sinkronisasiPemasukanFromPembayaran belum ada di KeuanganRepository
      // Akan ditambahkan di fase berikutnya

      // Reload data setelah sinkronisasi
      await loadPembayaranData();
      await loadChartData();
      filterDataByMonth();

      ToastHelper.showSuccess(
        'Sinkronisasi pemasukan berhasil',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      ToastHelper.showError(
        'Sinkronisasi pemasukan gagal: ${e.toString()}',
        title: 'Gagal',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPembayaranData() async {
    try {
      // Use getPemasukanList with kostId filter
      final data = await _keuanganRepo.getPemasukanList(kostId: kostId.value);
      allPemasukanList.value = data;
      print('Loaded ${data.length} pemasukan records');
    } catch (e) {
      print('Error loading pemasukan: $e');
      allPemasukanList.clear();
    }
  }

  Future<void> loadPengeluaranData() async {
    try {
      final data = await _keuanganRepo.getPengeluaranList(kostId: kostId.value);
      allPengeluaranList.value = data;
      print('Loaded ${data.length} pengeluaran records');
    } catch (e) {
      print('Error loading pengeluaran: $e');
      allPengeluaranList.clear();
    }
  }

  Future<void> loadChartData() async {
    try {
      final pemasukanData = await _keuanganRepo.getPemasukanList(
        kostId: kostId.value,
      );
      final pengeluaranData = await _keuanganRepo.getPengeluaranList(
        kostId: kostId.value,
      );

      // Find earliest and latest transaction dates
      DateTime? earliestDate;
      DateTime? latestDate;

      // Check pemasukan dates
      for (final item in pemasukanData) {
        final tanggal = _parseDate(item['tanggal']);
        if (tanggal != null) {
          if (earliestDate == null || tanggal.isBefore(earliestDate)) {
            earliestDate = tanggal;
          }
          if (latestDate == null || tanggal.isAfter(latestDate)) {
            latestDate = tanggal;
          }
        }
      }

      // Check pengeluaran dates
      for (final item in pengeluaranData) {
        final tanggal = _parseDate(item['tanggal']);
        if (tanggal != null) {
          if (earliestDate == null || tanggal.isBefore(earliestDate)) {
            earliestDate = tanggal;
          }
          if (latestDate == null || tanggal.isAfter(latestDate)) {
            latestDate = tanggal;
          }
        }
      }

      // Generate months for chart
      final months = <DateTime>[];

      // SINKRONISASI GRAFIK: Gunakan parameter filter periode agar selalu menyesuaikan bulan yang dipilih
      final endMonth = DateTime(
        selectedMonth.value.year,
        selectedMonth.value.month,
        1,
      );

      // Always generate exactly 6 months ending at endMonth to ensure chart draws lines instead of dots
      var tempMonth = DateTime(endMonth.year, endMonth.month - 5, 1);
      while (tempMonth.isBefore(endMonth) ||
          tempMonth.isAtSameMomentAs(endMonth)) {
        months.add(tempMonth);
        tempMonth = DateTime(tempMonth.year, tempMonth.month + 1, 1);
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

        pemasukanByMonth.add(
          (pemasukanTotal / 1000000).isFinite ? pemasukanTotal / 1000000 : 0.0,
        ); // Convert to millions
        pengeluaranByMonth.add(
          (pengeluaranTotal / 1000000).isFinite
              ? pengeluaranTotal / 1000000
              : 0.0,
        );
        labels.add(_getMonthName(month.month));
      }

      pemasukanChartData.value = pemasukanByMonth;
      pengeluaranChartData.value = pengeluaranByMonth;
      chartLabels.value = labels;

      // Validasi data sebelum mengirim ke grafik
      final validPemasukan = pemasukanByMonth.every((value) => value.isFinite);
      final validPengeluaran = pengeluaranByMonth.every(
        (value) => value.isFinite,
      );

      if (!validPemasukan || !validPengeluaran) {
        print('⚠️ Warning: Invalid data detected in chart, using fallback');
        pemasukanChartData.value = List.filled(labels.length, 0.0);
        pengeluaranChartData.value = List.filled(labels.length, 0.0);
      }

      print(
        '📊 Chart data loaded: ${labels.length} months from ${labels.isNotEmpty ? labels.first : 'N/A'} to ${labels.isNotEmpty ? labels.last : 'N/A'}',
      );
    } catch (e) {
      print('Error loading chart data: $e');
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

  // Helper method untuk parsing amount yang robust
  int _parseAmount(dynamic amountData) {
    // Jika sudah integer, langsung return
    if (amountData is int) return amountData;

    // Jika string atau tipe lain, parse ke integer
    final amountString = amountData?.toString() ?? '0';
    final cleanAmountString = amountString.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanAmountString) ?? 0;
  }

  void addPengeluaran(Map<String, dynamic> data) async {
    try {
      final amount = _parseAmount(data['amount']);

      final date = data['date'] as DateTime;
      final title = data['title'] as String;
      final description = data['description'] as String;

      // Simpan ke database (convert int ke double untuk repository)
      await _keuanganRepo.createPengeluaran(
        kostId: kostId.value,
        nama: title,
        jumlah: amount.toDouble(),
        tanggal: date,
        deskripsi: description,
      );

      // Reload data
      await loadPengeluaranData();
      await loadChartData();
      filterDataByMonth();

      ToastHelper.showSuccess(
        'Pengeluaran berhasil ditambahkan',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      ToastHelper.showError(
        'Gagal menambahkan pengeluaran: ${e.toString()}',
        title: 'Gagal',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void editPengeluaran(int index, Map<String, dynamic> data) async {
    try {
      final amount = _parseAmount(data['amount']);

      final date = data['date'] as DateTime;
      final title = data['title'] as String;
      final description = data['description'] as String;

      // Get ID from list
      final pengeluaranId = pengeluaranList[index]['id']?.toString() ?? '';
      if (pengeluaranId.isEmpty) {
        throw Exception('ID pengeluaran tidak ditemukan');
      }

      // Update di database (convert int ke double untuk repository)
      await _keuanganRepo.updatePengeluaran(
        id: pengeluaranId,
        kostId: kostId.value,
        nama: title,
        jumlah: amount.toDouble(),
        tanggal: date,
        deskripsi: description,
      );

      // Reload data
      await loadPengeluaranData();
      await loadChartData();
      filterDataByMonth();

      ToastHelper.showSuccess(
        'Pengeluaran berhasil diupdate',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      ToastHelper.showError(
        'Gagal mengupdate pengeluaran: ${e.toString()}',
        title: 'Gagal',
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
      await _keuanganRepo.deletePengeluaran(pengeluaranId);

      // Reload data
      await loadPengeluaranData();
      await loadChartData();
      filterDataByMonth();

      ToastHelper.showSuccess(
        'Pengeluaran berhasil dihapus',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      ToastHelper.showError(
        'Gagal menghapus pengeluaran: ${e.toString()}',
        title: 'Gagal',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void calculateFinancialSummary() {
    // Calculate total pemasukan
    totalPemasukan.value = pemasukanList.fold<double>(0.0, (sum, item) {
      final jumlah = item['jumlah'];
      if (jumlah is int) return sum + jumlah.toDouble();
      if (jumlah is double) return sum + jumlah;
      return sum + (double.tryParse(jumlah?.toString() ?? '0') ?? 0.0);
    });

    // Calculate total pengeluaran
    totalPengeluaran.value = pengeluaranList.fold<double>(0.0, (sum, item) {
      final jumlah = item['jumlah'];
      if (jumlah is int) return sum + jumlah.toDouble();
      if (jumlah is double) return sum + jumlah;
      return sum + (double.tryParse(jumlah?.toString() ?? '0') ?? 0.0);
    });

    // Calculate laba bersih
    labaBersih.value = totalPemasukan.value - totalPengeluaran.value;
  }

  void filterDataByMonth() {
    pemasukanList.value = allPemasukanList.where((item) {
      final date = _parseDate(item['tanggal']);
      if (date == null) return false;
      return date.year == selectedMonth.value.year &&
          date.month == selectedMonth.value.month;
    }).toList();

    pengeluaranList.value = allPengeluaranList.where((item) {
      final date = _parseDate(item['tanggal']);
      if (date == null) return false;
      return date.year == selectedMonth.value.year &&
          date.month == selectedMonth.value.month;
    }).toList();

    calculateFinancialSummary();
    loadChartData(); // Perbarui grafik setiap kali filter bulan diubah (sinkronisasi UI)
  }

  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
    filterDataByMonth();
  }

  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
    filterDataByMonth();
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
