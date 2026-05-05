import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper class untuk form utilities yang digunakan di dialog-dialog
class FormHelpers {
  /// Input decoration yang konsisten untuk semua form
  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6B8E7A)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  /// Validator untuk judul pengumuman
  static String? validateJudul(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Judul pengumuman wajib diisi';
    }
    if (text.length < 5) {
      return 'Minimal 5 karakter';
    }
    return null;
  }

  /// Validator untuk deskripsi pengumuman
  static String? validateDeskripsi(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Deskripsi pengumuman wajib diisi';
    }
    if (text.length < 10) {
      return 'Minimal 10 karakter';
    }
    return null;
  }

  /// Show error snackbar dengan format yang konsisten
  static void showFormException(Object error, String fallbackMessage) {
    final raw = error.toString().trim();
    var message = raw;

    if (message.startsWith('Exception:')) {
      message = message.substring('Exception:'.length).trim();
    }

    if (message.isEmpty) {
      message = fallbackMessage;
    }

    Get.snackbar('Error', message);
  }
}
