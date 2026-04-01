import 'package:get/get.dart';

class UserHistoryPembayaranController extends GetxController {
  // Payment history data
  final paymentHistory = <Map<String, dynamic>>[
    {
      'id': 1,
      'month': 'Februari 2026',
      'method': 'Transfer Bank',
      'amount': 'Rp 1.500.000',
      'date': '15 Feb 2026',
      'status': 'Terverifikasi',
    },
    {
      'id': 2,
      'month': 'Januari 2026',
      'method': 'Tunai',
      'amount': 'Rp 1.500.000',
      'date': '18 Jan 2026',
      'status': 'Terverifikasi',
    },
    {
      'id': 3,
      'month': 'Desember 2025',
      'method': 'Transfer Bank',
      'amount': 'Rp 1.500.000',
      'date': '10 Des 2025',
      'status': 'Terverifikasi',
    },
    {
      'id': 4,
      'month': 'November 2025',
      'method': 'Tunai',
      'amount': 'Rp 1.500.000',
      'date': '15 Nov 2025',
      'status': 'Terverifikasi',
    },
  ].obs;

  // Calculate total payment
  String get totalPayment {
    final total = paymentHistory.length * 1500000;
    return 'Rp ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Get payment count
  int get paymentCount => paymentHistory.length;
}
