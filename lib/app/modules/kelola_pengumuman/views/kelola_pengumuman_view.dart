import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../controllers/kelola_pengumuman_controller.dart';
import 'widgets/gedung_card_widget.dart';
import 'widgets/pengumuman_card_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/error_state_widget.dart';
import 'widgets/detail_pengumuman_dialog.dart';
import 'widgets/add_pengumuman_dialog.dart';
import 'widgets/edit_pengumuman_dialog.dart';
import 'widgets/delete_pengumuman_dialog.dart';

class KelolaPengumumanView extends GetView<KelolaPengumumanController> {
  const KelolaPengumumanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedGedung = controller.selectedGedung.value;
      return Scaffold(
        backgroundColor: const Color(0xFFF1F3F2),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(selectedGedung),
              Expanded(
                child: selectedGedung == null
                    ? _buildPilihGedungContent()
                    : _buildKelolaPengumumanContent(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(GedungKostModel? selectedGedung) {
    return CustomHeader(
      title: 'Kelola Pengumuman',
      subtitle: selectedGedung?.nama ?? 'Kelola informasi pengumuman kost',
      showBackButton: true,
      onBackPressed: () {
        if (selectedGedung != null) {
          controller.kembaliKePilihGedung();
          return;
        }
        Get.back();
      },
    );
  }

  Widget _buildPilihGedungContent() {
    if (controller.isLoadingGedung.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.gedungKostList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            controller.errorMessage.value ?? 'Belum ada data kost.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body14.colored(AppColors.textGray),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: controller.gedungKostList
            .map(
              (gedung) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GedungCardWidget(
                  gedung: gedung,
                  totalPengumuman: controller.getPengumumanCountForKost(
                    gedung.id,
                  ),
                  onTap: () => controller.pilihGedungKost(gedung),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildKelolaPengumumanContent() {
    return RefreshIndicator(
      onRefresh: controller.refreshPengumumanAktif,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E7A),
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: controller.isSavingPengumuman.value
                  ? null
                  : AddPengumumanDialog.show,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Tambah Pengumuman',
                    style: AppTextStyles.subtitle16.colored(Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (controller.isLoadingPengumuman.value)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: CircularProgressIndicator(),
              )
            else if (controller.errorMessage.value != null)
              ErrorStateWidget(message: controller.errorMessage.value!)
            else if (controller.pengumumanList.isEmpty)
              const EmptyStateWidget()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.pengumumanList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = controller.pengumumanList[index];
                  return PengumumanCardWidget(
                    item: item,
                    onTap: () => DetailPengumumanDialog.show(item),
                    onEdit: () => EditPengumumanDialog.show(item),
                    onDelete: () => DeletePengumumanDialog.show(item.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
