import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/supabase_service.dart';
import '../models/penghuni_model.dart';
import '../controllers/kelola_kontrak_controller.dart';
import '../controllers/penghuni_controller.dart';
import 'widgets/kelola_kontrak_bottom_sheet.dart';

class PenghuniDetailView extends StatelessWidget {
  const PenghuniDetailView({super.key});

  static final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    final PenghuniModel? penghuniArg = Get.arguments as PenghuniModel?;

    // Handle null case
    if (penghuniArg == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Data penghuni tidak ditemukan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan kembali dan coba lagi',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E7F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final PenghuniModel penghuni = penghuniArg;
    final billingFuture = _loadBillingHistory(penghuni);
    final contractBadge = _getContractBadge(penghuni);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                    blurRadius: 25,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -64,
                    top: -64,
                    child: Container(
                      width: 256,
                      height: 256,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -48,
                    bottom: -48,
                    child: Container(
                      width: 192,
                      height: 192,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detail Penghuni',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Informasi lengkap penghuni kost',
                                    style: TextStyle(
                                      fontSize: 14,
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
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Card Info Penghuni
                    Container(
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      penghuni.nama,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 16,
                                          color: Color(0xFF718096),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          penghuni.noTelepon,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF718096),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.home,
                                          size: 16,
                                          color: Color(0xFF718096),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Kamar ${penghuni.nomorKamar} • ${penghuni.namaKost}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF718096),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: contractBadge.backgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: contractBadge.textColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      contractBadge.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: contractBadge.textColor,
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

                    const SizedBox(height: 16),

                    // Card Informasi Kamar
                    Container(
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
                          const Row(
                            children: [
                              Icon(
                                Icons.home_outlined,
                                size: 20,
                                color: Color(0xFF6B8E7F),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Informasi Kamar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.meeting_room,
                            'Nomor Kamar',
                            penghuni.nomorKamar,
                            const Color(0xFFF2A65A).withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.location_on,
                            'Nama Kost',
                            penghuni.namaKost,
                            const Color(0xFFF2A65A).withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.attach_money,
                            'Harga Sewa (per bulan)',
                            'Rp ${penghuni.sewaBulanan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                            const Color(0xFFF2A65A).withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Card Informasi Kontrak
                    Container(
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
                          const Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 20,
                                color: Color(0xFF6B8E7F),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Informasi Kontrak',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Durasi Kontrak',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${penghuni.durasiKontrak} Bulan',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: const Color(0xFFE5E7EB),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Sistem Pembayaran',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        penghuni.sistemPembayaran,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tanggal Mulai',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        penghuni.tanggalMasuk,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: const Color(0xFFE5E7EB),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tanggal Berakhir',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        penghuni.tanggalBerakhir,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(
                            'Total Pembayaran:',
                            '${penghuni.durasiKontrak} x Rp ${penghuni.sewaBulanan.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Total Nilai Kontrak:',
                            'Rp ${penghuni.totalNilaiKontrak.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                            isBold: true,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  // Hapus controller lama jika ada
                                  if (Get.isRegistered<
                                    KelolaKontrakController
                                  >()) {
                                    Get.delete<KelolaKontrakController>();
                                  }

                                  final controller = Get.put(
                                    KelolaKontrakController(),
                                  );
                                  controller.penghuni = penghuni;
                                  controller.initializeEditForm();

                                  final result = await Get.bottomSheet<bool>(
                                    const KelolaKontrakBottomSheet(),
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    enableDrag: true,
                                  );

                                  if (result != true) return;

                                  // Show loading indicator while refreshing
                                  Get.dialog(
                                    WillPopScope(
                                      onWillPop: () async => false,
                                      child: const Center(
                                        child: Card(
                                          child: Padding(
                                            padding: EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(),
                                                SizedBox(height: 16),
                                                Text('Memuat data terbaru...'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    barrierDismissible: false,
                                  );

                                  // Wait a bit more to ensure data is synced
                                  await Future.delayed(
                                    const Duration(milliseconds: 800),
                                  );

                                  final refreshed =
                                      await _loadLatestPenghuniModel(
                                        penghuni.id,
                                        fallback: penghuni,
                                      );

                                  if (Get.isDialogOpen ?? false) {
                                    Get.back(); // Close loading dialog
                                  }

                                  // Use callback to update data instead of navigation
                                  Get.offNamed(
                                    '/penghuni/detail',
                                    arguments: refreshed,
                                    preventDuplicates: false,
                                  );
                                } catch (e) {
                                  // Close any open dialogs
                                  if (Get.isDialogOpen ?? false) {
                                    Get.back();
                                  }
                                  
                                  Get.snackbar(
                                    'Error',
                                    'Terjadi kesalahan: ${e.toString()}',
                                    backgroundColor: const Color(0xFFEF4444),
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                  );
                                }
                              },
                              icon: const Icon(Icons.refresh, size: 20),
                              label: const Text('Kelola Kontrak'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B8E7F),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Card History Pembayaran
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 20,
                                color: Color(0xFF6B8E7F),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'History Pembayaran',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<List<PembayaranModel>>(
                            future: billingFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final billingHistory = snapshot.data ?? const [];
                              if (billingHistory.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Belum ada data history pembayaran.',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: billingHistory.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final history = billingHistory[index];
                                  return _buildHistoryItem(history);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconBgColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFF2A65A)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF6B7280),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(PembayaranModel history) {
    final bool isLunas = history.status.toLowerCase() == 'lunas';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLunas
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLunas ? Icons.check_circle_outline : Icons.access_time,
              color: isLunas
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        history.bulan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 132),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLunas
                              ? const Color(0xFFD1FAE5).withOpacity(0.5)
                              : const Color(0xFFFEE2E2).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          history.status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLunas
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp ${history.jumlah.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B8E7F),
                  ),
                ),
                const SizedBox(height: 12),
                if (!isLunas)
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Jatuh tempo: ${history.jatuhTempo}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Jatuh tempo:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  Text(
                                    history.jatuhTempo,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Dibayar:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  Text(
                                    history.tanggalBayar ?? '-',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
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
        ],
      ),
    );
  }

  Future<List<PembayaranModel>> _loadBillingHistory(
    PenghuniModel penghuni,
  ) async {
    try {
      final rows = await _supabaseService.getTagihanByPenghuniId(penghuni.id);
      if (rows.isEmpty) {
        return [];
      }

      final expectedKeys = _buildExpectedBillingKeys(penghuni);

      final byKey = <String, Map<String, dynamic>>{};
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw);
        final bulan = _toInt(row['bulan']);
        final tahun = _toInt(row['tahun']);
        if (bulan < 1 || bulan > 12 || tahun <= 0) {
          continue;
        }

        final key = '$tahun-${bulan.toString().padLeft(2, '0')}';
        final status = (row['status'] ?? '').toString().toLowerCase().trim();

        final inContract = expectedKeys.contains(key);
        final isPaid = status == 'lunas';
        if (!inContract && !isPaid) {
          continue;
        }

        final existing = byKey[key];
        if (existing == null) {
          byKey[key] = row;
          continue;
        }

        final existingStatus = (existing['status'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
        final existingPaid = existingStatus == 'lunas';
        if (!existingPaid && isPaid) {
          byKey[key] = row;
        }
      }

      final filteredRows = byKey.values.toList()
        ..sort((a, b) {
          final tahunA = _toInt(a['tahun']);
          final tahunB = _toInt(b['tahun']);
          if (tahunA != tahunB) return tahunB.compareTo(tahunA);

          final bulanA = _toInt(a['bulan']);
          final bulanB = _toInt(b['bulan']);
          return bulanB.compareTo(bulanA);
        });

      if (filteredRows.isEmpty) {
        return [];
      }

      final siklusBulan = _resolveSiklusBulan(penghuni.sistemPembayaran);

      return filteredRows.map((row) {
        final bulan = _toInt(row['bulan']);
        final tahun = _toInt(row['tahun']);
        final startPeriode = (bulan >= 1 && bulan <= 12 && tahun > 0)
            ? DateTime(tahun, bulan, 1)
            : null;
        final rowSiklus = _resolveTagihanSiklusBulan(
          row,
          penghuni,
          fallbackSiklus: siklusBulan,
        );
        final periodLabel = startPeriode == null
            ? '-'
            : _formatPeriodeLabel(startPeriode, rowSiklus);
        final dueDate = startPeriode == null
            ? '-'
            : _formatDueDate(startPeriode);

        return PembayaranModel(
          bulan: periodLabel,
          jumlah: _toDouble(row['jumlah']),
          jatuhTempo: dueDate,
          status: _mapTagihanStatus(row['status']?.toString()),
          tanggalBayar: row['tanggal_bayar']?.toString(),
        );
      }).toList();
    } catch (_) {
      return penghuni.historyPembayaran;
    }
  }

  Set<String> _buildExpectedBillingKeys(PenghuniModel penghuni) {
    final startDate = _parseDate(penghuni.tanggalMasuk);
    if (startDate == null || penghuni.durasiKontrak <= 0) {
      return <String>{};
    }

    final siklus = _resolveSiklusBulan(penghuni.sistemPembayaran);
    final total = (penghuni.durasiKontrak / siklus).ceil();
    final keys = <String>{};

    for (var i = 0; i < total; i++) {
      final periode = DateTime(
        startDate.year,
        startDate.month + (i * siklus),
        1,
      );
      keys.add('${periode.year}-${periode.month.toString().padLeft(2, '0')}');
    }

    return keys;
  }

  Future<PenghuniModel> _loadLatestPenghuniModel(
    String penghuniId, {
    required PenghuniModel fallback,
  }) async {
    if (Get.isRegistered<PenghuniController>()) {
      final penghuniController = Get.find<PenghuniController>();
      final fromController = penghuniController.penghuniList.firstWhereOrNull(
        (item) => item.id == penghuniId,
      );
      if (fromController != null) {
        return fromController;
      }
    }

    final row = await _supabaseService.getPenghuniDetailById(penghuniId);
    if (row == null) return fallback;

    final durasi = _toInt(row['durasi_kontrak']);
    final sewa = _toDouble(row['harga']);
    final siklusRaw = _toInt(row['sistem_pembayaran_bulan']);

    final durasiFinal = durasi <= 0 ? fallback.durasiKontrak : durasi;
    final sewaFinal = sewa <= 0 ? fallback.sewaBulanan : sewa;
    var siklusFinal = siklusRaw <= 0 ? 1 : siklusRaw;
    if (siklusFinal > durasiFinal) {
      siklusFinal = durasiFinal;
    }

    final tanggalMasuk = _formatDateFromRaw(row['tanggal_masuk']);
    final tanggalKeluar = _formatDateFromRaw(row['tanggal_keluar']);

    return PenghuniModel(
      id: row['id']?.toString() ?? fallback.id,
      nama: (row['nama']?.toString().trim().isNotEmpty ?? false)
          ? row['nama'].toString()
          : fallback.nama,
      noTelepon: (row['no_tlpn']?.toString().trim().isNotEmpty ?? false)
          ? row['no_tlpn'].toString()
          : fallback.noTelepon,
      nomorKamar: (row['nomor_kamar']?.toString().trim().isNotEmpty ?? false)
          ? row['nomor_kamar'].toString()
          : fallback.nomorKamar,
      namaKost: (row['nama_kost']?.toString().trim().isNotEmpty ?? false)
          ? row['nama_kost'].toString()
          : fallback.namaKost,
      sewaBulanan: sewaFinal,
      tanggalMasuk: tanggalMasuk == '-' ? fallback.tanggalMasuk : tanggalMasuk,
      durasiKontrak: durasiFinal,
      sistemPembayaran: _formatSistemPembayaranFromBulan(siklusFinal),
      tanggalBerakhir: tanggalKeluar == '-'
          ? fallback.tanggalBerakhir
          : tanggalKeluar,
      totalNilaiKontrak: sewaFinal * durasiFinal,
      historyPembayaran: fallback.historyPembayaran,
    );
  }

  String _formatDateFromRaw(dynamic value) {
    final dt = DateTime.tryParse(value?.toString() ?? '');
    if (dt == null) return '-';

    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  String _formatSistemPembayaranFromBulan(int bulan) {
    if (bulan <= 1) return 'Bulanan (1 bulan)';
    if (bulan == 3) return '3 Bulanan';
    if (bulan == 6) return '6 Bulanan';
    if (bulan == 12) return 'Tahunan (1 tahun)';
    if (bulan == 24) return '2 Tahunan';
    return '$bulan Bulanan';
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _mapTagihanStatus(String? rawStatus) {
    final status = (rawStatus ?? '').trim().toLowerCase();
    if (status == 'lunas') return 'Lunas';
    if (status == 'menunggu_verifikasi') return 'Menunggu Verifikasi';
    return 'Belum Dibayar';
  }

  List<PembayaranModel> _buildBillingHistory(PenghuniModel penghuni) {
    final startDate = _parseDate(penghuni.tanggalMasuk);
    if (startDate == null || penghuni.durasiKontrak <= 0) {
      return penghuni.historyPembayaran;
    }

    final siklusBulan = _resolveSiklusBulan(penghuni.sistemPembayaran);
    final totalTagihan = (penghuni.durasiKontrak / siklusBulan).ceil();
    final jumlahPerTagihan = penghuni.sewaBulanan * siklusBulan;

    final existingHistory = {
      for (final item in penghuni.historyPembayaran)
        item.bulan.toLowerCase(): item,
    };

    return List.generate(totalTagihan, (index) {
      final dueDate = DateTime(
        startDate.year,
        startDate.month + (index * siklusBulan),
        startDate.day,
      );
      final bulanLabel = _formatPeriodeLabel(dueDate, siklusBulan);
      final existing = existingHistory[bulanLabel.toLowerCase()];
      if (existing != null) {
        return existing;
      }

      return PembayaranModel(
        bulan: bulanLabel,
        jumlah: jumlahPerTagihan,
        jatuhTempo: _formatDueDate(dueDate),
        status: 'Belum Dibayar',
      );
    });
  }

  DateTime? _parseDate(String tanggal) {
    final parts = tanggal.split(RegExp(r'\s+'));
    if (parts.length < 3) return null;
    final day = int.tryParse(parts[0]);
    final month = _monthNumber(parts[1].toLowerCase());
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  String _formatMonthLabel(DateTime date) {
    return '${_monthNames[date.month]} ${date.year}';
  }

  String _formatPeriodeLabel(DateTime start, int siklusBulan) {
    if (siklusBulan <= 1) {
      return _formatMonthLabel(start);
    }

    final end = DateTime(start.year, start.month + siklusBulan - 1, start.day);
    return '${_monthNames[start.month]}-\n${_monthNames[end.month]} ${end.year}';
  }

  String _formatDueDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthNames[date.month]} ${date.year}';
  }

  int _resolveSiklusBulan(String sistemPembayaran) {
    final raw = sistemPembayaran.toLowerCase();
    if (raw.contains('24') || raw.contains('2 tahun')) return 24;
    if (raw.contains('12') || raw.contains('tahunan')) return 12;
    if (raw.contains('6')) return 6;
    if (raw.contains('3')) return 3;
    return 1;
  }

  int _resolveTagihanSiklusBulan(
    Map<String, dynamic> row,
    PenghuniModel penghuni, {
    required int fallbackSiklus,
  }) {
    final sewaBulanan = penghuni.sewaBulanan;
    final jumlahTagihan = _toDouble(row['jumlah']);

    if (sewaBulanan <= 0 || jumlahTagihan <= 0) {
      return fallbackSiklus <= 0 ? 1 : fallbackSiklus;
    }

    final ratio = jumlahTagihan / sewaBulanan;
    final rounded = ratio.round();
    // Accept near-integer ratios to tolerate minor rounding differences.
    if (rounded > 0 && (ratio - rounded).abs() <= 0.15) {
      return rounded;
    }

    return fallbackSiklus <= 0 ? 1 : fallbackSiklus;
  }

  ({String label, Color backgroundColor, Color textColor}) _getContractBadge(
    PenghuniModel penghuni,
  ) {
    final endDate = _parseDate(penghuni.tanggalBerakhir);
    if (endDate == null) {
      return (
        label: 'Aktif',
        backgroundColor: const Color(0xFF16A34A),
        textColor: Colors.white,
      );
    }

    final today = DateTime.now();
    final diff = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).difference(DateTime(today.year, today.month, today.day));

    if (diff.inDays < 0) {
      return (
        label: 'Berakhir',
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
      );
    }

    if (diff.inDays <= 30) {
      return (
        label: 'Segera Berakhir',
        backgroundColor: const Color(0xFFF59E0B),
        textColor: Colors.white,
      );
    }

    return (
      label: 'Aktif',
      backgroundColor: const Color(0xFF16A34A),
      textColor: Colors.white,
    );
  }

  int? _monthNumber(String month) {
    const monthMap = {
      'jan': 1,
      'januari': 1,
      'feb': 2,
      'februari': 2,
      'mar': 3,
      'maret': 3,
      'apr': 4,
      'april': 4,
      'mei': 5,
      'jun': 6,
      'juni': 6,
      'jul': 7,
      'juli': 7,
      'agu': 8,
      'agustus': 8,
      'sep': 9,
      'september': 9,
      'okt': 10,
      'oktober': 10,
      'nov': 11,
      'november': 11,
      'des': 12,
      'desember': 12,
    };
    return monthMap[month];
  }

  static const _monthNames = {
    1: 'Januari',
    2: 'Februari',
    3: 'Maret',
    4: 'April',
    5: 'Mei',
    6: 'Juni',
    7: 'Juli',
    8: 'Agustus',
    9: 'September',
    10: 'Oktober',
    11: 'November',
    12: 'Desember',
  };
}
