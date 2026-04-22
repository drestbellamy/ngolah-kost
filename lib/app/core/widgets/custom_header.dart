import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../values/values.dart';

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
                  Colors.black.withOpacity(0.10),
                  BlendMode.darken,
                ),
              )
            : null,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              right: -120,
              top: -180,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -80,
              bottom: -100,
              child: Container(
                width: 192,
                height: 192,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(
              24, 
              MediaQuery.of(context).padding.top + 24, 
              24, 
              30
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
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
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
                                .colored(Colors.white),
                          ),
                          const SizedBox(height: 4),
                          if (subtitleWidget != null)
                            subtitleWidget!
                          else if (subtitle != null)
                            Text(
                              subtitle!,
                              style: AppTextStyles.subtitle14.colored(AppColors.primaryLight),
                            ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                if (progressIndicator != null) ...[
                  const SizedBox(height: 16),
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
