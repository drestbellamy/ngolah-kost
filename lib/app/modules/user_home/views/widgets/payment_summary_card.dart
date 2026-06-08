import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_home_controller.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';

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
          style: AppTextStyles.header18
              .colored(AppColors.textPrimary)
              .copyWith(
                fontSize: context.fontSize(18),
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: context.spacing(16)),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context: context,
                  icon: Icons.check_circle_outline,
                  iconBgColor: const Color(0xFFD1FAE5),
                  iconColor: const Color(0xFF10B981),
                  title: 'Total Lunas',
                  value: '${controller.totalLunas.value} Bulan',
                  subtitle: controller.firstPaidMonth.value.isNotEmpty
                      ? controller.firstPaidMonth.value
                      : controller.totalLunas.value > 0
                      ? 'Pembayaran selesai'
                      : 'Belum ada pembayaran',
                  subtitleColor: const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: context.spacing(16)),
              Expanded(
                child: _buildSummaryItem(
                  context: context,
                  icon: Icons.error_outline,
                  iconBgColor: const Color(0xFFFFEDDB),
                  iconColor: const Color(0xFFFF6B2C),
                  title: 'Belum Bayar',
                  value: '${controller.totalBelumBayar.value} Bulan',
                  subtitle: controller.unpaidMonthsList.value.isNotEmpty
                      ? controller.unpaidMonthsList.value
                      : 'Tidak ada tagihan',
                  subtitleColor: const Color(0xFFFF6B2C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: context.allPadding(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.iconSize(56),
            height: context.iconSize(56),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: context.iconSize(28)),
          ),
          SizedBox(height: context.spacing(16)),
          Text(
            title,
            style: AppTextStyles.body12
                .colored(const Color(0xFF9CA3AF))
                .copyWith(fontSize: context.fontSize(14)),
          ),
          SizedBox(height: context.spacing(8)),
          Text(
            value,
            style: AppTextStyles.header18
                .colored(const Color(0xFF1F2937))
                .copyWith(
                  fontSize: context.fontSize(18),
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: context.spacing(8)),
          Text(
            subtitle,
            style: AppTextStyles.body12
                .colored(subtitleColor)
                .copyWith(
                  fontSize: context.fontSize(13),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
