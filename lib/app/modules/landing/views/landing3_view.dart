import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/landing_controller.dart';

class Landing3View extends GetView<LandingController> {
  const Landing3View({super.key});

  static const String _landingLottieAsset = 'assets/lotties/Home.json';
  static const String _landingPage3BackgroundAsset =
      'assets/images/landing_page3/miniatur.png';

  @override
  Widget build(BuildContext context) {
    return _buildThirdOnboardingPage(context);
  }

  Widget _buildThirdOnboardingPage(BuildContext context) {
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
                  _landingPage3BackgroundAsset, // Pakai gambar miniatur
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF6B8E7A),
                    alignment: Alignment.center,
                    child: const Text('Image not found'),
                  ),
                ),
                Container(color: Colors.black.withOpacity(0.05)),
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
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Lewati',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pantau Pembayaran',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5F8571), // Dark green
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6C8F7B), // Light grayish green
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

                // Indicators
                Row(
                  children: [
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
                    const SizedBox(width: 8),
                    Container(
                      width: 28, // Ini yang aktif (halaman 3)
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6E947F),
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
                    onPressed: controller
                        .navigateToLogin, // Aksi khusus slide terakhir
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E947F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mulai Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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
            -26, // Menambah nilai minus agar lebih dekat
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
                      color: Colors.black.withOpacity(0.50),
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
}
