import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';

class PaymentMethodOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isExpanded;
  final Widget? expandedContent;

  const PaymentMethodOption({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isExpanded,
    this.expandedContent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.borderRadius(16)),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B8E7A)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: context.allPadding(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFFBBF24), size: context.iconSize(24)),
                SizedBox(width: context.spacing(12)),
                Text(
                  title,
                  style: AppTextStyles.header16.colored(AppColors.textPrimary).copyWith(
                    fontSize: context.fontSize(16),
                  ),
                ),
              ],
            ),
            if (isExpanded && expandedContent != null) ...[
              SizedBox(height: context.spacing(16)),
              expandedContent!,
            ],
          ],
        ),
      ),
    );
  }
}
