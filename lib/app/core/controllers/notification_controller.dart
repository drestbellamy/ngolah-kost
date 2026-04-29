import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../repositories/penghuni_repository.dart';
import '../../../repositories/repository_factory.dart';
import '../../../services/supabase_service.dart';

class NotificationController extends GetxController {
  final PenghuniRepository _penghuniRepo;
  final _authController = Get.find<AuthController>();

  NotificationController({PenghuniRepository? penghuniRepository})
    : _penghuniRepo =
          penghuniRepository ?? RepositoryFactory.instance.penghuniRepository;

  final hasTagihanNotification = false.obs;
  final hasInfoNotification = false.obs;
  
  // Counter for notification badges
  final infoNotificationCount = 0.obs;

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
      // TODO: Move to repository when notification repository is created
      final data = await SupabaseService().supabase
          .from('user_notification_status')
          .select('last_seen_tagihan, last_seen_pengumuman, last_seen_peraturan')
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        // Store as ID for simpler comparison
        lastSeenTagihanId.value = data['last_seen_tagihan']?.toString();
        lastSeenPengumumanId.value = data['last_seen_pengumuman']?.toString();
        lastSeenPeraturanId.value = data['last_seen_peraturan']?.toString();
        
        print('=== Loaded Last Seen IDs ===');
        print('Pengumuman: ${lastSeenPengumumanId.value}');
        print('Peraturan: ${lastSeenPeraturanId.value}');
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
      final penghuniData = await _penghuniRepo.getPenghuniByUserId(userId);
      if (penghuniData == null) return;

      final penghuniId = penghuniData['id']?.toString();
      if (penghuniId == null) return;

      // TODO: Move to TagihanRepository when method is available
      // Check if there are any unpaid tagihan
      final tagihan = await SupabaseService().supabase
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
      final penghuniData = await _penghuniRepo.getPenghuniByUserId(userId);
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

      int newCount = 0;

      // TODO: Move to PengumumanRepository and PeraturanRepository when methods are available
      // Check for new pengumuman (uses 'tanggal' column)
      final pengumumanList = await SupabaseService().supabase
          .from('pengumuman')
          .select('id, tanggal')
          .eq('kost_id', kostId)
          .order('tanggal', ascending: false);

      print('All pengumuman: $pengumumanList');

      // Count new pengumuman
      if (pengumumanList.isNotEmpty) {
        final lastSeenId = lastSeenPengumumanId.value;
        
        if (lastSeenId == null) {
          // If never seen before, count all
          newCount += pengumumanList.length;
        } else {
          // Count until we find the last seen ID
          for (var item in pengumumanList) {
            final itemId = item['id']?.toString();
            if (itemId == lastSeenId) break;
            newCount++;
          }
        }
      }

      // Check for new peraturan (uses 'created_at' column)
      final peraturanList = await SupabaseService().supabase
          .from('peraturan')
          .select('id, created_at')
          .eq('kost_id', kostId)
          .order('created_at', ascending: false);

      print('All peraturan: $peraturanList');

      // Count new peraturan
      if (peraturanList.isNotEmpty) {
        final lastSeenId = lastSeenPeraturanId.value;
        
        if (lastSeenId == null) {
          // If never seen before, count all
          newCount += peraturanList.length;
        } else {
          // Count until we find the last seen ID
          for (var item in peraturanList) {
            final itemId = item['id']?.toString();
            if (itemId == lastSeenId) break;
            newCount++;
          }
        }
      }

      infoNotificationCount.value = newCount;
      hasInfoNotification.value = newCount > 0;
      
      print('✅ Info notification count: $newCount');
      print('✅ Has info notification: ${hasInfoNotification.value}');
    } catch (e) {
      print('Error checking info notification: $e');
      hasInfoNotification.value = false;
      infoNotificationCount.value = 0;
    }
  }

  Future<void> markTagihanAsSeen() async {
    final userId = _authController.currentUser?.id;
    if (userId == null) return;

    try {
      // Get latest tagihan ID
      final penghuniData = await _penghuniRepo.getPenghuniByUserId(userId);
      if (penghuniData == null) return;

      final penghuniId = penghuniData['id']?.toString();
      if (penghuniId == null) return;

      // TODO: Move to TagihanRepository when method is available
      final tagihan = await SupabaseService().supabase
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

        // TODO: Move to notification repository when created
        await SupabaseService().supabase
            .from('user_notification_status')
            .upsert({'user_id': userId, 'last_seen_tagihan': tagihanId});
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
      final penghuniData = await _penghuniRepo.getPenghuniByUserId(userId);
      if (penghuniData == null) return;

      final kostId = penghuniData['kost_id']?.toString();
      if (kostId == null) return;

      // TODO: Move to PengumumanRepository and PeraturanRepository when methods are available
      final pengumumanList = await SupabaseService().supabase
          .from('pengumuman')
          .select('id, tanggal')
          .eq('kost_id', kostId)
          .order('tanggal', ascending: false)
          .limit(1);

      String? latestPengumumanId;
      if (pengumumanList.isNotEmpty) {
        latestPengumumanId = pengumumanList.first['id']?.toString();
        lastSeenPengumumanId.value = latestPengumumanId;
      }

      final peraturanList = await SupabaseService().supabase
          .from('peraturan')
          .select('id, created_at')
          .eq('kost_id', kostId)
          .order('created_at', ascending: false)
          .limit(1);

      String? latestPeraturanId;
      if (peraturanList.isNotEmpty) {
        latestPeraturanId = peraturanList.first['id']?.toString();
        lastSeenPeraturanId.value = latestPeraturanId;
      }

      hasInfoNotification.value = false;
      infoNotificationCount.value = 0;

      print('=== Marking Info as Seen ===');
      print('Latest Pengumuman ID: $latestPengumumanId');
      print('Latest Peraturan ID: $latestPeraturanId');

      // TODO: Move to notification repository when created
      // Store BOTH pengumuman and peraturan IDs separately
      await SupabaseService().supabase.from('user_notification_status').upsert({
        'user_id': userId,
        'last_seen_pengumuman': latestPengumumanId,
        'last_seen_peraturan': latestPeraturanId,
      });
      
      print('✅ Successfully saved to database');
    } catch (e) {
      print('❌ Error marking info as seen: $e');
    }
  }
}
