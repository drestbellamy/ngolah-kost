import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';

class CompactFinancialItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const CompactFinancialItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body12
                      .colored(AppColors.textSecondary)
                      .weighted(FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.header20
                      .copyWith(fontSize: 22)
                      .colored(AppColors.textPrimary)
                      .weighted(FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
