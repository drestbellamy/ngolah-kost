import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/values/values.dart';
import '../../controllers/user_info_controller.dart';

class TabSelector extends GetView<UserInfoController> {
  const TabSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing(24)),
      child: Container(
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
        child: Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  context,
                  index: 0,
                  icon: Icons.notifications_none_outlined,
                  label: 'Pengumuman',
                  isSelected: controller.selectedTabIndex.value == 0,
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  context,
                  index: 1,
                  icon: Icons.menu_book_outlined,
                  label: 'Peraturan',
                  isSelected: controller.selectedTabIndex.value == 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.spacing(12)),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B8E7A) : Colors.transparent,
          borderRadius: BorderRadius.circular(context.borderRadius(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: context.iconSize(16),
              color: isSelected ? Colors.white : const Color(0xFF6B8E7A),
            ),
            SizedBox(width: context.spacing(8)),
            Text(
              label,
              style: AppTextStyles.subtitle14
                  .weighted(FontWeight.w600)
                  .colored(isSelected ? Colors.white : const Color(0xFF6B8E7A))
                  .copyWith(fontSize: context.fontSize(14)),
            ),
          ],
        ),
      ),
    );
  }
}
