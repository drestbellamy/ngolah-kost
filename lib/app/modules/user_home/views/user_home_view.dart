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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            SafeArea(
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
