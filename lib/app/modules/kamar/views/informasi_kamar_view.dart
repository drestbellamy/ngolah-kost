import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/informasi_kamar_controller.dart';

class InformasiKamarView extends GetView<InformasiKamarController> {
  const InformasiKamarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6B8E7A),
                  Color(0xFF8FAA9F),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: controller.goBack,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Text(
                                'Kamar ${controller.nomorKamar.value}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: Color(0xFFA8D5BA),
                                  ),
                                  const SizedBox(width: 4),
                                  Obx(() => Text(
                                    controller.namaKost.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFA8D5BA),
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Status badge
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: controller.status.value == 'Kosong' 
                            ? const Color(0xFFF2A65A) 
                            : const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.status.value == 'Kosong' ? 'Tersedia' : controller.status.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: Obx(() {
              // Jika kamar kosong, tampilkan UI untuk kamar tersedia
              if (controller.status.value == 'Kosong') {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Informasi Kamar
                      _buildInfoCard(
                        title: 'Informasi Kamar',
                        children: [
                          _buildInfoRow(
                            icon: Icons.meeting_room_outlined,
                            label: 'Nomor Kamar',
                            value: controller.nomorKamar.value,
                            iconColor: const Color(0xFF6B8E7A),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            icon: Icons.attach_money,
                            label: 'Harga per Bulan',
                            value: controller.hargaPerBulan.value,
                            iconColor: const Color(0xFFF2A65A),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Belum Ada Penghuni Card
                      Container(
                        padding: const EdgeInsets.all(32),
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
                          children: [
                            // Icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2A65A).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_add_outlined,
                                size: 40,
                                color: Color(0xFFF2A65A),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Title
                            const Text(
                              'Belum Ada Penghuni',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F2F2F),
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Description
                            const Text(
                              'Kamar ini masih kosong dan tersedia untuk\npenghuni baru',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: controller.tambahPenghuni,
                                icon: const Icon(Icons.person_add_outlined, size: 20),
                                label: const Text('Tambah Penghuni'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B8E7A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Jika kamar terisi, tampilkan UI lengkap
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Informasi Kamar
                    _buildInfoCard(
                      title: 'Informasi Kamar',
                      children: [
                        _buildInfoRow(
                          icon: Icons.meeting_room_outlined,
                          label: 'Nomor Kamar',
                          value: controller.nomorKamar.value,
                          iconColor: const Color(0xFF6B8E7A),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.attach_money,
                          label: 'Harga per Bulan',
                          value: controller.hargaPerBulan.value,
                          iconColor: const Color(0xFFF2A65A),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Informasi Penghuni
                    _buildInfoCard(
                      title: 'Informasi Penghuni',
                      children: [
                        _buildInfoRow(
                          icon: Icons.person_outline,
                          label: 'Nama',
                          value: controller.namaPenghuni.value,
                          iconColor: const Color(0xFF6B8E7A),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Telepon',
                          value: controller.telepon.value,
                          iconColor: const Color(0xFF6B8E7A),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Tanggal Masuk',
                          value: controller.tanggalMasuk.value,
                          iconColor: const Color(0xFF6B8E7A),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Informasi Kontrak
                    _buildInfoCard(
                      title: 'Informasi Kontrak',
                      badge: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Obx(() => Text(
                          controller.statusKontrak.value,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        )),
                      ),
                      children: [
                        _buildInfoRow(
                          icon: Icons.access_time_outlined,
                          label: 'Durasi Kontrak',
                          value: controller.durasiKontrak.value,
                          iconColor: const Color(0xFFF2A65A),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.payment_outlined,
                          label: 'Sistem Pembayaran',
                          value: controller.sistemPembayaran.value,
                          iconColor: const Color(0xFFF2A65A),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.calendar_month_outlined,
                          label: 'Periode Kontrak',
                          value: controller.periodeKontrak.value,
                          iconColor: const Color(0xFF6B8E7A),
                        ),
                        const SizedBox(height: 16),
                        
                        // Ringkasan Tagihan
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F9F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ringkasan Tagihan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B8E7A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildSummaryRow(
                                'Total Tagihan:',
                                controller.totalTagihan.value,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                'Per Tagihan:',
                                controller.perTagihan.value,
                              ),
                              const SizedBox(height: 8),
                              const Divider(
                                color: Color(0xFFE5E7EB),
                                height: 1,
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                'Total Nilai Kontrak:',
                                controller.totalNilaiKontrak.value,
                                isBold: true,
                                labelColor: const Color(0xFF6B7280),
                                valueColor: const Color(0xFF6B8E7A),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    Widget? badge,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F2F),
                ),
              ),
              if (badge != null) badge,
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F2F2F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? labelColor, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: labelColor ?? const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? const Color(0xFF2F2F2F),
          ),
        ),
      ],
    );
  }
}
