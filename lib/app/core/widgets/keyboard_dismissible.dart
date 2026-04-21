import 'package:flutter/material.dart';

/// Widget wrapper untuk menutup keyboard saat tap di luar TextField
/// 
/// Gunakan widget ini sebagai parent dari Scaffold atau halaman utama
/// untuk otomatis menutup keyboard saat user tap di area kosong
class KeyboardDismissible extends StatelessWidget {
  final Widget child;

  const KeyboardDismissible({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Menutup keyboard saat tap di luar TextField
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
