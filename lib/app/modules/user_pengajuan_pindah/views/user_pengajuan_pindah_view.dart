import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../controllers/user_pengajuan_pindah_controller.dart';

class UserPengajuanPindahView extends GetView<UserPengajuanPindahController> {
  const UserPengajuanPindahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeader(
            title: 'Pengajuan Pindah Kamar',
            subtitle: 'Ajukan perpindahan ke kamar atau kost lain',
            showBackButton: true,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      controller.errorMessage.value,
                      style: AppTextStyles.body16.colored(AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (controller.activePengajuan.value != null) {
                return _buildStatusPengajuan();
              }

              return _buildFormPengajuan(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPengajuan() {
    final pengajuan = controller.activePengajuan.value!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.access_time_filled,
            size: 80,
            color: AppColors.warning,
          ),
          const SizedBox(height: 24),
          Text(
            'Pengajuan Sedang Diproses',
            style: AppTextStyles.headlineSmall.colored(AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  'Tujuan',
                  'Kamar ${pengajuan.noKamarTujuan ?? '-'} (${pengajuan.namaKostTujuan ?? '-'})',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),
                _buildInfoRow(
                  'Tanggal Pindah',
                  DateFormat(
                    'd MMM yyyy',
                    'id_ID',
                  ).format(pengajuan.tanggalPindah),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),
                _buildInfoRow('Status', pengajuan.status.toUpperCase()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Harap tunggu konfirmasi dari admin pengelola kost. Notifikasi akan dikirimkan setelah pengajuan Anda disetujui atau ditolak.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body14.colored(AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body14.colored(AppColors.textTertiary),
        ),
        Text(
          value,
          style: AppTextStyles.subtitle14.colored(AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildFormPengajuan(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Kost Tujuan',
            style: AppTextStyles.header16.colored(AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _buildKostSelectionButton(context),
          const SizedBox(height: 24),

          Text(
            'Pilih Kamar Tujuan',
            style: AppTextStyles.header16.colored(AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _buildRoomSelectionButton(context),
          const SizedBox(height: 24),

          Text(
            'Tanggal Pindah',
            style: AppTextStyles.header16.colored(AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _buildDatePickerButton(context),
          const SizedBox(height: 24),

          Text(
            'Alasan Pindah',
            style: AppTextStyles.header16.colored(AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.backgroundWhite,
            ),
            child: Column(
              children: [
                TextField(
                  controller: controller.reasonController,
                  maxLines: 3,
                  style: AppTextStyles.body14.colored(AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Jelaskan alasan Anda ingin pindah kamar...',
                    hintStyle: AppTextStyles.body14.colored(
                      AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ALASAN PINDAH',
                        style: AppTextStyles.labelMedium.colored(
                          AppColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Wajib diisi',
                        style: AppTextStyles.labelMedium.colored(
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.submitPengajuan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.backgroundWhite,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.send,
                            color: AppColors.backgroundWhite,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kirim Pengajuan',
                            style: AppTextStyles.buttonLarge.colored(
                              AppColors.backgroundWhite,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKostSelectionButton(BuildContext context) {
    return Obx(() {
      final selectedId = controller.selectedKostId.value;
      final isSelected = selectedId != null;
      final text = isSelected
          ? (controller.groupedKosts[selectedId]?['nama_kost']?.toString() ??
                'Pilih kost tujuan...')
          : 'Pilih kost tujuan...';

      return InkWell(
        onTap: () => _showKostBottomSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.02)
                : AppColors.backgroundWhite,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_city,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: isSelected
                      ? AppTextStyles.subtitle16.colored(AppColors.textPrimary)
                      : AppTextStyles.body16.colored(AppColors.textTertiary),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRoomSelectionButton(BuildContext context) {
    return Obx(() {
      final selectedKost = controller.selectedKostId.value;
      final selectedRoom = controller.selectedRoomId.value;

      final isKostSelected = selectedKost != null;
      final isRoomSelected = selectedRoom != null;

      String text = 'Pilih kost terlebih dahulu';
      if (isKostSelected) {
        text = 'Pilih kamar tujuan...';
        if (isRoomSelected) {
          final rooms =
              controller.groupedKosts[selectedKost]?['rooms'] as List?;
          final room = rooms?.firstWhereOrNull(
            (r) => r['id'].toString() == selectedRoom,
          );
          if (room != null) {
            text = 'Kamar ${room['no_kamar']?.toString() ?? ''}';
          }
        }
      }

      return InkWell(
        onTap: isKostSelected ? () => _showRoomBottomSheet(context) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isRoomSelected ? AppColors.primary : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isKostSelected
                ? (isRoomSelected
                      ? AppColors.primary.withValues(alpha: 0.02)
                      : AppColors.backgroundWhite)
                : AppColors.backgroundGray,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isRoomSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : (isKostSelected
                            ? Colors.grey.shade100
                            : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.home_outlined,
                  color: isRoomSelected
                      ? AppColors.primary
                      : (isKostSelected
                            ? AppColors.textTertiary
                            : Colors.grey.shade400),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: isRoomSelected
                      ? AppTextStyles.subtitle16.colored(AppColors.textPrimary)
                      : AppTextStyles.body16.colored(
                          isKostSelected
                              ? AppColors.textTertiary
                              : Colors.grey.shade400,
                        ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isRoomSelected
                    ? AppColors.primary
                    : (isKostSelected
                          ? AppColors.textTertiary
                          : Colors.grey.shade400),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDatePickerButton(BuildContext context) {
    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      final text = selectedDate != null
          ? DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate)
          : 'Pilih tanggal pindah';

      return InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate:
                selectedDate ?? DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (date != null) {
            controller.selectDate(date);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedDate != null
                  ? AppColors.primary
                  : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(16),
            color: selectedDate != null
                ? AppColors.primary.withValues(alpha: 0.02)
                : AppColors.backgroundWhite,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selectedDate != null
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: selectedDate != null
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: selectedDate != null
                      ? AppTextStyles.subtitle16.colored(AppColors.textPrimary)
                      : AppTextStyles.body16.colored(AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showKostBottomSheet(BuildContext context) {
    if (controller.groupedKosts.isEmpty) {
      Get.snackbar(
        'Info',
        'Saat ini tidak ada data kost yang tersedia.',
        backgroundColor: AppColors.warningBg,
        colorText: AppColors.warning,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.backgroundWhite,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pilih Kost Tujuan',
                style: AppTextStyles.header18.colored(AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih salah satu kost yang tersedia',
                style: AppTextStyles.body14.colored(AppColors.textTertiary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.groupedKosts.length,
                  itemBuilder: (context, index) {
                    final key = controller.groupedKosts.keys.elementAt(index);
                    final kostGroup = controller.groupedKosts[key]!;
                    final rooms = kostGroup['rooms'] as List;
                    final availableCount = rooms
                        .where(
                          (r) =>
                              r['status']?.toString().toLowerCase() == 'kosong',
                        )
                        .length;

                    return Obx(() {
                      final isSelected = controller.selectedKostId.value == key;
                      return GestureDetector(
                        onTap: () {
                          controller.selectKost(key);
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : AppColors.backgroundWhite,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.location_city,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      kostGroup['nama_kost']?.toString() ??
                                          'Kost',
                                      style: AppTextStyles.subtitle16.colored(
                                        AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      kostGroup['alamat']?.toString() ?? '-',
                                      style: AppTextStyles.body12.colored(
                                        AppColors.textTertiary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: availableCount > 0
                                            ? AppColors.successBg
                                            : AppColors.warningBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        availableCount > 0
                                            ? '$availableCount kamar tersedia'
                                            : 'Semua kamar penuh',
                                        style: AppTextStyles.labelMedium
                                            .colored(
                                              availableCount > 0
                                                  ? AppColors.success
                                                  : AppColors.warning,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRoomBottomSheet(BuildContext context) {
    final selectedKostId = controller.selectedKostId.value;
    if (selectedKostId == null ||
        !controller.groupedKosts.containsKey(selectedKostId)) {
      return;
    }

    final rooms = controller.groupedKosts[selectedKostId]!['rooms'] as List;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.backgroundWhite,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pilih Kamar Tujuan',
                style: AppTextStyles.header18.colored(AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih salah satu kamar yang tersedia',
                style: AppTextStyles.body14.colored(AppColors.textTertiary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index] as Map<String, dynamic>;
                    final roomId = room['id'].toString();
                    final nomorKamar = room['no_kamar']?.toString() ?? '-';
                    final harga = room['harga'] ?? 0;
                    final kapasitas = room['kapasitas'] ?? 1;
                    final status =
                        room['status']?.toString().toLowerCase() ?? 'kosong';
                    final isKosong = status == 'kosong';

                    final formatCurrency = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    );

                    return Obx(() {
                      final isSelected =
                          controller.selectedRoomId.value == roomId;
                      return GestureDetector(
                        onTap: isKosong
                            ? () {
                                controller.selectRoom(roomId);
                                Navigator.pop(context);
                              }
                            : () {
                                Get.snackbar(
                                  'Kamar Tidak Tersedia',
                                  'Kamar ini sudah terisi, silakan pilih kamar yang kosong.',
                                  backgroundColor: AppColors.errorBg,
                                  colorText: AppColors.error,
                                  margin: const EdgeInsets.all(16),
                                );
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isKosong
                                ? (isSelected
                                      ? AppColors.primary.withValues(
                                          alpha: 0.05,
                                        )
                                      : AppColors.backgroundWhite)
                                : Colors.grey.shade50,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isKosong
                                        ? Colors.grey.shade200
                                        : Colors.transparent),
                              width: isSelected ? 1.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isKosong
                                      ? (isSelected
                                            ? AppColors.primary.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.grey.shade100)
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.meeting_room,
                                  color: isKosong
                                      ? (isSelected
                                            ? AppColors.primary
                                            : AppColors.textTertiary)
                                      : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Kamar $nomorKamar',
                                          style: AppTextStyles.subtitle16
                                              .colored(
                                                isKosong
                                                    ? AppColors.textPrimary
                                                    : AppColors.textTertiary,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isKosong
                                                ? AppColors.successBg
                                                : AppColors.errorBg,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: AppTextStyles.labelMedium
                                                .colored(
                                                  isKosong
                                                      ? AppColors.success
                                                      : AppColors.error,
                                                )
                                                .copyWith(fontSize: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatCurrency.format(harga),
                                      style: AppTextStyles.subtitle14.colored(
                                        isKosong
                                            ? AppColors.primary
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Slot: $kapasitas Penghuni',
                                        style: AppTextStyles.labelMedium
                                            .colored(AppColors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
