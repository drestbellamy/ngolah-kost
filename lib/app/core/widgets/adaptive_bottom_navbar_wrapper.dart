import 'package:flutter/material.dart';
import 'dart:async';

/// Wrapper untuk bottom navbar yang otomatis menyesuaikan dengan sistem navigasi
class AdaptiveBottomNavbarWrapper extends StatefulWidget {
  final Widget child;

  const AdaptiveBottomNavbarWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AdaptiveBottomNavbarWrapper> createState() =>
      _AdaptiveBottomNavbarWrapperState();
}

class _AdaptiveBottomNavbarWrapperState
    extends State<AdaptiveBottomNavbarWrapper> with WidgetsBindingObserver {
  Timer? _debounceTimer;
  bool _needsRebuild = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Tandai bahwa perlu rebuild, tapi jangan langsung setState
    _needsRebuild = true;
    
    // Debounce untuk menghindari rebuild berlebihan
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted && _needsRebuild) {
        _needsRebuild = false;
        // Gunakan scheduleMicrotask untuk menghindari rebuild saat frame sedang dibangun
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
