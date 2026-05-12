import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class LandingController extends GetxController {
  final showContent = false.obs;
  final showDescription = false.obs;
  final currentPage = 0.obs;
  final pageCount = 3;

  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    _startAnimation();
  }

  void _startAnimation() {
    // Tampilkan logo (fade in) lebih cepat
    Future.delayed(const Duration(milliseconds: 300), () {
      showContent.value = true;
    });

    // Pindah ke landing page setelah 1.5 detik
    Future.delayed(const Duration(milliseconds: 1800), () {
      showDescription.value = true;
    });
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void navigateToLogin() {
    Get.toNamed(Routes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
