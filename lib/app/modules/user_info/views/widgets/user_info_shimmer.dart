import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../../core/utils/responsive_utils.dart';

class UserInfoShimmer extends StatelessWidget {
  const UserInfoShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: context.allPadding(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Selector Shimmer
            _buildTabSelectorShimmer(context),
            SizedBox(height: context.spacing(24)),
            
            // Content List Shimmer
            ...List.generate(
              4,
              (index) => _buildInfoCardShimmer(context, index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelectorShimmer(BuildContext context) {
    return Container(
      padding: context.allPadding(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(context.borderRadius(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ShimmerBox(
              height: 40,
              borderRadius: BorderRadius.circular(context.borderRadius(10)),
            ),
          ),
          SizedBox(width: context.spacing(8)),
          Expanded(
            child: ShimmerBox(
              height: 40,
              borderRadius: BorderRadius.circular(context.borderRadius(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardShimmer(BuildContext context, int index) {
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(
                width: context.iconSize(48),
                height: context.iconSize(48),
                borderRadius: BorderRadius.circular(context.borderRadius(12)),
              ),
              SizedBox(width: context.spacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: double.infinity,
                      height: context.fontSize(16),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    SizedBox(height: context.spacing(8)),
                    ShimmerBox(
                      width: context.screenWidth * 0.4,
                      height: context.fontSize(12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(12)),
          ShimmerBox(
            width: double.infinity,
            height: context.fontSize(14),
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: context.spacing(6)),
          ShimmerBox(
            width: context.screenWidth * 0.6,
            height: context.fontSize(14),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
