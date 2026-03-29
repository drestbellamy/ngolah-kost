import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/menu_item.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with gradient and notification overlay
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Header Container
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6B8E7A),
                                Color(0xFF4F6F5D),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 25,
                                offset: const Offset(0, 20),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Decorative circles
                              Positioned(
                                right: -64,
                                top: -64,
                                child: Container(
                                  width: 256,
                                  height: 256,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -48,
                                bottom: -48,
                                child: Container(
                                  width: 192,
                                  height: 192,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dashboard Admin',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Kelola rumah kost Anda',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFA8D5BA),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    
                                    // Decorative building icons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildDecorativeIcon(80, 0.2),
                                        const SizedBox(width: 8),
                                        _buildDecorativeIcon(96, 0.3),
                                        const SizedBox(width: 8),
                                        _buildDecorativeIcon(80, 0.2),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Verification Alert - Overlapping
                        Positioned(
                          left: 24,
                          right: 24,
                          bottom: -54,
                          child: GestureDetector(
                            onTap: controller.navigateToVerifikasi,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF6900), Color(0xFFF54900)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 25,
                                    offset: const Offset(0, 20),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Obx(() => Text(
                                          '${controller.menungguVerifikasi.value} Pembayaran\nPerlu Verifikasi',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.3,
                                          ),
                                        )),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Klik untuk memeriksa bukti transfer',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFFFEDD4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 78),
                    
                    // Dashboard Cards Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Obx(() => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DashboardCard(
                                  icon: Icons.home_work_outlined,
                                  value: controller.totalKost.value.toString(),
                                  label: 'Total Kost',
                                  iconBgColor: const Color(0xFF6B8E7A),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DashboardCard(
                                  icon: Icons.meeting_room_outlined,
                                  value: controller.totalKamar.value.toString(),
                                  label: 'Total Kamar',
                                  iconBgColor: const Color(0xFFA8D5BA),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DashboardCard(
                                  icon: Icons.door_front_door_outlined,
                                  value: controller.kamarKosong.value.toString(),
                                  label: 'Kamar Kosong',
                                  iconBgColor: const Color(0xFFF2A65A),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DashboardCard(
                                  icon: Icons.people_outline,
                                  value: controller.totalPenghuni.value.toString(),
                                  label: 'Total Penghuni',
                                  iconBgColor: const Color(0xFF6B8E7A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DashboardCard(
                                  icon: Icons.access_time_outlined,
                                  value: controller.tagihanBelumBayar.value.toString(),
                                  label: 'Tagihan Belum Bayar',
                                  iconBgColor: const Color(0xFFF59E0B),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DashboardCard(
                                  icon: Icons.check_circle_outline,
                                  value: controller.menungguVerifikasi.value.toString(),
                                  label: 'Menunggu Verifikasi',
                                  iconBgColor: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Settings Section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Pengaturan & Lainnya',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          MenuItem(
                            icon: Icons.receipt_long_outlined,
                            title: 'Kelola Tagihan',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF2A65A), Color(0xFFE8953D)],
                            ),
                            onTap: controller.navigateToKelolaTagihan,
                          ),
                          const SizedBox(height: 12),
                          MenuItem(
                            icon: Icons.campaign_outlined,
                            title: 'Kelola Pengumuman',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2D7A6E), Color(0xFF1F5449)],
                            ),
                            onTap: controller.navigateToKelolaPengumuman,
                          ),
                          const SizedBox(height: 12),
                          MenuItem(
                            icon: Icons.rule_outlined,
                            title: 'Kelola Peraturan',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8FAA9F), Color(0xFF6B8E7A)],
                            ),
                            onTap: controller.navigateToKelolaPeraturan,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDecorativeIcon(double height, double opacity) {
    return Container(
      width: 64,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.home_work,
            color: Colors.white.withOpacity(0.6),
            size: height > 90 ? 40 : 32,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 81,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1.1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 50,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Beranda',
            index: 0,
            isSelected: controller.selectedIndex.value == 0,
          ),
          _buildNavItem(
            icon: Icons.home_work_outlined,
            label: 'Kost',
            index: 1,
            isSelected: controller.selectedIndex.value == 1,
          ),
          _buildNavItem(
            icon: Icons.people_outline,
            label: 'Penghuni',
            index: 2,
            isSelected: controller.selectedIndex.value == 2,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Profil',
            index: 3,
            isSelected: controller.selectedIndex.value == 3,
          ),
        ],
      )),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B8E7A).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF6B8E7A)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF6B8E7A)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
