import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_home_controller.dart';
import '../../../../core/values/values.dart';

class PaymentSummaryCard extends StatelessWidget {
  final UserHomeController controller;

  const PaymentSummaryCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Pembayaran',
          style: AppTextStyles.subtitle18.colored(AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(0xFF10B981),
                  title: 'Sudah Lunas',
                  value: '${controller.totalLunas.value}',
                  subtitle: controller.totalLunas.value == 1
                      ? 'Tagihan'
                      : 'Tagihan',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.schedule,
                  iconColor: const Color(0xFFF2A65A),
                  title: 'Belum Bayar',
                  value: '${controller.totalBelumBayar.value}',
                  subtitle: controller.totalBelumBayar.value == 1
                      ? 'Tagihan'
                      : 'Tagihan',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.body12.colored(AppColors.textGray),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.subtitle18.colored(AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.body10.colored(iconColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
