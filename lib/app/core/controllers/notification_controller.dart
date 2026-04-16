import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../services/supabase_service.dart';

class NotificationController extends GetxController {
  final _supabaseService = SupabaseService();
  final _authController = Get.find<AuthController>();

  final hasTagihanNotification = false.obs;
  final hasInfoNotification = false.obs;

  // Track last seen IDs instead of timestamps
  final RxnString lastSeenPengumumanId = RxnString();
  final RxnString lastSeenPeraturanId = RxnString();
  final RxnString lastSeenTagihanId = RxnString();

  @override
  void onInit() {
    super.onInit();
    print('=== NotificationController initialized ===');
    loadLastSeenIds();
    checkNotifications();
  }

  Future<void> loadLastSeenIds() async {
    final userId = _authController.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _supabaseService.supabase
          .from('user_notification_status')
          .select('last_seen_tagihan, last_seen_info')
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        // Store as ID for simpler comparison
        lastSeenTagihanId.value = data['last_seen_tagihan']?.toString();
        lastSeenPengumumanId.value = data['last_seen_info']?.toString();
      }
    } catch (e) {
      print('Error loading last seen IDs: $e');
    }
  }

  Future<void> checkNotifications() async {
    await checkTagihanNotification();
    await checkInfoNotification();
  }

  Future<void> checkTagihanNotification() async {
    final userId = _authController.currentUser?.id;
    if (userId == null) return;

    try {
      // Get penghuni data to get kost_id
      final penghuniData = await _supabaseService.getPenghuniByUserId(userId);
      if (penghuniData == null) return;

      final penghuniId = penghuniData['id']?.toString();
      if (penghuniId == null) return;

      // Check if there are any unpaid tagihan
      final tagihan = await _supabaseService.supabase
          .from('tagihan')
          .select('id')
          .eq('penghuni_id', penghuniId)
          .eq('status', 'pending')
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (tagihan != null) {
        final tagihanId = tagihan['id']?.toString();
        // Show notification if there's a tagihan and it's different from last seen
        if (tagihanId != null && tagihanId != lastSeenTagihanId.value) {
          hasTagihanNotification.value = true;
          return;
        }
      }

      hasTagihanNotification.value = false;
    } catch (e) {
      print('Error checking tagihan notification: $e');
    }
  }

  Future<void> checkInfoNotification() async {
    final userId = _authController.currentUser?.id;
    print('=== Checking Info Notification ===');
    print('User ID: $userId');

    if (userId == null) {
      print('❌ User ID is null');
      return;
    }

    try {
      // Get penghuni data to get kost_id
      final penghuniData = await _supabaseService.getPenghuniByUserId(userId);
      if (penghuniData == null) {
        print('❌ Penghuni data not found');
        return;
      }

      final kostId = penghuniData['kost_id']?.toString();
      print('Kost ID: $kostId');

      if (kostId == null) {
        print('❌ Kost ID is null');
        return;
      }

      // Check for new pengumuman (uses 'tanggal' column)
      final pengumumanList = await _supabaseService.supabase
          .from('pengumuman')
          .select('id, tanggal')
          .eq('kost_id', kostId)
          .order('tanggal', ascending: false)
          .limit(1);

      print('Latest pengumuman: $pengumumanList');

      // If there's any pengumuman and it's different from last seen, show notification
      if (pengumumanList.isNotEmpty) {
        final latestId = pengumumanList.first['id']?.toString();
        if (latestId != null && latestId != lastSeenPengumumanId.value) {
          hasInfoNotification.value = true;
          print('✅ Info notification SET TO TRUE (new pengumuman)');
          return;
        }
      }

      // Check for new peraturan (uses 'created_at' column)
      final peraturanList = await _supabaseService.supabase
          .from('peraturan')
          .select('id, created_at')
          .eq('kost_id', kostId)
          .order('created_at', ascending: false)
          .limit(1);

      print('Latest peraturan: $peraturanList');

      if (peraturanList.isNotEmpty) {
        final latestId = peraturanList.first['id']?.toString();
        if (latestId != null && latestId != lastSeenPeraturanId.value) {
          hasInfoNotification.value = true;
          print('✅ Info notification SET TO TRUE (new peraturan)');
          return;
        }
      }

      hasInfoNotification.value = false;
      print('❌ Info notification SET TO FALSE');
    } catch (e) {
      print('Error checking info notification: $e');
      hasInfoNotification.value = false;
    }
  }

  Future<void> markTagihanAsSeen() async {
    final userId = _authController.currentUser?.id;
    if (userId == null) return;

    try {
      // Get latest tagihan ID
      final penghuniData = await _supabaseService.getPenghuniByUserId(userId);
      if (penghuniData == null) return;

      final penghuniId = penghuniData['id']?.toString();
      if (penghuniId == null) return;

      final tagihan = await _supabaseService.supabase
          .from('tagihan')
          .select('id')
          .eq('penghuni_id', penghuniId)
          .eq('status', 'pending')
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      if (tagihan != null) {
        final tagihanId = tagihan['id']?.toString();
        lastSeenTagihanId.value = tagihanId;
        hasTagihanNotification.value = false;

        await _supabaseService.supabase.from('user_notification_status').upsert(
          {'user_id': userId, 'last_seen_tagihan': tagihanId},
        );
      }
    } catch (e) {
      print('Error marking tagihan as seen: $e');
    }
  }

  Future<void> markInfoAsSeen() async {
    final userId = _authController.currentUser?.id;
    if (userId == null) return;

    try {
      // Get latest pengumuman and peraturan IDs
      final penghuniData = await _supabaseService.getPenghuniByUserId(userId);
      if (penghuniData == null) return;

      final kostId = penghuniData['kost_id']?.toString();
      if (kostId == null) return;

      final pengumumanList = await _supabaseService.supabase
          .from('pengumuman')
          .select('id, tanggal')
          .eq('kost_id', kostId)
          .order('tanggal', ascending: false)
          .limit(1);

      if (pengumumanList.isNotEmpty) {
        final latestId = pengumumanList.first['id']?.toString();
        lastSeenPengumumanId.value = latestId;
      }

      final peraturanList = await _supabaseService.supabase
          .from('peraturan')
          .select('id, created_at')
          .eq('kost_id', kostId)
          .order('created_at', ascending: false)
          .limit(1);

      if (peraturanList.isNotEmpty) {
        final latestId = peraturanList.first['id']?.toString();
        lastSeenPeraturanId.value = latestId;
      }

      hasInfoNotification.value = false;

      // Store the latest pengumuman ID as last_seen_info
      await _supabaseService.supabase.from('user_notification_status').upsert({
        'user_id': userId,
        'last_seen_info':
            lastSeenPengumumanId.value ?? lastSeenPeraturanId.value,
      });
    } catch (e) {
      print('Error marking info as seen: $e');
    }
  }
}
