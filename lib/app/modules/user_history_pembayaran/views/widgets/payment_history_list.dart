import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../controllers/user_history_pembayaran_controller.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import 'payment_card.dart';

class PaymentHistoryList extends GetView<UserHistoryPembayaranController> {
  const PaymentHistoryList({super.key});

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Batal', style: AppTextStyles.subtitle14)),
          TextButton(
            onPressed: () async {
              Get.back();
              final authCtrl = Get.find<AuthController>();
              await authCtrl.clearUser();
              Get.offAllNamed(Routes.login);
            },
            child: Text('Keluar', style: AppTextStyles.subtitle14.colored(Colors.red)),
          ),
        ],
      ),
    );
  }

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
            Text(
              'Terjadi Kesalahan',
              style: AppTextStyles.header18.colored(const Color(0xFF1F2937)),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.colored(AppColors.textSecondary),
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
                style: AppTextStyles.subtitle14,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _showLogoutDialog(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Keluar', style: AppTextStyles.subtitle14.colored(Colors.red)),
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
            style: AppTextStyles.header16.colored(AppColors.textSecondary),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)),
            ),
          ],
        ],
      ),
    );
  }
}
