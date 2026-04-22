import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/login_controller.dart';
import '../../../core/widgets/keyboard_dismissible.dart';
import '../../../core/values/values.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    const double logoVerticalOffset = -55;
    const double logoBottomPadding = 0;
    const double logoSize = 100;
    const double lottieScale = 0.40;
    const double textLogoGap = -26;
    final double imageHeightRatio = 0.55;

    const Color fieldBorderColor = Color(0xFF6B8E7A);
    const Color fieldFocusColor = Color(0xFF6B8E7A);
    const Color fieldIconColor = Color(0xFF6B7280);
    const Color fieldHintColor = Color(0xFFAAAAAA);
    const Color fieldTextColor = Color(0xFF333333);
    const Color fieldFillColor = Colors.white;
    const double fieldBorderRadius = 20;
    const double fieldBorderWidth = 1.4;
    const double fieldFocusWidth = 2.4;
    const double fieldVertPadding = 15;
    const double fieldHorizPadding = 12;
    const double usernamePasswordFieldGap = 18;

    return KeyboardDismissible(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
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
                    'assets/images/login_page/gedung.png',
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
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ── Logo + teks dibungkus satu Transform ──
                            Transform.translate(
                              offset: Offset(0, logoVerticalOffset),
                              child: Column(
                                children: [
                                  // ── Animated logo ──
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Green rounded square background
                                      Container(
                                        width: logoSize,
                                        height: logoSize,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6E947F),
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.25,
                                            ),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.50,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Lottie animation
                                      Padding(
                                        padding: const EdgeInsets.all(1),
                                        child: Transform.scale(
                                          scale: lottieScale,
                                          child: Lottie.asset(
                                            'assets/lotties/Home.json',
                                            repeat: true,
                                            fit: BoxFit.cover,
                                            frameRate: FrameRate.composition,
                                            options: LottieOptions(
                                              enableMergePaths: true,
                                            ),
                                            errorBuilder: (_, e, s) =>
                                                const Icon(
                                                  Icons.home_rounded,
                                                  size: 58,
                                                  color: Color(0xFF6B8E7A),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: logoBottomPadding),

                                  // ── App name — jarak diatur lewat textLogoGap ──
                                  Transform.translate(
                                    offset: Offset(0, textLogoGap),
                                    child: Text(
                                      'Ngolah Kost',
                                      style: AppTextStyles.headlineLarge
                                          .copyWith(
                                            color: Colors.white,
                                            letterSpacing: 0.4,
                                            height: 0.1,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.50,
                                                ),
                                                offset: const Offset(0, 2),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // White card content
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting
                            Text(
                              'Selamat Datang',
                              style: AppTextStyles.headlineSmall
                                  .weighted(FontWeight.w800)
                                  .colored(const Color(0xFF4A7A5A)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Silakan masuk ke akun Anda untuk melanjutkan',
                              style: AppTextStyles.body14.colored(
                                const Color(0xFF9E9E9E),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Username field
                            Obx(
                              () => _buildTextField(
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
                            const SizedBox(height: usernamePasswordFieldGap),

                            // Password field
                            Obx(
                              () => _buildTextField(
                                textController: controller.passwordController,
                                hintText: 'Password',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                obscureText: controller.isPasswordHidden.value,
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

                            const SizedBox(height: 20),

                            // Remember Me checkbox
                            Obx(
                              () => Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: controller.rememberMe.value,
                                      onChanged: (value) =>
                                          controller.toggleRememberMe(),
                                      activeColor: const Color(0xFF4E7B63),
                                      checkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: controller.toggleRememberMe,
                                    child: Text(
                                      'Ingatkan saya',
                                      style: AppTextStyles.body14.colored(
                                        const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 35),

                            // Login button
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4E7B63),
                                    disabledBackgroundColor: const Color(
                                      0xFF4E7B63,
                                    ).withValues(alpha: 0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Masuk',
                                              style: AppTextStyles.buttonLarge
                                                  .copyWith(
                                                    color: Colors.white,
                                                    letterSpacing: 0.4,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),

                            // Bottom safe area padding
                            SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 24,
                            ),
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
    );
  }

  Widget _buildTextField({
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
      style: AppTextStyles.body14.copyWith(fontSize: 15, color: textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.body14.copyWith(
          color: hintColor,
          fontSize: 15,
        ),
        errorText: errorText,
        errorStyle: AppTextStyles.body12.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: iconColor, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: iconColor,
                  size: 22,
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
