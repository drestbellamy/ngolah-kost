import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/penghuni_model.dart';
import '../../../../../repositories/repository_factory.dart';
import '../../controllers/kelola_kontrak_controller.dart';
import '../../../../core/utils/toast_helper.dart';

class InformasiKontrakCard extends StatelessWidget {
  final PenghuniModel penghuni;
  final Function(PenghuniModel) onContractUpdated;

  const InformasiKontrakCard({
    super.key,
    required this.penghuni,
    required this.onContractUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              onPressed: () => _handleKelolaKontrak(context),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Kelola Kontrak'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E7F),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
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

  Future<void> _handleKelolaKontrak(BuildContext context) async {
    try {
      // Hapus controller lama jika ada
      if (Get.isRegistered<KelolaKontrakController>()) {
        Get.delete<KelolaKontrakController>();
      }

      // Buat controller baru
      final controller = Get.put(
        KelolaKontrakController(
          penghuniRepository: RepositoryFactory.instance.penghuniRepository,
          tagihanRepository: RepositoryFactory.instance.tagihanRepository,
        ),
      );

      // Set penghuni dan initialize form menggunakan method khusus
      controller.setPenghuniAndInitialize(penghuni);

      // Tunggu sebentar untuk memastikan controller sudah siap
      await Future.delayed(const Duration(milliseconds: 100));

      // Pastikan controller masih terdaftar dan penghuni tidak null
      if (!Get.isRegistered<KelolaKontrakController>() ||
          controller.penghuni == null) {
        ToastHelper.showError('Gagal memuat data kontrak. Silakan coba lagi.');
        return;
      }

      // Navigate to page instead of bottom sheet
      final result = await Get.toNamed('/kelola-kontrak');

      // If contract was ended, don't reload detail page
      if (result == 'kontrak_diakhiri') {
        return; // Already navigated back to penghuni list
      }

      if (result != true) return;

      // Fetch latest data in background (no loading dialog)
      final refreshed = await _loadLatestPenghuniModel(
        penghuni.id,
        fallback: penghuni,
      );

      // Update the current detail page state using callback
      // This updates the existing page without adding new page to stack
      onContractUpdated(refreshed);
    } catch (e) {
      ToastHelper.showError('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<PenghuniModel> _loadLatestPenghuniModel(
    String penghuniId, {
    required PenghuniModel fallback,
  }) async {
    final penghuniRepo = RepositoryFactory.instance.penghuniRepository;

    final row = await penghuniRepo.getPenghuniDetailById(penghuniId);
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
}
