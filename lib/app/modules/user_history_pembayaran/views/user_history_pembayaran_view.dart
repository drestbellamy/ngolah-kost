import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/user_bottom_navbar.dart';
import '../controllers/user_history_pembayaran_controller.dart';
import 'widgets/filter_tabs.dart';
import 'widgets/payment_history_list.dart';
import 'widgets/total_payment_card.dart';

class UserHistoryPembayaranView
    extends GetView<UserHistoryPembayaranController> {
  const UserHistoryPembayaranView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Column(
        children: [
          SafeArea(
            top: false,
            child: CustomHeader(
              title: 'Riwayat Pembayaran',
              subtitle: 'Lihat Semua Transaksi',
              showBackButton: false,
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: TotalPaymentCard(),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: FilterTabs(),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2F2F),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshData(),
              color: const Color(0xFF6B8E7A),
              child: const PaymentHistoryList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavbar(currentIndex: 2),
    );
  }
}
