import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_keuangan_kost_controller.dart';
import '../widgets/financial_chart.dart';
import 'widgets/tambah_pengeluaran_bottom_sheet.dart';

class DetailKeuanganKostView extends GetView<DetailKeuanganKostController> {
  const DetailKeuanganKostView({super.key});

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
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.kostName.value,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.kostAddress.value,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFA8D5BA),
                              ),
                            ),
                          ],
                        ),
                      ),
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

                    // Grafik Keuangan Bulanan
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
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
                              'Grafik Keuangan Bulanan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F2F2F),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Chart
                            Obx(
                              () => controller.pemasukanChartData.isNotEmpty
                                  ? FinancialChart(
                                      pemasukanData: controller
                                          .pemasukanChartData
                                          .toList(),
                                      pengeluaranData: controller
                                          .pengeluaranChartData
                                          .toList(),
                                      labels: controller.chartLabels.toList(),
                                    )
                                  : const SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            // Legend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegend(
                                  'Pemasukan',
                                  const Color(0xFF10B981),
                                ),
                                const SizedBox(width: 24),
                                _buildLegend(
                                  'Pengeluaran',
                                  const Color(0xFFEF4444),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Pemasukan dari Penghuni
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF10B981),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Pemasukan dari Penghuni',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2F2F2F),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              if (controller.pemasukanList.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'Belum ada data pemasukan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.pemasukanList.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 24),
                                itemBuilder: (context, index) {
                                  final item = controller.pemasukanList[index];
                                  final jumlah = item['jumlah'];
                                  final amount = jumlah is int
                                      ? jumlah.toDouble()
                                      : (jumlah is double
                                            ? jumlah
                                            : double.tryParse(
                                                    jumlah?.toString() ?? '0',
                                                  ) ??
                                                  0.0);

                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['deskripsi']?.toString() ??
                                                  'Pembayaran',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2F2F2F),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              controller.formatDate(
                                                item['tanggal'],
                                              ),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '+${controller.formatCurrency(amount)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Daftar Pengeluaran
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFEF4444,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.receipt_long,
                                        color: Color(0xFFEF4444),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Daftar Pengeluaran',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2F2F2F),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Get.bottomSheet(
                                      TambahPengeluaranBottomSheet(),
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                    );

                                    if (result != null) {
                                      controller.addPengeluaran(result);
                                    }
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6B8E7A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              if (controller.pengeluaranList.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      'Belum ada data pengeluaran',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.pengeluaranList.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 24),
                                itemBuilder: (context, index) {
                                  final item =
                                      controller.pengeluaranList[index];
                                  final jumlah = item['jumlah'];
                                  final amount = jumlah is int
                                      ? jumlah.toDouble()
                                      : (jumlah is double
                                            ? jumlah
                                            : double.tryParse(
                                                    jumlah?.toString() ?? '0',
                                                  ) ??
                                                  0.0);

                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  item['nama']?.toString() ??
                                                      'Pengeluaran',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF2F2F2F),
                                                  ),
                                                ),
                                                Text(
                                                  '-${controller.formatCurrency(amount)}',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFEF4444),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item['deskripsi']?.toString() ??
                                                  '-',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 12,
                                                  color: Colors.grey[500],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  controller.formatDate(
                                                    item['tanggal'],
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Action buttons
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              final result =
                                                  await Get.bottomSheet(
                                                    TambahPengeluaranBottomSheet(
                                                      initialData: item,
                                                    ),
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  );

                                              if (result != null) {
                                                controller.editPengeluaran(
                                                  index,
                                                  result,
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: Color(0xFF6B8E7A),
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            onPressed: () {
                                              Get.dialog(
                                                AlertDialog(
                                                  title: const Text(
                                                    'Hapus Pengeluaran',
                                                  ),
                                                  content: Text(
                                                    'Apakah Anda yakin ingin menghapus "${item['nama']?.toString() ?? 'pengeluaran ini'}"?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Get.back(),
                                                      child: const Text(
                                                        'Batal',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Get.back();
                                                        controller
                                                            .deletePengeluaran(
                                                              index,
                                                            );
                                                      },
                                                      child: const Text(
                                                        'Hapus',
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFFEF4444,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Color(0xFFEF4444),
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            }),
                          ],
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

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }
}
