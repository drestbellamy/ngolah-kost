import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/user_home_controller.dart';
import '../../../../core/values/values.dart';

class PaymentDueAlert extends StatelessWidget {
  final UserHomeController controller;

  const PaymentDueAlert({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.dueStatus.value;
      final days = controller.daysUntilDue.value;

      Color bgColor;
      Color borderColor;
      Color iconBgColor;
      Color textColor;
      String title;
      String subtitle;
      IconData icon;

      switch (status) {
        case 'overdue':
          bgColor = const Color(0xFFFEE2E2);
          borderColor = const Color(0xFFEF4444);
          iconBgColor = const Color(0xFFEF4444);
          textColor = const Color(0xFFEF4444);
          title = 'Tagihan Terlambat!';
          subtitle = 'Sudah lewat ${days.abs()} hari';
          icon = Icons.error_outline;
          break;
        case 'soon':
          bgColor = const Color(0xFFFFF7ED);
          borderColor = const Color(0xFFF2A65A);
          iconBgColor = const Color(0xFFF2A65A);
          textColor = const Color(0xFFF2A65A);
          title = 'Segera Jatuh Tempo!';
          subtitle = days == 0
              ? 'Jatuh tempo hari ini'
              : 'Jatuh tempo $days hari lagi';
          icon = Icons.access_time;
          break;
        case 'pending':
          bgColor = const Color(0xFFFFFBEB);
          borderColor = const Color(0xFFF59E0B);
          iconBgColor = const Color(0xFFF59E0B);
          textColor = const Color(0xFFF59E0B);
          title = 'Menunggu Verifikasi';
          subtitle = 'Pembayaran sedang diproses';
          icon = Icons.schedule;
          break;
        case 'upcoming':
          bgColor = const Color(0xFFECFDF5);
          borderColor = const Color(0xFF10B981);
          iconBgColor = const Color(0xFF10B981);
          textColor = const Color(0xFF10B981);
          title = 'Tagihan Mendatang';
          subtitle = 'Jatuh tempo $days hari lagi';
          icon = Icons.schedule;
          break;
        default:
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD1D5DB).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tidak Ada Tagihan',
                        style: AppTextStyles.header16.colored(AppColors.textGray),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Semua tagihan sudah lunas',
                        style: AppTextStyles.body12.colored(const Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.header16.colored(textColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.body12.colored(textColor.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 8),
            if (status != 'pending') ...[
              Text(
                _formatCurrency(controller.dueAmount.value),
                style: AppTextStyles.subtitle18.colored(AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: textColor),
                  const SizedBox(width: 4),
                  Text(
                    'Jatuh tempo: ${controller.dueDate.value}',
                    style: AppTextStyles.body12.colored(textColor),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Bukti pembayaran Anda sedang diverifikasi oleh admin',
                style: AppTextStyles.body12,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: status == 'pending'
                    ? () => Get.toNamed('/user-history-pembayaran')
                    : controller.payNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == 'overdue'
                      ? const Color(0xFFEF4444)
                      : status == 'soon'
                      ? const Color(0xFFF2A65A)
                      : status == 'pending'
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  status == 'pending'
                      ? 'Lihat Status'
                      : status == 'overdue'
                      ? 'Bayar Sekarang!'
                      : 'Bayar Tagihan',
                  style: AppTextStyles.subtitle14.colored(Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}
