import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  static const String _loginLottieAsset = 'assets/lotties/Home.json';
  static const String _loginBackgroundAsset =
      'assets/images/login_page/gedung.png';
  static const String _loginEllipseAsset =
      'assets/images/login_page/ellipse.png';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: constraints.maxHeight * 0.55,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            _loginBackgroundAsset,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: const Color(0xFF6B8E7A)),
                          ),
                          Container(
                            color: const Color(0xFF6B8E7A).withOpacity(0.20),
                          ),
                          Positioned(
                            top: constraints.maxHeight * 0.07,
                            left: 0,
                            right: 0,
                            child: _buildBrandHeader(
                              titleColor: Colors.white,
                              logoBackground: const Color(0xFF4F6F5F),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: constraints.maxHeight * 0.45,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 250,
                            child: Image.asset(
                              _loginEllipseAsset,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(),
                            ),
                          ),
                          Positioned(
                            top: 118,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(color: Colors.white),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 66),
                                      const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF6D947F),
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      const Text(
                                        'Username',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2F2F2F),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller:
                                            controller.usernameController,
                                        decoration: InputDecoration(
                                          hintText: 'Username',
                                          prefixIcon: const Icon(
                                            Icons.person_outline,
                                            size: 22,
                                            color: Color(0xFF6B8E7A),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF6B8E7A),
                                              width: 1.2,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFB5C3BC),
                                              width: 1.2,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF6B8E7A),
                                              width: 1.8,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      const Text(
                                        'Password',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2F2F2F),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Obx(
                                        () => TextField(
                                          controller:
                                              controller.passwordController,
                                          obscureText:
                                              controller.isPasswordHidden.value,
                                          decoration: InputDecoration(
                                            hintText: 'Password',
                                            prefixIcon: const Icon(
                                              Icons.lock_outline,
                                              size: 22,
                                              color: Color(0xFF6B8E7A),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                controller
                                                        .isPasswordHidden
                                                        .value
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                size: 20,
                                                color: const Color(0xFF6B7280),
                                              ),
                                              onPressed: controller
                                                  .togglePasswordVisibility,
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF6B8E7A),
                                                width: 1.2,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFB5C3BC),
                                                width: 1.2,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF6B8E7A),
                                                width: 1.8,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 40),

                                      Container(
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 16,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Obx(
                                          () => ElevatedButton(
                                            onPressed:
                                                controller.isLoading.value
                                                ? null
                                                : controller.login,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF6D947F,
                                              ),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: controller.isLoading.value
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : const Text(
                                                    'Login',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader({
    required Color titleColor,
    required Color logoBackground,
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
                  _loginLottieAsset,
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
          child: Text(
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
        ),
      ],
    );
  }
}
