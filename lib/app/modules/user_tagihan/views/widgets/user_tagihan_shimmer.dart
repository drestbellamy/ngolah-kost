import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../../../core/utils/responsive_utils.dart';

class UserTagihanShimmer extends StatelessWidget {
  const UserTagihanShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Column(
        children: [
          // Total Card Shimmer
          _buildTotalCardShimmer(context),
          
          // Tagihan List Shimmer
          Expanded(
            child: ListView.builder(
              padding: context.allPadding(24),
              itemCount: 5,
              itemBuilder: (context, index) => _buildTagihanItemShimmer(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCardShimmer(BuildContext context) {
    return Container(
      margin: context.symmetricPadding(horizontal: 24, vertical: 16),
      padding: context.allPadding(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ShimmerBox(
            width: context.screenWidth * 0.4,
            height: context.fontSize(14),
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: context.spacing(12)),
          ShimmerBox(
            width: context.screenWidth * 0.6,
            height: context.fontSize(32),
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: context.spacing(20)),
          Row(
            children: [
              Expanded(
                child: _buildStatusItemShimmer(context),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[200],
              ),
              Expanded(
                child: _buildStatusItemShimmer(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItemShimmer(BuildContext context) {
    return Column(
      children: [
        ShimmerBox(
          width: context.screenWidth * 0.25,
          height: context.fontSize(12),
          borderRadius: BorderRadius.circular(4),
        ),
        SizedBox(height: context.spacing(8)),
        ShimmerBox(
          width: context.screenWidth * 0.2,
          height: context.fontSize(20),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildTagihanItemShimmer(BuildContext context, int index) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: context.screenWidth * 0.3,
                    height: context.fontSize(16),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  SizedBox(height: context.spacing(6)),
                  ShimmerBox(
                    width: context.screenWidth * 0.25,
                    height: context.fontSize(12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              ShimmerBox(
                width: 80,
                height: 28,
                borderRadius: BorderRadius.circular(context.borderRadius(20)),
              ),
            ],
          ),
          SizedBox(height: context.spacing(12)),
          const Divider(),
          SizedBox(height: context.spacing(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(
                width: context.screenWidth * 0.2,
                height: context.fontSize(14),
                borderRadius: BorderRadius.circular(4),
              ),
              ShimmerBox(
                width: context.screenWidth * 0.3,
                height: context.fontSize(18),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          SizedBox(height: context.spacing(12)),
          ShimmerBox(
            width: double.infinity,
            height: 40,
            borderRadius: BorderRadius.circular(context.borderRadius(8)),
          ),
        ],
      ),
    );
  }
}
