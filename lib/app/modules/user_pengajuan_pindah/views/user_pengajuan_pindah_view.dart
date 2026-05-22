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
      backgroundColor: const Color(0xFFF7F9F8),
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: CustomHeader(
              title: 'Pindah Kamar',
              subtitle: 'Ajukan perpindahan kamar/kost',
              showBackButton: true,
            ),
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
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Jika sudah ada pengajuan aktif, tampilkan status
              if (controller.activePengajuan.value != null) {
                return _buildStatusPengajuan();
              }

              // Jika belum ada pengajuan, tampilkan form
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
          const Icon(Icons.access_time_filled, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'Pengajuan Sedang Diproses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  'Tujuan',
                  'Kamar ${pengajuan.noKamarTujuan ?? '-'} (${pengajuan.namaKostTujuan ?? '-'})',
                ),
                const Divider(),
                _buildInfoRow(
                  'Tanggal Pindah',
                  DateFormat(
                    'd MMM yyyy',
                    'id_ID',
                  ).format(pengajuan.tanggalPindah),
                ),
                const Divider(),
                _buildInfoRow('Status', pengajuan.status.toUpperCase()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Harap tunggu konfirmasi dari admin pengelola kost. Notifikasi akan dikirimkan setelah pengajuan Anda disetujui atau ditolak.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFormPengajuan(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Kost Tujuan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildKostList(),
          const SizedBox(height: 24),

          Obx(() {
            if (controller.selectedKostId.value == null) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Kamar Tujuan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildRoomSelection(),
                const SizedBox(height: 24),
              ],
            );
          }),

          const Text(
            'Rencana Tanggal Pindah',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDatePicker(context),
          const SizedBox(height: 24),

          const Text(
            'Alasan Pindah (Opsional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tuliskan alasan Anda...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.submitPengajuan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488), // Teal color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Ajukan Pindah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKostList() {
    if (controller.groupedKosts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Saat ini tidak ada kost yang memiliki kamar kosong.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.groupedKosts.length,
      itemBuilder: (context, index) {
        final key = controller.groupedKosts.keys.elementAt(index);
        final kostGroup = controller.groupedKosts[key]!;
        final roomsCount = (kostGroup['rooms'] as List).length;

        return Obx(() {
          final isSelected = controller.selectedKostId.value == key;
          return GestureDetector(
            onTap: () => controller.selectKost(key),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF22C55E)
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_city,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kostGroup['nama_kost']?.toString() ?? 'Kost',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$roomsCount Kamar Tersedia',
                          style: const TextStyle(
                            color: Color(0xFF0D9488),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          kostGroup['alamat']?.toString() ?? '-',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Color(0xFF22C55E)),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildRoomSelection() {
    final selectedKostId = controller.selectedKostId.value;
    if (selectedKostId == null ||
        !controller.groupedKosts.containsKey(selectedKostId)) {
      return const SizedBox.shrink();
    }

    final rooms = controller.groupedKosts[selectedKostId]!['rooms'] as List;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index] as Map<String, dynamic>;
        final roomId = room['id'].toString();

        return Obx(() {
          final isSelected = controller.selectedRoomId.value == roomId;
          return GestureDetector(
            onTap: () => controller.selectRoom(roomId),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0D9488) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0D9488)
                      : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  room['no_kamar']?.toString() ?? '-',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          controller.selectDate(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              final date = controller.selectedDate.value;
              return Text(
                date == null
                    ? 'Pilih tanggal'
                    : DateFormat('d MMMM yyyy', 'id_ID').format(date),
                style: TextStyle(
                  color: date == null ? Colors.grey : Colors.black87,
                  fontSize: 16,
                ),
              );
            }),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
