import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../routes/app_routes.dart';
import '../controllers/user_info_controller.dart';

class UserInfoView extends GetView<UserInfoController> {
  const UserInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomHeader(
              title: 'Informasi Kost',
              subtitle: 'Pengumuman & berita terbaru',
              showBackButton: false,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Toggle Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
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
                      child: Obx(
                        () => Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.changeTab(0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        controller.selectedTabIndex.value == 0
                                        ? const Color(0xFF6B8E7A)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.notifications_none_outlined,
                                        size: 16,
                                        color:
                                            controller.selectedTabIndex.value ==
                                                0
                                            ? Colors.white
                                            : const Color(0xFF6B8E7A),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Pengumuman',
                                        style: TextStyle(
                                          color:
                                              controller
                                                      .selectedTabIndex
                                                      .value ==
                                                  0
                                              ? Colors.white
                                              : const Color(0xFF6B8E7A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.changeTab(1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        controller.selectedTabIndex.value == 1
                                        ? const Color(0xFF6B8E7A)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.menu_book_outlined,
                                        size: 16,
                                        color:
                                            controller.selectedTabIndex.value ==
                                                1
                                            ? Colors.white
                                            : const Color(0xFF6B8E7A),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Peraturan',
                                        style: TextStyle(
                                          color:
                                              controller
                                                      .selectedTabIndex
                                                      .value ==
                                                  1
                                              ? Colors.white
                                              : const Color(0xFF6B8E7A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content List
                  Obx(() {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: controller.selectedTabIndex.value == 0
                          ? ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.announcements.length,
                              itemBuilder: (context, index) {
                                final announcement =
                                    controller.announcements[index];
                                return _buildAnnouncementCard(announcement);
                              },
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.rules.length,
                              itemBuilder: (context, index) {
                                final rule = controller.rules[index];
                                return _buildRuleCard(rule);
                              },
                            ),
                    );
                  }),

                  const SizedBox(height: 100), // Padding for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.home_outlined, 'Beranda', false, () {
                  Get.offAllNamed(Routes.userHome);
                }),
                _buildBottomNavItem(
                  Icons.receipt_long_outlined,
                  'Tagihan',
                  false,
                  () {
                    Get.offAllNamed(Routes.userTagihan);
                  },
                ),
                _buildBottomNavItem(
                  Icons.history_outlined,
                  'Riwayat',
                  false,
                  () {
                    Get.offAllNamed(Routes.userHistoryPembayaran);
                  },
                ),
                _buildBottomNavItem(
                  Icons.notifications_outlined,
                  'Info',
                  true,
                  () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF6B8E7A) : const Color(0xFF9CA3AF),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? const Color(0xFF6B8E7A)
                  : const Color(0xFF9CA3AF),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF6B8E7A),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    Color getIconColor(AnnouncementType type) {
      switch (type) {
        case AnnouncementType.pemeliharaan:
          return Colors.blue;
        case AnnouncementType.libur:
          return Colors.green;
        case AnnouncementType.pembayaran:
          return Colors.orange;
        case AnnouncementType.fasilitas:
          return Colors.grey;
        case AnnouncementType.peraturan:
          return Colors.red;
      }
    }

    IconData getIcon(AnnouncementType type) {
      switch (type) {
        case AnnouncementType.pemeliharaan:
          return Icons.access_time_filled_outlined;
        case AnnouncementType.libur:
          return Icons.calendar_month_outlined;
        case AnnouncementType.pembayaran:
          return Icons.notifications_active_outlined;
        case AnnouncementType.fasilitas:
          return Icons.wifi;
        case AnnouncementType.peraturan:
          return Icons.warning_amber_outlined;
      }
    }

    String getTypeLabel(AnnouncementType type) {
      switch (type) {
        case AnnouncementType.pemeliharaan:
          return 'Pemeliharaan';
        case AnnouncementType.libur:
          return 'Libur';
        case AnnouncementType.pembayaran:
          return 'Pembayaran';
        case AnnouncementType.fasilitas:
          return 'Fasilitas';
        case AnnouncementType.peraturan:
          return 'Peraturan';
      }
    }

    Color getBackgroundLight(AnnouncementType type) {
      return getIconColor(type).withValues(alpha: 0.1);
    }

    Color getTextColor(AnnouncementType type) {
      return getIconColor(type);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: getIconColor(announcement.type).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getIcon(announcement.type),
                  color: getIconColor(announcement.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  announcement.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    announcement.date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getBackgroundLight(announcement.type),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getTypeLabel(announcement.type),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: getTextColor(announcement.type),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(Rule rule) {
    bool isImportant = rule.type == RuleType.penting;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isImportant ? const Color(0xFFFFF7ED) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isImportant
              ? Colors.orange.withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isImportant)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRuleIcon(rule.type),
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  rule.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  rule.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          SizedBox(height: isImportant ? 8 : 16),
          ...rule.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isImportant)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isImportant
                            ? Colors.orange
                            : const Color(0xFF4B5563),
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (!isImportant) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: isImportant
                            ? Colors.orange[800]
                            : const Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRuleIcon(RuleType type) {
    switch (type) {
      case RuleType.jamMalam:
        return Icons.access_time_outlined;
      case RuleType.kebersihan:
        return Icons.cleaning_services_outlined;
      case RuleType.fasilitas:
        return Icons.spa_outlined;
      case RuleType.kendaraan:
        return Icons.directions_car_outlined;
      case RuleType.larangan:
        return Icons.shield_outlined;
      case RuleType.penting:
        return Icons.warning_amber_outlined;
    }
  }
}
