import 'package:get/get.dart';
import '../../../core/utils/toast_helper.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final String type; // 'tagihan', 'pengaduan', 'pengumuman', 'penghuni'
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.isRead = false,
  });
}

class RiwayatNotifikasiController extends GetxController {
  final isLoading = true.obs;
  final notifications = <NotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() async {
    try {
      isLoading.value = true;
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data based on requested logic
      notifications.assignAll([
        NotificationItem(
          id: '1',
          title: 'Verifikasi Pembayaran',
          message:
              'Penghuni Budi mengirimkan bukti pembayaran tagihan bulan ini.',
          date: DateTime.now().subtract(const Duration(minutes: 30)),
          type: 'tagihan',
          isRead: false,
        ),
        NotificationItem(
          id: '2',
          title: 'Pengaduan Baru',
          message: 'AC di kamar 102 tidak dingin.',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'pengaduan',
          isRead: false,
        ),
        NotificationItem(
          id: '3',
          title: 'Penghuni Baru',
          message: 'Siti telah terdaftar sebagai penghuni baru kamar 201.',
          date: DateTime.now().subtract(const Duration(days: 1)),
          type: 'penghuni',
          isRead: true,
        ),
        NotificationItem(
          id: '4',
          title: 'Pengumuman Dibuat',
          message:
              'Pengumuman "Kerja Bakti Mingguan" berhasil dikirim ke semua penghuni.',
          date: DateTime.now().subtract(const Duration(days: 2)),
          type: 'pengumuman',
          isRead: true,
        ),
      ]);
    } catch (e) {
      ToastHelper.showError('Gagal memuat notifikasi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      final notif = notifications[index];
      notifications[index] = NotificationItem(
        id: notif.id,
        title: notif.title,
        message: notif.message,
        date: notif.date,
        type: notif.type,
        isRead: true,
      );
    }
  }

  void handleNotificationTap(NotificationItem notif) {
    markAsRead(notif.id);
    switch (notif.type) {
      case 'tagihan':
        Get.toNamed('/kelola-tagihan', arguments: {'tab': 'verifikasi'});
        break;
      case 'pengaduan':
        Get.toNamed('/kelola-pengaduan');
        break;
      case 'pengumuman':
        Get.toNamed('/kelola-pengumuman');
        break;
      case 'penghuni':
        Get.toNamed('/penghuni');
        break;
      default:
        break;
    }
  }
}
