import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_profil_controller.dart';
import '../../../core/widgets/user_bottom_navbar.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';
import 'widgets/contract_info_section.dart';
import 'widgets/profile_header.dart';
import 'widgets/room_info_section.dart';
import 'widgets/tenant_info_section.dart';

class UserProfilView extends GetView<UserProfilController> {
  const UserProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          // Tampilkan card dengan data kosong + pesan error di bawah
          return RefreshIndicator(
            onRefresh: controller.fetchUserProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const ProfileHeader(),
                  Padding(
                    padding: context.symmetricPadding(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      children: [
                        const RoomInfoSection(),
                        SizedBox(height: context.spacing(16)),
                        const TenantInfoSection(),
                        SizedBox(height: context.spacing(16)),
                        const ContractInfoSection(),
                        SizedBox(height: context.spacing(24)),
                        // Error message card
                        Container(
                          width: double.infinity,
                          padding: context.allPadding(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(context.borderRadius(12)),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.red,
                                size: context.iconSize(24),
                              ),
                              SizedBox(height: context.spacing(8)),
                              Text(
                                controller.errorMessage.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: context.fontSize(14),
                                ),
                              ),
                              SizedBox(height: context.spacing(12)),
                              ElevatedButton.icon(
                                onPressed: controller.fetchUserProfile,
                                icon: Icon(Icons.refresh, size: context.iconSize(16)),
                                label: Text('Coba Lagi', style: TextStyle(fontSize: context.fontSize(14))),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: context.symmetricPadding(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.spacing(16)),
                        _buildLogoutButton(context),
                        SizedBox(height: context.spacing(24)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchUserProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const ProfileHeader(),
                Padding(
                  padding: context.symmetricPadding(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    children: [
                      const RoomInfoSection(),
                      SizedBox(height: context.spacing(16)),
                      const TenantInfoSection(),
                      SizedBox(height: context.spacing(16)),
                      const ContractInfoSection(),
                      SizedBox(height: context.spacing(24)),
                      _buildLogoutButton(context),
                      SizedBox(height: context.spacing(24)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: const UserBottomNavbar(currentIndex: 4),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => controller.showLogoutDialog(),
        style: OutlinedButton.styleFrom(
          padding: context.verticalPadding(16),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.borderRadius(12)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red, size: context.iconSize(20)),
            SizedBox(width: context.spacing(8)),
            Text(
              'Keluar',
              style: AppTextStyles.subtitle14.colored(Colors.red).copyWith(
                fontSize: context.fontSize(14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
