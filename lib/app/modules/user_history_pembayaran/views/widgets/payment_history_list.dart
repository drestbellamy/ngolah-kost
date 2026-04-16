import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_history_pembayaran_controller.dart';
import 'payment_card.dart';

class PaymentHistoryList extends GetView<UserHistoryPembayaranController> {
  const PaymentHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(color: Color(0xFF6B8E7A)),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorState();
      }

      if (controller.paymentHistory.isEmpty) {
        return _buildEmptyState(
          'Belum ada riwayat pembayaran',
          'Riwayat pembayaran akan muncul setelah tagihan lunas',
        );
      }

      final filteredList = controller.filteredPaymentHistory;

      if (filteredList.isEmpty) {
        return _buildEmptyState(
          controller.selectedFilter.value == 1
              ? 'Belum ada pembayaran lunas'
              : 'Belum ada pembayaran pending',
          null,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final payment = filteredList[index];
          return PaymentCard(payment: payment);
        },
      );
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadPaymentHistory(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E7A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String? subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
          ],
        ],
      ),
    );
  }
}
