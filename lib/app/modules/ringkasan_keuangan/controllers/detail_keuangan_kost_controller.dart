import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailKeuanganKostController extends GetxController {
  final kostName = ''.obs;
  final kostAddress = ''.obs;

  final pemasukanList = <Map<String, String>>[].obs;
  final pengeluaranList = <Map<String, String>>[].obs;

  // Chart data
  final pemasukanChartData = <double>[].obs;
  final pengeluaranChartData = <double>[].obs;
  final chartLabels = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Get data from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      kostName.value = args['kostName'] ?? '';
      kostAddress.value = args['kostAddress'] ?? '';
    }

    loadDummyData();
    loadChartData();
  }

  void loadDummyData() {
    // Dummy pemasukan data
    pemasukanList.value = [
      {
        'name': 'Ahmad Wijaya',
        'detail': 'A-101 • Maret 2026',
        'amount': '+Rp 1.5 Jt',
      },
    ];

    // Dummy pengeluaran data
    pengeluaranList.value = [
      {
        'title': 'Pemeliharaan',
        'description': 'Perbaikan atap bocor lantai 2',
        'date': '15 Feb 2026',
        'amount': '-Rp 500 Rb',
      },
      {
        'title': 'Utilitas',
        'description': 'Tagihan listrik bulan Februari',
        'date': '1 Mar 2026',
        'amount': '-Rp 350 Rb',
      },
      {
        'title': 'Kebersihan',
        'description': 'Jasa cleaning service mingguan',
        'date': '10 Mar 2026',
        'amount': '-Rp 200 Rb',
      },
    ];
  }

  void loadChartData() {
    // Dummy chart data (in millions for better visualization)
    // Data for Jan, Feb, Mar, Apr, Mei, Jun
    pemasukanChartData.value = [5.0, 5.2, 4.8, 5.5, 5.3, 5.6];
    pengeluaranChartData.value = [2.0, 2.2, 1.9, 2.3, 2.5, 2.1];
    chartLabels.value = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];
  }

  void addPengeluaran(Map<String, dynamic> data) {
    final amount = double.tryParse(data['amount']) ?? 0;
    final date = data['date'] as DateTime;

    pengeluaranList.add({
      'title': data['title'],
      'description': data['description'],
      'date': '${date.day} ${_getMonthName(date.month)} ${date.year}',
      'amount': '-Rp ${_formatAmount(amount)}',
    });

    Get.snackbar(
      'Berhasil',
      'Pengeluaran berhasil ditambahkan',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void editPengeluaran(int index, Map<String, dynamic> data) {
    final amount = double.tryParse(data['amount']) ?? 0;
    final date = data['date'] as DateTime;

    pengeluaranList[index] = {
      'title': data['title'],
      'description': data['description'],
      'date': '${date.day} ${_getMonthName(date.month)} ${date.year}',
      'amount': '-Rp ${_formatAmount(amount)}',
    };

    Get.snackbar(
      'Berhasil',
      'Pengeluaran berhasil diupdate',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void deletePengeluaran(int index) {
    pengeluaranList.removeAt(index);

    Get.snackbar(
      'Berhasil',
      'Pengeluaran berhasil dihapus',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
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
}
