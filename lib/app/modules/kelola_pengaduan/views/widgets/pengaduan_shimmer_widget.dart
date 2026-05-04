import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class PengaduanShimmerWidget extends StatelessWidget {
  const PengaduanShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.allPadding(24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: context.verticalPadding(8),
          padding: context.allPadding(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.borderRadius(12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: context.screenWidth * 0.4,
                    height: context.fontSize(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(
                        context.borderRadius(4),
                      ),
                    ),
                  ),
                  Container(
                    width: context.screenWidth * 0.2,
                    height: context.fontSize(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(
                        context.borderRadius(8),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing(12)),
              Container(
                width: context.screenWidth * 0.6,
                height: context.fontSize(14),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(context.borderRadius(4)),
                ),
              ),
              SizedBox(height: context.spacing(8)),
              Container(
                width: context.screenWidth * 0.5,
                height: context.fontSize(14),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(context.borderRadius(4)),
                ),
              ),
              SizedBox(height: context.spacing(12)),
              Container(
                width: double.infinity,
                height: context.fontSize(14) * 2,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(context.borderRadius(4)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
