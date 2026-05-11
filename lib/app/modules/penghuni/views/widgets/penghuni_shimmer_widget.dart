import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class PenghuniShimmerWidget extends StatefulWidget {
  const PenghuniShimmerWidget({super.key});

  @override
  State<PenghuniShimmerWidget> createState() => _PenghuniShimmerWidgetState();
}

class _PenghuniShimmerWidgetState extends State<PenghuniShimmerWidget>
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
    return ListView.builder(
      padding: context.horizontalPadding(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(bottom: context.spacing(12)),
              padding: context.allPadding(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.borderRadius(16)),
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
                      // Avatar shimmer
                      _buildShimmerBox(
                        context.iconSize(48),
                        context.iconSize(48),
                        _animation.value,
                        borderRadius: context.borderRadius(12),
                      ),
                      SizedBox(width: context.spacing(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama shimmer
                            _buildShimmerBox(
                              context.screenWidth * 0.4,
                              context.fontSize(16),
                              _animation.value,
                            ),
                            SizedBox(height: context.spacing(4)),
                            // Kost shimmer
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
                                  context.screenWidth * 0.3,
                                  context.fontSize(12),
                                  _animation.value,
                                ),
                              ],
                            ),
                            SizedBox(height: context.spacing(2)),
                            // Phone shimmer
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
                                  context.screenWidth * 0.25,
                                  context.fontSize(12),
                                  _animation.value,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Status badge shimmer
                          _buildShimmerBox(
                            80,
                            context.fontSize(12) + 8,
                            _animation.value,
                            borderRadius: context.borderRadius(20),
                          ),
                          SizedBox(height: context.spacing(8)),
                          // Room badge shimmer
                          _buildShimmerBox(
                            60,
                            context.fontSize(12) + 12,
                            _animation.value,
                            borderRadius: context.borderRadius(8),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacing(12)),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  SizedBox(height: context.spacing(12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerBox(
                            100,
                            context.fontSize(12),
                            _animation.value,
                          ),
                          SizedBox(height: context.spacing(4)),
                          _buildShimmerBox(
                            120,
                            context.fontSize(14),
                            _animation.value,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildShimmerBox(
                            100,
                            context.fontSize(12),
                            _animation.value,
                          ),
                          SizedBox(height: context.spacing(4)),
                          _buildShimmerBox(
                            80,
                            context.fontSize(14),
                            _animation.value,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
