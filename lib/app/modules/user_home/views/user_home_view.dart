import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/user_bottom_navbar.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../routes/app_routes.dart';
import '../controllers/user_home_controller.dart';
import 'widgets/room_info_card.dart';
import 'widgets/payment_due_alert.dart';
import 'widgets/payment_summary_card.dart';
import 'widgets/contact_management_card.dart';
import 'widgets/pengaduan_card.dart';

class UserHomeView extends GetView<UserHomeController> {
  const UserHomeView({super.key});

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.allPadding(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: context.iconSize(64),
              color: Colors.red,
            ),
            SizedBox(height: context.spacing(16)),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14
                  .colored(Colors.red)
                  .copyWith(fontSize: context.fontSize(14)),
            ),
            SizedBox(height: context.spacing(24)),
            ElevatedButton.icon(
              onPressed: controller.loadUserData,
              icon: Icon(Icons.refresh, size: context.iconSize(20)),
              label: Text(
                'Coba Lagi',
                style: TextStyle(fontSize: context.fontSize(14)),
              ),
              style: ElevatedButton.styleFrom(
                padding: context.symmetricPadding(horizontal: 24, vertical: 12),
              ),
            ),
            SizedBox(height: context.spacing(16)),
            OutlinedButton(
              onPressed: () => controller.showLogoutDialog(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.borderRadius(8)),
                ),
                padding: context.symmetricPadding(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Keluar',
                style: AppTextStyles.subtitle14
                    .colored(Colors.red)
                    .copyWith(fontSize: context.fontSize(14)),
              ),
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
          return _buildErrorState(context);
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
                      width: context.iconSize(48),
                      height: context.iconSize(48),
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
                          ? Icon(
                              Icons.person,
                              size: context.iconSize(32),
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
                    padding: context.allPadding(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RoomInfoCard(controller: controller),
                        SizedBox(height: context.spacing(20)),
                        if (controller.hasDuePayment.value) ...[
                          PaymentDueAlert(controller: controller),
                          SizedBox(height: context.spacing(24)),
                        ],
                        PaymentSummaryCard(controller: controller),
                        SizedBox(height: context.spacing(24)),
                        const PengaduanCard(),
                        SizedBox(height: context.spacing(24)),
                        ContactManagementCard(controller: controller),
                        SizedBox(height: context.spacing(24)),
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
