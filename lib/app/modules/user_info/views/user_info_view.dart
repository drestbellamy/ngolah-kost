import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/user_bottom_navbar.dart';
import '../controllers/user_info_controller.dart';
import 'widgets/info_content_section.dart';
import 'widgets/tab_selector.dart';

class UserInfoView extends GetView<UserInfoController> {
  const UserInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Column(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: CustomHeader(
              title: 'Informasi Kost',
              subtitle: 'Pengumuman & berita terbaru',
              showBackButton: false,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              color: const Color(0xFF6B8E7A),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const TabSelector(),
                    const SizedBox(height: 12),
                    const InfoContentSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UserBottomNavbar(currentIndex: 3),
    );
  }
}
