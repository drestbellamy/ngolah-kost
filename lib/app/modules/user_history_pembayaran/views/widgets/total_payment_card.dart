import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../controllers/user_history_pembayaran_controller.dart';

class TotalPaymentCard extends GetView<UserHistoryPembayaranController> {
  const TotalPaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Pembayaran',
            style: AppTextStyles.body14.colored(AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              controller.totalPayment,
              style: AppTextStyles.header20.copyWith(fontSize: 32).colored(const Color(0xFF6B8E7A)),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              '${controller.paymentCount} pembayaran selesai',
              style: AppTextStyles.body12.colored(const Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }
}
