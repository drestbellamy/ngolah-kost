import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_notifikasi_controller.dart';
import '../../../core/widgets/custom_header.dart';
import '../../../core/values/values.dart';
import '../../../core/utils/responsive_utils.dart';

class RiwayatNotifikasiView extends GetView<RiwayatNotifikasiController> {
  const RiwayatNotifikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const CustomHeader(
              title: 'Riwayat Notifikasi',
              subtitle: 'Notifikasi dan aktivitas terbaru',
              showBackButton: true,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6B8E7A)),
                  );
                }

                if (controller.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: context.spacing(16)),
                        Text(
                          'Belum ada notifikasi',
                          style: AppTextStyles.body16.colored(
                            Colors.grey[600]!,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: context.allPadding(16),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    final notif = controller.notifications[index];
                    return _buildNotificationItem(context, notif);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationItem notif) {
    IconData iconData;
    Color iconColor;

    switch (notif.type) {
      case 'tagihan':
        iconData = Icons.receipt_long_outlined;
        iconColor = const Color(0xFFE6A046);
        break;
      case 'pengaduan':
        iconData = Icons.report_problem_outlined;
        iconColor = const Color(0xFFE56A69);
        break;
      case 'pengumuman':
        iconData = Icons.campaign_outlined;
        iconColor = const Color(0xFF83A9DE);
        break;
      case 'penghuni':
        iconData = Icons.person_add_outlined;
        iconColor = const Color(0xFF6B8E7A);
        break;
      default:
        iconData = Icons.notifications_active_outlined;
        iconColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing(12)),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.borderRadius(12)),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      color: notif.isRead ? Colors.white : const Color(0xFFF0FDF4),
      child: InkWell(
        onTap: () => controller.handleNotificationTap(notif),
        borderRadius: BorderRadius.circular(context.borderRadius(12)),
        child: Padding(
          padding: context.allPadding(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: context.allPadding(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: context.iconSize(24),
                ),
              ),
              SizedBox(width: context.spacing(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: AppTextStyles.subtitle16.weighted(
                              notif.isRead ? FontWeight.w500 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notif.isRead) ...[
                          SizedBox(width: context.spacing(8)),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE56A69),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: context.spacing(4)),
                    Text(
                      notif.message,
                      style: AppTextStyles.body14.colored(
                        notif.isRead ? Colors.grey[600]! : Colors.black87,
                      ),
                    ),
                    SizedBox(height: context.spacing(8)),
                    Text(
                      _formatDate(notif.date),
                      style: AppTextStyles.body12.colored(Colors.grey[500]!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
