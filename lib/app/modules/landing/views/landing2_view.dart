import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Landing2View extends StatelessWidget {
  const Landing2View({super.key});

  static const String _landingLottieAsset = 'assets/lotties/Home.json';
  static const String _landingPage2BackgroundAsset =
      'assets/images/landing_page2/gedung.png';
  static const String _landingPage2EllipseAsset =
      'assets/images/landing_page2/ellipse.png';
  static const String _landingPage2Rumah1Asset =
      'assets/images/landing_page2/rumah1.png';
  static const String _landingPage2Rumah2Asset =
      'assets/images/landing_page2/rumah2.png';
  static const String _landingPage2Rumah3Asset =
      'assets/images/landing_page2/rumah3.png';
  static const String _landingPage2Rumah4Asset =
      'assets/images/landing_page2/rumah4.png';
  static const String _landingPage2Rumah5Asset =
      'assets/images/landing_page2/rumah5.png';
  static const String _landingPage2Rumah6Asset =
      'assets/images/landing_page2/rumah6.png';
  static const String _landingPage2PersonAsset =
      'assets/images/landing_page2/person2.png';

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
                    _landingPage2BackgroundAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF6B8E7A),
                      alignment: Alignment.center,
                      child: const Text(
                        'Image not found\nassets/images/landing_page2/gedung.png',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
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
                    height: 250, // Tinggi lengkungan sama dengan landing 1
                    child: Image.asset(
                      _landingPage2EllipseAsset,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
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
                      child: IgnorePointer(child: _buildDecorativeHouses()),
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
                            'Atur Penghuni & Kamar', // Text diubah sedikit untuk slide 2
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
                                      'Tambahkan data penghuni baru, atur kamar yang tersedia, dan pantau status hunian secara',
                                ),
                                TextSpan(
                                  text: ' real-time.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(text: ''),
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
                                _landingPage2PersonAsset,
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomCenter,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(),
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

  Widget _buildDecorativeHouses() {
    return Stack(
      children: [
        Positioned(
          right: 50,
          top: 0,
          child: Image.asset(
            _landingPage2Rumah1Asset,
            width: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
        Positioned(
          left: 95,
          top: 30,
          child: Image.asset(
            _landingPage2Rumah2Asset,
            width: 60,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
        Positioned(
          left: 11,
          top: 80,
          child: Image.asset(
            _landingPage2Rumah3Asset,
            width: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
        Positioned(
          right: 28,
          top: 70,
          child: Image.asset(
            _landingPage2Rumah4Asset,
            width: 130,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
        // Tambahan rumah 5 dan 6 karena lebih banyak
        Positioned(
          bottom: 0,
          left: 0,
          child: Image.asset(
            _landingPage2Rumah5Asset,
            width: 180,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
        Positioned(
          right: 66,
          bottom: 2,
          child: Image.asset(
            _landingPage2Rumah6Asset,
            width: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
      ],
    );
  }
}
