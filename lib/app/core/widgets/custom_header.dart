import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../values/values.dart';
import '../utils/responsive_utils.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? trailing;
  final Widget? progressIndicator;
  final String? backgroundImage;

  const CustomHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.showBackButton = false,
    this.onBackPressed,
    this.trailing,
    this.progressIndicator,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: backgroundImage == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6B8E7A), Color(0xFF4F6F5D)],
              )
            : null,
        image: backgroundImage != null
            ? DecorationImage(
                image: AssetImage(backgroundImage!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.10),
                  BlendMode.darken,
                ),
              )
            : null,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.borderRadius(24)),
          bottomRight: Radius.circular(context.borderRadius(24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          if (backgroundImage == null) ...[
            Positioned(
              right: context.isSmallMobile ? -100 : -120,
              top: context.isSmallMobile ? -150 : -180,
              child: Container(
                width: context.isSmallMobile ? 200 : 256,
                height: context.isSmallMobile ? 200 : 256,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: context.isSmallMobile ? -60 : -80,
              bottom: context.isSmallMobile ? -80 : -100,
              child: Container(
                width: context.isSmallMobile ? 150 : 192,
                height: context.isSmallMobile ? 150 : 192,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.padding(24),
              MediaQuery.of(context).padding.top + context.padding(24),
              context.padding(24),
              context.padding(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (showBackButton)
                      GestureDetector(
                        onTap: onBackPressed ?? () => Get.back(),
                        child: Container(
                          width: context.iconSize(40),
                          height: context.iconSize(40),
                          margin: EdgeInsets.only(right: context.spacing(16)),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              context.borderRadius(12),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: context.iconSize(20),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headlineSmall
                                .weighted(FontWeight.w700)
                                .colored(Colors.white)
                                .copyWith(fontSize: context.fontSize(20)),
                          ),
                          SizedBox(height: context.spacing(4)),
                          if (subtitleWidget != null)
                            subtitleWidget!
                          else if (subtitle != null)
                            Text(
                              subtitle!,
                              style: AppTextStyles.subtitle14
                                  .colored(AppColors.primaryLight)
                                  .copyWith(fontSize: context.fontSize(14)),
                            ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                if (progressIndicator != null) ...[
                  SizedBox(height: context.spacing(16)),
                  progressIndicator!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
