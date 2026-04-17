import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
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
        top: false,
        child: Column(
          children: [
            // Header
            Obx(
              () => CustomHeader(
                title: controller.kostName.value,
                subtitle: controller.kostAddress.value.isNotEmpty
                    ? controller.kostAddress.value
                    : 'Detail keuangan kost',
                showBackButton: true,
              ),
            ),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadKeuanganData,
                color: const Color(0xFF6B8E7A),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF10B981,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                  // Sync button untuk debug
                                  GestureDetector(
                                    onTap: controller.sinkronisasiPemasukan,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF6B8E7A,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.sync,
                                        color: Color(0xFF6B8E7A),
                                        size: 18,
                                      ),
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
                                    final item =
                                        controller.pemasukanList[index];
                                    final jumlah = item['jumlah'];
                                    final amount = jumlah is int
                                        ? jumlah.toDouble()
                                        : (jumlah is double
                                              ? jumlah
                                              : double.tryParse(
                                                      jumlah?.toString() ?? '0',
                                                    ) ??
                                                    0.0);

                                    final namaPenghuni =
                                        item['nama_penghuni']?.toString() ??
                                        '-';
                                    final keterangan =
                                        item['keterangan']?.toString() ?? '';

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                namaPenghuni,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2F2F2F),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              if (keterangan.isNotEmpty)
                                                Text(
                                                  keterangan,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              const SizedBox(height: 2),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFEF4444,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['nama']?.toString() ??
                                                    'Pengeluaran',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2F2F2F),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
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
                                          item['deskripsi']?.toString() ?? '-',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
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
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () async {
                                                    final result =
                                                        await Get.bottomSheet(
                                                          TambahPengeluaranBottomSheet(
                                                            initialData: item,
                                                          ),
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                        );

                                                    if (result != null) {
                                                      controller
                                                          .editPengeluaran(
                                                            index,
                                                            result,
                                                          );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    size: 18,
                                                    color: Color(0xFF6B8E7A),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                                const SizedBox(width: 2),
                                                IconButton(
                                                  onPressed: () {
                                                    Get.dialog(
                                                      AlertDialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                        title: const Text(
                                                          'Hapus Pengeluaran',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                              0xFF2F2F2F,
                                                            ),
                                                          ),
                                                        ),
                                                        content: Text(
                                                          'Apakah Anda yakin ingin menghapus "${item['nama']?.toString() ?? 'pengeluaran ini'}"?',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                color: Color(
                                                                  0xFF6B7280,
                                                                ),
                                                              ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Get.back(),
                                                            style: TextButton.styleFrom(
                                                              foregroundColor:
                                                                  const Color(
                                                                    0xFF6B7280,
                                                                  ),
                                                            ),
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
                                                            style: TextButton.styleFrom(
                                                              foregroundColor:
                                                                  const Color(
                                                                    0xFFEF4444,
                                                                  ),
                                                            ),
                                                            child: const Text(
                                                              'Hapus',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                    color: Color(0xFFEF4444),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ],
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
