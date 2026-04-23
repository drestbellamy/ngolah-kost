import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/landing_controller.dart';
import 'landing2_view.dart';
import 'landing3_view.dart';
import '../../../core/values/values.dart';

class LandingView extends GetView<LandingController> {
  const LandingView({super.key});

  static const String _landingLottieAsset = 'assets/lotties/Home.json';
  static const String _landingPage1BackgroundAsset =
      'assets/images/landing_page1/gedung.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => controller.showDescription.value
              ? _buildOnboardingPager(context)
              : Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Obx(
                        () => AnimatedPositioned(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                          top: controller.showContent.value
                              ? MediaQuery.of(context).size.height *
                                    0.07 // Menyamakan dengan max height posisi atas
                              : MediaQuery.of(context).size.height / 2 - 148,
                          left: 0,
                          right: 0,
                          child: _buildIntroLogo(),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPager(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          children: [
            _buildFirstOnboardingPage(context),
            const Landing2View(), // Menggunakan Landing Page 2 yang baru dibuat
            const Landing3View(), // Menggunakan Landing Page 3 yang baru dibuat
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 18,
          child: Obx(
            () => AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity:
                  controller.currentPage.value ==
                      2 // Nanti disesuaikan di slide ke berapa indicator mau dimatikan, sekarang semua punya indicator custom masing2
                  ? 0.0
                  : 0.0,
              child: _buildPageIndicator(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFirstOnboardingPage(BuildContext context) {
    return Stack(
      children: [
        // Container putih sebagai base belakang (agar ujung bawah terlihat putih mulus)
        Container(color: Colors.white),

        // Top full background image dengan border radius di bawah
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).size.height * 0.45,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _landingPage1BackgroundAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                Container(color: Colors.black.withValues(alpha: 0.05)),
              ],
            ),
          ),
        ),

        // Top Right 'Lewati' button
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 24.0),
              child: GestureDetector(
                onTap: controller.navigateToLogin,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Lewati',
                    style: AppTextStyles.body14.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Center Logo overlay
        Positioned(
          top: MediaQuery.of(context).size.height * 0.10,
          left: 0,
          right: 0,
          child: _buildBrandHeader(
            titleColor: Colors.white,
            subtitleColor: Colors.transparent,
            logoBackground: const Color(0xFF6E947F), // Match design green
            subtitle: '',
          ),
        ),

        // Bottom White Content Sheet
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: MediaQuery.of(context).size.height * 0.45,
          child: Container(
            color: Colors
                .transparent, // Transparan karena belakang sudah putih di cover container dasar
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelola Kost Mudah',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5F8571),
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.body16.colored(const Color(0xFF6C8F7B)),
                    children: [
                      TextSpan(
                        text:
                            'Ngolah Kost membantu kamu mengatur data penghuni, kamar, dan keuangan dalam satu aplikasi yang ',
                      ),
                      TextSpan(
                        text: 'praktis',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' dan '),
                      TextSpan(
                        text: 'efisien.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Indicators
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6E947F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E8E3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E8E3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E947F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Selanjutnya',
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(controller.pageCount, (index) {
          final isActive = controller.currentPage.value == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 18 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : const Color(0xFF6E947F).withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(99),
              border: isActive
                  ? Border.all(color: const Color(0xFF6E947F).withValues(alpha: 0.28))
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBrandHeader({
    required Color titleColor,
    required Color subtitleColor,
    required Color logoBackground,
    required String subtitle,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: logoBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.50),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(1),
              child: Transform.scale(
                scale: 0.40,
                child: Lottie.asset(
                  _landingLottieAsset,
                  repeat: true,
                  fit: BoxFit.cover,
                  frameRate: FrameRate.composition,
                  options: LottieOptions(enableMergePaths: true),
                  errorBuilder: (_, __, _) => const Icon(
                    Icons.home_rounded,
                    size: 58,
                    color: Color(0xFF6B8E7A),
                  ),
                ),
              ),
            ),
          ],
        ),
        Transform.translate(
          offset: const Offset(
            0,
            -26, // Menambah nilai minus agar lebih dekat
          ), // Mengurangi jarak antara animasi dan teks
          child: Column(
            children: [
              Text(
                'Ngolah Kost',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: titleColor,
                  letterSpacing: 0.4,
                  height: 0.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.50),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body16.colored(subtitleColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntroLogo() {
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
                      ? const Color(0xFF4F6F5F).withValues(alpha: 0.08)
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
                      ? const Color(0xFF4F6F5F).withValues(alpha: 0.12)
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
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
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
                          errorBuilder: (_, __, _) => Icon(
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
              ? Text(
                  'Ngolah Kost',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: const Color(0xFF4F6F5F),
                    letterSpacing: 0.5,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
