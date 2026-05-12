import 'package:flutter/material.dart';

class DetailKeuanganShimmerWidget extends StatefulWidget {
  const DetailKeuanganShimmerWidget({super.key});

  @override
  State<DetailKeuanganShimmerWidget> createState() =>
      _DetailKeuanganShimmerWidgetState();
}

class _DetailKeuanganShimmerWidgetState
    extends State<DetailKeuanganShimmerWidget>
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
          // Chart / Summary Card Shimmer (Same as Ringkasan)
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

          // Pemasukan Section Shimmer
          _buildTransactionSectionShimmer(),

          const SizedBox(height: 16),

          // Pengeluaran Section Shimmer
          _buildTransactionSectionShimmer(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTransactionSectionShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row Shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => _buildShimmerBox(
                        36,
                        36,
                        _animation.value,
                        borderRadius: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) => _buildShimmerBox(
                        160,
                        20,
                        _animation.value,
                        borderRadius: 4,
                      ),
                    ),
                  ],
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) => _buildShimmerBox(
                    36,
                    36,
                    _animation.value,
                    borderRadius: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // List Items Shimmer
            Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) => _buildShimmerBox(
                                120,
                                16,
                                _animation.value,
                                borderRadius: 4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) => _buildShimmerBox(
                                80,
                                12,
                                _animation.value,
                                borderRadius: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) => _buildShimmerBox(
                          100,
                          20,
                          _animation.value,
                          borderRadius: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
