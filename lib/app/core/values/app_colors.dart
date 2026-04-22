import 'package:flutter/material.dart';

/// App Colors untuk aplikasi Ngolah Kost
class AppColors {
  // ==================== PRIMARY COLORS ====================
  static const primary = Color(0xFF6B8E7A);
  static const primaryDark = Color(0xFF4F6F5D);
  static const primaryLight = Color(0xFFA8D5BA);
  static const primaryLighter = Color(0xFFE8F0ED);

  // ==================== SECONDARY COLORS ====================
  static const secondary = Color(0xFFFF9F66);
  static const secondaryDark = Color(0xFFE8953D);
  static const secondaryLight = Color(0xFFF2A65A);

  // ==================== BACKGROUND COLORS ====================
  static const background = Color(0xFFF7F9F8);
  static const backgroundWhite = Color(0xFFFFFFFF);
  static const backgroundGray = Color(0xFFF3F4F6);

  // ==================== TEXT COLORS ====================
  static const textPrimary = Color(0xFF2F2F2F);
  static const textSecondary = Color(0xFF2D3748);
  static const textTertiary = Color(0xFF718096);
  static const textGray = Color(0xFF6B7280);
  static const textLight = Color(0xFFCBD5E0);
  static const textWhite = Color(0xFFFFFFFF);

  // ==================== STATUS COLORS ====================
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFF4CAF50);
  static const successBg = Color(0xFFE8F5E9);

  static const error = Color(0xFFE53E3E);
  static const errorLight = Color(0xFFEF4444);
  static const errorBg = Color(0xFFFEE2E2);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFF2A65A);
  static const warningBg = Color(0xFFFEF3C7);

  static const info = Color(0xFF4B83F3);
  static const infoLight = Color(0xFF285ADA);
  static const infoBg = Color(0xFFDCEAFE);

  // ==================== ALERT COLORS ====================
  static const alertOrange = Color(0xFFFF6900);
  static const alertOrangeDark = Color(0xFFF54900);
  static const alertOrangeLight = Color(0xFFFFEDD4);

  // ==================== BORDER COLORS ====================
  static const border = Color(0xFFF3F4F6);
  static const borderLight = Color(0xFFE5E7EB);
  static const borderDark = Color(0xFFD1D5DB);

  // ==================== SHADOW COLORS ====================
  static Color shadow = Colors.black.withValues(alpha: 0.1);
  static Color shadowLight = Colors.black.withValues(alpha: 0.05);
  static Color shadowDark = Colors.black.withValues(alpha: 0.15);

  // ==================== OVERLAY COLORS ====================
  static Color overlay = Colors.black.withValues(alpha: 0.5);
  static Color overlayLight = Colors.black.withValues(alpha: 0.3);
  static Color overlayDark = Colors.black.withValues(alpha: 0.7);

  // ==================== GRADIENT COLORS ====================
  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF6B8E7A), Color(0xFF4F6F5D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSecondary = LinearGradient(
    colors: [Color(0xFFF2A65A), Color(0xFFE8953D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientAlert = LinearGradient(
    colors: [Color(0xFFFF6900), Color(0xFFF54900)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientBlue = LinearGradient(
    colors: [Color(0xFF4B83F3), Color(0xFF285ADA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientGreen = LinearGradient(
    colors: [Color(0xFF2D7A6E), Color(0xFF1F5449)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientGray = LinearGradient(
    colors: [Color(0xFF8FAA9F), Color(0xFF6B8E7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
