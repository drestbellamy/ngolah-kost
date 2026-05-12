import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class DashboardShimmerWidget extends StatefulWidget {
  const DashboardShimmerWidget({super.key});

  @override
  State<DashboardShimmerWidget> createState() => _DashboardShimmerWidgetState();
}

class _DashboardShimmerWidgetState extends State<DashboardShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildShimmerBox(
    double width,
    double height,
    double animationValue, {
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: [animationValue - 0.3, animationValue, animationValue + 0.3],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildShimmerCard()),
                SizedBox(width: context.spacing(16)),
                Expanded(child: _buildShimmerCard()),
              ],
            ),
            SizedBox(height: context.spacing(16)),
            Row(
              children: [
                Expanded(child: _buildShimmerCard()),
                SizedBox(width: context.spacing(16)),
                Expanded(child: _buildShimmerCard()),
              ],
            ),
            SizedBox(height: context.spacing(16)),
            Row(
              children: [
                Expanded(child: _buildShimmerCard()),
                SizedBox(width: context.spacing(16)),
                Expanded(child: _buildShimmerCard()),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 165,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildShimmerBox(56, 56, _animation.value, borderRadius: 16),
          const Spacer(),
          _buildShimmerBox(
            60, // Lebar kotak text angkanya
            36, // Tinggi font - displaySmall fontSize 30
            _animation.value,
            borderRadius: 6,
          ),
          const SizedBox(height: 4),
          _buildShimmerBox(
            110, // Lebar kotak string title
            16, // Tinggi font label body12
            _animation.value,
            borderRadius: 6,
          ),
        ],
      ),
    );
  }
}
