import 'package:flutter/material.dart';

class RingkasanKeuanganShimmerWidget extends StatefulWidget {
  const RingkasanKeuanganShimmerWidget({super.key});

  @override
  State<RingkasanKeuanganShimmerWidget> createState() =>
      _RingkasanKeuanganShimmerWidgetState();
}

class _RingkasanKeuanganShimmerWidgetState
    extends State<RingkasanKeuanganShimmerWidget>
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Chart Card Shimmer
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return _buildShimmerBox(
                          double.infinity,
                          double.infinity,
                          _animation.value,
                          borderRadius: 16,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => _buildShimmerBox(
                        24,
                        8,
                        _animation.value,
                        borderRadius: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => _buildShimmerBox(
                        8,
                        8,
                        _animation.value,
                        borderRadius: 4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Title Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) =>
                  _buildShimmerBox(150, 24, _animation.value, borderRadius: 4),
            ),
          ),
          const SizedBox(height: 16),
          // Kost List Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return _buildShimmerBox(
                        double.infinity,
                        80,
                        _animation.value,
                        borderRadius: 12,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(
    double width,
    double height,
    double animationValue, {
    double borderRadius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFE5E7EB),
            Color(0xFFF3F4F6),
            Color(0xFFE5E7EB),
          ],
          stops: [
            (animationValue - 1).clamp(0.0, 1.0),
            animationValue.clamp(0.0, 1.0),
            (animationValue + 1).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}
