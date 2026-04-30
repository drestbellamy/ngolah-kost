import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
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
      margin: EdgeInsets.only(bottom: context.spacing(16)),
      padding: context.allPadding(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(16)),
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
            width: context.spacing(48),
            height: context.spacing(48),
            decoration: BoxDecoration(
              color: statusBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: context.iconSize(24)),
          ),

          SizedBox(width: context.spacing(16)),

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
                        style: AppTextStyles.header16.colored(AppColors.textPrimary).copyWith(
                          fontSize: context.fontSize(16),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing(12),
                        vertical: context.spacing(4),
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(context.borderRadius(12)),
                      ),
                      child: Text(
                        payment['status'],
                        style: AppTextStyles.body12.weighted(FontWeight.w600).colored(statusColor).copyWith(
                          fontSize: context.fontSize(12),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing(4)),
                Text(
                  payment['method'],
                  style: AppTextStyles.body14.colored(AppColors.textSecondary).copyWith(
                    fontSize: context.fontSize(14),
                  ),
                ),
                SizedBox(height: context.spacing(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      payment['amount'],
                      style: AppTextStyles.header16.colored(AppColors.textPrimary).copyWith(
                        fontSize: context.fontSize(16),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: context.iconSize(14),
                          color: const Color(0xFF9CA3AF),
                        ),
                        SizedBox(width: context.spacing(4)),
                        Text(
                          payment['date'],
                          style: AppTextStyles.body12.colored(const Color(0xFF9CA3AF)).copyWith(
                            fontSize: context.fontSize(12),
                          ),
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
