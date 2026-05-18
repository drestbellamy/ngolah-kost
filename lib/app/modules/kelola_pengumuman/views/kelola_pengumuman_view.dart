import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'widgets/kelola_pengumuman_shimmer_widget.dart';

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
                    ? _buildPilihGedungContent(context)
                    : _buildKelolaPengumumanContent(),
              ),
            ],
          ),
        ),
        floatingActionButton:
            (selectedGedung != null &&
                !controller.isLoadingPengumuman.value &&
                controller.pengumumanList.isNotEmpty)
            ? FloatingActionButton(
                onPressed: controller.isSavingPengumuman.value
                    ? null
                    : AddPengumumanDialog.show,
                backgroundColor: const Color(0xFFFF9F66),
                child: const Icon(Icons.add, color: Colors.white),
              ).animate().scale(
                delay: 200.ms,
                duration: 300.ms,
                curve: Curves.easeOutBack,
              )
            : null,
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

  Widget _buildPilihGedungContent(BuildContext context) {
    if (controller.isLoadingGedung.value && controller.gedungKostList.isEmpty) {
      return const KelolaPengumumanShimmerWidget(isGedung: true);
    }

    return RefreshIndicator(
      onRefresh: controller.loadGedungKost,
      child: controller.gedungKostList.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      controller.errorMessage.value ?? 'Belum ada data kost.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body14.colored(AppColors.textGray),
                    ),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: controller.gedungKostList.asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final gedung = entry.value;
                  return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GedungCardWidget(
                          gedung: gedung,
                          totalPengumuman: controller.getPengumumanCountForKost(
                            gedung.id,
                          ),
                          onTap: () => controller.pilihGedungKost(gedung),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildKelolaPengumumanContent() {
    return RefreshIndicator(
      onRefresh: controller.refreshPengumumanAktif,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
        child: Column(
          children: [
            if (controller.isLoadingPengumuman.value &&
                controller.pengumumanList.isEmpty)
              const KelolaPengumumanShimmerWidget(isGedung: false)
            else if (controller.errorMessage.value != null &&
                controller.pengumumanList.isEmpty)
              ErrorStateWidget(message: controller.errorMessage.value!)
            else if (controller.pengumumanList.isEmpty)
              EmptyStateWidget(
                onAdd: controller.isSavingPengumuman.value
                    ? null
                    : AddPengumumanDialog.show,
              )
            else
              ListView.separated(
                padding: EdgeInsets.zero,
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
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
                },
              ),
          ],
        ),
      ),
    );
  }
}
