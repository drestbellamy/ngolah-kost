import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class UserBottomNavbar extends StatelessWidget {
  final int currentIndex;

  // Nanti badge notifikasi bisa dibuat dinamis melalui State Management/Controller.
  // Sementara ini dibuat sebagai opsi opsional.
  final bool hasTagihanNotification;
  final bool hasInfoNotification;

  const UserBottomNavbar({
    super.key,
    required this.currentIndex,
    this.hasTagihanNotification = true,
    this.hasInfoNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () {
                  if (currentIndex != 0) {
                    Get.offAllNamed(Routes.userHome);
                  }
                },
              ),
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Tagihan',
                isActive: currentIndex == 1,
                hasNotification: hasTagihanNotification,
                onTap: () {
                  if (currentIndex != 1) {
                    Get.offAllNamed(Routes.userTagihan);
                  }
                },
              ),
              _buildNavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'Riwayat',
                isActive: currentIndex == 2,
                onTap: () {
                  if (currentIndex != 2) {
                    Get.offAllNamed(Routes.userHistoryPembayaran);
                  }
                },
              ),
              _buildNavItem(
                icon: Icons.notifications_none_outlined,
                activeIcon: Icons.notifications,
                label: 'Info',
                isActive: currentIndex == 3,
                hasNotification: hasInfoNotification,
                onTap: () {
                  if (currentIndex != 3) {
                    Get.offAllNamed(Routes.userInfo);
                  }
                },
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
                isActive: currentIndex == 4,
                onTap: () {
                  if (currentIndex != 4) {
                    Get.offAllNamed(Routes.userProfil);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool hasNotification = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6B8E7A).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? const Color(0xFF6B8E7A)
                      : const Color(0xFF6C727F),
                  size: 24,
                ),
                if (hasNotification)
                  Positioned(
                    right: -2,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? const Color(0xFF6B8E7A)
                    : const Color(0xFF6C727F),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
