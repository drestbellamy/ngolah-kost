import 'package:flutter/material.dart';
import '../../../../core/values/values.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../models/pengaduan_admin_model.dart';
import 'photo_viewer.dart';

class DetailPhotoCard extends StatelessWidget {
  final PengaduanAdminModel pengaduan;

  const DetailPhotoCard({super.key, required this.pengaduan});

  @override
  Widget build(BuildContext context) {
    if (pengaduan.buktiFoto.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: context.allPadding(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.image,
                size: context.iconSize(20),
                color: const Color(0xFF6B8E7A),
              ),
              SizedBox(width: context.spacing(8)),
              Text(
                'Lampiran Foto',
                style: AppTextStyles.subtitle16
                    .colored(AppColors.textPrimary)
                    .copyWith(
                      fontSize: context.fontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(width: context.spacing(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing(8),
                  vertical: context.spacing(4),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.borderRadius(8)),
                ),
                child: Text(
                  '${pengaduan.buktiFoto.length} Foto',
                  style: AppTextStyles.body12
                      .colored(const Color(0xFF6B8E7A))
                      .copyWith(
                        fontSize: context.fontSize(12),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          // Grid of images
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: pengaduan.buktiFoto.length == 1 ? 1 : 2,
              crossAxisSpacing: context.spacing(8),
              mainAxisSpacing: context.spacing(8),
              childAspectRatio:
                  1.0, // Ubah dari 1.2 ke 1.0 untuk mengurangi gap
            ),
            itemCount: pengaduan.buktiFoto.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoViewer(
                        imageUrls: pengaduan.buktiFoto,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.borderRadius(12)),
                  child: Image.network(
                    pengaduan.buktiFoto[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: context.iconSize(48),
                            color: Colors.grey[400],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
