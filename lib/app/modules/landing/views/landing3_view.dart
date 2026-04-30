import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/landing_controller.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';

class Landing3View extends GetView<LandingController> {
  const Landing3View({super.key});

  static const String _landingLottieAsset = 'assets/lotties/Home.json';
  static const String _landingPage3BackgroundAsset =
      'assets/images/landing_page3/Landing3.webp';

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
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(context.borderRadius(40)),
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
              padding: EdgeInsets.only(top: context.padding(8.0), right: context.padding(24.0)),
              child: GestureDetector(
                onTap: controller.navigateToLogin,
                child: Container(
                  padding: context.symmetricPadding(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(context.borderRadius(16)),
                  ),
                  child: Text(
                    'Lewati',
                    style: AppTextStyles.body14.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: context.fontSize(14),
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
            padding: EdgeInsets.fromLTRB(
              context.padding(28),
              context.padding(48),
              context.padding(28),
              context.padding(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pantau Pembayaran',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF5F8571),
                    fontSize: context.fontSize(28),
                  ),
                ),
                SizedBox(height: context.spacing(16)),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.body16.colored(const Color(0xFF6C8F7B)).copyWith(
                      fontSize: context.fontSize(16),
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
                      width: context.spacing(8),
                      height: context.spacing(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E8E3),
                        borderRadius: BorderRadius.circular(context.borderRadius(4)),
                      ),
                    ),
                    SizedBox(width: context.spacing(8)),
                    Container(
                      width: context.spacing(8),
                      height: context.spacing(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E8E3),
                        borderRadius: BorderRadius.circular(context.borderRadius(4)),
                      ),
                    ),
                    SizedBox(width: context.spacing(8)),
                    Container(
                      width: context.spacing(28), // Ini yang aktif (halaman 3)
                      height: context.spacing(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6E947F),
                        borderRadius: BorderRadius.circular(context.borderRadius(4)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing(24)),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: context.buttonHeight(56),
                  child: ElevatedButton(
                    onPressed: controller
                        .navigateToLogin, // Aksi khusus slide terakhir
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E947F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.borderRadius(16)),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mulai Sekarang',
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: Colors.white,
                            fontSize: context.fontSize(16),
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
    return Builder(
      builder: (context) => Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: context.iconSize(100),
                height: context.iconSize(100),
                decoration: BoxDecoration(
                  color: logoBackground,
                  borderRadius: BorderRadius.circular(context.borderRadius(24)),
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
                padding: context.allPadding(1),
                child: Transform.scale(
                  scale: 0.40,
                  child: Lottie.asset(
                    _landingLottieAsset,
                    repeat: true,
                    fit: BoxFit.cover,
                    frameRate: FrameRate.composition,
                    options: LottieOptions(enableMergePaths: true),
                    errorBuilder: (_, __, _) => Icon(
                      Icons.home_rounded,
                      size: context.iconSize(58),
                      color: const Color(0xFF6B8E7A),
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
                    fontFamily: 'Helvetica Neu',
                    color: titleColor,
                    letterSpacing: 0.4,
                    height: 0.1,
                    fontSize: context.fontSize(28),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.50),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacing(8)),
                Padding(
                  padding: context.horizontalPadding(40),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body16.colored(subtitleColor).copyWith(
                      fontSize: context.fontSize(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
