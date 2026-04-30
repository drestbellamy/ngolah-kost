import 'package:flutter/material.dart';
import '../../../../data/models/metode_pembayaran_model.dart';
import '../../../../core/utils/image_downloader.dart';
import '../../../../core/utils/responsive_utils.dart';

class QrisInfo extends StatelessWidget {
  final List<MetodePembayaranModel> methods;

  const QrisInfo({super.key, required this.methods});

  Future<void> _downloadQRCode(MetodePembayaranModel metode) async {
    if (metode.qrImage == null || metode.qrImage!.isEmpty) {
      return;
    }

    // Generate filename from method name
    final fileName =
        'QRIS_${metode.nama.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';

    await ImageDownloader.downloadImage(metode.qrImage!, fileName);
  }

  @override
  Widget build(BuildContext context) {
    if (methods.isEmpty) {
      return Container(
        padding: context.allPadding(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(context.borderRadius(12)),
        ),
        child: Text(
          'Belum ada QRIS yang tersedia.',
          style: TextStyle(fontSize: context.fontSize(12), color: const Color(0xFFD97706)),
        ),
      );
    }

    return Column(
      children: [
        // Display all available QRIS
        ...methods.map(
          (metode) => Container(
            margin: EdgeInsets.only(bottom: context.spacing(16)),
            padding: context.allPadding(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(context.borderRadius(12)),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                // QRIS Name
                Text(
                  metode.nama,
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: context.spacing(12)),

                // QR Code Image
                if (metode.qrImage != null && metode.qrImage!.isNotEmpty)
                  Container(
                    width: context.spacing(180),
                    height: context.spacing(180),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.borderRadius(8)),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(context.borderRadius(8)),
                      child: Image.network(
                        metode.qrImage!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[100],
                            child: Icon(
                              Icons.qr_code_2,
                              size: context.iconSize(100),
                              color: const Color(0xFF9CA3AF),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    width: context.spacing(180),
                    height: context.spacing(180),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(context.borderRadius(8)),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Icon(
                      Icons.qr_code_2,
                      size: context.iconSize(100),
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),

                // Download button for individual QR (if image exists)
                if (metode.qrImage != null && metode.qrImage!.isNotEmpty) ...[
                  SizedBox(height: context.spacing(12)),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadQRCode(metode),
                      icon: Icon(
                        Icons.download,
                        color: const Color(0xFF6B8E7A),
                        size: context.iconSize(16),
                      ),
                      label: Text(
                        'Download ${metode.nama}',
                        style: TextStyle(
                          color: const Color(0xFF6B8E7A),
                          fontWeight: FontWeight.w600,
                          fontSize: context.fontSize(12),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6B8E7A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.borderRadius(8)),
                        ),
                        padding: context.symmetricPadding(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
