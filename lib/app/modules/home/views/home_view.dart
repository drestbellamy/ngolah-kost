import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/menu_item.dart';
import 'widgets/ringkasan_keuangan_widget.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';
import '../../../core/widgets/custom_header.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header - dengan background image
            const CustomHeader(
              title: 'Dashboard Admin',
              subtitle: 'Kelola rumah kost Anda',
              showBackButton: false,
              backgroundImage: 'assets/images/dashboard_admin/header_admin.png',
            ),

            // Konten
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadDashboardData,
                color: const Color(0xFF6B8E7A),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Verification Alert Card - Only show if there are payments to verify
                      Obx(() {
                        if (controller.menungguVerifikasi.value > 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: GestureDetector(
                              onTap: controller.navigateToVerifikasi,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6900),
                                      Color(0xFFF54900),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${controller.menungguVerifikasi.value} Pembayaran\nPerlu Verifikasi',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              height: 1.3,
                                            ),
                                          ),
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
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),

                      const SizedBox(height: 20),

                      // Dashboard Cards Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF6B8E7A),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DashboardCard(
                                      icon: Icons.home_work_outlined,
                                      value: controller.totalKost.value
                                          .toString(),
                                      label: 'Total Kost',
                                      iconBgColor: const Color(0xFF6B8E7A),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DashboardCard(
                                      icon: Icons.meeting_room_outlined,
                                      value: controller.totalKamar.value
                                          .toString(),
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
                                      value: controller.kamarKosong.value
                                          .toString(),
                                      label: 'Kamar Kosong',
                                      iconBgColor: const Color(0xFFF2A65A),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DashboardCard(
                                      icon: Icons.people_outline,
                                      value: controller.totalPenghuni.value
                                          .toString(),
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
                                      value: controller.tagihanBelumBayar.value
                                          .toString(),
                                      label: 'Tagihan Belum Bayar',
                                      iconBgColor: const Color(0xFFF59E0B),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DashboardCard(
                                      icon: Icons.check_circle_outline,
                                      value: controller.menungguVerifikasi.value
                                          .toString(),
                                      label: 'Menunggu Verifikasi',
                                      iconBgColor: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // Ringkasan Keuangan Widget
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: RingkasanKeuanganWidget(),
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
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'Metode Pembayaran',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4B83F3), Color(0xFF285ADA)],
                              ),
                              onTap: controller.navigateToMetodePembayaran,
                            ),
                            const SizedBox(height: 12),
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 0),
    );
  }
}
