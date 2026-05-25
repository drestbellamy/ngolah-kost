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
  
  // Shared static list for notifications to persist across views
  static final RxList<NotificationItem> sharedNotifications = <NotificationItem>[].obs;

  static void addNotification(String title, String message, String type) {
    sharedNotifications.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        date: DateTime.now(),
        type: type,
        isRead: false,
      ),
    );
  }

  // Getter for the view to observe
  RxList<NotificationItem> get notifications => sharedNotifications;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() {
      _cleanupOldNotifications();
      loadNotifications();
    });
  }

  void _cleanupOldNotifications() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    // Hapus notifikasi yang sudah dibaca dan usianya lebih dari 30 hari
    sharedNotifications.removeWhere(
      (n) => n.isRead && n.date.isBefore(thirtyDaysAgo),
    );
  }

  void loadNotifications() async {
    try {
      isLoading.value = true;
      // TODO: Fetch real data from the database here
      // final data = await supabase.from('notifications').select()...
      // sharedNotifications.assignAll(data);
    } catch (e) {
      ToastHelper.showError('Gagal memuat notifikasi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void markAsRead(String id) {
    final index = sharedNotifications.indexWhere((n) => n.id == id);
    if (index != -1 && !sharedNotifications[index].isRead) {
      final notif = sharedNotifications[index];
      sharedNotifications[index] = NotificationItem(
        id: notif.id,
        title: notif.title,
        message: notif.message,
        date: notif.date,
        type: notif.type,
        isRead: true,
      );
    }
  }

  void removeNotification(String id) {
    sharedNotifications.removeWhere((n) => n.id == id);
  }

  void handleNotificationTap(NotificationItem notif) {
    // Ubah notifikasi menjadi sudah dibaca (warna putih) saat diklik, bukan menghapusnya
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
