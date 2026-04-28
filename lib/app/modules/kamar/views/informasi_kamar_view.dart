import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
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
          SafeArea(
            top: false,
            child: Obx(
              () => CustomHeader(
                title: 'Kamar ${controller.nomorKamar.value}',
                showBackButton: true,
                onBackPressed: controller.goBack,
                subtitleWidget: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFFA8D5BA),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.namaKost.value,
                      style: AppTextStyles.body14.colored(
                        const Color(0xFFA8D5BA),
                      ),
                    ),
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
                                color: const Color(
                                  0xFFF2A65A,
                                ).withValues(alpha: 0.1),
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
                            Text(
                              'Belum Ada Penghuni',
                              style: AppTextStyles.header18.colored(
                                AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Description
                            Text(
                              'Kamar ini masih kosong dan tersedia untuk\npenghuni baru',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body14
                                  .colored(AppColors.textGray)
                                  .copyWith(height: 1.5),
                            ),
                            const SizedBox(height: 24),

                            // Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: controller.tambahPenghuni,
                                icon: const Icon(
                                  Icons.person_add_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  'Tambah Penghuni',
                                  style: AppTextStyles.subtitle14.colored(
                                    Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B8E7A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Kapasitas dan Terisi Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryBox(
                            icon: Icons.people_outline,
                            iconColor: Colors.white,
                            iconBgColor: const Color(0xFF6B8E7A),
                            title: 'Kapasitas',
                            value: '${controller.kapasitas.value}',
                            subtitle: 'orang maksimal',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryBox(
                            icon: Icons.person_outline,
                            iconColor: Colors.white,
                            iconBgColor: const Color(0xFFF2A65A),
                            title: 'Terisi',
                            value:
                                '${controller.terisi.value}/${controller.kapasitas.value}',
                            subtitle: 'penghuni aktif',
                            valueSize: 24,
                            valueSubtitleSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Informasi Kamar Box
                    Container(
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
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B8E7A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.door_front_door_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Informasi Kamar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F2F2F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F9F8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF6B8E7A,
                                    ).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.door_front_door_outlined,
                                    color: Color(0xFF6B8E7A),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nomor Kamar',
                                      style: AppTextStyles.body12.colored(
                                        AppColors.textGray,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      controller.nomorKamar.value,
                                      style: AppTextStyles.header16.colored(
                                        AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFFF2A65A,
                                ).withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF2A65A,
                                    ).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.attach_money,
                                    color: Color(0xFFF2A65A),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Harga per Bulan',
                                      style: AppTextStyles.body12.colored(
                                        AppColors.textGray,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      controller.hargaPerBulan.value,
                                      style: AppTextStyles.header16.colored(
                                        AppColors.primary,
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
                    const SizedBox(height: 16),

                    // Daftar Penghuni Box
                    Container(
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
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B8E7A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.people_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daftar Penghuni',
                                    style: AppTextStyles.header18.colored(
                                      AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${controller.terisi.value} penghuni aktif',
                                    style: AppTextStyles.body14.colored(
                                      AppColors.textGray,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // List of Penghuni
                          ...List.generate(controller.daftarPenghuni.length, (
                            index,
                          ) {
                            var penghuni = controller.daftarPenghuni[index];
                            return _buildPenghuniItem(index, penghuni);
                          }),

                          const SizedBox(height: 20),
                          // Button Tambah Penghuni
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  controller.terisi.value <
                                      controller.kapasitas.value
                                  ? controller.tambahPenghuni
                                  : null,
                              icon: const Icon(
                                Icons.person_add_outlined,
                                size: 20,
                              ),
                              label: Text(
                                'Tambah Penghuni (${controller.kapasitas.value - controller.terisi.value} slot tersisa)',
                                style: AppTextStyles.subtitle14.colored(
                                  Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B8E7A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: const Color(
                                  0xFFE5E7EB,
                                ),
                                disabledForegroundColor: const Color(
                                  0xFFA1A1AA,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSummaryBox({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required String subtitle,
    double valueSize = 24,
    double valueSubtitleSize = 24,
  }) {
    List<TextSpan> valueSpans = [];
    if (value.contains('/')) {
      var parts = value.split('/');
      valueSpans.add(
        TextSpan(
          text: parts[0],
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2F2F2F),
          ),
        ),
      );
      valueSpans.add(
        TextSpan(
          text: '/${parts[1]}',
          style: TextStyle(
            fontSize: valueSubtitleSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      );
    } else {
      valueSpans.add(
        TextSpan(
          text: value,
          style: TextStyle(
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2F2F2F),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(text: TextSpan(children: valueSpans)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.body12.colored(AppColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildPenghuniItem(int index, Map<String, dynamic> penghuni) {
    bool isExpanded = penghuni['isExpanded'] ?? false;
    return GestureDetector(
      onTap: () => controller.toggleExpand(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B8E7A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          penghuni['nama'],
                          style: AppTextStyles.header16.colored(
                            AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          penghuni['telepon'],
                          style: AppTextStyles.body14.colored(
                            AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Akun Section
                    Row(
                      children: [
                        Icon(
                          Icons.account_circle_outlined,
                          size: 16,
                          color: const Color(0xFF6B8E7A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Akun',
                          style: AppTextStyles.subtitle14.colored(
                            const Color(0xFF6B8E7A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username',
                          style: AppTextStyles.body12.colored(
                            AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          penghuni['username'],
                          style: AppTextStyles.subtitle14.colored(
                            AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Kontrak Section
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: const Color(0xFF6B8E7A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Informasi Kontrak',
                          style: AppTextStyles.subtitle14.colored(
                            const Color(0xFF6B8E7A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status Kontrak',
                          style: AppTextStyles.subtitle14.colored(
                            AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: penghuni['statusKontrak'] == 'Aktif'
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                penghuni['statusKontrak'] == 'Aktif'
                                    ? Icons.check_circle_outline
                                    : Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                penghuni['statusKontrak'],
                                style: AppTextStyles.subtitle12.colored(
                                  Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Durasi Kontrak',
                                style: AppTextStyles.body12.colored(
                                  AppColors.textGray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                penghuni['durasiKontrak'],
                                style: AppTextStyles.subtitle14.colored(
                                  AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tanggal Mulai',
                                style: AppTextStyles.body12.colored(
                                  AppColors.textGray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                penghuni['tanggalMulai'],
                                style: AppTextStyles.subtitle14.colored(
                                  AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Siklus Bayar',
                                style: AppTextStyles.body12.colored(
                                  AppColors.textGray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                penghuni['siklusBayar'],
                                style: AppTextStyles.subtitle14.colored(
                                  AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tanggal Berakhir',
                                style: AppTextStyles.body12.colored(
                                  AppColors.textGray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                penghuni['tanggalBerakhir'],
                                style: AppTextStyles.subtitle14.colored(
                                  AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 16),
                    Text(
                      'Harga Sewa',
                      style: AppTextStyles.body12.colored(AppColors.textGray),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          penghuni['hargaSewa'],
                          style: AppTextStyles.header18.colored(
                            const Color(0xFF6B8E7A),
                          ),
                        ),
                        Text(
                          '/bulan',
                          style: AppTextStyles.body14.colored(
                            AppColors.textGray,
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
                style: AppTextStyles.header16.colored(AppColors.textPrimary),
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
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body12.colored(AppColors.textGray),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.subtitle14.colored(AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
