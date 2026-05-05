import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../enums/toast_type.dart';
import '../widgets/toast_container.dart';

class ToastHelper {
  /// Show success toast
  static void showSuccess(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: _buildToastContent(
          message: message,
          title: title ?? 'Berhasil',
          icon: icon ?? Icons.check_circle_outline,
          type: ToastType.success,
        ),
        backgroundColor: Colors.transparent,
        duration: duration,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 16,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        snackPosition: SnackPosition.TOP,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Show error toast
  static void showError(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: _buildToastContent(
          message: message,
          title: title ?? 'Gagal',
          icon: icon ?? Icons.error_outline,
          type: ToastType.error,
        ),
        backgroundColor: Colors.transparent,
        duration: duration,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 16,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        snackPosition: SnackPosition.TOP,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Show warning toast
  static void showWarning(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: _buildToastContent(
          message: message,
          title: title ?? 'Peringatan',
          icon: icon ?? Icons.warning_amber_outlined,
          type: ToastType.warning,
        ),
        backgroundColor: Colors.transparent,
        duration: duration,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 16,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        snackPosition: SnackPosition.TOP,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Show info toast
  static void showInfo(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: _buildToastContent(
          message: message,
          title: title ?? 'Informasi',
          icon: icon ?? Icons.info_outline,
          type: ToastType.info,
        ),
        backgroundColor: Colors.transparent,
        duration: duration,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 16,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        snackPosition: SnackPosition.TOP,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Show custom toast with full control
  static void show({
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    bool dismissible = true,
    IconData? icon,
  }) {
    IconData defaultIcon;
    String defaultTitle;

    switch (type) {
      case ToastType.success:
        defaultIcon = Icons.check_circle_outline;
        defaultTitle = 'Success';
        break;
      case ToastType.error:
        defaultIcon = Icons.error_outline;
        defaultTitle = 'Error';
        break;
      case ToastType.warning:
        defaultIcon = Icons.warning_amber_outlined;
        defaultTitle = 'Warning';
        break;
      case ToastType.info:
        defaultIcon = Icons.info_outline;
        defaultTitle = 'Information';
        break;
    }

    Get.showSnackbar(
      GetSnackBar(
        messageText: _buildToastContent(
          message: message,
          title: title ?? defaultTitle,
          icon: icon ?? defaultIcon,
          type: type,
        ),
        backgroundColor: Colors.transparent,
        duration: duration,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 16,
        isDismissible: dismissible,
        dismissDirection: DismissDirection.horizontal,
        snackPosition: SnackPosition.TOP,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Build toast content widget
  static Widget _buildToastContent({
    required String message,
    required String title,
    required IconData icon,
    required ToastType type,
  }) {
    return ToastContainer(
      message: message,
      title: title,
      type: type,
      customIcon: icon,
      onDismiss: null, // GetSnackBar handles dismiss
    );
  }

  /// Dismiss current toast
  static void dismiss() {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
  }
}
