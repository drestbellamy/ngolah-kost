import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/menu_item.dart';
import 'widgets/ringkasan_keuangan_widget.dart';
import '../../../core/widgets/admin_bottom_navbar.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';

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
                      SizedBox(height: context.spacing(24)),

                      // Verification Alert Card - Only show if there are payments to verify
                      Obx(() {
                        if (controller.menungguVerifikasi.value > 0) {
                          return Padding(
                            padding: context.horizontalPadding(24),
                            child: GestureDetector(
                              onTap: controller.navigateToVerifikasi,
                              child: Container(
                                padding: context.allPadding(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6900),
                                      Color(0xFFF54900),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    context.borderRadius(16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: context.iconSize(48),
                                      height: context.iconSize(48),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(
                                          context.borderRadius(16),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                        size: context.iconSize(24),
                                      ),
                                    ),
                                    SizedBox(width: context.spacing(12)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${controller.menungguVerifikasi.value} Pembayaran\nPerlu Verifikasi',
                                            style: AppTextStyles.header18
                                                .colored(Colors.white)
                                                .copyWith(
                                                  fontSize: context.fontSize(18),
                                                ),
                                          ),
                                          SizedBox(height: context.spacing(4)),
                                          Text(
                                            'Klik untuk memeriksa bukti transfer',
                                            style: AppTextStyles.body14
                                                .colored(AppColors.alertOrangeLight)
                                                .copyWith(
                                                  fontSize: context.fontSize(14),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: context.iconSize(20),
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

                      SizedBox(height: context.spacing(20)),

                      // Dashboard Cards Grid
                      Padding(
                        padding: context.horizontalPadding(24),
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return Center(
                              child: Padding(
                                padding: context.allPadding(40),
                                child: const CircularProgressIndicator(
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
                                  SizedBox(width: context.spacing(16)),
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
                              SizedBox(height: context.spacing(16)),
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
                                  SizedBox(width: context.spacing(16)),
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
                              SizedBox(height: context.spacing(16)),
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
                                  SizedBox(width: context.spacing(16)),
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

                      SizedBox(height: context.spacing(24)),

                      // Ringkasan Keuangan Widget
                      Padding(
                        padding: context.horizontalPadding(24),
                        child: const RingkasanKeuanganWidget(),
                      ),

                      SizedBox(height: context.spacing(24)),

                      // Settings Section
                      Padding(
                        padding: context.horizontalPadding(24),
                        child: Text(
                          'Pengaturan & Lainnya',
                          style: AppTextStyles.subtitle18
                              .colored(AppColors.textPrimary)
                              .copyWith(fontSize: context.fontSize(18)),
                        ),
                      ),

                      SizedBox(height: context.spacing(16)),

                      Padding(
                        padding: context.horizontalPadding(24),
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
                            SizedBox(height: context.spacing(12)),
                            MenuItem(
                              icon: Icons.receipt_long_outlined,
                              title: 'Kelola Tagihan',
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF2A65A), Color(0xFFE8953D)],
                              ),
                              onTap: controller.navigateToKelolaTagihan,
                            ),
                            SizedBox(height: context.spacing(12)),
                            MenuItem(
                              icon: Icons.trending_up_outlined,
                              title: 'Kelola Keuangan',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                              onTap: controller.navigateToKelolaKeuangan,
                            ),
                            SizedBox(height: context.spacing(12)),
                            MenuItem(
                              icon: Icons.campaign_outlined,
                              title: 'Kelola Pengumuman',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2D7A6E), Color(0xFF1F5449)],
                              ),
                              onTap: controller.navigateToKelolaPengumuman,
                            ),
                            SizedBox(height: context.spacing(12)),
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

                      SizedBox(height: context.spacing(100)),
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
