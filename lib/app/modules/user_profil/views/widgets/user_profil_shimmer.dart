import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class UserProfilShimmer extends StatefulWidget {
  const UserProfilShimmer({super.key});

  @override
  State<UserProfilShimmer> createState() => _UserProfilShimmerState();
}

class _UserProfilShimmerState extends State<UserProfilShimmer>
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

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
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
        children: [
          _buildProfileHeaderShimmer(context),
          Padding(
            padding: context.symmetricPadding(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              children: [
                _buildInfoSectionShimmer(context, 3),
                SizedBox(height: context.spacing(16)),
                _buildInfoSectionShimmer(context, 4),
                SizedBox(height: context.spacing(16)),
                _buildInfoSectionShimmer(context, 3),
                SizedBox(height: context.spacing(24)),
                _buildLogoutButtonShimmer(context),
                SizedBox(height: context.spacing(24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGradient(Widget child) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              transform: const GradientRotation(-0.5),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }

  Widget _buildProfileHeaderShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6B8E7A).withValues(alpha: 0.3),
            const Color(0xFF8BA888).withValues(alpha: 0.3),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: context.allPadding(24),
          child: _buildShimmerGradient(
            Column(
              children: [
                SizedBox(height: context.spacing(20)),
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: context.spacing(16)),
                Container(
                  width: context.screenWidth * 0.5,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: context.spacing(8)),
                Container(
                  width: context.screenWidth * 0.6,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: context.spacing(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSectionShimmer(BuildContext context, int itemCount) {
    return _buildShimmerGradient(
      Container(
        padding: context.allPadding(20),
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
            Container(
              width: context.screenWidth * 0.4,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: context.spacing(16)),
            Divider(color: Colors.grey[200]),
            SizedBox(height: context.spacing(16)),
            ...List.generate(
              itemCount,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < itemCount - 1 ? context.spacing(16) : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: context.screenWidth * 0.3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: context.spacing(8)),
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButtonShimmer(BuildContext context) {
    return _buildShimmerGradient(
      Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(context.borderRadius(12)),
          border: Border.all(color: Colors.grey[300]!),
        ),
      ),
    );
  }
}
