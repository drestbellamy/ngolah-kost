import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/login_controller.dart';
import '../../../core/widgets/keyboard_dismissible.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final double imageHeightRatio = 0.48;

    const Color fieldBorderColor = Color(0xFF6B8E7A);
    const Color fieldFocusColor = Color(0xFF6B8E7A);
    const Color fieldIconColor = Color(0xFF6B7280);
    const Color fieldHintColor = Color(0xFFAAAAAA);
    const Color fieldTextColor = Color(0xFF333333);
    const Color fieldFillColor = Colors.white;
    final double fieldBorderRadius = context.borderRadius(20);
    final double fieldBorderWidth = context.isSmallMobile ? 1.2 : 1.4;
    final double fieldFocusWidth = context.isSmallMobile ? 2.0 : 2.4;
    final double fieldVertPadding = context.padding(15);
    final double fieldHorizPadding = context.padding(12);
    final double usernamePasswordFieldGap = context.spacing(18);

    return KeyboardDismissible(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = constraints.maxHeight * imageHeightRatio;

              return Stack(
                children: [
                  // ── Background Image ──────────────────────────────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: imageHeight,
                    child: Image.asset(
                      'assets/images/login_page/LoginPage.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // ── Subtle dark overlay on image ──────────────────────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: imageHeight,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x22000000)],
                        ),
                      ),
                    ),
                  ),

                  // ── White card background ─────────────────────────────
                  Positioned(
                    top: imageHeight - 30,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  // ── Main content column ───────────────────────────────
                  Column(
                    children: [
                      // Image section with logo & app name
                      SizedBox(
                        height: imageHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo dan teks dihapus
                          ],
                        ),
                      ),

                      // White card content
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(
                            context.padding(24),
                            context.padding(28),
                            context.padding(24),
                            0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Greeting with Slide Animation
                              _SlideAnimation(
                                delay: 100,
                                child: Text(
                                  'Selamat Datang',
                                  style: AppTextStyles.headlineSmall
                                      .weighted(FontWeight.w800)
                                      .colored(const Color(0xFF4A7A5A))
                                      .copyWith(fontSize: context.fontSize(24)),
                                ),
                              ),
                              SizedBox(height: context.spacing(6)),
                              _SlideAnimation(
                                delay: 200,
                                child: Text(
                                  'Silakan masuk ke akun Anda untuk melanjutkan',
                                  style: AppTextStyles.body14
                                      .colored(const Color(0xFF9E9E9E))
                                      .copyWith(fontSize: context.fontSize(14)),
                                ),
                              ),
                              SizedBox(height: context.spacing(30)),

                              // Username field with Slide Animation
                              _SlideAnimation(
                                delay: 300,
                                child: Obx(
                                  () => _buildTextField(
                                    context: context,
                                    textController: controller.usernameController,
                                    hintText: 'Username',
                                    icon: Icons.person_outline_rounded,
                                    errorText: controller.usernameError.value,
                                    borderColor: fieldBorderColor,
                                    focusColor: fieldFocusColor,
                                    iconColor: fieldIconColor,
                                    hintColor: fieldHintColor,
                                    textColor: fieldTextColor,
                                    fillColor: fieldFillColor,
                                    borderRadius: fieldBorderRadius,
                                    borderWidth: fieldBorderWidth,
                                    focusWidth: fieldFocusWidth,
                                    vertPadding: fieldVertPadding,
                                    horizPadding: fieldHorizPadding,
                                  ),
                                ),
                              ),
                              SizedBox(height: usernamePasswordFieldGap),

                              // Password field with Slide Animation
                              _SlideAnimation(
                                delay: 400,
                                child: Obx(
                                  () => _buildTextField(
                                    context: context,
                                    textController: controller.passwordController,
                                    hintText: 'Password',
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    obscureText:
                                        controller.isPasswordHidden.value,
                                    errorText: controller.passwordError.value,
                                    onTogglePassword:
                                        controller.togglePasswordVisibility,
                                    borderColor: fieldBorderColor,
                                    focusColor: fieldFocusColor,
                                    iconColor: fieldIconColor,
                                    hintColor: fieldHintColor,
                                    textColor: fieldTextColor,
                                    fillColor: fieldFillColor,
                                    borderRadius: fieldBorderRadius,
                                    borderWidth: fieldBorderWidth,
                                    focusWidth: fieldFocusWidth,
                                    vertPadding: fieldVertPadding,
                                    horizPadding: fieldHorizPadding,
                                  ),
                                ),
                              ),

                              SizedBox(height: context.spacing(20)),

                              // Remember Me checkbox with Slide Animation
                              _SlideAnimation(
                                delay: 500,
                                child: Obx(
                                  () => Row(
                                    children: [
                                      SizedBox(
                                        width: context.iconSize(24),
                                        height: context.iconSize(24),
                                        child: Checkbox(
                                          value: controller.rememberMe.value,
                                          onChanged: (value) =>
                                              controller.toggleRememberMe(),
                                          activeColor: const Color(0xFF4E7B63),
                                          checkColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              context.borderRadius(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: context.spacing(12)),
                                      GestureDetector(
                                        onTap: controller.toggleRememberMe,
                                        child: Text(
                                          'Ingatkan saya',
                                          style: AppTextStyles.body14
                                              .colored(const Color(0xFF6B7280))
                                              .copyWith(
                                                fontSize: context.fontSize(14),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: context.spacing(35)),

                              // Login button with Slide Animation
                              _SlideAnimation(
                                delay: 600,
                                child: Obx(
                                  () => SizedBox(
                                    width: double.infinity,
                                    height: context.buttonHeight(56),
                                    child:
                                        ElevatedButton(
                                              onPressed:
                                                  controller.isLoading.value
                                                  ? null
                                                  : controller.login,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF4E7B63,
                                                ),
                                                disabledBackgroundColor:
                                                    const Color(
                                                      0xFF4E7B63,
                                                    ).withValues(alpha: 0.6),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        context.borderRadius(16),
                                                      ),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: controller.isLoading.value
                                                  ? SizedBox(
                                                      width: context.iconSize(24),
                                                      height: context.iconSize(
                                                        24,
                                                      ),
                                                      child:
                                                          const CircularProgressIndicator(
                                                            strokeWidth: 2.5,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Masuk',
                                                          style: AppTextStyles
                                                              .buttonLarge
                                                              .copyWith(
                                                                color:
                                                                    Colors.white,
                                                                letterSpacing:
                                                                    0.4,
                                                                fontSize: context
                                                                    .fontSize(16),
                                                              ),
                                                        ),
                                                        SizedBox(
                                                          width: context.spacing(
                                                            8,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_rounded,
                                                          color: Colors.white,
                                                          size: context.iconSize(
                                                            20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            )
                                            .animate(
                                              // Membuat efek shimmer berkala pada tombol utama CTA ini!
                                              onPlay: (c) =>
                                                  c.repeat(reverse: false),
                                            )
                                            .shimmer(
                                              duration: 2500.ms,
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              angle: 45,
                                            ),
                                  ),
                                ),
                              ),

                              SizedBox(height: context.spacing(80)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController textController,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    String? errorText,
    VoidCallback? onTogglePassword,
    Color borderColor = const Color(0xFF6B8E7A),
    Color focusColor = const Color(0xFF6B8E7A),
    Color iconColor = const Color(0xFF6B7280),
    Color hintColor = const Color(0xFFAAAAAA),
    Color textColor = const Color(0xFF333333),
    Color fillColor = Colors.white,
    double borderRadius = 22,
    double borderWidth = 1.4,
    double focusWidth = 1.2,
    double vertPadding = 14,
    double horizPadding = 18,
  }) {
    return TextField(
      controller: textController,
      obscureText: obscureText,
      style: AppTextStyles.body14.copyWith(
        fontSize: context.fontSize(15),
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.body14.copyWith(
          color: hintColor,
          fontSize: context.fontSize(15),
        ),
        errorText: errorText,
        errorStyle: AppTextStyles.body12.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.w500,
          fontSize: context.fontSize(12),
        ),
        prefixIcon: Icon(icon, color: iconColor, size: context.iconSize(22)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: iconColor,
                  size: context.iconSize(22),
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: fillColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: horizPadding,
          vertical: vertPadding,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: focusColor, width: focusWidth),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
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
