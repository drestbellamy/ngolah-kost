import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/landing_controller.dart';

class LandingView extends GetView<LandingController> {
  const LandingView({super.key});

  static const String _landingLottieAsset = 'assets/lotties/Home.json';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B8E7A), Color(0xFF8FAA9F)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated Logo
              Obx(
                () => AnimatedPositioned(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  top: controller.showContent.value
                      ? 120
                      : MediaQuery.of(context).size.height / 2 - 148,
                  left: 0,
                  right: 0,
                  child: _buildLogo(),
                ),
              ),

              // Content that fades in
              Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: controller.showDescription.value ? 1.0 : 0.0,
                  child: Column(
                    children: [
                      const SizedBox(height: 360), // Space for logo + title
                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Kelola properti kost Anda dengan mudah dan efisien',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Get Started Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: controller.navigateToLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6B8E7A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: const Text(
                              'Mulai Sekarang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Logo with decorative circles
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle
            Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                width: controller.showContent.value ? 160 : 200,
                height: controller.showContent.value ? 160 : 200,
                decoration: BoxDecoration(
                  color: controller.showContent.value
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Inner circle
            Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                width: controller.showContent.value ? 112 : 140,
                height: controller.showContent.value ? 112 : 140,
                decoration: BoxDecoration(
                  color: controller.showContent.value
                      ? Colors.white.withOpacity(0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Logo container
            Obx(() {
              final isShown = controller.showContent.value;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                width: isShown ? 96 : 164,
                height: isShown ? 96 : 164,
                curve: Curves.easeInOut,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutBack,
                      scale: isShown ? 1 : 0.72,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        opacity: isShown ? 1 : 0,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F6F5F),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isShown ? 1 : 0),
                      child: Transform.scale(
                        scale: isShown ? 1.55 : 1.35,
                        child: Lottie.asset(
                          _landingLottieAsset,
                          repeat: true,
                          fit: BoxFit.cover,
                          frameRate: FrameRate.composition,
                          options: LottieOptions(enableMergePaths: true),
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.home_rounded,
                            size: isShown ? 58 : 76,
                            color: const Color(0xFF6B8E7A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),

        const SizedBox(height: 10),

        // Title
        Obx(
          () => controller.showContent.value
              ? const Text(
                  'Ngolah Kost',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
