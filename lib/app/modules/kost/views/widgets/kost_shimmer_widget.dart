import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class KostShimmerWidget extends StatefulWidget {
  const KostShimmerWidget({super.key});

  @override
  State<KostShimmerWidget> createState() => _KostShimmerWidgetState();
}

class _KostShimmerWidgetState extends State<KostShimmerWidget>
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
      children: [
        // Map View Button Shimmer
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.padding(16),
            context.padding(16),
            context.padding(16),
            0,
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return _buildShimmerBox(
                double.infinity,
                context.buttonHeight(48),
                _animation.value,
                borderRadius: context.borderRadius(12),
              );
            },
          ),
        ),
        // Kost List Shimmer
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(ResponsiveUtils.padding(context, 16)),
            itemCount: 4,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    margin: EdgeInsets.only(bottom: context.padding(16)),
                    padding: context.allPadding(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        context.borderRadius(16),
                      ),
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
                          children: [
                            // Icon shimmer
                            _buildShimmerBox(
                              context.iconSize(48),
                              context.iconSize(48),
                              _animation.value,
                              borderRadius: context.borderRadius(12),
                            ),
                            SizedBox(width: context.spacing(12)),
                            // Info shimmer
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name shimmer
                                  _buildShimmerBox(
                                    context.screenWidth * 0.4,
                                    context.fontSize(16),
                                    _animation.value,
                                  ),
                                  SizedBox(height: context.spacing(4)),
                                  // Address shimmer
                                  Row(
                                    children: [
                                      _buildShimmerBox(
                                        context.iconSize(14),
                                        context.iconSize(14),
                                        _animation.value,
                                        borderRadius: 2,
                                      ),
                                      SizedBox(width: context.spacing(4)),
                                      _buildShimmerBox(
                                        context.screenWidth * 0.35,
                                        context.fontSize(12),
                                        _animation.value,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Menu icon shimmer
                            _buildShimmerBox(
                              context.iconSize(24),
                              context.iconSize(24),
                              _animation.value,
                              borderRadius: context.borderRadius(12),
                            ),
                          ],
                        ),
                        SizedBox(height: context.spacing(12)),
                        // Room count shimmer
                        _buildShimmerBox(
                          80,
                          context.fontSize(12) + 8,
                          _animation.value,
                          borderRadius: context.borderRadius(6),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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
