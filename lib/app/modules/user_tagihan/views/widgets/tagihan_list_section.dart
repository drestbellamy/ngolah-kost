import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_tagihan_controller.dart';
import 'tagihan_card.dart';

class TagihanListSection extends GetView<UserTagihanController> {
  const TagihanListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(24.0),
      sliver: Obx(() {
        if (controller.isLoading.value) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: Color(0xFF6B8E7A)),
              ),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.loadTagihanData(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E7A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (controller.tagihanBelumDibayar.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Semua Tagihan Lunas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tidak ada tagihan yang perlu dibayar saat ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final tagihan = controller.tagihanBelumDibayar[index];
            return TagihanCard(tagihan: tagihan);
          }, childCount: controller.tagihanBelumDibayar.length),
        );
      }),
    );
  }
}
