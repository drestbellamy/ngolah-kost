import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../controllers/kelola_peraturan_controller.dart';
import 'widgets/add_peraturan_dialog.dart';
import 'widgets/delete_peraturan_dialog.dart';
import 'widgets/edit_peraturan_dialog.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/error_state_widget.dart';
import 'widgets/gedung_card_widget.dart';
import 'widgets/info_banner_widget.dart';
import 'widgets/kategori_card_widget.dart';
import 'widgets/kelola_peraturan_shimmer_widget.dart';

class KelolaPeraturanView extends GetView<KelolaPeraturanController> {
  const KelolaPeraturanView({super.key});

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
                    : _buildKelolaPeraturanContent(),
              ),
            ],
          ),
        ),
        floatingActionButton:
            (selectedGedung != null &&
                !controller.isLoadingPeraturan.value &&
                controller.kategoriList.isNotEmpty)
            ? FloatingActionButton(
                onPressed: controller.isSavingPeraturan.value
                    ? null
                    : AddPeraturanDialog.show,
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
      title: 'Kelola Peraturan',
      subtitle: selectedGedung?.nama ?? 'Kelola informasi peraturan kost',
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
    if (controller.isLoadingGedung.value && controller.gedungKostList.isEmpty) {
      return const KelolaPeraturanShimmerWidget(isGedung: true);
    }

    return RefreshIndicator(
      onRefresh: controller.loadGedungKost,
      child: controller.gedungKostList.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(Get.context!).size.height * 0.7,
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                          totalPeraturan: controller.getPeraturanCountForKost(
                            gedung.id,
                          ),
                          onTap: () => controller.pilihGedungKost(gedung),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                      .slideY(begin: 0.1);
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildKelolaPeraturanContent() {
    if (controller.isLoadingPeraturan.value &&
        controller.kategoriList.isEmpty) {
      return const KelolaPeraturanShimmerWidget(isGedung: false);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshPeraturanAktif,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          children: [
            if (!controller.isLoadingPeraturan.value &&
                controller.kategoriList.isNotEmpty) ...[
              InfoBannerWidget(
                    namaGedung: controller.selectedGedung.value?.nama,
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.1),
              const SizedBox(height: 12),
            ],
            if (controller.errorMessage.value != null)
              ErrorStateWidget(message: controller.errorMessage.value!)
            else if (controller.kategoriList.isEmpty)
              EmptyStateWidget(
                onAdd: controller.isSavingPeraturan.value
                    ? null
                    : AddPeraturanDialog.show,
              )
            else
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.kategoriList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final kategori = controller.kategoriList[index];
                  return KategoriCardWidget(
                        kategori: kategori,
                        onEdit: () => EditPeraturanDialog.show(kategori),
                        onDelete: () => DeletePeraturanDialog.show(kategori),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (200 + (index * 100)).ms)
                      .slideY(begin: 0.1);
                },
              ),
          ],
        ),
      ),
    );
  }
}
