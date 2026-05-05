import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/values.dart';
import '../../controllers/kelola_tagihan_controller.dart';

class KostFilterBottomSheet extends GetView<KelolaTagihanController> {
  const KostFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Obx(() {
        final kostList = controller.kostFilterList;
        final selected = controller.selectedKostId.value;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Filter Kost',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih kost yang ingin ditampilkan',
                style: AppTextStyles.body12.colored(AppColors.textGray),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: kostList.length + 1, // +1 for "Semua Kost"
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      // "Semua Kost" option
                      final isSelected = selected == 'semua';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected
                              ? const Color(0xFF6B8E7F)
                              : const Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        title: Text(
                          'Semua Kost',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF1F2937)
                                : const Color(0xFF4B5563),
                          ),
                        ),
                        onTap: () {
                          controller.changeKostFilter('semua');
                          Navigator.of(context).pop();
                        },
                      );
                    }

                    final kost = kostList[index - 1];
                    final kostId = kost['id']!;
                    final kostName = kost['name']!;
                    final isSelected = kostId == selected;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? const Color(0xFF6B8E7F)
                            : const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      title: Text(
                        kostName,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF1F2937)
                              : const Color(0xFF4B5563),
                        ),
                      ),
                      onTap: () {
                        controller.changeKostFilter(kostId);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
