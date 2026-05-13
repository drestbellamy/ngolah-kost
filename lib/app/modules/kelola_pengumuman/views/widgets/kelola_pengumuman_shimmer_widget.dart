import 'package:flutter/material.dart';

class KelolaPengumumanShimmerWidget extends StatefulWidget {
  final bool isGedung;
  const KelolaPengumumanShimmerWidget({super.key, this.isGedung = false});

  @override
  State<KelolaPengumumanShimmerWidget> createState() =>
      _KelolaPengumumanShimmerWidgetState();
}

class _KelolaPengumumanShimmerWidgetState
    extends State<KelolaPengumumanShimmerWidget>
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return widget.isGedung
            ? _buildGedungShimmer()
            : _buildPengumumanShimmer();
      },
    );
  }

  Widget _buildGedungShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              width: double.infinity,
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(width: 58, height: 58, borderRadius: 14),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerBox(width: 150, height: 20),
                        const SizedBox(height: 8),
                        _buildShimmerBox(width: 100, height: 14),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildShimmerBox(width: 80, height: 16),
                            const Spacer(),
                            _buildShimmerBox(
                              width: 32,
                              height: 32,
                              borderRadius: 8,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPengumumanShimmer() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      child: Column(
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              width: double.infinity,
              height: 110,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerBox(width: 180, height: 20),
                      Row(
                        children: [
                          _buildShimmerBox(
                            width: 24,
                            height: 24,
                            borderRadius: 4,
                          ),
                          const SizedBox(width: 8),
                          _buildShimmerBox(
                            width: 24,
                            height: 24,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildShimmerBox(width: 250, height: 14),
                  const Spacer(),
                  Row(
                    children: [
                      _buildShimmerBox(width: 100, height: 14),
                      const Spacer(),
                      _buildShimmerBox(width: 80, height: 14),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
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
            Color(0xFFE5E7EB),
            Color(0xFFF3F4F6),
            Color(0xFFE5E7EB),
          ],
          stops: [
            _animation.value - 0.2,
            _animation.value,
            _animation.value + 0.2,
          ],
        ),
      ),
    );
  }
}
