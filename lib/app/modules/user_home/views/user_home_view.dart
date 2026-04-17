import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/user_bottom_navbar.dart';
import '../../../routes/app_routes.dart';
import '../controllers/user_home_controller.dart';
import 'widgets/room_info_card.dart';
import 'widgets/payment_due_alert.dart';
import 'widgets/payment_summary_card.dart';
import 'widgets/contact_management_card.dart';

class UserHomeView extends GetView<UserHomeController> {
  const UserHomeView({super.key});

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.loadUserData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => controller.showLogoutDialog(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState();
        }

        return Column(
          children: [
            SafeArea(
              top: false,
              bottom: false,
              child: CustomHeader(
                title: 'Hallo, ${controller.userName}!',
                subtitle: 'Selamat datang kembali',
                showBackButton: false,
                trailing: Obx(() {
                  final photoUrl = controller.fotoProfilUrl.value;
                  return GestureDetector(
                    onTap: () => Get.toNamed(Routes.userProfil),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: photoUrl != null && photoUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(photoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: photoUrl == null || photoUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadUserData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RoomInfoCard(controller: controller),
                        const SizedBox(height: 20),
                        if (controller.hasDuePayment.value) ...[
                          PaymentDueAlert(controller: controller),
                          const SizedBox(height: 24),
                        ],
                        PaymentSummaryCard(controller: controller),
                        const SizedBox(height: 24),
                        ContactManagementCard(controller: controller),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const UserBottomNavbar(currentIndex: 0),
    );
  }
}
