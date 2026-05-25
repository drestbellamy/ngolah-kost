import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/admin_pengajuan_pindah_controller.dart';
import '../../../data/models/pengajuan_pindah_model.dart';
import '../../../core/widgets/custom_header.dart';

class AdminPengajuanPindahDetailView extends StatelessWidget {
  const AdminPengajuanPindahDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as PengajuanPindahModel;
    final controller = Get.find<AdminPengajuanPindahController>();

    final isMenunggu = item.status == 'menunggu';
    
    final diajukanStr = DateFormat('dd MMMM yyyy').format(item.createdAt);
    final pindahStr = DateFormat('dd MMMM yyyy').format(item.tanggalPindah);

    final statusColor = item.status == 'menunggu' 
        ? Colors.orange 
        : (item.status == 'disetujui' ? Colors.green : Colors.red);
    final statusText = item.status.toString().capitalizeFirst ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const CustomHeader(
              title: 'Detail Pengajuan',
              subtitle: 'Lihat detail pengajuan penghuni',
              showBackButton: true,
              backgroundImage: 'assets/images/dashboard_admin/header_admin.png',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card 1: Penghuni Info
                    _buildPenghuniCard(item, statusColor, statusText),
                    const SizedBox(height: 16),
                    
                    // Card 2: Detail Perpindahan
                    _buildDetailPerpindahanCard(item),
                    const SizedBox(height: 16),
                    
                    // Card 3: Tanggal & Waktu
                    _buildTanggalWaktuCard(diajukanStr, pindahStr),
                    const SizedBox(height: 16),
                    
                    // Card 4: Alasan Pindah
                    _buildAlasanPindahCard(item.alasan ?? ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isMenunggu ? _buildBottomActions(controller, item.id) : null,
    );
  }

  Widget _buildPenghuniCard(PengajuanPindahModel item, Color statusColor, String statusText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: Color(0xFF6B8E7A)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.namaPenghuni ?? 'Penghuni',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Since Phone Number is not stored in the old model mapping, 
                // we show a default or placeholder if it's missing.
                // You can modify `buildPenghuniLookup` later to include 'no_tlpn'
                Text(
                  item.noTeleponPenghuni ?? '-', // Real phone number
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 12, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPerpindahanCard(PengajuanPindahModel item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
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
                  color: const Color(0xFFF5F7F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.meeting_room_outlined, color: Color(0xFF6B8E7A), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Perpindahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Informasi kamar', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Kamar Saat Ini
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KAMAR SAAT INI', style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.home_outlined, color: Color(0xFF6B8E7A), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.noKamarAsal ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(item.namaKostAsal ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.alamatKostAsal ?? '-', 
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Arrow connector
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B8E7A), size: 24),
              ),
            ),
          ),
          
          // Kamar Tujuan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F9F5), // Light green tint
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6B8E7A).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KAMAR TUJUAN', style: TextStyle(color: const Color(0xFF6B8E7A), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.home_filled, color: Color(0xFF6B8E7A), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.noKamarTujuan ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(item.namaKostTujuan ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.alamatKostTujuan ?? '-', 
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Price pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B8E7A).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.hargaKamarTujuan != null 
                                  ? '${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.hargaKamarTujuan)}/bulan' 
                                  : '-',
                              style: const TextStyle(color: Color(0xFF4A6B5A), fontSize: 12, fontWeight: FontWeight.bold),
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

  Widget _buildTanggalWaktuCard(String diajukanStr, String pindahStr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
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
                  color: const Color(0xFFF5F7F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF6B8E7A), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tanggal & Waktu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Timeline pengajuan', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tanggal Pengajuan', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(diajukanStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.description_outlined, color: Colors.blue, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF6B8E7A).withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rencana Pindah', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(pindahStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B8E7A).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.meeting_room_outlined, color: Color(0xFF6B8E7A), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlasanPindahCard(String alasan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
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
                  color: const Color(0xFFF5F7F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.article_outlined, color: Color(0xFF6B8E7A), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alasan Pindah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Keterangan dari penghuni', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              alasan.isNotEmpty ? alasan : 'Tidak ada keterangan.',
              style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(AdminPengajuanPindahController controller, String id) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Get.back();
                _showTolakDialog(controller, id);
              },
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text('Tolak', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Get.back();
                controller.updateStatus(id, 'disetujui');
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text('Setujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E7A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTolakDialog(AdminPengajuanPindahController controller, String id) {
    final keteranganController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Pengajuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Berikan alasan penolakan untuk penghuni:', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(
              controller: keteranganController,
              decoration: InputDecoration(
                hintText: 'Contoh: Kamar sudah penuh',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFF5F7F9),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (keteranganController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Alasan penolakan tidak boleh kosong');
                return;
              }
              Get.back();
              controller.updateStatus(id, 'ditolak', keteranganAdmin: keteranganController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tolak Pengajuan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
