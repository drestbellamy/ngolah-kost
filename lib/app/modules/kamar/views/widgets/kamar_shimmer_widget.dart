import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class KamarShimmerWidget extends StatefulWidget {
  const KamarShimmerWidget({super.key});

  @override
  State<KamarShimmerWidget> createState() => _KamarShimmerWidgetState();
}

class _KamarShimmerWidgetState extends State<KamarShimmerWidget>
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
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        context.padding(24),
        context.padding(8),
        context.padding(24),
        context.padding(96),
      ),
      sliver: SliverList.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.only(bottom: context.spacing(16)),
                padding: context.allPadding(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.borderRadius(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon shimmer
                        _buildShimmerBox(
                          context.iconSize(48),
                          context.iconSize(48),
                          _animation.value,
                          borderRadius: context.borderRadius(12),
                        ),
                        SizedBox(width: context.spacing(16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Nama kamar shimmer
                                  _buildShimmerBox(
                                    context.screenWidth * 0.25,
                                    context.fontSize(16),
                                    _animation.value,
                                  ),
                                  // Status badge shimmer
                                  _buildShimmerBox(
                                    80,
                                    context.fontSize(12) + 8,
                                    _animation.value,
                                    borderRadius: context.borderRadius(20),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.spacing(6)),
                              // Penghuni info shimmer
                              Row(
                                children: [
                                  _buildShimmerBox(
                                    100,
                                    context.fontSize(12),
                                    _animation.value,
                                  ),
                                  SizedBox(width: context.spacing(4)),
                                  _buildShimmerBox(
                                    context.iconSize(16),
                                    context.iconSize(16),
                                    _animation.value,
                                    borderRadius: 2,
                                  ),
                                ],
                              ),
                              SizedBox(height: context.spacing(10)),
                              // Harga shimmer
                              _buildShimmerBox(
                                120,
                                context.fontSize(14),
                                _animation.value,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing(16)),
                    // Buttons shimmer
                    Row(
                      children: [
                        Expanded(
                          child: _buildShimmerBox(
                            double.infinity,
                            context.buttonHeight(44),
                            _animation.value,
                            borderRadius: context.borderRadius(12),
                          ),
                        ),
                        SizedBox(width: context.spacing(12)),
                        Expanded(
                          child: _buildShimmerBox(
                            double.infinity,
                            context.buttonHeight(44),
                            _animation.value,
                            borderRadius: context.borderRadius(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
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
