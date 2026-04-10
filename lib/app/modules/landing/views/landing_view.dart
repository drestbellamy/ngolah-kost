import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/landing_controller.dart';

class LandingView extends GetView<LandingController> {
  const LandingView({super.key});

  static const String _landingLottieAsset = 'assets/lotties/Home.json';
  static const String _landingPage1BackgroundAsset =
      'assets/images/landing_page1/gedung.png';
  static const String _landingPage1EllipseAsset =
      'assets/images/landing_page1/ellipse.png';
  static const String _landingPage1Circle1Asset =
      'assets/images/landing_page1/circle1.png';
  static const String _landingPage1Circle2Asset =
      'assets/images/landing_page1/circle2.png';
  static const String _landingPage1Circle3Asset =
      'assets/images/landing_page1/circle3.png';
  static const String _landingPage1Circle4Asset =
      'assets/images/landing_page1/circle4.png';
  static const String _landingPage1PersonAsset =
      'assets/images/landing_page1/person1.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.showDescription.value
            ? _buildOnboardingPager(context)
            : Container(
                width: double.infinity,
                color: Colors.white,
                child: SafeArea(
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
    return SafeArea(
      child: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            children: [
              _buildFirstOnboardingPage(context),
              _buildPlaceholderPage(
                title: 'Pantau Hunian Secara Real-Time',
                subtitle:
                    'Geser lagi ke kiri untuk lanjut ke halaman berikutnya.',
              ),
              _buildPlaceholderPage(
                title: 'Semua Data Keuangan Tersusun',
                subtitle: 'Satu langkah lagi untuk mulai pakai aplikasi.',
                showButton: true,
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: _buildPageIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstOnboardingPage(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Background Image & Top Section
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: constraints.maxHeight * 0.55,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _landingPage1BackgroundAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Container(color: const Color(0xFF6B8E7A).withOpacity(0.20)),
                  Positioned(
                    top:
                        constraints.maxHeight *
                        0.07, // Dinaikkan (sebelumnya 0.12)
                    left: 0,
                    right: 0,
                    child: _buildBrandHeader(
                      titleColor: Colors.white,
                      subtitleColor: Colors.white.withOpacity(0.92),
                      logoBackground: const Color(0xFF4F6F5F),
                      subtitle: '',
                    ),
                  ),
                ],
              ),
            ),

            // Bottom White Section (Using Stack)
            Positioned(
              top: constraints.maxHeight * 0.45,
              left: 0,
              right: 0,
              bottom: 0,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  // LENGKUNGAN PADA BACKGROUND PUTIH
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 250, // <--- UBAH/EDIT TINGGI LENGKUNGAN DI SINI
                    child: Image.asset(
                      _landingPage1EllipseAsset,
                      fit: BoxFit.fill,
                    ),
                  ),

                  // KOTAK PUTIH DI BAWAH LENGKUNGAN
                  Positioned(
                    top: 118, // Naik sedikit agar tidak bergaris kosong
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.white,
                      child: IgnorePointer(child: _buildDecorativeCircles()),
                    ),
                  ),

                  // KONTEN (Teks & Avatar)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 50, // Turunkan posisi teks kalau perlu
                          ),
                          const Text(
                            'Kelola Kost Jadi Lebih Mudah',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6D947F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6C8F7B),
                                height: 1.5,
                              ),
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
                          Expanded(
                            flex: 100, // Menghindari batasan exact pixel
                            child: Transform.scale(
                              scale: 1.10,
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                _landingPage1PersonAsset,
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholderPage({
    required String title,
    required String subtitle,
    bool showButton = false,
  }) {
    return Container(
      color: const Color(0xFFEEF4EF),
      padding: const EdgeInsets.fromLTRB(24, 86, 24, 84),
      child: Column(
        children: [
          _buildBrandHeader(
            titleColor: const Color(0xFF5F8571),
            subtitleColor: const Color(0xFF6C8F7B),
            logoBackground: const Color(0xFFEFF4F0),
            subtitle: subtitle,
          ),
          const Spacer(),
          Container(
            width: 184,
            height: 184,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5F8571).withOpacity(0.14),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.swipe_left_rounded,
              size: 78,
              color: Color(0xFF6E947F),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5F8571),
              height: 1.25,
            ),
          ),
          const Spacer(),
          if (showButton)
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: controller.navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6B8E7A),
                  elevation: 9,
                  shadowColor: Colors.black.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text(
                  'Mulai Sekarang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
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
                  : const Color(0xFF6E947F).withOpacity(0.72),
              borderRadius: BorderRadius.circular(99),
              border: isActive
                  ? Border.all(color: const Color(0xFF6E947F).withOpacity(0.28))
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 75,
          child: Image.asset(
            _landingPage1Circle1Asset,
            width: 50,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Image.asset(
            _landingPage1Circle2Asset,
            width: 70,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Image.asset(
            _landingPage1Circle3Asset,
            width: 30,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Image.asset(
            _landingPage1Circle4Asset,
            width: 90,
            fit: BoxFit.contain,
          ),
        ),
      ],
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
                  color: Colors.white.withOpacity(0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.50),
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
                  errorBuilder: (_, __, ___) => const Icon(
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
            -12,
          ), // Mengurangi jarak antara animasi dan teks
          child: Column(
            children: [
              Text(
                'Ngolah Kost',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  letterSpacing: 0.4,
                  height: 0.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.35),
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
                  style: TextStyle(
                    fontSize: 16,
                    color: subtitleColor,
                    height: 1.45,
                  ),
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
                      ? const Color(0xFF4F6F5F).withOpacity(0.08)
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
                      ? const Color(0xFF4F6F5F).withOpacity(0.12)
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
                    color: Color(0xFF4F6F5F),
                    letterSpacing: 0.5,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
