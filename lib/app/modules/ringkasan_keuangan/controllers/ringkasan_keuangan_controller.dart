import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/kost_repository.dart';
import '../../../../repositories/keuangan_repository.dart';
import '../models/ringkasan_keuangan_model.dart';

class RingkasanKeuanganController extends GetxController {
  final KostRepository _kostRepo;
  final KeuanganRepository _keuanganRepo;

  RingkasanKeuanganController({
    KostRepository? kostRepository,
    KeuanganRepository? keuanganRepository,
  }) : _kostRepo = kostRepository ?? RepositoryFactory.instance.kostRepository,
       _keuanganRepo =
           keuanganRepository ?? RepositoryFactory.instance.keuanganRepository;

  final kostList = <RingkasanKeuanganModel>[].obs;
  final totalPemasukan = 0.0.obs;
  final totalPengeluaran = 0.0.obs;
  final totalLabaBersih = 0.0.obs;
  
  // Chart data
  final pemasukanChartData = <double>[].obs;
  final pengeluaranChartData = <double>[].obs;
  final chartLabels = <String>[].obs;
  
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
      final kosts = await _kostRepo.getKostList();
      final List<RingkasanKeuanganModel> tempList = [];

      for (final kost in kosts) {
        final ringkasan = await _keuanganRepo.getFinancialSummary(
          kostId: kost.id,
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
      await loadChartData();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data keuangan: ${e.toString()}';
      kostList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadChartData() async {
    try {
      // Get all pemasukan and pengeluaran data from all kosts
      final List<Map<String, dynamic>> allPemasukan = [];
      final List<Map<String, dynamic>> allPengeluaran = [];

      for (final kost in kostList) {
        final pemasukanData = await _keuanganRepo.getPemasukanList(
          kostId: kost.kostId,
        );
        final pengeluaranData = await _keuanganRepo.getPengeluaranList(
          kostId: kost.kostId,
        );

        allPemasukan.addAll(pemasukanData);
        allPengeluaran.addAll(pengeluaranData);
      }

      // Find earliest and latest transaction dates
      DateTime? earliestDate;
      DateTime? latestDate;

      // Check pemasukan dates
      for (final item in allPemasukan) {
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
      for (final item in allPengeluaran) {
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
      final now = DateTime.now();
      final months = <DateTime>[];

      if (earliestDate != null && latestDate != null) {
        // Start from earliest transaction month
        final startMonth = DateTime(earliestDate.year, earliestDate.month, 1);
        // End at the latest between current month and latest transaction month
        final currentMonth = DateTime(now.year, now.month, 1);
        final latestTransactionMonth = DateTime(
          latestDate.year,
          latestDate.month,
          1,
        );
        final endMonth = latestTransactionMonth.isAfter(currentMonth)
            ? latestTransactionMonth
            : currentMonth;

        // Calculate months between start and end
        var tempMonth = startMonth;
        final allMonths = <DateTime>[];

        while (tempMonth.isBefore(endMonth) ||
            tempMonth.isAtSameMomentAs(endMonth)) {
          allMonths.add(tempMonth);
          tempMonth = DateTime(tempMonth.year, tempMonth.month + 1, 1);
        }

        // Take last 6 months or all months if less than 6
        if (allMonths.length > 6) {
          months.addAll(allMonths.sublist(allMonths.length - 6));
        } else {
          months.addAll(allMonths);
        }
      } else {
        // No data found, show current month only
        months.add(DateTime(now.year, now.month, 1));
      }

      final pemasukanByMonth = <double>[];
      final pengeluaranByMonth = <double>[];
      final labels = <String>[];

      for (final month in months) {
        // Calculate pemasukan for this month
        final pemasukanTotal = allPemasukan.fold<double>(0.0, (sum, item) {
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
        final pengeluaranTotal = allPengeluaran.fold<double>(0.0, (sum, item) {
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
