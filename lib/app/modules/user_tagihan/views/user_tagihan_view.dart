import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/widgets/user_bottom_navbar.dart';
import '../controllers/user_tagihan_controller.dart';
import '../../../data/models/tagihan_user_model.dart';


class UserTagihanView extends GetView<UserTagihanController> {
  const UserTagihanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header melengkung persis gambar
          SafeArea(
            bottom: false,
            child: CustomHeader(
              title: 'Tagihan',
              subtitle: 'Lihat Semua Tagihan',
              showBackButton: false,
            ),
          ),

          // List Tagihan List
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total yang dibayar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => Text(
                              NumberFormat.currency(
                                locale: 'id',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(controller.totalBayarTerpilih),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B8E7A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: Obx(() {
                    if (controller.tagihanBelumDibayar.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(child: Text('Tidak ada tagihan.')),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tagihan = controller.tagihanBelumDibayar[index];
                        return _buildTagihanCard(tagihan);
                      }, childCount: controller.tagihanBelumDibayar.length),
                    );
                  }),
                ),

                // Section Pembayaran
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Metode Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Pilihan Pembayaran
                        Obx(
                          () => _buildMetodePembayaranOption(
                            title: 'Transfer Bank',
                            isSelected:
                                controller.metodePembayaran.value ==
                                'Transfer Bank',
                            onTap: () => controller.metodePembayaran.value =
                                'Transfer Bank',
                            isExpanded:
                                controller.metodePembayaran.value ==
                                'Transfer Bank',
                            expandedContent: _buildTransferBankInfo(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => _buildMetodePembayaranOption(
                            title: 'QRIS',
                            isSelected:
                                controller.metodePembayaran.value == 'QRIS',
                            onTap: () =>
                                controller.metodePembayaran.value = 'QRIS',
                            isExpanded:
                                controller.metodePembayaran.value == 'QRIS',
                            expandedContent: _buildQRISInfo(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => _buildMetodePembayaranOption(
                            title: 'Tunai',
                            isSelected:
                                controller.metodePembayaran.value == 'Tunai',
                            onTap: () =>
                                controller.metodePembayaran.value = 'Tunai',
                            isExpanded:
                                controller.metodePembayaran.value == 'Tunai',
                            expandedContent: _buildTunaiInfo(),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Tombol Kirim
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Obx(() {
                            bool isEnabled =
                                controller.tagihanTerpilih.isNotEmpty;
                            return ElevatedButton(
                              onPressed: isEnabled
                                  ? () {
                                      // Logika kirim pembayaran disini
                                      Get.snackbar(
                                        'Informasi',
                                        'Fitur mengirim bukti pembayaran sedang dibuat.',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFBBF24),
                                disabledBackgroundColor: const Color(
                                  0xFFFBBF24,
                                ).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Kirim',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ], // end slivers array
            ), // end CustomScrollView
          ), // end Expanded
        ], // end Column children
      ), // end Column
      bottomNavigationBar: const UserBottomNavbar(currentIndex: 1),
    );
  }

  // Komponen Card Tagihan dengan Checkbox
  Widget _buildTagihanCard(TagihanUserModel tagihan) {
    return Obx(() {
      bool isSelected = controller.tagihanTerpilih.contains(tagihan);

      return GestureDetector(
        onTap: () => controller.toggleTagihan(tagihan),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF6B8E7A) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF6B8E7A),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tagihan Bulanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          tagihan.nomorKamar,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tagihan.status,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Periode Penagihan',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  Text(
                    tagihan.periodePenagihan,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tanggal Jatuh Tempo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat(
                      'dd MMMM yyyy',
                      'id_ID',
                    ).format(tagihan.jatuhTempo),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444), // Merah
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Checkbox visual untuk simulasi selection
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6B8E7A)
                                : const Color(0xFFD1D5DB),
                            width: 2,
                          ),
                          color: isSelected
                              ? const Color(0xFF6B8E7A)
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Jumlah Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(tagihan.totalBayar),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B8E7A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMetodePembayaranOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isExpanded,
    Widget? expandedContent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B8E7A)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  title == 'Transfer Bank'
                      ? Icons.account_balance
                      : title == 'QRIS'
                      ? Icons.qr_code_2
                      : Icons.money,
                  color: const Color(0xFFFBBF24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            if (isExpanded && expandedContent != null) ...[
              const SizedBox(height: 16),
              expandedContent,
            ],
          ],
        ),
      ),
    );
  }

  // Container Rekening untuk Transfer Bank
  Widget _buildTransferBankInfo() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Bank BCA',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              SizedBox(height: 4),
              Text(
                '1234567890',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'a.n. Green Valley Kost',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _showUploadBottomSheet,
            icon: const Icon(Icons.upload_file, color: Colors.white, size: 18),
            label: const Text(
              'Unggah Bukti Transfer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF6B8E7A),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Container Rekening untuk QRIS
  Widget _buildQRISInfo() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                width: 200,
                height: 200,
                color: Colors.transparent,
                child: const Icon(
                  Icons.qr_code_2,
                  size: 150,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showUploadBottomSheet,
                icon: const Icon(
                  Icons.upload_file,
                  color: Colors.white,
                  size: 16,
                ),
                label: const Text(
                  'Unggah Bukti',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8E7A),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Logika download QR
                },
                icon: const Icon(Icons.download, color: Colors.white, size: 16),
                label: const Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8E7A),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Container Info untuk Tunai
  Widget _buildTunaiInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // blue-50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)), // blue-200
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info,
            color: Color(0xFF3B82F6), // blue-500
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Instruksi Pembayaran Tunai',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A), // blue-900
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Silakan lakukan pembayaran langsung kepada pemilik atau pengelola kost. Pastikan Anda menerima konfirmasi setelah pembayaran.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1D4ED8), // blue-700
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

  void _showUploadBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Foto Profil',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Get.back();
                // Logika pilih dari galeri di sini
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Pilih dari Galeri',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Pilih foto yang sudah ada',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
