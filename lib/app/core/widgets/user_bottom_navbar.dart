import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../controllers/notification_controller.dart';
import '../values/values.dart';
import '../utils/responsive_utils.dart';
import 'adaptive_bottom_navbar_wrapper.dart';

class UserBottomNavbar extends StatefulWidget {
  final int currentIndex;

  const UserBottomNavbar({super.key, required this.currentIndex});

  @override
  State<UserBottomNavbar> createState() => _UserBottomNavbarState();
}

class _UserBottomNavbarState extends State<UserBottomNavbar> {
  NotificationController? _notificationController;

  @override
  void initState() {
    super.initState();
    // Safely get controller after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Get.isRegistered<NotificationController>()) {
        setState(() {
          _notificationController = Get.find<NotificationController>();
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBottomNavbarWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: _buildNavbarContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavbarContent() {
    // If controller not ready, show without notifications
    if (_notificationController == null) {
      return _buildNavbarRow(
        hasTagihanNotif: false,
        hasInfoNotif: false,
        infoNotifCount: 0,
      );
    }

    // Use Obx for reactive updates with error handling
    try {
      return Obx(() {
        // Check if controller is still valid
        if (_notificationController == null) {
          return _buildNavbarRow(
            hasTagihanNotif: false,
            hasInfoNotif: false,
            infoNotifCount: 0,
          );
        }
        
        return _buildNavbarRow(
          hasTagihanNotif: _notificationController!.hasTagihanNotification.value,
          hasInfoNotif: _notificationController!.hasInfoNotification.value,
          infoNotifCount: _notificationController!.infoNotificationCount.value,
        );
      });
    } catch (e) {
      // Fallback if Obx fails
      return _buildNavbarRow(
        hasTagihanNotif: false,
        hasInfoNotif: false,
        infoNotifCount: 0,
      );
    }
  }

  Widget _buildNavbarRow({
    required bool hasTagihanNotif,
    required bool hasInfoNotif,
    required int infoNotifCount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          isActive: widget.currentIndex == 0,
          onTap: () {
            if (widget.currentIndex != 0) {
              Get.offAllNamed(Routes.userHome);
            }
          },
        ),
        _buildNavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'Tagihan',
          isActive: widget.currentIndex == 1,
          hasNotification: hasTagihanNotif,
          onTap: () {
            if (widget.currentIndex != 1) {
              Get.offAllNamed(Routes.userTagihan);
            }
          },
        ),
        _buildNavItem(
          icon: Icons.history_outlined,
          activeIcon: Icons.history,
          label: 'Riwayat',
          isActive: widget.currentIndex == 2,
          onTap: () {
            if (widget.currentIndex != 2) {
              Get.offAllNamed(Routes.userHistoryPembayaran);
            }
          },
        ),
        _buildNavItem(
          icon: Icons.notifications_none_outlined,
          activeIcon: Icons.notifications,
          label: 'Info',
          isActive: widget.currentIndex == 3,
          hasNotification: hasInfoNotif,
          notificationCount: infoNotifCount,
          onTap: () {
            if (widget.currentIndex != 3) {
              Get.offAllNamed(Routes.userInfo);
            }
          },
        ),
        _buildNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profil',
          isActive: widget.currentIndex == 4,
          onTap: () {
            if (widget.currentIndex != 4) {
              Get.offAllNamed(Routes.userProfil);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool hasNotification = false,
    int notificationCount = 0,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: context.padding(16),
            vertical: context.padding(10),
          ),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF6B8E7A).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(context.borderRadius(16)),
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
                    size: context.iconSize(24),
                  ),
                  if (hasNotification && notificationCount > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.padding(5),
                          vertical: context.padding(2),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30),
                          borderRadius: BorderRadius.circular(
                            context.borderRadius(10),
                          ),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: BoxConstraints(
                          minWidth: context.iconSize(18),
                          minHeight: context.iconSize(18),
                        ),
                        child: Text(
                          notificationCount > 99 ? '99+' : '$notificationCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.fontSize(10),
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (hasNotification)
                    Positioned(
                      right: -2,
                      top: 0,
                      child: Container(
                        width: context.iconSize(10),
                        height: context.iconSize(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: context.spacing(4)),
              Text(
                label,
                style: AppTextStyles.labelMedium
                    .weighted(isActive ? FontWeight.w600 : FontWeight.w400)
                    .colored(
                      isActive ? AppColors.primary : const Color(0xFF6C727F),
                    )
                    .copyWith(fontSize: context.fontSize(11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
