import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/values/values.dart';
import '../../controllers/user_history_pembayaran_controller.dart';

class FilterTabs extends GetView<UserHistoryPembayaranController> {
  const FilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildFilterTab(
                context,
                label: 'Semua',
                index: 0,
                isSelected: controller.selectedFilter.value == 0,
              ),
            ),
            Expanded(
              child: _buildFilterTab(
                context,
                label: 'Lunas',
                index: 1,
                isSelected: controller.selectedFilter.value == 1,
              ),
            ),
            Expanded(
              child: _buildFilterTab(
                context,
                label: 'Pending',
                index: 2,
                isSelected: controller.selectedFilter.value == 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(
    BuildContext context, {
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.changeFilter(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.spacing(12)),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B8E7A) : Colors.transparent,
          borderRadius: BorderRadius.circular(context.borderRadius(12)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: isSelected 
              ? AppTextStyles.subtitle14.weighted(FontWeight.w600).colored(Colors.white).copyWith(
                  fontSize: context.fontSize(14),
                )
              : AppTextStyles.subtitle14.weighted(FontWeight.w600).colored(AppColors.textSecondary).copyWith(
                  fontSize: context.fontSize(14),
                ),
        ),
      ),
    );
  }
}
