import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../controllers/kelola_tagihan_controller.dart';
import '../models/tagihan_model.dart';
import 'widgets/verifikasi_pembayaran_bottom_sheet.dart';

class KelolaTagihanView extends GetView<KelolaTagihanController> {
  const KelolaTagihanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            CustomHeader(
              title: 'Kelola Tagihan',
              showBackButton: true,
              subtitleWidget: Obx(
                () => Text(
                  '${controller.getTotalTagihan()} tagihan',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA8D5BA),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.searchTagihan,
                        decoration: InputDecoration(
                          hintText: 'Cari penghuni, kamar, atau kost...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFA0AEC0),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9CA3AF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Filter Chips
                    Obx(
                      () => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'Semua (${controller.tagihanList.length})',
                              'semua',
                              const Color(0xFF6B8E7F),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Menunggu (${controller.tagihanList.where((t) => t.status == 'menunggu_verifikasi').length})',
                              'menunggu_verifikasi',
                              const Color(0xFFF2A65A),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Belum Dibayar (${controller.tagihanList.where((t) => t.status == 'belum_dibayar').length})',
                              'belum_dibayar',
                              const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Lunas (${controller.tagihanList.where((t) => t.status == 'lunas').length})',
                              'lunas',
                              const Color(0xFF10B981),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tagihan List
                    Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.filteredTagihanList.length,
                        itemBuilder: (context, index) {
                          final tagihan = controller.filteredTagihanList[index];
                          return _buildTagihanCard(tagihan);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = controller.selectedFilter.value == value;
    return GestureDetector(
      onTap: () => controller.changeFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildTagihanCard(TagihanModel tagihan) {
    Color statusColor;
    String statusText;

    switch (tagihan.status) {
      case 'lunas':
        statusColor = const Color(0xFF10B981);
        statusText = 'Lunas';
        break;
      case 'menunggu_verifikasi':
        statusColor = const Color(0xFFF2A65A);
        statusText = 'Menunggu Verifikasi';
        break;
      case 'belum_dibayar':
        statusColor = const Color(0xFFEF4444);
        statusText = 'Belum Dibayar';
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Text(
                  tagihan.namaPenghuni,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.home_work, size: 14, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tagihan.namaKost,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.meeting_room,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tagihan.nomorKamar,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tagihan.tanggalJatuhTempo,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jumlah Tagihan',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              Text(
                'Rp ${tagihan.jumlahTagihan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF2A65A),
                ),
              ),
            ],
          ),
          if (tagihan.status == 'menunggu_verifikasi') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.bottomSheet(
                    VerifikasiPembayaranBottomSheet(tagihan: tagihan),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Verifikasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2A65A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
