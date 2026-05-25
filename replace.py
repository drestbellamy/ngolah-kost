import sys
import re

with open('lib/app/modules/user_pengajuan_pindah/views/user_pengajuan_pindah_view.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# I will replace from _buildFormPengajuan to the end of the file.
start_idx = content.find('  Widget _buildFormPengajuan(BuildContext context) {')
if start_idx != -1:
    content = content[:start_idx] + '''  Widget _buildFormPengajuan(BuildContext context) {
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
          _buildKostSelectionButton(context),
          const SizedBox(height: 24),

          const Text(
            'Pilih Kamar Tujuan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRoomSelectionButton(context),
          const SizedBox(height: 24),

          const Text(
            'Tanggal Pindah',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDatePickerButton(context),
          const SizedBox(height: 24),

          const Text(
            'Alasan Pindah',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              children: [
                TextField(
                  controller: controller.reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Jelaskan alasan Anda ingin pindah kamar...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'ALASAN PINDAH',
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        'Wajib diisi',
                        style: TextStyle(color: Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.bold),
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
            height: 50,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => controller.submitPengajuan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Kirim Pengajuan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
          ? (controller.groupedKosts[selectedId]?['nama_kost']?.toString() ?? 'Pilih kost tujuan...')
          : 'Pilih kost tujuan...';
          
      return InkWell(
        onTap: () => _showKostBottomSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_city, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
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
              final rooms = controller.groupedKosts[selectedKost]?['rooms'] as List?;
              final room = rooms?.firstWhere((r) => r['id'].toString() == selectedRoom, orElse: () => null);
              if (room != null) {
                  text = 'Kamar ' + (room['no_kamar']?.toString() ?? '');
              }
          }
      }
          
      return InkWell(
        onTap: isKostSelected ? () => _showRoomBottomSheet(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: isKostSelected ? Colors.white : Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.home_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isRoomSelected ? Colors.black87 : Colors.grey,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
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
              initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
                controller.selectDate(date);
            }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black87 : Colors.grey,
                  ),
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
        Get.snackbar('Info', 'Saat ini tidak ada kost yang memiliki kamar kosong.', backgroundColor: Colors.orange.shade50, colorText: Colors.orange);
        return;
    }
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pilih Kost Tujuan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih salah satu kost yang tersedia',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.groupedKosts.length,
                  itemBuilder: (context, index) {
                    final key = controller.groupedKosts.keys.elementAt(index);
                    final kostGroup = controller.groupedKosts[key]!;
                    final roomsCount = (kostGroup['rooms'] as List).length;

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
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0D9488) : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.location_city, color: Colors.grey),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      kostGroup['nama_kost']?.toString() ?? 'Kost',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      kostGroup['alamat']?.toString() ?? '-',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: roomsCount > 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        roomsCount > 0 ? f'{roomsCount} kamar tersedia' : 'Penuh',
                                        style: TextStyle(
                                          color: roomsCount > 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
    if (selectedKostId == null || !controller.groupedKosts.containsKey(selectedKostId)) {
        return;
    }

    final rooms = controller.groupedKosts[selectedKostId]!['rooms'] as List;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pilih Kamar Tujuan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih salah satu kamar yang tersedia',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
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
                    
                    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

                    return Obx(() {
                      final isSelected = controller.selectedRoomId.value == roomId;
                      return GestureDetector(
                        onTap: () {
                          controller.selectRoom(roomId);
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0D9488) : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.meeting_room, color: Colors.grey),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kamar ' + nomorKamar,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatCurrency.format(harga),
                                      style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Slot: ' + kapasitas.toString() + ' Penghuni',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
'''
    with open('lib/app/modules/user_pengajuan_pindah/views/user_pengajuan_pindah_view.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Replaced content successfully.")
else:
    print("Could not find start idx")
