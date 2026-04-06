import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/metode_pembayaran_controller.dart';

class MetodePembayaranView extends GetView<MetodePembayaranController> {
  const MetodePembayaranView({super.key});

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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6B8E7A),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Metode Pembayaran',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(
                              () => Text(
                                '${controller.totalAktif} metode aktif dari ${controller.totalMetode}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFA8D5BA),
                                ),
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter by Boarding House
                    const Text(
                      'Filter berdasarkan kost',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: DropdownButton<String>(
                          value: controller.selectedKost.value,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          dropdownColor: Colors.white,
                          items:
                              [
                                'Semua Kost',
                                'Green Valley Kost',
                                'Sunrise Boarding House',
                                'Peaceful Haven Kost',
                                'Urban Residence',
                                'Cozy Corner Kost',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.setKostFilter(value);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Filter Chips
                    Obx(
                      () => Row(
                        children: [
                          Flexible(
                            child: _buildFilterChip(
                              'Semua',
                              controller.selectedFilter.value == 'Semua',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _buildFilterChip(
                              'Bank',
                              controller.selectedFilter.value == 'Bank',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _buildFilterChip(
                              'QRIS',
                              controller.selectedFilter.value == 'QRIS',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _buildFilterChip(
                              'Cash',
                              controller.selectedFilter.value == 'Cash',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Grid Metode Pembayaran
                    Obx(
                      () => GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: controller.filteredList.length,
                        itemBuilder: (context, index) {
                          final metode = controller.filteredList[index];
                          return _buildMetodeCard(metode);
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
      floatingActionButton: FloatingActionButton(
        onPressed: controller.tambahMetode,
        backgroundColor: const Color(0xFF6B8E7A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Flexible(
      child: GestureDetector(
        onTap: () => controller.setJenisFilter(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6B8E7A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6B8E7A)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetodeCard(metode) {
    final isActive = metode.isActive;
    final opacity = isActive ? 1.0 : 0.4;

    return Container(
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
      child: Opacity(
        opacity: opacity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: metode.jenis == 'bank'
                        ? const Color(0xFFDCEEFF)
                        : metode.jenis == 'cash'
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEF3C7), // QRIS color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    metode.jenis == 'bank'
                        ? Icons.credit_card
                        : metode.jenis == 'cash'
                        ? Icons.money
                        : Icons.qr_code, // QRIS icon
                    color: metode.jenis == 'bank'
                        ? const Color(0xFF3B82F6)
                        : metode.jenis == 'cash'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B), // QRIS color
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: metode.isActive
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    metode.isActive ? 'Aktif' : 'Off',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: metode.isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Nama Bank
            Text(
              metode.nama,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),

            const SizedBox(height: 4),

            // Nama Kost
            Text(
              metode.namaKost,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Nomor Rekening / QRIS Info
            if (metode.jenis == 'qris')
              const Text(
                'QR Code Payment',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              )
            else
              Row(
                children: [
                  const Text(
                    '•••• ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    metode.nomorRekening,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),

            const Spacer(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  icon: metode.isActive ? Icons.toggle_on : Icons.toggle_off,
                  backgroundColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFF59E0B),
                  onTap: () => controller.toggleStatus(metode.id),
                ),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  backgroundColor: const Color(0xFFDCEEFF),
                  iconColor: const Color(0xFF3B82F6),
                  onTap: () => controller.editMetode(metode.id),
                ),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  backgroundColor: const Color(0xFFFFE5E5),
                  iconColor: const Color(0xFFEF4444),
                  onTap: () => controller.deleteMetode(metode.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}
