import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_profil_controller.dart';
import '../../../core/widgets/user_bottom_navbar.dart';
import '../../../core/values/values.dart';
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      children: [
                        const RoomInfoSection(),
                        const SizedBox(height: 16),
                        const TenantInfoSection(),
                        const SizedBox(height: 16),
                        const ContractInfoSection(),
                        const SizedBox(height: 24),
                        // Error message card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.red,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.errorMessage.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: controller.fetchUserProfile,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Coba Lagi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLogoutButton(),
                        const SizedBox(height: 24),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    children: [
                      const RoomInfoSection(),
                      const SizedBox(height: 16),
                      const TenantInfoSection(),
                      const SizedBox(height: 16),
                      const ContractInfoSection(),
                      const SizedBox(height: 24),
                      _buildLogoutButton(),
                      const SizedBox(height: 24),
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => controller.showLogoutDialog(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              'Keluar',
              style: AppTextStyles.subtitle14.colored(Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
