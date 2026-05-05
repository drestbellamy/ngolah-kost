import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../controllers/kelola_pengaduan_controller.dart';
import 'pengaduan_card_widget.dart';
import '../kelola_pengaduan_detail_view.dart';

class PengaduanListWidget extends GetView<KelolaPengaduanController> {
  const PengaduanListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.filteredPengaduanList.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: context.allPadding(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ilustrasi dengan background circle
                  Container(
                    width: context.screenWidth * 0.4,
                    height: context.screenWidth * 0.4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.inbox_outlined,
                        size: context.iconSize(80),
                        color: const Color(0xFF6B8E7A).withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  SizedBox(height: context.spacing(24)),

                  // Title
                  Text(
                    'Belum Ada Pengaduan',
                    style: TextStyle(
                      fontSize: context.fontSize(18),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: context.spacing(8)),

                  // Description
                  Text(
                    controller.selectedFilter.value == 'semua'
                        ? 'Belum ada laporan pengaduan dari penghuni'
                        : 'Tidak ada pengaduan dengan status "${_getFilterLabel()}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.fontSize(14),
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  // Hint jika ada filter aktif
                  if (controller.selectedFilter.value != 'semua' ||
                      controller.selectedKostId.value != 'semua' ||
                      controller.searchQuery.value.isNotEmpty) ...[
                    SizedBox(height: context.spacing(24)),
                    Container(
                      padding: context.allPadding(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(
                          context.borderRadius(12),
                        ),
                        border: Border.all(
                          color: const Color(0xFFFFE082),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: context.iconSize(20),
                            color: const Color(0xFFF57C00),
                          ),
                          SizedBox(width: context.spacing(12)),
                          Expanded(
                            child: Text(
                              'Coba hapus filter atau ubah pencarian',
                              style: TextStyle(
                                fontSize: context.fontSize(13),
                                color: const Color(0xFFF57C00),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        padding: context.allPadding(16),
        itemCount: controller.filteredPengaduanList.length,
        itemBuilder: (context, index) {
          final pengaduan = controller.filteredPengaduanList[index];
          return PengaduanCardWidget(
            pengaduan: pengaduan,
            onTap: () {
              Get.to(
                () => KelolaPengaduanDetailView(pengaduan: pengaduan),
                transition: Transition.rightToLeft,
              );
            },
          );
        },
      );
    });
  }

  String _getFilterLabel() {
    switch (controller.selectedFilter.value.toLowerCase()) {
      case 'menunggu':
        return 'Menunggu';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Semua';
    }
  }
}
