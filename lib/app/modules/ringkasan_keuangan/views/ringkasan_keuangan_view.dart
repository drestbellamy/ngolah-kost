import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ringkasan_keuangan_controller.dart';

class RingkasanKeuanganView extends GetView<RingkasanKeuanganController> {
  const RingkasanKeuanganView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B8E7A), Color(0xFF4F6F5D)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kelola Keuangan',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Pilih rumah kost untuk melihat detail',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFA8D5BA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Total Summary Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Obx(
                        () => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                              const Text(
                                'Total Semua Kost',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F2F2F),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFinancialItem(
                                'Pemasukan',
                                controller.formatCurrency(
                                  controller.totalPemasukan.value,
                                ),
                                const Color(0xFF10B981),
                                Icons.trending_up,
                              ),
                              const SizedBox(height: 12),
                              _buildFinancialItem(
                                'Pengeluaran',
                                controller.formatCurrency(
                                  controller.totalPengeluaran.value,
                                ),
                                const Color(0xFFEF4444),
                                Icons.trending_down,
                              ),
                              const SizedBox(height: 12),
                              _buildFinancialItem(
                                'Laba Bersih',
                                controller.formatCurrency(
                                  controller.totalLabaBersih.value,
                                ),
                                const Color(0xFF6B8E7A),
                                Icons.attach_money,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Pilih Rumah Kost',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F2F2F),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Kost List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Obx(
                        () => ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.kostList.length,
                          itemBuilder: (context, index) {
                            final kost = controller.kostList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    '/detail-keuangan-kost',
                                    arguments: {
                                      'kostName': kost.kostName,
                                      'kostAddress': kost.kostAddress,
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Icon
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6B8E7A),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.home_work,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              kost.kostName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2F2F2F),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              kost.kostAddress,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[500],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            // Financial indicators in one row
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                _buildSmallIndicator(
                                                  Icons.trending_up,
                                                  controller.formatCurrency(
                                                    kost.pemasukan,
                                                  ),
                                                  const Color(0xFF10B981),
                                                ),
                                                _buildSmallIndicator(
                                                  Icons.trending_down,
                                                  controller.formatCurrency(
                                                    kost.pengeluaran,
                                                  ),
                                                  const Color(0xFFEF4444),
                                                ),
                                                _buildSmallIndicator(
                                                  Icons.attach_money,
                                                  controller.formatCurrency(
                                                    kost.labaBersih.abs(),
                                                  ),
                                                  Colors.grey[600]!,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Arrow
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey[400],
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIndicator(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
