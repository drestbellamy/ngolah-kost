import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/values/values.dart';
import '../../controllers/user_history_pembayaran_controller.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import 'payment_card.dart';

class PaymentHistoryList extends GetView<UserHistoryPembayaranController> {
  const PaymentHistoryList({super.key});

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Keluar', style: TextStyle(fontSize: context.fontSize(18))),
        content: Text('Apakah Anda yakin ingin keluar?', style: TextStyle(fontSize: context.fontSize(14))),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: Text('Batal', style: AppTextStyles.subtitle14.copyWith(fontSize: context.fontSize(14))),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final authCtrl = Get.find<AuthController>();
              await authCtrl.clearUser();
              Get.offAllNamed(Routes.login);
            },
            child: Text('Keluar', style: AppTextStyles.subtitle14.colored(Colors.red).copyWith(fontSize: context.fontSize(14))),
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
        padding: EdgeInsets.symmetric(horizontal: context.spacing(24)),
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
        padding: EdgeInsets.all(Get.context!.spacing(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: Get.context!.iconSize(48), color: const Color(0xFFEF4444)),
            SizedBox(height: Get.context!.spacing(16)),
            Text(
              'Terjadi Kesalahan',
              style: AppTextStyles.header18.colored(const Color(0xFF1F2937)).copyWith(
                fontSize: Get.context!.fontSize(18),
              ),
            ),
            SizedBox(height: Get.context!.spacing(8)),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.colored(AppColors.textSecondary).copyWith(
                fontSize: Get.context!.fontSize(14),
              ),
            ),
            SizedBox(height: Get.context!.spacing(16)),
            ElevatedButton(
              onPressed: () => controller.loadPaymentHistory(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E7A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Get.context!.borderRadius(8)),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: AppTextStyles.subtitle14.copyWith(
                  fontSize: Get.context!.fontSize(14),
                ),
              ),
            ),
            SizedBox(height: Get.context!.spacing(12)),
            OutlinedButton(
              onPressed: () => _showLogoutDialog(Get.context!),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Get.context!.borderRadius(8)),
                ),
              ),
              child: Text('Keluar', style: AppTextStyles.subtitle14.colored(Colors.red).copyWith(
                fontSize: Get.context!.fontSize(14),
              )),
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
          Icon(
            Icons.receipt_long_outlined,
            size: Get.context!.iconSize(64),
            color: const Color(0xFF9CA3AF),
          ),
          SizedBox(height: Get.context!.spacing(16)),
          Text(
            title,
            style: AppTextStyles.header16.colored(AppColors.textSecondary).copyWith(
              fontSize: Get.context!.fontSize(16),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: Get.context!.spacing(8)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.colored(const Color(0xFF9CA3AF)).copyWith(
                fontSize: Get.context!.fontSize(14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
