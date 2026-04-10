import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/landing_controller.dart';

class Landing3View extends GetView<LandingController> {
  const Landing3View({super.key});

  static const String _landingLottieAsset = 'assets/lotties/Home.json';
  static const String _landingPage3BackgroundAsset =
      'assets/images/landing_page3/gedung.png';
  static const String _landingPage3EllipseAsset =
      'assets/images/landing_page3/ellipse.png';
  static const String _landingPage3Circle1Asset =
      'assets/images/landing_page3/circle1.png';
  static const String _landingPage3Circle2Asset =
      'assets/images/landing_page3/circle2.png';
  static const String _landingPage3Circle3Asset =
      'assets/images/landing_page3/circle3.png';
  static const String _landingPage3Circle4Asset =
      'assets/images/landing_page3/circle4.png';
  static const String _landingPage3PersonAsset =
      'assets/images/landing_page3/person3.png';

  @override
  Widget build(BuildContext context) {
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
                    _landingPage3BackgroundAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Container(color: const Color(0xFF6B8E7A).withOpacity(0.20)),
                  Positioned(
                    top: constraints.maxHeight * 0.07,
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
                    height: 250,
                    child: Image.asset(
                      _landingPage3EllipseAsset,
                      fit: BoxFit.fill,
                    ),
                  ),

                  // KOTAK PUTIH DI BAWAH LENGKUNGAN
                  Positioned(
                    top: 118,
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
                          const SizedBox(height: 50),
                          const Text(
                            'Pantau Pembayaran Kost',
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
                                      'Cek pembayaran penghuni, lihat riwayat transaksi, dan pastikan semua tagihan ',
                                ),
                                TextSpan(
                                  text: 'terkontrol',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(text: ' dengan baik.'),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 100,
                            child: Transform.scale(
                              scale: 1.10,
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                _landingPage3PersonAsset,
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tombol Mulai Sekarang
                  Positioned(
                    bottom: 40,
                    left: 24,
                    right: 24,
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 24,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6B8E7A),
                          elevation:
                              0, // Matikan elevasi bawaan agar efek shadow kustom terlihat
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          'Mulai Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
          offset: const Offset(0, -12),
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
              if (subtitle.isNotEmpty)
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

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 75,
          child: Image.asset(
            _landingPage3Circle1Asset,
            width: 50,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Image.asset(
            _landingPage3Circle2Asset,
            width: 70,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Image.asset(
            _landingPage3Circle3Asset,
            width: 30,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Image.asset(
            _landingPage3Circle4Asset,
            width: 90,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
