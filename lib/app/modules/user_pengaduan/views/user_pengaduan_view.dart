import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_pengaduan_controller.dart';
import 'user_pengaduan_form_view.dart';
import 'user_pengaduan_detail_view.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/custom_header.dart';
import 'widgets/pengaduan_shimmer_widget.dart';

class UserPengaduanView extends GetView<UserPengaduanController> {
  const UserPengaduanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header dengan CustomHeader
          const CustomHeader(
            title: 'Laporan Pengaduan',
            subtitle: 'Lihat Semua Laporan Pengaduan',
            showBackButton: true,
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Cari riwayat laporan...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // List Pengaduan
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const PengaduanShimmerWidget();
              }

              final filteredList = controller.filteredPengaduanList;

              if (filteredList.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.fetchPengaduan,
                  color: const Color(0xFF6B9080),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada laporan pengaduan',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tarik ke bawah untuk refresh',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchPengaduan,
                color: const Color(0xFF6B9080),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    final isSelesai = item.status.toUpperCase() == 'SELESAI';
                    final statusColor = isSelesai
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800);
                    final statusBgColor = isSelesai
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0);

                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => UserPengaduanDetailView(pengaduan: item),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.kodeLaporan,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat(
                                          'dd MMM yyyy',
                                        ).format(item.tanggal),
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusBgColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.status.toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.deskripsi,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.buktiLaporan != null &&
                                  item.buktiLaporan!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: Color(0xFF6B9080),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Kendala Fasilitas',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '1 Foto dilampirkan',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 11,
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
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const UserPengaduanFormView()),
          backgroundColor: const Color(0xFF6B9080),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Buat Pengaduan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
