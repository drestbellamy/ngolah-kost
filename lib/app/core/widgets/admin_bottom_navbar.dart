import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../values/values.dart';
import '../utils/responsive_utils.dart';
import 'adaptive_bottom_navbar_wrapper.dart';

/// Shared bottom navigation bar for all admin pages.
/// Pass [currentIndex] to highlight the active tab:
///   0 = Beranda, 1 = Kost, 2 = Penghuni, 3 = Profil
class AdminBottomNavbar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNavbar({super.key, required this.currentIndex});

  void _onTabTapped(int index) {
    if (index == currentIndex) return; // already on this tab

    switch (index) {
      case 0:
        Get.offAllNamed(Routes.home);
        break;
      case 1:
        Get.offAllNamed(Routes.kost);
        break;
      case 2:
        Get.offAllNamed(Routes.penghuni);
        break;
      case 3:
        Get.offAllNamed(Routes.profil);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBottomNavbarWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 50,
              offset: const Offset(0, 25),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  label: 'Beranda',
                  index: 0,
                  isSelected: currentIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.home_work_outlined,
                  label: 'Kost',
                  index: 1,
                  isSelected: currentIndex == 1,
                ),
                _buildNavItem(
                  icon: Icons.people_outline,
                  label: 'Penghuni',
                  index: 2,
                  isSelected: currentIndex == 2,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  index: 3,
                  isSelected: currentIndex == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => _onTabTapped(index),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.padding(16),
            vertical: context.padding(8),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(context.borderRadius(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: context.iconSize(20),
                color: isSelected ? AppColors.primary : AppColors.textGray,
              ),
              SizedBox(height: context.spacing(4)),
              Text(
                label,
                style: AppTextStyles.labelMedium
                    .weighted(isSelected ? FontWeight.w600 : FontWeight.w500)
                    .colored(isSelected ? AppColors.primary : AppColors.textGray)
                    .copyWith(fontSize: context.fontSize(11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
