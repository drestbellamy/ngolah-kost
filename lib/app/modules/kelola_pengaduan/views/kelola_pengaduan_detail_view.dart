import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/values/values.dart';
import '../models/pengaduan_admin_model.dart';
import '../controllers/kelola_pengaduan_controller.dart';
import 'widgets/detail_profile_card.dart';
import 'widgets/detail_info_card.dart';
import 'widgets/detail_photo_card.dart';

class KelolaPengaduanDetailView extends StatefulWidget {
  final PengaduanAdminModel pengaduan;

  const KelolaPengaduanDetailView({super.key, required this.pengaduan});

  @override
  State<KelolaPengaduanDetailView> createState() =>
      _KelolaPengaduanDetailViewState();
}

class _KelolaPengaduanDetailViewState extends State<KelolaPengaduanDetailView> {
  late String selectedStatus;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.pengaduan.status;
  }

  void _onStatusChanged(String newStatus) {
    setState(() {
      selectedStatus = newStatus;
      hasChanges = newStatus != widget.pengaduan.status;
    });
  }

  Future<void> _saveChanges() async {
    final controller = Get.find<KelolaPengaduanController>();

    try {
      await controller.updateStatus(widget.pengaduan.idLaporan, selectedStatus);

      if (mounted) {
        // Set filter sesuai status yang baru
        controller.changeFilter(selectedStatus.toLowerCase());

        setState(() {
          hasChanges = false;
        });

        // Kembali ke list terlebih dahulu
        Get.back();

        // Tunggu sebentar agar navigasi selesai, baru tampilkan toast
        await Future.delayed(const Duration(milliseconds: 300));

        // Show success toast setelah kembali ke list
        ToastHelper.showSuccess('Status pengaduan berhasil diubah');
      }
    } catch (e) {
      if (mounted) {
        // Show error toast
        ToastHelper.showError('Gagal mengubah status: ${e.toString()}');
      }
    }
  }

  void _cancelChanges() {
    setState(() {
      selectedStatus = widget.pengaduan.status;
      hasChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KelolaPengaduanController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header
            const CustomHeader(
              title: 'Detail Pengaduan',
              subtitle: 'Informasi lengkap pengaduan',
              showBackButton: true,
              backgroundImage: 'assets/images/dashboard_admin/header_admin.png',
            ),

            // Content with Pull to Refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.loadPengaduanData();
                },
                color: const Color(0xFF6B8E7A),
                child: SingleChildScrollView(
                  padding: context.allPadding(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile, Kost & Status Card (with editable status)
                      DetailProfileCard(
                        pengaduan: widget.pengaduan,
                        selectedStatus: selectedStatus,
                        onStatusChanged: _onStatusChanged,
                      ),

                      SizedBox(height: context.spacing(16)),

                      // Informasi Laporan Card
                      DetailInfoCard(pengaduan: widget.pengaduan),

                      // Lampiran Foto Card
                      if (widget.pengaduan.buktiFoto.isNotEmpty) ...[
                        SizedBox(height: context.spacing(16)),
                        DetailPhotoCard(pengaduan: widget.pengaduan),
                      ],

                      SizedBox(height: context.spacing(100)),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Action Buttons (only show when there are changes)
            if (hasChanges)
              Container(
                padding: EdgeInsets.all(context.spacing(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelChanges,
                        style: OutlinedButton.styleFrom(
                          padding: context.verticalPadding(16),
                          side: BorderSide(
                            color: AppColors.textSecondary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              context.borderRadius(12),
                            ),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: AppTextStyles.buttonMedium
                              .colored(AppColors.textSecondary)
                              .copyWith(
                                fontSize: context.fontSize(14),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),

                    SizedBox(width: context.spacing(12)),

                    // Save Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          padding: context.verticalPadding(16),
                          backgroundColor: const Color(0xFF6B8E7A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              context.borderRadius(12),
                            ),
                          ),
                        ),
                        child: Text(
                          'Simpan Perubahan',
                          style: AppTextStyles.buttonMedium
                              .colored(Colors.white)
                              .copyWith(
                                fontSize: context.fontSize(14),
                                fontWeight: FontWeight.w600,
                              ),
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
  }
}
