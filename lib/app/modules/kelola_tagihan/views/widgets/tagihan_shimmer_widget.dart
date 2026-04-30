import 'package:flutter/material.dart';

class TagihanShimmerWidget extends StatefulWidget {
  const TagihanShimmerWidget({super.key});

  @override
  State<TagihanShimmerWidget> createState() => _TagihanShimmerWidgetState();
}

class _TagihanShimmerWidgetState extends State<TagihanShimmerWidget>
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
    return Column(
      children: List.generate(
        3,
        (index) => AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(top: index == 0 ? 12 : 0, bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerBox(150, 20, _animation.value),
                      _buildShimmerBox(80, 28, _animation.value),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildShimmerBox(120, 14, _animation.value),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerBox(80, 16, _animation.value),
                      _buildShimmerBox(120, 16, _animation.value),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerBox(100, 14, _animation.value),
                      _buildShimmerBox(120, 20, _animation.value),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height, double animationValue) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
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
