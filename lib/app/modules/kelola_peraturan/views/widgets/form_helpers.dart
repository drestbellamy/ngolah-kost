import 'package:flutter/material.dart';

class FormHelpers {
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

  static Widget requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }

  static String? validateNama(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Nama kategori wajib diisi';
    }
    if (text.length < 3) {
      return 'Minimal 3 karakter';
    }
    return null;
  }

  static String? validateDeskripsi(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty || text == '1.') {
      return 'Deskripsi peraturan wajib diisi';
    }
    if (text.length < 10) {
      return 'Minimal 10 karakter';
    }
    return null;
  }
}
