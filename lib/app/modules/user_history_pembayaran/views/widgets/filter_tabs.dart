import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_history_pembayaran_controller.dart';

class FilterTabs extends GetView<UserHistoryPembayaranController> {
  const FilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildFilterTab(
                label: 'Semua',
                index: 0,
                isSelected: controller.selectedFilter.value == 0,
              ),
            ),
            Expanded(
              child: _buildFilterTab(
                label: 'Lunas',
                index: 1,
                isSelected: controller.selectedFilter.value == 1,
              ),
            ),
            Expanded(
              child: _buildFilterTab(
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

  Widget _buildFilterTab({
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.changeFilter(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B8E7A) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
