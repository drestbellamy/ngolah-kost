import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/toast_helper.dart';
import '../../../core/controllers/auth_controller.dart';

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

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      date: DateTime.parse(json['created_at'] as String),
      type: json['type'] as String,
      isRead: json['is_read'] as bool,
    );
  }
}

class RiwayatNotifikasiController extends GetxController {
  final isLoading = true.obs;
  final supabase = Supabase.instance.client;
  
  // Instance-based notifications list (loaded from database)
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;

  static Future<void> addNotification(String title, String message, String type, {String? userId}) async {
    try {
      final client = Supabase.instance.client;
      // Gunakan AuthController untuk mendapatkan id user saat ini jika userId tidak diberikan
      String? targetUserId = userId;
      if (targetUserId == null) {
        if (Get.isRegistered<AuthController>()) {
          targetUserId = Get.find<AuthController>().currentUser?.id;
        }
      }
      
      if (targetUserId == null) return;

      // Insert ke database - ini yang PENTING, data disimpan persistent
      await client.from('notifications').insert({
        'user_id': targetUserId,
        'title': title,
        'message': message,
        'type': type,
        'is_read': false,
      });

      // Reload notifications di controller yang aktif (jika ada)
      if (Get.isRegistered<RiwayatNotifikasiController>()) {
        final controller = Get.find<RiwayatNotifikasiController>();
        await controller.loadNotifications();
      }
    } catch (e) {
      Get.log('Error adding notification: $e');
    }
  }

  // Notifikasi khusus untuk dikirim ke semua Admin
  static Future<void> notifyAdmins(String title, String message, String type) async {
    try {
      final client = Supabase.instance.client;
      
      // Ambil seluruh user dengan role 'admin'
      final admins = await client.from('users').select('id').eq('role', 'admin');
      
      if ((admins as List).isEmpty) return;

      for (var admin in admins) {
        await addNotification(title, message, type, userId: admin['id']);
      }
    } catch (e) {
      Get.log('Error notifying admins: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Load notifikasi dari database saat controller di-init
    loadNotifications();
  }

  @override
  void onReady() {
    super.onReady();
    // Cleanup old notifications setelah data loaded
    _cleanupOldNotifications();
  }

  void _cleanupOldNotifications() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      String? userId;
      if (Get.isRegistered<AuthController>()) {
        userId = Get.find<AuthController>().currentUser?.id;
      }
      
      if (userId == null) return;

      // Hapus notifikasi yang sudah dibaca dan usianya lebih dari 30 hari dari DB
      await supabase.from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('is_read', true)
          .lt('created_at', thirtyDaysAgo.toIso8601String());

      // Reload dari database untuk sync
      await loadNotifications();
    } catch (e) {
      Get.log('Error cleaning up notifications: $e');
    }
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      
      String? userId;
      if (Get.isRegistered<AuthController>()) {
        userId = Get.find<AuthController>().currentUser?.id;
      }
      
      if (userId == null) {
        isLoading.value = false;
        return;
      }

      // SELALU load dari database, bukan dari static variable
      final data = await supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      notifications.assignAll(
        (data as List).map((e) => NotificationItem.fromJson(e)).toList(),
      );
    } catch (e) {
      ToastHelper.showError('Gagal memuat notifikasi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      // Update di database terlebih dahulu
      await supabase
          .from('notifications')
          .update({
            'is_read': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      // Update local state untuk UI responsiveness
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
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
    } catch (e) {
      Get.log('Error marking as read: $e');
      ToastHelper.showError('Gagal menandai notifikasi');
    }
  }

  Future<void> removeNotification(String id) async {
    try {
      // Hapus dari database
      await supabase.from('notifications').delete().eq('id', id);
      
      // Hapus dari state lokal
      notifications.removeWhere((n) => n.id == id);
    } catch (e) {
      ToastHelper.showError('Gagal menghapus notifikasi: $e');
    }
  }

  void handleNotificationTap(NotificationItem notif) {
    // Hanya tandai sebagai sudah dibaca (warna putih) saat diklik, tanpa berpindah halaman
    markAsRead(notif.id);
  }
}
