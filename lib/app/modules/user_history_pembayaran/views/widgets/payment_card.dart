import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';

class PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;

  const PaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final rawStatus = payment['rawStatus'] ?? 'pending';

    // Determine icon and color based on status
    IconData statusIcon;
    Color statusColor;
    Color statusBgColor;

    if (rawStatus == 'lunas' || rawStatus == 'verified') {
      statusIcon = Icons.check_circle;
      statusColor = const Color(0xFF10B981);
      statusBgColor = const Color(0xFF10B981).withValues(alpha: 0.1);
    } else if (rawStatus == 'ditolak' || rawStatus == 'rejected') {
      statusIcon = Icons.cancel;
      statusColor = const Color(0xFFEF4444);
      statusBgColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
    } else {
      // pending
      statusIcon = Icons.schedule;
      statusColor = const Color(0xFFF59E0B);
      statusBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // Status Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),

          const SizedBox(width: 16),

          // Payment Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        payment['month'],
                        style: AppTextStyles.header16.colored(AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        payment['status'],
                        style: AppTextStyles.body12.weighted(FontWeight.w600).colored(statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  payment['method'],
                  style: AppTextStyles.body14.colored(AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      payment['amount'],
                      style: AppTextStyles.header16.colored(AppColors.textPrimary),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          payment['date'],
                          style: AppTextStyles.body12.colored(const Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
