import 'package:flutter/material.dart';
import '../enums/toast_type.dart';

class ToastContainer extends StatelessWidget {
  final String message;
  final String? title;
  final ToastType type;
  final VoidCallback? onDismiss;
  final IconData? customIcon;
  final Color? backgroundColor;

  const ToastContainer({
    super.key,
    required this.message,
    this.title,
    required this.type,
    this.onDismiss,
    this.customIcon,
    this.backgroundColor,
  });

  // Background gradient (soft color to white)
  LinearGradient _getBackgroundGradient() {
    switch (type) {
      case ToastType.success:
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFD1FAE5), // Soft green
            Color(0xFFFFFFFF), // White
          ],
          stops: [0.0, 0.35], // Gradient stops at 25% (around icon area)
        );
      case ToastType.error:
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFECACA), // Soft red/pink
            Color(0xFFFFFFFF), // White
          ],
          stops: [0.0, 0.35], // Gradient stops at 25% (around icon area)
        );
      case ToastType.warning:
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFDE68A), // Soft yellow
            Color(0xFFFFFFFF), // White
          ],
          stops: [0.0, 0.35], // Gradient stops at 25% (around icon area)
        );
      case ToastType.info:
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFBFDBFE), // Soft blue
            Color(0xFFFFFFFF), // White
          ],
          stops: [0.0, 0.35], // Gradient stops at 25% (around icon area)
        );
    }
  }

  // Icon colors (vibrant)
  Color _getIconColor() {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF10B981); // Green
      case ToastType.error:
        return const Color(0xFFEF4444); // Red
      case ToastType.warning:
        return const Color(0xFFF59E0B); // Orange/Yellow
      case ToastType.info:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  IconData _getIcon() {
    if (customIcon != null) return customIcon!;

    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: _getBackgroundGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container (white square with rounded corners and shadow)
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(_getIcon(), color: _getIconColor(), size: 26),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: const TextStyle(
                        color: Color(0xFF111827), // Very dark gray
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF), // Light gray
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Close button
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onDismiss ?? () {},
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                color: const Color(0xFFD1D5DB), // Very light gray
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
