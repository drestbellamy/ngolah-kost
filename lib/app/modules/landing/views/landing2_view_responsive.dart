import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/landing_controller.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';

class Landing2View extends GetView<LandingController> {
  const Landing2View({super.key});

  static const String _landingLottieAsset = 'assets/lotties/Home.json';
  static const String _landingPage2BackgroundAsset =
      'assets/images/landing_page2/Landing2.webp';

  @override
  Widget build(BuildContext context) {
    return _buildSecondOnboardingPage(context);
  }

  Widget _buildSecondOnboardingPage(BuildContext context) {
    final imageHeight = context.heightPercent(55);
    final contentHeight = context.heightPercent(45);

    return Stack(
      children: [
        // Container putih sebagai base belakang
        Container(color: Colors.white),

        // Top full background image dengan border radius di bawah
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: imageHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(context.borderRadius(40)),
            ),
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
                    child: Text(
                      'Image not found',
                      style: TextStyle(fontSize: context.fontSize(14)),
                    ),
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
              padding: EdgeInsets.only(
                top: context.padding(8),
                right: context.padding(24),
              ),
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
          top: context.heightPercent(10),
          left: 0,
          right: 0,
          child: _buildBrandHeader(
            context,
            titleColor: Colors.white,
            subtitleColor: Colors.transparent,
            logoBackground: const Color(0xFF6E947F),
            subtitle: '',
          ),
        ),

        // Bottom White Content Sheet
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: contentHeight,
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
                  'Atur Penghuni & Kamar',
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
                    children: const [
                      TextSpan(
                        text:
                            'Tambahkan data penghuni baru, atur kamar yang tersedia, dan pantau status hunian secara ',
                      ),
                      TextSpan(
                        text: 'real-time.',
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
                      width: context.iconSize(8),
                      height: context.iconSize(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E8E3),
                        borderRadius: BorderRadius.circular(context.borderRadius(4)),
                      ),
                    ),
                    SizedBox(width: context.spacing(8)),
                    Container(
                      width: context.iconSize(28),
                      height: context.iconSize(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6E947F),
                        borderRadius: BorderRadius.circular(context.borderRadius(4)),
                      ),
                    ),
                    SizedBox(width: context.spacing(8)),
                    Container(
                      width: context.iconSize(8),
                      height: context.iconSize(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E8E3),
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
                    onPressed: () {
                      controller.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
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
                          'Selanjutnya',
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: Colors.white,
                            fontSize: context.fontSize(16),
                          ),
                        ),
                        SizedBox(width: context.spacing(8)),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: context.iconSize(20),
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

  Widget _buildBrandHeader(
    BuildContext context, {
    required Color titleColor,
    required Color subtitleColor,
    required Color logoBackground,
    required String subtitle,
  }) {
    final logoSize = context.iconSize(100);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: logoSize,
              height: logoSize,
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
              padding: const EdgeInsets.all(1),
              child: Transform.scale(
                scale: 0.40,
                child: Lottie.asset(
                  _landingLottieAsset,
                  repeat: true,
                  fit: BoxFit.cover,
                  frameRate: FrameRate.composition,
                  options: LottieOptions(enableMergePaths: true),
                  errorBuilder: (_, __, ___) => Icon(
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
          offset: Offset(0, context.isSmallMobile ? -20 : -26),
          child: Column(
            children: [
              Text(
                'Ngolah Kost',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontFamily: 'SF Pro',
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
                  style: AppTextStyles.body16
                      .colored(subtitleColor)
                      .copyWith(fontSize: context.fontSize(16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
