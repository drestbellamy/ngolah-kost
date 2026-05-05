import 'package:flutter/material.dart';

/// Utility class untuk membuat aplikasi responsive di berbagai ukuran device
class ResponsiveUtils {
  /// Breakpoints untuk berbagai ukuran device
  static const double mobileSmall = 320; // iPhone SE, small Android
  static const double mobileMedium = 375; // iPhone 12/13/14
  static const double mobileLarge = 414; // iPhone Plus models
  static const double mobileXLarge = 428; // iPhone Pro Max
  static const double tablet = 768;
  static const double desktop = 1024;

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is small mobile (width < 360)
  static bool isSmallMobile(BuildContext context) {
    return screenWidth(context) < 360;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < tablet;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= tablet && screenWidth(context) < desktop;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= desktop;
  }

  /// Get responsive value based on screen width
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width < mobileSmall) {
      return baseSize * 0.85; // 85% untuk device sangat kecil
    } else if (width < mobileMedium) {
      return baseSize * 0.9; // 90% untuk device kecil
    } else if (width < mobileLarge) {
      return baseSize; // 100% untuk device medium
    } else if (width < mobileXLarge) {
      return baseSize * 1.05; // 105% untuk device besar
    } else if (width < tablet) {
      return baseSize * 1.1; // 110% untuk device sangat besar
    } else {
      return baseSize * 1.2; // 120% untuk tablet+
    }
  }

  /// Get responsive padding
  static double padding(BuildContext context, double basePadding) {
    final width = screenWidth(context);
    if (width < mobileSmall) {
      return basePadding * 0.75;
    } else if (width < mobileMedium) {
      return basePadding * 0.85;
    } else if (width < mobileLarge) {
      return basePadding;
    } else if (width < tablet) {
      return basePadding * 1.1;
    } else {
      return basePadding * 1.3;
    }
  }

  /// Get responsive spacing
  static double spacing(BuildContext context, double baseSpacing) {
    return padding(context, baseSpacing);
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    if (width < mobileSmall) {
      return baseSize * 0.85;
    } else if (width < mobileMedium) {
      return baseSize * 0.9;
    } else if (width < mobileLarge) {
      return baseSize;
    } else if (width < tablet) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  /// Get responsive border radius
  static double borderRadius(BuildContext context, double baseRadius) {
    final width = screenWidth(context);
    if (width < mobileSmall) {
      return baseRadius * 0.85;
    } else if (width < mobileMedium) {
      return baseRadius * 0.9;
    } else {
      return baseRadius;
    }
  }

  /// Get responsive button height
  static double buttonHeight(BuildContext context, double baseHeight) {
    final width = screenWidth(context);
    if (width < mobileSmall) {
      return baseHeight * 0.85;
    } else if (width < mobileMedium) {
      return baseHeight * 0.9;
    } else {
      return baseHeight;
    }
  }

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context, double basePadding) {
    return EdgeInsets.symmetric(
      horizontal: padding(context, basePadding),
    );
  }

  /// Get responsive vertical padding
  static EdgeInsets verticalPadding(BuildContext context, double basePadding) {
    return EdgeInsets.symmetric(
      vertical: padding(context, basePadding),
    );
  }

  /// Get responsive symmetric padding
  static EdgeInsets symmetricPadding(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: padding(context, horizontal),
      vertical: padding(context, vertical),
    );
  }

  /// Get responsive all padding
  static EdgeInsets allPadding(BuildContext context, double basePadding) {
    return EdgeInsets.all(padding(context, basePadding));
  }

  /// Get responsive card elevation
  static double elevation(BuildContext context, double baseElevation) {
    final width = screenWidth(context);
    if (width < mobileSmall) {
      return baseElevation * 0.8;
    } else {
      return baseElevation;
    }
  }

  /// Get responsive aspect ratio
  static double aspectRatio(BuildContext context, double baseRatio) {
    final width = screenWidth(context);
    if (width < mobileSmall) {
      return baseRatio * 0.9;
    } else {
      return baseRatio;
    }
  }

  /// Get responsive width percentage
  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  /// Get responsive height percentage
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  /// Get text scale factor
  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  /// Clamp text scale factor untuk mencegah text terlalu besar/kecil
  static double clampedTextScaleFactor(
    BuildContext context, {
    double min = 0.8,
    double max = 1.3,
  }) {
    final scale = textScaleFactor(context);
    return scale.clamp(min, max);
  }
}

/// Extension untuk memudahkan penggunaan responsive utils
extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils();

  double get screenWidth => ResponsiveUtils.screenWidth(this);
  double get screenHeight => ResponsiveUtils.screenHeight(this);

  bool get isSmallMobile => ResponsiveUtils.isSmallMobile(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  double fontSize(double baseSize) => ResponsiveUtils.fontSize(this, baseSize);
  double padding(double basePadding) =>
      ResponsiveUtils.padding(this, basePadding);
  double spacing(double baseSpacing) =>
      ResponsiveUtils.spacing(this, baseSpacing);
  double iconSize(double baseSize) => ResponsiveUtils.iconSize(this, baseSize);
  double borderRadius(double baseRadius) =>
      ResponsiveUtils.borderRadius(this, baseRadius);
  double buttonHeight(double baseHeight) =>
      ResponsiveUtils.buttonHeight(this, baseHeight);

  EdgeInsets get safeAreaPadding => ResponsiveUtils.safeAreaPadding(this);
  EdgeInsets horizontalPadding(double basePadding) =>
      ResponsiveUtils.horizontalPadding(this, basePadding);
  EdgeInsets verticalPadding(double basePadding) =>
      ResponsiveUtils.verticalPadding(this, basePadding);
  EdgeInsets symmetricPadding({double horizontal = 0, double vertical = 0}) =>
      ResponsiveUtils.symmetricPadding(
        this,
        horizontal: horizontal,
        vertical: vertical,
      );
  EdgeInsets allPadding(double basePadding) =>
      ResponsiveUtils.allPadding(this, basePadding);

  double widthPercent(double percent) =>
      ResponsiveUtils.widthPercent(this, percent);
  double heightPercent(double percent) =>
      ResponsiveUtils.heightPercent(this, percent);
}

/// Widget builder untuk responsive layout
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
      builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, constraints);
      },
    );
  }
}

/// Widget untuk conditional rendering berdasarkan ukuran screen
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isDesktop(context) && desktop != null) {
      return desktop!;
    }
    if (ResponsiveUtils.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}
