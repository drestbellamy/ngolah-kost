import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../enums/toast_type.dart';
import 'toast_container.dart';

class CustomToast {
  static OverlayEntry? _currentToast;
  static bool _isShowing = false;

  static void show({
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    bool dismissible = true,
    IconData? icon, // Add custom icon parameter
  }) {
    // Dismiss current toast if exists
    if (_isShowing) {
      dismiss();
    }

    // Try to get overlay context with fallback
    BuildContext? context = Get.overlayContext;
    context ??= Get.context;

    if (context == null) {
      print('Toast error: No context available');
      return;
    }

    // Check if overlay is still mounted
    try {
      final overlay = Overlay.of(context, rootOverlay: true);

      _isShowing = true;

      _currentToast = OverlayEntry(
        builder: (context) => _ToastAnimation(
          child: ToastContainer(
            message: message,
            title: title,
            type: type,
            onDismiss: dismissible ? dismiss : null,
            customIcon: icon, // Pass custom icon
          ),
        ),
      );

      overlay.insert(_currentToast!);

      // Auto dismiss after duration
      Future.delayed(duration, () {
        dismiss();
      });
    } catch (e) {
      // If overlay is not available, silently fail
      print('Toast error: $e');
      _isShowing = false;
    }
  }

  static void dismiss() {
    if (_currentToast != null && _isShowing) {
      _currentToast?.remove();
      _currentToast = null;
      _isShowing = false;
    }
  }
}

class _ToastAnimation extends StatefulWidget {
  final Widget child;

  const _ToastAnimation({required this.child});

  @override
  State<_ToastAnimation> createState() => _ToastAnimationState();
}

class _ToastAnimationState extends State<_ToastAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
      ),
    );
  }
}
