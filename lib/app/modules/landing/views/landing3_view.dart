import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/landing_controller.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';

class Landing3View extends GetView<LandingController> {
  const Landing3View({super.key});

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
                  _landingPage3BackgroundAsset,
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

        // Bottom White Content Sheet with Slide Animation
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
                _SlideAnimation(
                  delay: 200,
                  child: Text(
                    'Pantau Pembayaran',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5F8571),
                      fontSize: context.fontSize(28),
                    ),
                  ),
                ),
                SizedBox(height: context.spacing(16)),
                _SlideAnimation(
                  delay: 400,
                  child: RichText(
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
                ),
                const Spacer(),

                // Indicators
                _SlideAnimation(
                  delay: 600,
                  child: Row(
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
                        width: context.spacing(28),
                        height: context.spacing(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6E947F),
                          borderRadius: BorderRadius.circular(context.borderRadius(4)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.spacing(24)),

                // Button
                _SlideAnimation(
                  delay: 800,
                  child: SizedBox(
                    width: double.infinity,
                    height: context.buttonHeight(56),
                    child: ElevatedButton(
                      onPressed: controller.navigateToLogin,
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

// Slide Animation Widget
class _SlideAnimation extends StatefulWidget {
  final Widget child;
  final int delay;

  const _SlideAnimation({
    required this.child,
    this.delay = 0,
  });

  @override
  State<_SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<_SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
