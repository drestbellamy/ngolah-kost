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
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B8E7A).withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B8E7A).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        size: 40,
                        color: Color(0xFF6B8E7A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Belum Ada Pengaduan',
                      style: TextStyle(
                        fontSize: context.fontSize(16),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.selectedFilter.value == 'semua' &&
                              controller.selectedKostId.value == 'semua' &&
                              controller.searchQuery.value.isEmpty
                          ? 'Saat ini tidak ada laporan pengaduan dari penghuni. Laporan baru akan muncul di sini saat ada keluhan.'
                          : 'Tidak ada pengaduan dengan filter yang dipilih.\nCoba hapus filter atau ubah pencarian.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.fontSize(14),
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
}

