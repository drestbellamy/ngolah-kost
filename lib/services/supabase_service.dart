import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/modules/kost/models/kost_model.dart';
import '../app/modules/login/models/login_user_model.dart';

class SupabaseService {
  static const String _metodePembayaranQrisBucket = 'metode-pembayaran-qris';
  static const String _buktiPembayaranBucket = 'bukti-pembayaran';

  final supabase = Supabase.instance.client;

  // CREATE USER PENGHUNI (secure via RPC)
  Future<String> createPenghuniUserSecure({
    required String nama,
    required String noTlpn,
    required String username,
    required String password,
    String? kostPrefix,
  }) async {
    final baseParams = {
      'p_nama': nama,
      'p_no_tlpn': noTlpn,
      'p_username': username,
      'p_password': password,
      'p_role': 'user',
    };

    dynamic response;
    try {
      final paramsWithPrefix = Map<String, dynamic>.from(baseParams);
      if (kostPrefix != null && kostPrefix.trim().isNotEmpty) {
        paramsWithPrefix['p_prefix'] = kostPrefix.trim().toUpperCase();
      }

      response = await supabase.rpc(
        'create_user_secure',
        params: paramsWithPrefix,
      );
    } on PostgrestException catch (e) {
      final message = e.message.toLowerCase();

      // Backward compatibility if DB function still uses old signature.
      if (message.contains('p_prefix') || message.contains('function')) {
        response = await supabase.rpc('create_user_secure', params: baseParams);
      } else {
        rethrow;
      }
    }

    if (response is List && response.isNotEmpty) {
      final row = Map<String, dynamic>.from(response.first as Map);
      return (row['id'] ?? '').toString();
    }

    if (response is Map<String, dynamic>) {
      return (response['id'] ?? '').toString();
    }

    throw Exception('Gagal membuat user penghuni');
  }

  // LOGIN
  Future<LoginUserModel?> login(String username, String password) async {
    final response = await supabase.rpc(
      'login_user_secure',
      params: {'p_username': username, 'p_password': password},
    );

    if (response is! List || response.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(response.first as Map);
    return LoginUserModel.fromMap(row);
  }

  // GET USERS
  Future<List<dynamic>> getUsers() async {
    return await supabase.from('users').select();
  }

  // GET KOST
  Future<List<KostModel>> getKostList() async {
    final List<dynamic> response = await supabase
        .from('kost')
        .select('id, nama_kost, alamat, total_kamar, created_at')
        .order('created_at', ascending: false);

    return response
        .map((item) => KostModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  // GET METODE PEMBAYARAN
  Future<List<Map<String, dynamic>>> getMetodePembayaranList() async {
    final attempts = <({String select, bool orderByCreatedAt})>[
      (
        select:
            'id, kost_id, tipe, nama, no_rek, atas_nama, qr_image, is_active, created_at, kost:kost_id(id, nama_kost)',
        orderByCreatedAt: true,
      ),
      (
        select:
            'id, kost_id, tipe, nama, no_rek, atas_nama, qr_image, is_active, created_at',
        orderByCreatedAt: true,
      ),
      (select: '*', orderByCreatedAt: true),
      (select: '*', orderByCreatedAt: false),
    ];

    for (final attempt in attempts) {
      try {
        dynamic query = supabase
            .from('metode_pembayaran')
            .select(attempt.select);

        if (attempt.orderByCreatedAt) {
          query = query.order('created_at', ascending: false);
        }

        final raw = await query;
        if (raw is! List) return [];

        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      } catch (_) {
        // Try next shape in case schema differs between environments.
      }
    }

    throw Exception('Gagal memuat metode pembayaran');
  }

  // INSERT METODE PEMBAYARAN
  Future<void> createMetodePembayaran({
    required String kostId,
    required String tipe,
    required String nama,
    String? noRek,
    String? atasNama,
    String? qrImage,
    bool isActive = true,
  }) async {
    if (kostId.trim().isEmpty) {
      throw Exception('Kost wajib dipilih');
    }

    final normalizedTipe = _normalizeMetodePembayaranTipe(tipe);
    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama metode pembayaran wajib diisi');
    }

    final payload = <String, dynamic>{
      'kost_id': kostId.trim(),
      'tipe': normalizedTipe,
      'nama': cleanNama,
      'no_rek': (noRek ?? '').trim().isEmpty ? '-' : noRek!.trim(),
      'atas_nama': (atasNama ?? '').trim().isEmpty ? null : atasNama!.trim(),
      'qr_image': (qrImage ?? '').trim().isEmpty ? null : qrImage!.trim(),
      'is_active': isActive,
    };

    try {
      await supabase.from('metode_pembayaran').insert(payload);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // UPDATE METODE PEMBAYARAN
  Future<void> updateMetodePembayaran({
    required String id,
    required String kostId,
    required String tipe,
    required String nama,
    String? noRek,
    String? atasNama,
    String? qrImage,
    bool? isActive,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('ID metode pembayaran tidak valid');
    }
    if (kostId.trim().isEmpty) {
      throw Exception('Kost wajib dipilih');
    }

    final normalizedTipe = _normalizeMetodePembayaranTipe(tipe);
    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama metode pembayaran wajib diisi');
    }

    final payload = <String, dynamic>{
      'kost_id': kostId.trim(),
      'tipe': normalizedTipe,
      'nama': cleanNama,
      'no_rek': (noRek ?? '').trim().isEmpty ? '-' : noRek!.trim(),
      'atas_nama': (atasNama ?? '').trim().isEmpty ? null : atasNama!.trim(),
      'qr_image': (qrImage ?? '').trim().isEmpty ? null : qrImage!.trim(),
    };

    if (isActive != null) {
      payload['is_active'] = isActive;
    }

    try {
      await supabase.from('metode_pembayaran').update(payload).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // DELETE METODE PEMBAYARAN
  Future<void> deleteMetodePembayaran(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID metode pembayaran tidak valid');
    }

    try {
      await supabase.from('metode_pembayaran').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // UPDATE STATUS METODE PEMBAYARAN
  Future<void> updateMetodePembayaranStatus({
    required String id,
    required bool isActive,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('ID metode pembayaran tidak valid');
    }

    try {
      await supabase
          .from('metode_pembayaran')
          .update({'is_active': isActive})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // UPLOAD QRIS IMAGE TO STORAGE
  Future<String> uploadMetodePembayaranQrisImage({
    required Uint8List imageBytes,
    required String fileExt,
    required String kostId,
    required String namaMetode,
  }) async {
    if (imageBytes.isEmpty) {
      throw Exception('File QRIS tidak valid');
    }

    final extension = _normalizeFileExtension(fileExt);
    final safeKostId = kostId.trim().isEmpty ? 'umum' : kostId.trim();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${_slugify(namaMetode)}.$extension';
    final objectPath = '$safeKostId/$fileName';

    try {
      await supabase.storage
          .from(_metodePembayaranQrisBucket)
          .uploadBinary(
            objectPath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: false,
              cacheControl: '3600',
              contentType: _contentTypeFromFileExtension(extension),
            ),
          );

      return supabase.storage
          .from(_metodePembayaranQrisBucket)
          .getPublicUrl(objectPath);
    } on StorageException catch (e) {
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // UPLOAD BUKTI PEMBAYARAN TO STORAGE
  Future<String> uploadBuktiPembayaran({
    required Uint8List imageBytes,
    required String fileExt,
    required String penghuniId,
  }) async {
    if (imageBytes.isEmpty) {
      throw Exception('File bukti pembayaran tidak valid');
    }

    final extension = _normalizeFileExtension(fileExt);
    final fileName =
        'bukti_${penghuniId}_${DateTime.now().millisecondsSinceEpoch}.$extension';

    try {
      await supabase.storage
          .from(_buktiPembayaranBucket)
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: FileOptions(
              upsert: false,
              cacheControl: '3600',
              contentType: _contentTypeFromFileExtension(extension),
            ),
          );

      return supabase.storage
          .from(_buktiPembayaranBucket)
          .getPublicUrl(fileName);
    } on StorageException catch (e) {
      throw Exception(e.message);
    }
  }

  // CREATE PEMBAYARAN WITH BUKTI (Direct insert)
  Future<void> createPembayaran({
    required String penghuniId,
    required String tagihanId,
    required double totalJumlah,
    required String metodeId,
    required String buktiPembayaranUrl,
  }) async {
    try {
      print('=== createPembayaran START ===');
      print('Tagihan ID: $tagihanId');
      print('Penghuni ID: $penghuniId');
      print('Jumlah: $totalJumlah');
      print('Metode ID: $metodeId');
      print('Bukti URL: $buktiPembayaranUrl');

      // Direct insert to pembayaran table
      final insertResult = await supabase.from('pembayaran').insert({
        'penghuni_id': penghuniId,
        'tagihan_id': tagihanId,
        'jumlah': totalJumlah.toInt(),
        'metode_id': metodeId,
        'bukti_pembayaran': buktiPembayaranUrl,
        'status': 'pending',
        'tanggal': DateTime.now().toIso8601String(),
      }).select();

      print('✅ Direct insert pembayaran success');
      print('Insert result: $insertResult');

      // Update status tagihan menjadi menunggu_verifikasi
      final updateResult = await supabase
          .from('tagihan')
          .update({'status': 'menunggu_verifikasi'})
          .eq('id', tagihanId)
          .select();

      print('✅ Status tagihan updated to menunggu_verifikasi');
      print('Update result: $updateResult');

      // Verify the data
      final verifyPembayaran = await supabase
          .from('pembayaran')
          .select('*')
          .eq('tagihan_id', tagihanId)
          .order('created_at', ascending: false)
          .limit(1);
      print('🔍 Verify pembayaran: $verifyPembayaran');

      final verifyTagihan = await supabase
          .from('tagihan')
          .select('id, status')
          .eq('id', tagihanId)
          .single();
      print('🔍 Verify tagihan: $verifyTagihan');

      print('=== createPembayaran END ===');
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.message}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
      throw Exception(_formatPostgrestError(e));
    } catch (e) {
      print('❌ Error createPembayaran: $e');
      throw Exception('Gagal membuat pembayaran: ${e.toString()}');
    }
  }

  // VERIFIKASI PEMBAYARAN (Terima)
  Future<void> verifikasiPembayaran({
    required String tagihanId,
    required String pembayaranId,
  }) async {
    try {
      // Get data pembayaran dan tagihan untuk insert ke pemasukan
      final pembayaranData = await supabase
          .from('pembayaran')
          .select('''
            id, 
            penghuni_id, 
            jumlah, 
            tanggal,
            tagihan:tagihan_id(
              bulan,
              tahun
            )
          ''')
          .eq('id', pembayaranId)
          .single();

      // Update status tagihan menjadi lunas
      await supabase
          .from('tagihan')
          .update({'status': 'lunas'})
          .eq('id', tagihanId);

      // Update status pembayaran menjadi verified
      await supabase
          .from('pembayaran')
          .update({'status': 'verified'})
          .eq('id', pembayaranId);

      // Insert ke tabel pemasukan
      final tagihan = pembayaranData['tagihan'];
      final bulan = tagihan is Map ? tagihan['bulan'] : null;
      final tahun = tagihan is Map ? tagihan['tahun'] : null;

      String periodeBulan = '';
      if (bulan != null && tahun != null) {
        const namaBulan = [
          '',
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];
        final bulanInt = bulan is int
            ? bulan
            : int.tryParse(bulan.toString()) ?? 0;
        final tahunInt = tahun is int
            ? tahun
            : int.tryParse(tahun.toString()) ?? 0;

        if (bulanInt >= 1 && bulanInt <= 12 && tahunInt > 0) {
          periodeBulan = '${namaBulan[bulanInt]} $tahunInt';
        }
      }

      await supabase.from('pemasukan').insert({
        'penghuni_id': pembayaranData['penghuni_id'],
        'jumlah': pembayaranData['jumlah'],
        'tanggal': pembayaranData['tanggal'],
        'keterangan': 'Pembayaran kost periode $periodeBulan',
        'pembayaran_id': pembayaranId, // Referensi ke pembayaran
      });

      print('✅ Pembayaran verified dan data pemasukan berhasil dibuat');
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    } catch (e) {
      throw Exception('Gagal memverifikasi pembayaran: ${e.toString()}');
    }
  }

  // TOLAK PEMBAYARAN
  Future<void> tolakPembayaran({
    required String tagihanId,
    required String pembayaranId,
  }) async {
    try {
      // Update status tagihan kembali ke belum_dibayar
      await supabase
          .from('tagihan')
          .update({'status': 'belum_dibayar'})
          .eq('id', tagihanId);

      // Update status pembayaran menjadi rejected
      await supabase
          .from('pembayaran')
          .update({'status': 'rejected'})
          .eq('id', pembayaranId);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    } catch (e) {
      throw Exception('Gagal menolak pembayaran: ${e.toString()}');
    }
  }

  // INSERT KOST
  Future<void> createKost({
    required String namaKost,
    required String alamat,
    required int totalKamar,
    double? latitude,
    double? longitude,
  }) async {
    await supabase.from('kost').insert({
      'nama_kost': namaKost,
      'alamat': alamat,
      'total_kamar': totalKamar,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
  }

  // UPDATE KOST
  Future<void> updateKost({
    required String id,
    required String namaKost,
    required String alamat,
    required int totalKamar,
    double? latitude,
    double? longitude,
  }) async {
    await supabase
        .from('kost')
        .update({
          'nama_kost': namaKost,
          'alamat': alamat,
          'total_kamar': totalKamar,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        })
        .eq('id', id);
  }

  // DELETE KOST
  Future<void> deleteKost(String id) async {
    await supabase.from('kost').delete().eq('id', id);
  }

  // GET KAMAR BY KOST
  Future<List<Map<String, dynamic>>> getKamarByKostId(String kostId) async {
    final List<dynamic> response = await supabase
        .from('kamar')
        .select('id, kost_id, no_kamar, harga, kapasitas, status, created_at')
        .eq('kost_id', kostId)
        .order('created_at', ascending: false);

    return response.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // INSERT KAMAR
  Future<void> createKamar({
    required String kostId,
    required String noKamar,
    required int harga,
    required int kapasitas,
    String status = 'kosong',
  }) async {
    await supabase.from('kamar').insert({
      'kost_id': kostId,
      'no_kamar': noKamar,
      'harga': harga,
      'kapasitas': kapasitas,
      'status': status,
    });
  }

  // UPDATE KAMAR
  Future<void> updateKamar({
    required String id,
    required String noKamar,
    required int harga,
    required int kapasitas,
    required String status,
  }) async {
    await supabase
        .from('kamar')
        .update({
          'no_kamar': noKamar,
          'harga': harga,
          'kapasitas': kapasitas,
          'status': status,
        })
        .eq('id', id);
  }

  // DELETE KAMAR
  Future<void> deleteKamar(String id) async {
    await supabase.from('kamar').delete().eq('id', id);
  }

  // UPDATE STATUS KAMAR
  Future<void> updateKamarStatus({
    required String id,
    required String status,
  }) async {
    await supabase.from('kamar').update({'status': status}).eq('id', id);
  }

  // INSERT PENGHUNI
  Future<String> createPenghuni({
    String? userId,
    required String kamarId,
    required int durasiKontrak,
    int? sistemPembayaranBulan,
    required DateTime tanggalMasuk,
    required DateTime tanggalKeluar,
    String status = 'aktif',
  }) async {
    final payload = <String, dynamic>{
      'user_id': userId,
      'kamar_id': kamarId,
      'durasi_kontrak': durasiKontrak,
      'tanggal_masuk': tanggalMasuk.toIso8601String().split('T').first,
      'tanggal_keluar': tanggalKeluar.toIso8601String().split('T').first,
      'status': status,
    };

    if (sistemPembayaranBulan != null && sistemPembayaranBulan > 0) {
      payload['sistem_pembayaran_bulan'] = sistemPembayaranBulan;
    }

    dynamic inserted;
    try {
      inserted = await supabase
          .from('penghuni')
          .insert(payload)
          .select('id')
          .single();
    } on PostgrestException catch (e) {
      final message = '${e.message} ${e.details}'.toLowerCase();

      // Backward compatibility for DB schema that does not have
      // sistem_pembayaran_bulan yet.
      if (payload.containsKey('sistem_pembayaran_bulan') &&
          message.contains('sistem_pembayaran_bulan')) {
        payload.remove('sistem_pembayaran_bulan');
        inserted = await supabase
            .from('penghuni')
            .insert(payload)
            .select('id')
            .single();
      } else {
        rethrow;
      }
    }

    if (inserted is Map<String, dynamic>) {
      return (inserted['id'] ?? '').toString();
    }

    if (inserted is Map) {
      return (inserted['id'] ?? '').toString();
    }

    throw Exception('Gagal membuat data penghuni');
  }

  // GET PENGHUNI BY KAMAR
  Future<List<Map<String, dynamic>>> getPenghuniByKamarId(
    String kamarId, {
    bool onlyActive = false,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_penghuni_by_kamar_secure',
        params: {'p_kamar_id': kamarId},
      );

      if (response is List) {
        var rows = response
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        if (onlyActive) {
          rows = rows.where((row) {
            final status = (row['status']?.toString() ?? '').toLowerCase();
            return status == 'aktif';
          }).toList();
        }
        return await _attachSistemPembayaranBulan(rows, kamarId);
      }
    } catch (_) {
      // Fallback to direct join query if RPC is not available yet.
    }

    dynamic fallbackQuery = supabase
        .from('penghuni')
        .select(
          'id, user_id, kamar_id, durasi_kontrak, sistem_pembayaran_bulan, tanggal_masuk, tanggal_keluar, status, created_at, users:user_id(id, nama, no_tlpn, username)',
        )
        .eq('kamar_id', kamarId);

    if (onlyActive) {
      fallbackQuery = fallbackQuery.eq('status', 'aktif');
    }

    final List<dynamic> fallback = await fallbackQuery.order(
      'created_at',
      ascending: false,
    );

    return fallback.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // GET SINGLE PENGHUNI DETAIL (enriched for detail page refresh)
  Future<Map<String, dynamic>?> getPenghuniDetailById(String penghuniId) async {
    if (penghuniId.trim().isEmpty) return null;

    try {
      final raw = await supabase
          .from('penghuni')
          .select(
            'id, durasi_kontrak, sistem_pembayaran_bulan, tanggal_masuk, tanggal_keluar, status, users:user_id(nama, no_tlpn), kamar:kamar_id(no_kamar, harga, kost:kost_id(nama_kost))',
          )
          .eq('id', penghuniId)
          .maybeSingle();

      final map = _asStringMap(raw);
      if (map != null && map.isNotEmpty) {
        final user = _asStringMap(map['users']) ?? <String, dynamic>{};
        final kamar = _asStringMap(map['kamar']) ?? <String, dynamic>{};
        final kost = _asStringMap(kamar['kost']) ?? <String, dynamic>{};

        return {
          'id': map['id']?.toString() ?? penghuniId,
          'nama': (user['nama'] ?? '').toString(),
          'no_tlpn': (user['no_tlpn'] ?? '').toString(),
          'durasi_kontrak': map['durasi_kontrak'],
          'sistem_pembayaran_bulan': map['sistem_pembayaran_bulan'],
          'tanggal_masuk': map['tanggal_masuk'],
          'tanggal_keluar': map['tanggal_keluar'],
          'status': map['status'],
          'nomor_kamar': (kamar['no_kamar'] ?? '').toString(),
          'harga': kamar['harga'],
          'nama_kost': (kost['nama_kost'] ?? '').toString(),
        };
      }
    } catch (_) {
      // Fall back to scan-based approach below.
    }

    // Fallback that reuses existing RLS-safe penghuni reader.
    final kosts = await getKostList();
    for (final kost in kosts) {
      final kamarList = await getKamarByKostId(kost.id);
      for (final kamar in kamarList) {
        final kamarId = kamar['id']?.toString() ?? '';
        if (kamarId.isEmpty) continue;

        final rows = await getPenghuniByKamarId(kamarId);
        for (final row in rows) {
          final id = row['id']?.toString() ?? '';
          if (id != penghuniId) continue;

          final user = _asStringMap(row['users']) ?? <String, dynamic>{};
          return {
            'id': id,
            'nama': (user['nama'] ?? row['nama'] ?? '').toString(),
            'no_tlpn': (user['no_tlpn'] ?? row['no_tlpn'] ?? '').toString(),
            'durasi_kontrak': row['durasi_kontrak'],
            'sistem_pembayaran_bulan': row['sistem_pembayaran_bulan'],
            'tanggal_masuk': row['tanggal_masuk'],
            'tanggal_keluar': row['tanggal_keluar'],
            'status': row['status'],
            'nomor_kamar': (kamar['no_kamar'] ?? '').toString(),
            'harga': kamar['harga'],
            'nama_kost': kost.name,
          };
        }
      }
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> _attachSistemPembayaranBulan(
    List<Map<String, dynamic>> rows,
    String kamarId,
  ) async {
    if (rows.isEmpty) return rows;

    final hasColumnInRpc = rows.any(
      (row) => row.containsKey('sistem_pembayaran_bulan'),
    );
    if (hasColumnInRpc) return rows;

    try {
      final raw = await supabase
          .from('penghuni')
          .select('id, sistem_pembayaran_bulan')
          .eq('kamar_id', kamarId);

      if (raw is! List) return rows;

      final byId = <String, int>{};
      for (final item in raw) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = map['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        final value = map['sistem_pembayaran_bulan'];
        if (value is int) {
          byId[id] = value;
        } else {
          byId[id] = int.tryParse(value?.toString() ?? '') ?? 0;
        }
      }

      return rows.map((row) {
        final id = row['id']?.toString() ?? '';
        if (id.isNotEmpty && byId.containsKey(id)) {
          row['sistem_pembayaran_bulan'] = byId[id];
        }
        return row;
      }).toList();
    } catch (_) {
      return rows;
    }
  }

  // GET PENGHUNI BY USER ID (for user profile)
  Future<Map<String, dynamic>?> getPenghuniByUserId(String userId) async {
    if (userId.trim().isEmpty) return null;

    try {
      print('Fetching penghuni data for userId: $userId'); // Debug

      // Get penghuni data with user info via RPC or direct query
      // Try using RPC first if available
      try {
        final rpcResult = await supabase.rpc(
          'get_user_profile_data',
          params: {'p_user_id': userId},
        );

        if (rpcResult != null && rpcResult is List && rpcResult.isNotEmpty) {
          final data = Map<String, dynamic>.from(rpcResult.first as Map);
          print('Profile data from RPC: $data'); // Debug

          // If kost_id is not in RPC result, fetch it separately
          if (!data.containsKey('kost_id') || data['kost_id'] == null) {
            print('kost_id not in RPC result, fetching separately...'); // Debug
            final penghuniId = data['id']?.toString() ?? '';
            if (penghuniId.isNotEmpty) {
              final penghuniRaw = await supabase
                  .from('penghuni')
                  .select('kamar_id')
                  .eq('id', penghuniId)
                  .maybeSingle();

              if (penghuniRaw != null) {
                final kamarId = penghuniRaw['kamar_id']?.toString() ?? '';
                if (kamarId.isNotEmpty) {
                  final kamarRaw = await supabase
                      .from('kamar')
                      .select('kost_id')
                      .eq('id', kamarId)
                      .maybeSingle();

                  if (kamarRaw != null) {
                    data['kost_id'] = kamarRaw['kost_id']?.toString() ?? '';
                    print(
                      'Added kost_id to RPC result: ${data['kost_id']}',
                    ); // Debug
                  }
                }
              }
            }
          }

          return data;
        }
      } catch (rpcError) {
        print('RPC not available, using fallback query: $rpcError');
      }

      // Fallback: Get penghuni with joined user data
      final raw = await supabase
          .from('penghuni')
          .select('''
            id, 
            user_id, 
            durasi_kontrak, 
            sistem_pembayaran_bulan, 
            tanggal_masuk, 
            tanggal_keluar, 
            status, 
            kamar_id,
            users!inner(nama, no_tlpn)
            ''')
          .eq('user_id', userId)
          .eq('status', 'aktif')
          .maybeSingle();

      final map = _asStringMap(raw);
      if (map == null || map.isEmpty) {
        print('No penghuni data found'); // Debug
        return null;
      }

      print('Penghuni data fetched: $map'); // Debug

      // Extract user data from joined result
      final userData = _asStringMap(map['users']);
      final nama = userData?['nama']?.toString() ?? '';
      final noTlpn = userData?['no_tlpn']?.toString() ?? '';

      print('User data from join: nama=$nama, no_tlpn=$noTlpn'); // Debug

      // Get kamar data
      final kamarId = map['kamar_id']?.toString() ?? '';
      final kamarRaw = await supabase
          .from('kamar')
          .select('no_kamar, harga, kost_id')
          .eq('id', kamarId)
          .maybeSingle();

      final kamar = _asStringMap(kamarRaw) ?? <String, dynamic>{};
      print('Kamar data fetched: $kamar'); // Debug

      // Get kost data
      final kostId = kamar['kost_id']?.toString() ?? '';
      final kostRaw = await supabase
          .from('kost')
          .select('nama_kost')
          .eq('id', kostId)
          .maybeSingle();

      final kost = _asStringMap(kostRaw) ?? <String, dynamic>{};
      print('Kost data fetched: $kost'); // Debug

      final result = {
        'id': map['id']?.toString() ?? '',
        'nama': nama,
        'no_tlpn': noTlpn,
        'durasi_kontrak': map['durasi_kontrak'],
        'sistem_pembayaran_bulan': map['sistem_pembayaran_bulan'],
        'tanggal_masuk': map['tanggal_masuk'],
        'tanggal_keluar': map['tanggal_keluar'],
        'status': map['status'],
        'nomor_kamar': (kamar['no_kamar'] ?? '').toString(),
        'harga': kamar['harga'],
        'kost_id': kostId, // Add kost_id to result
        'nama_kost': (kost['nama_kost'] ?? '').toString(),
      };

      print('Final result: $result'); // Debug
      return result;
    } catch (e) {
      print('Error getPenghuniByUserId: $e');
      rethrow;
    }
  }

  // GET PENGHUNI COUNT BY KAMAR
  Future<int> getPenghuniCountByKamarId(
    String kamarId, {
    bool onlyActive = true,
  }) async {
    dynamic query = supabase
        .from('penghuni')
        .select('id')
        .eq('kamar_id', kamarId);

    if (onlyActive) {
      query = query.eq('status', 'aktif');
    }

    final response = await query;

    if (response is List) {
      return response.length;
    }

    return 0;
  }

  // UPDATE KONTRAK PENGHUNI
  Future<void> updatePenghuniKontrak({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int sistemPembayaranBulan,
    String status = 'aktif',
  }) async {
    if (penghuniId.trim().isEmpty) {
      throw Exception('ID penghuni tidak valid');
    }
    if (durasiKontrakBulan <= 0) {
      throw Exception('Durasi kontrak harus lebih dari 0 bulan');
    }

    final tanggalKeluar = DateTime(
      tanggalMasuk.year,
      tanggalMasuk.month + durasiKontrakBulan,
      tanggalMasuk.day,
    );

    final normalizedSiklus = sistemPembayaranBulan <= 0
        ? 1
        : (sistemPembayaranBulan > durasiKontrakBulan
              ? durasiKontrakBulan
              : sistemPembayaranBulan);

    final payload = <String, dynamic>{
      'tanggal_masuk': tanggalMasuk.toIso8601String().split('T').first,
      'tanggal_keluar': tanggalKeluar.toIso8601String().split('T').first,
      'durasi_kontrak': durasiKontrakBulan,
      'status': status,
      'sistem_pembayaran_bulan': normalizedSiklus,
    };

    try {
      await supabase.from('penghuni').update(payload).eq('id', penghuniId);
    } on PostgrestException catch (e) {
      final message = '${e.message} ${e.details}'.toLowerCase();

      // Backward compatibility if schema has not added sistem_pembayaran_bulan.
      if (message.contains('sistem_pembayaran_bulan')) {
        payload.remove('sistem_pembayaran_bulan');
        await supabase.from('penghuni').update(payload).eq('id', penghuniId);
      } else {
        rethrow;
      }
    }
  }

  // SINKRON TAGIHAN BERDASARKAN KONTRAK (idempotent)
  Future<void> sinkronTagihanKontrak({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int sistemPembayaranBulan,
    required int hargaBulanan,
  }) async {
    if (penghuniId.trim().isEmpty || durasiKontrakBulan <= 0) return;
    if (hargaBulanan <= 0) return;

    final siklus = sistemPembayaranBulan <= 0
        ? 1
        : (sistemPembayaranBulan > durasiKontrakBulan
              ? durasiKontrakBulan
              : sistemPembayaranBulan);

    final coveredByLunas = await _loadCoveredMonthlyKeysByLunasTagihan(
      penghuniId: penghuniId,
      tanggalMasuk: tanggalMasuk,
      durasiKontrakBulan: durasiKontrakBulan,
      hargaBulanan: hargaBulanan,
    );

    final payload = _buildTagihanPayloadByKontrak(
      penghuniId: penghuniId,
      tanggalMasuk: tanggalMasuk,
      durasiKontrakBulan: durasiKontrakBulan,
      siklusPembayaranBulan: siklus,
      hargaBulanan: hargaBulanan,
      excludedMonthlyKeys: coveredByLunas,
    );

    // Rebuild unpaid schedule from scratch so old periods don't linger in kelola tagihan.
    await supabase
        .from('tagihan')
        .delete()
        .eq('penghuni_id', penghuniId)
        .neq('status', 'lunas');

    if (payload.isEmpty) return;

    await supabase
        .from('tagihan')
        .upsert(
          payload,
          onConflict: 'penghuni_id,bulan,tahun',
          ignoreDuplicates: true,
        );
  }

  // AKHIRI KONTRAK PENGHUNI
  Future<void> akhiriKontrakPenghuni({required String penghuniId}) async {
    if (penghuniId.trim().isEmpty) {
      throw Exception('ID penghuni tidak valid');
    }

    final now = DateTime.now();
    final today = now.toIso8601String().split('T').first;

    final raw = await supabase
        .from('penghuni')
        .select('id, user_id, kamar_id')
        .eq('id', penghuniId)
        .maybeSingle();

    final row = _asStringMap(raw);

    final userId = row?['user_id']?.toString() ?? '';
    final kamarId = row?['kamar_id']?.toString() ?? '';

    final penghuniPayload = <String, dynamic>{
      'status': 'berakhir',
      'tanggal_keluar': today,
      'user_id': null,
    };

    try {
      await supabase
          .from('penghuni')
          .update(penghuniPayload)
          .eq('id', penghuniId);
    } on PostgrestException catch (e) {
      final message = '${e.message} ${e.details}'.toLowerCase();
      if (message.contains('user_id')) {
        penghuniPayload.remove('user_id');
        await supabase
            .from('penghuni')
            .update(penghuniPayload)
            .eq('id', penghuniId);
      } else {
        rethrow;
      }
    }

    final pending = await supabase
        .from('tagihan')
        .select('id, bulan, tahun, status')
        .eq('penghuni_id', penghuniId)
        .eq('status', 'belum_dibayar');

    if (pending is List) {
      for (final item in pending) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = map['id']?.toString() ?? '';
        if (id.isEmpty) continue;

        final bulan = _toInt(map['bulan']);
        final tahun = _toInt(map['tahun']);
        final isFuture =
            tahun > now.year || (tahun == now.year && bulan > now.month);

        if (isFuture) {
          await supabase.from('tagihan').delete().eq('id', id);
        }
      }
    }

    if (kamarId.isNotEmpty) {
      final activeCount = await getPenghuniCountByKamarId(
        kamarId,
        onlyActive: true,
      );

      final kamarRaw = await supabase
          .from('kamar')
          .select('kapasitas')
          .eq('id', kamarId)
          .maybeSingle();

      final kamarMap = _asStringMap(kamarRaw);
      final kapasitas = _toInt(kamarMap?['kapasitas']);

      await supabase
          .from('kamar')
          .update({
            'status': _kamarStatusByOccupancy(
              activeCount,
              kapasitas <= 0 ? 1 : kapasitas,
            ),
          })
          .eq('id', kamarId);
    }

    if (userId.isNotEmpty) {
      try {
        await deleteUserById(userId);
      } catch (_) {
        // Fallback: keep data inaccessible if hard delete is blocked by schema.
        await supabase
            .from('users')
            .update({'is_active': false})
            .eq('id', userId);
      }
    }
  }

  Future<void> deleteUserById(String userId) async {
    if (userId.trim().isEmpty) {
      throw Exception('ID user tidak valid');
    }

    try {
      try {
        await supabase.rpc('delete_user_by_id', params: {'p_user_id': userId});
        return;
      } catch (rpcError) {
        print(
          'RPC delete_user_by_id not available, trying direct delete: $rpcError',
        );
      }

      await supabase.from('users').delete().eq('id', userId);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // INSERT TAGIHAN OTOMATIS BERDASARKAN KONTRAK
  Future<void> createTagihanOtomatis({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int sistemPembayaranBulan,
    required int hargaBulanan,
  }) async {
    if (penghuniId.isEmpty || durasiKontrakBulan <= 0 || hargaBulanan <= 0) {
      return;
    }

    final siklus = sistemPembayaranBulan <= 0
        ? 1
        : (sistemPembayaranBulan > durasiKontrakBulan
              ? durasiKontrakBulan
              : sistemPembayaranBulan);
    final payload = _buildTagihanPayloadByKontrak(
      penghuniId: penghuniId,
      tanggalMasuk: tanggalMasuk,
      durasiKontrakBulan: durasiKontrakBulan,
      siklusPembayaranBulan: siklus,
      hargaBulanan: hargaBulanan,
    );

    if (payload.isEmpty) return;
    await supabase
        .from('tagihan')
        .upsert(
          payload,
          onConflict: 'penghuni_id,bulan,tahun',
          ignoreDuplicates: true,
        );
  }

  List<Map<String, dynamic>> _buildTagihanPayloadByKontrak({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int siklusPembayaranBulan,
    required int hargaBulanan,
    Set<String> excludedMonthlyKeys = const <String>{},
  }) {
    final payload = <Map<String, dynamic>>[];

    if (penghuniId.trim().isEmpty ||
        durasiKontrakBulan <= 0 ||
        siklusPembayaranBulan <= 0 ||
        hargaBulanan <= 0) {
      return payload;
    }

    var monthCursor = 0;
    while (monthCursor < durasiKontrakBulan) {
      final periode = DateTime(
        tanggalMasuk.year,
        tanggalMasuk.month + monthCursor,
        1,
      );
      final key = _billingMonthKey(periode.year, periode.month);

      if (excludedMonthlyKeys.contains(key)) {
        monthCursor += 1;
        continue;
      }

      var durasiTagihan = 0;
      var probe = monthCursor;
      while (probe < durasiKontrakBulan &&
          durasiTagihan < siklusPembayaranBulan) {
        final periodeProbe = DateTime(
          tanggalMasuk.year,
          tanggalMasuk.month + probe,
          1,
        );
        final probeKey = _billingMonthKey(
          periodeProbe.year,
          periodeProbe.month,
        );
        if (excludedMonthlyKeys.contains(probeKey)) {
          break;
        }
        durasiTagihan += 1;
        probe += 1;
      }

      if (durasiTagihan <= 0) {
        monthCursor += 1;
        continue;
      }

      payload.add({
        'penghuni_id': penghuniId,
        'bulan': periode.month,
        'tahun': periode.year,
        'jumlah': hargaBulanan * durasiTagihan,
        'status': 'belum_dibayar',
      });

      monthCursor += durasiTagihan;
    }

    return payload;
  }

  Future<Set<String>> _loadCoveredMonthlyKeysByLunasTagihan({
    required String penghuniId,
    required DateTime tanggalMasuk,
    required int durasiKontrakBulan,
    required int hargaBulanan,
  }) async {
    final covered = <String>{};
    if (penghuniId.trim().isEmpty ||
        durasiKontrakBulan <= 0 ||
        hargaBulanan <= 0) {
      return covered;
    }

    final contractKeys = <String>{};
    for (var i = 0; i < durasiKontrakBulan; i++) {
      final period = DateTime(tanggalMasuk.year, tanggalMasuk.month + i, 1);
      contractKeys.add(_billingMonthKey(period.year, period.month));
    }

    try {
      final raw = await supabase
          .from('tagihan')
          .select('bulan, tahun, jumlah')
          .eq('penghuni_id', penghuniId)
          .eq('status', 'lunas');

      for (final item in raw) {
        final row = Map<String, dynamic>.from(item as Map);
        final bulan = _toInt(row['bulan']);
        final tahun = _toInt(row['tahun']);
        if (bulan < 1 || bulan > 12 || tahun <= 0) {
          continue;
        }

        final monthsCovered = _estimateMonthsCoveredByAmount(
          row['jumlah'],
          hargaBulanan,
        );

        for (var i = 0; i < monthsCovered; i++) {
          final period = DateTime(tahun, bulan + i, 1);
          final key = _billingMonthKey(period.year, period.month);
          if (contractKeys.contains(key)) {
            covered.add(key);
          }
        }
      }
    } catch (_) {
      return covered;
    }

    return covered;
  }

  int _estimateMonthsCoveredByAmount(dynamic jumlah, int hargaBulanan) {
    if (hargaBulanan <= 0) return 1;
    final total = _toInt(jumlah);
    if (total <= 0) return 1;

    final div = total ~/ hargaBulanan;
    final remainder = total % hargaBulanan;
    final months = remainder > 0 ? div + 1 : div;
    return months <= 0 ? 1 : months;
  }

  String _billingMonthKey(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  // GET TAGIHAN (enriched with penghuni, kamar, and kost labels)
  Future<List<Map<String, dynamic>>> getTagihanList() async {
    print('=== getTagihanList START ===');

    // Query tagihan with due dates
    final raw = await supabase
        .from('tagihan')
        .select(
          'id, penghuni_id, bulan, tahun, jumlah, status, created_at, tanggal_jatuh_tempo, batas_pembayaran',
        )
        .order('tahun', ascending: false)
        .order('bulan', ascending: false)
        .order('created_at', ascending: false);

    if (raw is! List) {
      print('❌ Raw is not a list');
      return [];
    }

    final rows = raw.map((item) => Map<String, dynamic>.from(item)).toList();
    print('📊 Total tagihan: ${rows.length}');

    if (rows.isEmpty) return rows;

    final penghuniLookup = await _buildPenghuniLookup();
    final now = DateTime.now();

    // Enrich each row with penghuni info and pembayaran data
    final enrichedRows = <Map<String, dynamic>>[];
    for (final row in rows) {
      final tagihanId = row['id']?.toString() ?? '';
      final penghuniId = row['penghuni_id']?.toString() ?? '';
      final status = row['status']?.toString() ?? '';
      final info = penghuniLookup[penghuniId] ?? const <String, String>{};

      row['nama_penghuni'] = info['nama'] ?? 'Penghuni';
      row['nomor_kamar'] = info['nomor_kamar'] ?? '-';
      row['nama_kost'] = info['nama_kost'] ?? '-';

      // Calculate late status
      final tanggalJatuhTempo = row['tanggal_jatuh_tempo'] != null
          ? DateTime.tryParse(row['tanggal_jatuh_tempo'].toString())
          : null;

      if (tanggalJatuhTempo != null && status != 'lunas') {
        final isLate = now.isAfter(tanggalJatuhTempo);
        row['is_terlambat'] = isLate;
        if (isLate) {
          row['hari_terlambat'] = now.difference(tanggalJatuhTempo).inDays;
        } else {
          row['hari_terlambat'] = 0;
        }
      } else {
        row['is_terlambat'] = false;
        row['hari_terlambat'] = 0;
      }

      print('Tagihan $tagihanId - Status: $status');

      // Get pembayaran data if status is menunggu_verifikasi or lunas
      if (status == 'menunggu_verifikasi' || status == 'lunas') {
        print('  → Fetching pembayaran for tagihan $tagihanId');
        try {
          final pembayaranRaw = await supabase
              .from('pembayaran')
              .select('id, bukti_pembayaran, tanggal, metode_id')
              .eq('tagihan_id', tagihanId)
              .order('created_at', ascending: false)
              .limit(1);

          print('  → Pembayaran query result: $pembayaranRaw');

          if (pembayaranRaw is List && pembayaranRaw.isNotEmpty) {
            final pembayaran = pembayaranRaw.first;
            row['pembayaran_id'] = pembayaran['id'];
            row['bukti_pembayaran_url'] = pembayaran['bukti_pembayaran'];
            row['tanggal_pembayaran'] = pembayaran['tanggal'];
            row['metode_pembayaran_id'] = pembayaran['metode_id'];
            print('  ✅ Pembayaran data found: ${pembayaran['id']}');
          } else {
            print('  ⚠️ No pembayaran found for tagihan $tagihanId');
          }
        } catch (e) {
          print('  ❌ Error getting pembayaran for tagihan $tagihanId: $e');
          // Continue without pembayaran data
        }
      }

      enrichedRows.add(row);
    }

    print(
      '=== getTagihanList END - Total enriched: ${enrichedRows.length} ===',
    );
    return enrichedRows;
  }

  // GET TAGIHAN BY PENGHUNI
  Future<List<Map<String, dynamic>>> getTagihanByPenghuniId(
    String penghuniId,
  ) async {
    if (penghuniId.trim().isEmpty) return [];

    final raw = await supabase
        .from('tagihan')
        .select(
          'id, penghuni_id, bulan, tahun, jumlah, status, created_at, tanggal_jatuh_tempo, batas_pembayaran',
        )
        .eq('penghuni_id', penghuniId)
        .order('tahun', ascending: false)
        .order('bulan', ascending: false)
        .order('created_at', ascending: false);

    if (raw is! List) return [];
    return raw.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // GET PENGUMUMAN BY KOST
  Future<List<Map<String, dynamic>>> getPengumumanByKostId(
    String kostId,
  ) async {
    if (kostId.trim().isEmpty) return [];

    final attempts = <({String select, String kostField, String? orderField})>[
      (
        select: 'id, kost_id, judul, isi, tanggal',
        kostField: 'kost_id',
        orderField: 'tanggal',
      ),
      (
        select: 'id, id_kost, judul, isi, tanggal',
        kostField: 'id_kost',
        orderField: 'tanggal',
      ),
      (
        select: 'id, kost_id, judul, deskripsi, tanggal',
        kostField: 'kost_id',
        orderField: 'tanggal',
      ),
      (
        select: 'id, id_kost, judul, deskripsi, tanggal',
        kostField: 'id_kost',
        orderField: 'tanggal',
      ),
      (
        select: 'id, kost_id, judul, isi, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, kost_id, title, description, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, id_kost, title, description, created_at',
        kostField: 'id_kost',
        orderField: 'created_at',
      ),
      (
        select: 'id, kost_id, title, content, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, id_kost, title, content, created_at',
        kostField: 'id_kost',
        orderField: 'created_at',
      ),
      (select: '*', kostField: 'kost_id', orderField: 'tanggal'),
      (select: '*', kostField: 'id_kost', orderField: 'tanggal'),
      (select: '*', kostField: 'kost_id', orderField: 'created_at'),
      (select: '*', kostField: 'id_kost', orderField: 'created_at'),
      (select: '*', kostField: 'kost_id', orderField: null),
      (select: '*', kostField: 'id_kost', orderField: null),
    ];

    for (final attempt in attempts) {
      try {
        dynamic query = supabase
            .from('pengumuman')
            .select(attempt.select)
            .eq(attempt.kostField, kostId);

        if (attempt.orderField != null) {
          query = query.order(attempt.orderField!, ascending: false);
        }

        final raw = await query;
        if (raw is! List) return [];

        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      } catch (_) {
        // Try next schema/column variation.
      }
    }

    throw Exception('Gagal memuat data pengumuman');
  }

  // GET JUMLAH PENGUMUMAN BY KOST
  Future<int> getPengumumanCountByKostId(String kostId) async {
    if (kostId.trim().isEmpty) return 0;

    final attempts = <({String select, String kostField})>[
      (select: 'id', kostField: 'kost_id'),
      (select: 'id', kostField: 'id_kost'),
      (select: '*', kostField: 'kost_id'),
      (select: '*', kostField: 'id_kost'),
    ];

    for (final attempt in attempts) {
      try {
        final raw = await supabase
            .from('pengumuman')
            .select(attempt.select)
            .eq(attempt.kostField, kostId);

        if (raw is List) return raw.length;
      } catch (_) {
        // Try next schema/column variation.
      }
    }

    return 0;
  }

  // GET PEMASUKAN BY KOST
  Future<List<Map<String, dynamic>>> getPemasukanByKostId(String kostId) async {
    if (kostId.trim().isEmpty) return [];

    try {
      // Ambil pemasukan dengan join ke penghuni dan kamar
      final raw = await supabase
          .from('pemasukan')
          .select('''
            id, 
            penghuni_id, 
            jumlah, 
            tanggal, 
            keterangan,
            pembayaran_id,
            created_at,
            penghuni:penghuni_id(
              kamar:kamar_id(
                kost_id
              )
            )
          ''')
          .order('tanggal', ascending: false);

      if (raw is! List) return [];

      // Filter by kost_id
      final kostFiltered = raw.where((item) {
        try {
          final penghuni = item['penghuni'];
          if (penghuni is Map) {
            final kamar = penghuni['kamar'];
            if (kamar is Map) {
              return kamar['kost_id'] == kostId;
            }
          }
          return false;
        } catch (_) {
          return false;
        }
      }).toList();

      // Untuk setiap pemasukan, ambil nama penghuni
      final enrichedData = <Map<String, dynamic>>[];

      for (final item in kostFiltered) {
        final map = Map<String, dynamic>.from(item);
        final pembayaranId = item['pembayaran_id']?.toString();

        // Default nama
        map['nama_penghuni'] = 'Penghuni';

        if (pembayaranId != null && pembayaranId.isNotEmpty) {
          try {
            // Ambil nama dari pembayaran
            final pembayaranData = await supabase
                .from('pembayaran')
                .select('''
                  penghuni:penghuni_id(
                    users:user_id(
                      nama
                    )
                  )
                ''')
                .eq('id', pembayaranId)
                .maybeSingle();

            if (pembayaranData != null) {
              final penghuni = pembayaranData['penghuni'];
              if (penghuni is Map) {
                final users = penghuni['users'];
                if (users is Map && users['nama'] != null) {
                  map['nama_penghuni'] =
                      users['nama']?.toString() ?? 'Penghuni';
                }
              }
            }
          } catch (e) {
            print('Error getting nama for pembayaran $pembayaranId: $e');
          }
        }

        enrichedData.add(map);
      }

      print(
        '📊 Loaded ${enrichedData.length} pemasukan records for kost $kostId',
      );
      return enrichedData;
    } catch (e) {
      print('Error getPemasukanByKostId: $e');
      return [];
    }
  }

  // GET PEMBAYARAN BY KOST (DEPRECATED - use getPemasukanByKostId instead)
  Future<List<Map<String, dynamic>>> getPembayaranByKostId(
    String kostId,
  ) async {
    if (kostId.trim().isEmpty) return [];

    try {
      final raw = await supabase
          .from('pembayaran')
          .select('id, jumlah, tanggal, deskripsi, created_at')
          .eq('kost_id', kostId)
          .order('tanggal', ascending: false);

      if (raw is! List) return [];
      return raw.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error getPembayaranByKostId: $e');
      return [];
    }
  }

  // GET PEMBAYARAN BY PENGHUNI ID
  Future<List<Map<String, dynamic>>> getPembayaranByPenghuniId(
    String penghuniId,
  ) async {
    if (penghuniId.trim().isEmpty) return [];

    try {
      final raw = await supabase
          .from('pembayaran')
          .select('*')
          .eq('penghuni_id', penghuniId)
          .order('tanggal', ascending: false);

      if (raw is! List) return [];
      return raw.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error getPembayaranByPenghuniId: $e');
      return [];
    }
  }

  // GET TAGIHAN BY ID
  Future<Map<String, dynamic>?> getTagihanById(String tagihanId) async {
    if (tagihanId.trim().isEmpty) return null;

    try {
      final raw = await supabase
          .from('tagihan')
          .select('*')
          .eq('id', tagihanId)
          .single();

      return Map<String, dynamic>.from(raw);
    } catch (e) {
      print('Error getTagihanById: $e');
      return null;
    }
  }

  // GET METODE PEMBAYARAN BY ID
  Future<Map<String, dynamic>?> getMetodePembayaranById(String metodeId) async {
    if (metodeId.trim().isEmpty) return null;

    try {
      final raw = await supabase
          .from('metode_pembayaran')
          .select('*')
          .eq('id', metodeId)
          .single();

      return Map<String, dynamic>.from(raw);
    } catch (e) {
      print('Error getMetodePembayaranById: $e');
      return null;
    }
  }

  // GET PENGELUARAN BY KOST
  Future<List<Map<String, dynamic>>> getPengeluaranByKostId(
    String kostId,
  ) async {
    if (kostId.trim().isEmpty) return [];

    try {
      final raw = await supabase
          .from('pengeluaran')
          .select('id, nama, jumlah, tanggal, deskripsi, created_at')
          .eq('kost_id', kostId)
          .order('tanggal', ascending: false);

      if (raw is! List) return [];
      return raw.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error getPengeluaranByKostId: $e');
      return [];
    }
  }

  // GET RINGKASAN KEUANGAN BY KOST
  Future<Map<String, dynamic>> getRingkasanKeuanganByKostId(
    String kostId,
  ) async {
    if (kostId.trim().isEmpty) {
      return {'pemasukan': 0.0, 'pengeluaran': 0.0, 'labaBersih': 0.0};
    }

    try {
      final pemasukanList = await getPemasukanByKostId(kostId);
      final pengeluaranList = await getPengeluaranByKostId(kostId);

      final totalPemasukan = pemasukanList.fold<double>(0.0, (sum, item) {
        final jumlah = item['jumlah'];
        if (jumlah is int) return sum + jumlah.toDouble();
        if (jumlah is double) return sum + jumlah;
        return sum + (double.tryParse(jumlah?.toString() ?? '0') ?? 0.0);
      });

      final totalPengeluaran = pengeluaranList.fold<double>(0.0, (sum, item) {
        final jumlah = item['jumlah'];
        if (jumlah is int) return sum + jumlah.toDouble();
        if (jumlah is double) return sum + jumlah;
        return sum + (double.tryParse(jumlah?.toString() ?? '0') ?? 0.0);
      });

      return {
        'pemasukan': totalPemasukan,
        'pengeluaran': totalPengeluaran,
        'labaBersih': totalPemasukan - totalPengeluaran,
      };
    } catch (_) {
      return {'pemasukan': 0.0, 'pengeluaran': 0.0, 'labaBersih': 0.0};
    }
  }

  // INSERT PENGUMUMAN
  Future<void> createPengumuman({
    required String kostId,
    required String title,
    required String description,
  }) async {
    if (kostId.trim().isEmpty) {
      throw Exception('ID kost tidak valid');
    }

    final judul = title.trim();
    final deskripsi = description.trim();
    final nowIso = DateTime.now().toIso8601String();
    if (judul.isEmpty || deskripsi.isEmpty) {
      throw Exception('Judul dan deskripsi pengumuman wajib diisi');
    }

    final payloads = <Map<String, dynamic>>[
      {
        'kost_id': kostId,
        'judul': judul,
        'deskripsi': deskripsi,
        'tanggal': nowIso,
      },
      {
        'id_kost': kostId,
        'judul': judul,
        'deskripsi': deskripsi,
        'tanggal': nowIso,
      },
      {'kost_id': kostId, 'judul': judul, 'isi': deskripsi, 'tanggal': nowIso},
      {'id_kost': kostId, 'judul': judul, 'isi': deskripsi, 'tanggal': nowIso},
      {
        'kost_id': kostId,
        'title': judul,
        'description': deskripsi,
        'tanggal': nowIso,
      },
      {
        'id_kost': kostId,
        'title': judul,
        'description': deskripsi,
        'tanggal': nowIso,
      },
      {
        'kost_id': kostId,
        'title': judul,
        'content': deskripsi,
        'tanggal': nowIso,
      },
      {
        'id_kost': kostId,
        'title': judul,
        'content': deskripsi,
        'tanggal': nowIso,
      },
    ];

    PostgrestException? lastError;
    for (final payload in payloads) {
      try {
        await supabase.from('pengumuman').insert(payload);
        return;
      } on PostgrestException catch (e) {
        lastError = e;
      }
    }

    if (lastError != null) {
      throw Exception(_formatPostgrestError(lastError));
    }

    throw Exception('Gagal menambahkan pengumuman');
  }

  // UPDATE PENGUMUMAN
  Future<void> updatePengumuman({
    required String id,
    required String title,
    required String description,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengumuman tidak valid');
    }

    final judul = title.trim();
    final deskripsi = description.trim();
    if (judul.isEmpty || deskripsi.isEmpty) {
      throw Exception('Judul dan deskripsi pengumuman wajib diisi');
    }

    final payloads = <Map<String, dynamic>>[
      {'judul': judul, 'deskripsi': deskripsi},
      {'judul': judul, 'isi': deskripsi},
      {'title': judul, 'description': deskripsi},
      {'title': judul, 'content': deskripsi},
    ];

    PostgrestException? lastError;
    for (final payload in payloads) {
      try {
        await supabase.from('pengumuman').update(payload).eq('id', id);
        return;
      } on PostgrestException catch (e) {
        lastError = e;
      }
    }

    if (lastError != null) {
      throw Exception(_formatPostgrestError(lastError));
    }

    throw Exception('Gagal memperbarui pengumuman');
  }

  // INSERT PENGELUARAN
  Future<void> createPengeluaran({
    required String kostId,
    required String nama,
    required double jumlah,
    required DateTime tanggal,
    String? deskripsi,
  }) async {
    if (kostId.trim().isEmpty) {
      throw Exception('ID kost tidak valid');
    }

    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama pengeluaran wajib diisi');
    }

    if (jumlah <= 0) {
      throw Exception('Jumlah pengeluaran harus lebih dari 0');
    }

    final payload = <String, dynamic>{
      'kost_id': kostId.trim(),
      'nama': cleanNama,
      'jumlah': jumlah.toInt(), // Convert to integer
      'tanggal': tanggal.toIso8601String().split('T').first,
      'deskripsi': (deskripsi ?? '').trim().isEmpty ? null : deskripsi!.trim(),
    };

    try {
      await supabase.from('pengeluaran').insert(payload);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // UPDATE PENGELUARAN
  Future<void> updatePengeluaran({
    required String id,
    required String nama,
    required double jumlah,
    required DateTime tanggal,
    String? deskripsi,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengeluaran tidak valid');
    }

    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama pengeluaran wajib diisi');
    }

    if (jumlah <= 0) {
      throw Exception('Jumlah pengeluaran harus lebih dari 0');
    }

    final payload = <String, dynamic>{
      'nama': cleanNama,
      'jumlah': jumlah.toInt(),
      'tanggal': tanggal.toIso8601String().split('T').first,
      'deskripsi': (deskripsi ?? '').trim().isEmpty ? null : deskripsi!.trim(),
    };

    try {
      await supabase.from('pengeluaran').update(payload).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // DELETE PENGELUARAN
  Future<void> deletePengeluaran(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengeluaran tidak valid');
    }

    try {
      await supabase.from('pengeluaran').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // DELETE PENGUMUMAN
  Future<void> deletePengumuman(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengumuman tidak valid');
    }

    await supabase.from('pengumuman').delete().eq('id', id);
  }

  // GET PERATURAN BY KOST
  Future<List<Map<String, dynamic>>> getPeraturanByKostId(String kostId) async {
    if (kostId.trim().isEmpty) return [];

    final attempts = <({String select, String kostField, String? orderField})>[
      (
        select: 'id, kost_id, judul, isi, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, id_kost, judul, isi, created_at',
        kostField: 'id_kost',
        orderField: 'created_at',
      ),
      (
        select: 'id, kost_id, judul, deskripsi, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, id_kost, judul, deskripsi, created_at',
        kostField: 'id_kost',
        orderField: 'created_at',
      ),
      (
        select: 'id, kost_id, title, content, created_at',
        kostField: 'kost_id',
        orderField: 'created_at',
      ),
      (
        select: 'id, id_kost, title, content, created_at',
        kostField: 'id_kost',
        orderField: 'created_at',
      ),
      (select: '*', kostField: 'kost_id', orderField: 'created_at'),
      (select: '*', kostField: 'id_kost', orderField: 'created_at'),
      (select: '*', kostField: 'kost_id', orderField: null),
      (select: '*', kostField: 'id_kost', orderField: null),
    ];

    for (final attempt in attempts) {
      try {
        dynamic query = supabase
            .from('peraturan')
            .select(attempt.select)
            .eq(attempt.kostField, kostId);

        if (attempt.orderField != null) {
          query = query.order(attempt.orderField!, ascending: false);
        }

        final raw = await query;
        if (raw is! List) return [];

        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      } catch (_) {
        // Try next schema/column variation.
      }
    }

    throw Exception('Gagal memuat data peraturan');
  }

  // GET JUMLAH PERATURAN BY KOST
  Future<int> getPeraturanCountByKostId(String kostId) async {
    if (kostId.trim().isEmpty) return 0;

    final attempts = <({String select, String kostField})>[
      (select: 'id', kostField: 'kost_id'),
      (select: 'id', kostField: 'id_kost'),
      (select: '*', kostField: 'kost_id'),
      (select: '*', kostField: 'id_kost'),
    ];

    for (final attempt in attempts) {
      try {
        final raw = await supabase
            .from('peraturan')
            .select(attempt.select)
            .eq(attempt.kostField, kostId);

        if (raw is List) return raw.length;
      } catch (_) {
        // Try next schema/column variation.
      }
    }

    return 0;
  }

  // INSERT PERATURAN
  Future<void> createPeraturan({
    required String kostId,
    required String title,
    required String description,
  }) async {
    if (kostId.trim().isEmpty) {
      throw Exception('ID kost tidak valid');
    }

    final judul = title.trim();
    final deskripsi = description.trim();
    final nowIso = DateTime.now().toIso8601String();
    if (judul.isEmpty || deskripsi.isEmpty) {
      throw Exception('Judul dan isi peraturan wajib diisi');
    }

    final payloads = <Map<String, dynamic>>[
      {
        'kost_id': kostId,
        'judul': judul,
        'isi': deskripsi,
        'created_at': nowIso,
      },
      {
        'id_kost': kostId,
        'judul': judul,
        'isi': deskripsi,
        'created_at': nowIso,
      },
      {
        'kost_id': kostId,
        'judul': judul,
        'deskripsi': deskripsi,
        'created_at': nowIso,
      },
      {
        'id_kost': kostId,
        'judul': judul,
        'deskripsi': deskripsi,
        'created_at': nowIso,
      },
      {
        'kost_id': kostId,
        'title': judul,
        'content': deskripsi,
        'created_at': nowIso,
      },
      {
        'id_kost': kostId,
        'title': judul,
        'content': deskripsi,
        'created_at': nowIso,
      },
      {
        'kost_id': kostId,
        'title': judul,
        'description': deskripsi,
        'created_at': nowIso,
      },
      {
        'id_kost': kostId,
        'title': judul,
        'description': deskripsi,
        'created_at': nowIso,
      },
    ];

    PostgrestException? lastError;
    for (final payload in payloads) {
      try {
        await supabase.from('peraturan').insert(payload);
        return;
      } on PostgrestException catch (e) {
        lastError = e;
      }
    }

    if (lastError != null) {
      throw Exception(_formatPostgrestError(lastError));
    }

    throw Exception('Gagal menambahkan peraturan');
  }

  // UPDATE PERATURAN
  Future<void> updatePeraturan({
    required String id,
    required String title,
    required String description,
  }) async {
    if (id.trim().isEmpty) {
      throw Exception('ID peraturan tidak valid');
    }

    final judul = title.trim();
    final deskripsi = description.trim();
    if (judul.isEmpty || deskripsi.isEmpty) {
      throw Exception('Judul dan isi peraturan wajib diisi');
    }

    final payloads = <Map<String, dynamic>>[
      {'judul': judul, 'isi': deskripsi},
      {'judul': judul, 'deskripsi': deskripsi},
      {'title': judul, 'content': deskripsi},
      {'title': judul, 'description': deskripsi},
    ];

    PostgrestException? lastError;
    for (final payload in payloads) {
      try {
        await supabase.from('peraturan').update(payload).eq('id', id);
        return;
      } on PostgrestException catch (e) {
        lastError = e;
      }
    }

    if (lastError != null) {
      throw Exception(_formatPostgrestError(lastError));
    }

    throw Exception('Gagal memperbarui peraturan');
  }

  // DELETE PERATURAN
  Future<void> deletePeraturan(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID peraturan tidak valid');
    }

    await supabase.from('peraturan').delete().eq('id', id);
  }

  Future<Map<String, Map<String, String>>> _buildPenghuniLookup() async {
    final lookup = <String, Map<String, String>>{};

    final kosts = await getKostList();
    for (final kost in kosts) {
      final kamarList = await getKamarByKostId(kost.id);

      for (final kamar in kamarList) {
        final kamarId = kamar['id']?.toString() ?? '';
        if (kamarId.isEmpty) continue;

        final penghuniRows = await getPenghuniByKamarId(kamarId);
        for (final row in penghuniRows) {
          final penghuniId = row['id']?.toString() ?? '';
          if (penghuniId.isEmpty) continue;

          final user = row['users'] is Map
              ? Map<String, dynamic>.from(row['users'] as Map)
              : <String, dynamic>{};

          lookup[penghuniId] = {
            'nama': (user['nama'] ?? row['nama'] ?? 'Penghuni').toString(),
            'nomor_kamar': (kamar['no_kamar'] ?? '-').toString(),
            'nama_kost': kost.name,
          };
        }
      }
    }

    return lookup;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatPostgrestError(PostgrestException error) {
    final dynamic raw = error;
    final code = (raw.code ?? '').toString().trim();
    final message = (raw.message ?? error.toString()).toString().trim();
    final details = (raw.details ?? '').toString().trim();
    final hintText = (raw.hint ?? '').toString().trim();
    final parts = <String>[];

    if (code.isNotEmpty) {
      parts.add('code=$code');
    }
    if (details.isNotEmpty && details.toLowerCase() != 'null') {
      parts.add('details=$details');
    }
    if (hintText.isNotEmpty && hintText.toLowerCase() != 'null') {
      parts.add('hint=$hintText');
    }

    if (parts.isEmpty) return message;
    return '$message (${parts.join(" | ")})';
  }

  double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Map<String, dynamic>? _asStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is! Map) return null;

    return value.map((key, val) => MapEntry(key.toString(), val));
  }

  String _kamarStatusByOccupancy(int terisi, int kapasitas) {
    if (terisi <= 0) return 'kosong';
    if (terisi >= kapasitas) return 'penuh';
    return 'terisi';
  }

  String _normalizeFileExtension(String rawExt) {
    final cleaned = rawExt.trim().toLowerCase().replaceAll('.', '');
    if (cleaned == 'png' ||
        cleaned == 'jpeg' ||
        cleaned == 'jpg' ||
        cleaned == 'webp') {
      return cleaned;
    }
    return 'jpg';
  }

  String _contentTypeFromFileExtension(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }

  String _slugify(String value) {
    final cleaned = value.trim().toLowerCase();
    if (cleaned.isEmpty) return 'qris';

    final onlySafe = cleaned.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final compact = onlySafe.replaceAll(RegExp(r'-+'), '-');
    return compact.replaceAll(RegExp(r'^-|-$'), '').isEmpty
        ? 'qris'
        : compact.replaceAll(RegExp(r'^-|-$'), '');
  }

  String _normalizeMetodePembayaranTipe(String tipe) {
    final normalized = tipe.trim().toLowerCase();
    if (normalized == 'cash' || normalized == 'tunai') return 'cash';
    if (normalized == 'qris' || normalized == 'qr') return 'qris';
    return 'bank';
  }

  // UPLOAD FOTO PROFIL TO STORAGE
  Future<String> uploadFotoProfilAdmin({
    required Uint8List imageBytes,
    required String fileExt,
    required String userId,
  }) async {
    if (imageBytes.isEmpty) {
      throw Exception('File foto tidak valid');
    }

    final extension = _normalizeFileExtension(fileExt);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$userId.$extension';
    final objectPath = 'admin/$fileName';

    try {
      await supabase.storage
          .from('foto-profil')
          .uploadBinary(
            objectPath,
            imageBytes,
            fileOptions: FileOptions(
              upsert: false,
              cacheControl: '3600',
              contentType: _contentTypeFromFileExtension(extension),
            ),
          );

      return supabase.storage.from('foto-profil').getPublicUrl(objectPath);
    } on StorageException catch (e) {
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // UPDATE FOTO PROFIL USER (using RPC for better security)
  Future<void> updateFotoProfilUser({
    required String userId,
    String? fotoProfilUrl,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('ID user tidak valid');
    }

    try {
      // Try using RPC function first (if available)
      try {
        await supabase.rpc(
          'update_user_foto_profil',
          params: {'p_user_id': userId, 'p_foto_profil_url': fotoProfilUrl},
        );
        return;
      } catch (rpcError) {
        print('RPC not available, trying direct update: $rpcError');
      }

      // Fallback to direct update
      await supabase
          .from('users')
          .update({'foto_profil': fotoProfilUrl})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // GET USER BY ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    if (userId.trim().isEmpty) return null;

    try {
      // Try using RPC function first (bypass RLS)
      try {
        final result = await supabase.rpc(
          'get_user_by_id',
          params: {'p_user_id': userId},
        );

        if (result is List && result.isNotEmpty) {
          return Map<String, dynamic>.from(result.first);
        }
      } catch (rpcError) {
        print(
          'RPC get_user_by_id not available, trying direct query: $rpcError',
        );
      }

      // Fallback to direct query
      final raw = await supabase
          .from('users')
          .select('id, username, nama, no_tlpn, role, foto_profil, is_active')
          .eq('id', userId)
          .maybeSingle();

      return _asStringMap(raw);
    } catch (e) {
      print('Error getUserById: $e');
      return null;
    }
  }

  // VERIFY PASSWORD
  Future<void> verifyPassword({
    required String userId,
    required String password,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('ID user tidak valid');
    }

    if (password.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    try {
      // Use RPC function to verify password
      final result = await supabase.rpc(
        'verify_user_password',
        params: {'p_user_id': userId, 'p_password': password},
      );

      // Check if password is correct
      if (result == false || result == 0) {
        throw Exception('Password tidak sesuai');
      }
    } on PostgrestException catch (e) {
      if (e.message.contains('not find the function')) {
        throw Exception(
          'Fitur verifikasi password belum tersedia. Hubungi administrator.',
        );
      }
      throw Exception(_formatPostgrestError(e));
    }
  }

  // UPDATE USERNAME
  Future<void> updateUsername({
    required String userId,
    required String newUsername,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('ID user tidak valid');
    }

    if (newUsername.trim().isEmpty) {
      throw Exception('Username tidak boleh kosong');
    }

    try {
      // Check if username already exists
      final existing = await supabase
          .from('users')
          .select('id')
          .eq('username', newUsername)
          .neq('id', userId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('Username sudah digunakan');
      }

      // Try using RPC function first
      try {
        await supabase.rpc(
          'update_user_username',
          params: {'p_user_id': userId, 'p_new_username': newUsername},
        );
        return;
      } catch (rpcError) {
        print(
          'RPC update_user_username not available, trying direct update: $rpcError',
        );
      }

      // Fallback to direct update
      await supabase
          .from('users')
          .update({'username': newUsername})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw Exception(_formatPostgrestError(e));
    }
  }

  // UPDATE PASSWORD
  Future<void> updatePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('ID user tidak valid');
    }

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      throw Exception('Password tidak boleh kosong');
    }

    if (newPassword.length < 6) {
      throw Exception('Password minimal 6 karakter');
    }

    try {
      // Use RPC function to verify old password and update
      final result = await supabase.rpc(
        'update_user_password',
        params: {
          'p_user_id': userId,
          'p_old_password': oldPassword,
          'p_new_password': newPassword,
        },
      );

      // Check if update was successful
      if (result == false || result == 0) {
        throw Exception('Password lama tidak sesuai');
      }
    } on PostgrestException catch (e) {
      if (e.message.contains('not find the function')) {
        throw Exception(
          'Fitur ubah password belum tersedia. Hubungi administrator.',
        );
      }
      throw Exception(_formatPostgrestError(e));
    }
  }

  // GET DASHBOARD STATISTICS
  Future<Map<String, int>> getDashboardStatistics() async {
    try {
      // Get total kost
      final kostList = await getKostList();
      final totalKost = kostList.length;

      // Get total kamar and kamar kosong
      int totalKamar = 0;
      int kamarKosong = 0;
      int totalPenghuni = 0;

      for (final kost in kostList) {
        final kamarList = await getKamarByKostId(kost.id);
        totalKamar += kamarList.length;

        for (final kamar in kamarList) {
          final status = (kamar['status']?.toString() ?? '').toLowerCase();
          if (status == 'kosong') {
            kamarKosong++;
          }

          // Count active penghuni
          final kamarId = kamar['id']?.toString() ?? '';
          if (kamarId.isNotEmpty) {
            final penghuniList = await getPenghuniByKamarId(kamarId);
            final activePenghuni = penghuniList.where((p) {
              final status = (p['status']?.toString() ?? '').toLowerCase();
              return status == 'aktif';
            }).length;
            totalPenghuni += activePenghuni;
          }
        }
      }

      // Get tagihan statistics
      final tagihanList = await getTagihanList();
      final tagihanBelumBayar = tagihanList.where((t) {
        final status = (t['status']?.toString() ?? '').toLowerCase();
        return status == 'belum_dibayar';
      }).length;

      final menungguVerifikasi = tagihanList.where((t) {
        final status = (t['status']?.toString() ?? '').toLowerCase();
        return status == 'menunggu_verifikasi';
      }).length;

      return {
        'totalKost': totalKost,
        'totalKamar': totalKamar,
        'kamarKosong': kamarKosong,
        'totalPenghuni': totalPenghuni,
        'tagihanBelumBayar': tagihanBelumBayar,
        'menungguVerifikasi': menungguVerifikasi,
      };
    } catch (e) {
      print('Error getDashboardStatistics: $e');
      return {
        'totalKost': 0,
        'totalKamar': 0,
        'kamarKosong': 0,
        'totalPenghuni': 0,
        'tagihanBelumBayar': 0,
        'menungguVerifikasi': 0,
      };
    }
  }

  // SINKRONISASI PEMASUKAN DARI PEMBAYARAN VERIFIED
  Future<void> sinkronisasiPemasukanFromPembayaran() async {
    try {
      print('🔄 Mulai sinkronisasi pemasukan dari pembayaran verified...');

      // Get semua pembayaran yang verified tapi belum ada di pemasukan
      final pembayaranVerified = await supabase
          .from('pembayaran')
          .select('''
            id, 
            penghuni_id, 
            jumlah, 
            tanggal,
            tagihan_id,
            tagihan:tagihan_id(
              bulan,
              tahun
            )
          ''')
          .eq('status', 'verified');

      print(
        '📊 Found ${pembayaranVerified.length} verified pembayaran records',
      );

      if (pembayaranVerified.isEmpty) {
        print('✅ Tidak ada pembayaran verified yang perlu disinkronisasi');
        return;
      }

      // Get semua pemasukan yang sudah ada berdasarkan pembayaran_id
      final existingPemasukan = await supabase
          .from('pemasukan')
          .select('pembayaran_id')
          .not('pembayaran_id', 'is', null);

      final existingPembayaranIds = existingPemasukan
          .map((item) => item['pembayaran_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      print(
        '📋 Found ${existingPembayaranIds.length} existing pemasukan records',
      );

      // Filter pembayaran yang belum ada di pemasukan
      final pembayaranToSync = pembayaranVerified
          .where(
            (item) =>
                !existingPembayaranIds.contains(item['id']?.toString() ?? ''),
          )
          .toList();

      if (pembayaranToSync.isEmpty) {
        print('✅ Semua pembayaran verified sudah ada di pemasukan');
        return;
      }

      print(
        '📝 Akan sinkronisasi ${pembayaranToSync.length} pembayaran ke pemasukan',
      );

      // Insert ke tabel pemasukan
      int successCount = 0;
      for (final pembayaran in pembayaranToSync) {
        try {
          final tagihan = pembayaran['tagihan'];
          final bulan = tagihan is Map ? tagihan['bulan'] : null;
          final tahun = tagihan is Map ? tagihan['tahun'] : null;

          String periodeBulan = '';
          if (bulan != null && tahun != null) {
            const namaBulan = [
              '',
              'Januari',
              'Februari',
              'Maret',
              'April',
              'Mei',
              'Juni',
              'Juli',
              'Agustus',
              'September',
              'Oktober',
              'November',
              'Desember',
            ];
            final bulanInt = bulan is int
                ? bulan
                : int.tryParse(bulan.toString()) ?? 0;
            final tahunInt = tahun is int
                ? tahun
                : int.tryParse(tahun.toString()) ?? 0;

            if (bulanInt >= 1 && bulanInt <= 12 && tahunInt > 0) {
              periodeBulan = '${namaBulan[bulanInt]} $tahunInt';
            }
          }

          final insertData = {
            'penghuni_id': pembayaran['penghuni_id'],
            'jumlah': pembayaran['jumlah'],
            'tanggal': pembayaran['tanggal'],
            'keterangan': 'Pembayaran kost periode $periodeBulan',
            'pembayaran_id': pembayaran['id'],
          };

          // Hanya tambahkan periode_bulan jika ada data bulan/tahun yang valid
          if (bulan != null && tahun != null) {
            final bulanInt = bulan is int
                ? bulan
                : int.tryParse(bulan.toString()) ?? 0;
            final tahunInt = tahun is int
                ? tahun
                : int.tryParse(tahun.toString()) ?? 0;

            if (bulanInt >= 1 && bulanInt <= 12 && tahunInt > 0) {
              // Jika periode_bulan adalah integer, gunakan bulan saja
              insertData['periode_bulan'] = bulanInt;
              // Atau jika periode_bulan adalah date, buat tanggal
              // insertData['periode_bulan'] = '$tahunInt-${bulanInt.toString().padLeft(2, '0')}-01';
            }
          }

          print(
            '  📝 Inserting pemasukan: ${pembayaran['id']} - $periodeBulan',
          );

          await supabase.from('pemasukan').insert(insertData);
          successCount++;

          print('  ✅ Sinkronisasi pembayaran ${pembayaran['id']} berhasil');
        } catch (e) {
          print('  ❌ Gagal sinkronisasi pembayaran ${pembayaran['id']}: $e');
        }
      }

      print(
        '🎉 Sinkronisasi pemasukan selesai: $successCount/${pembayaranToSync.length} berhasil',
      );
    } catch (e) {
      print('❌ Error sinkronisasiPemasukanFromPembayaran: $e');
      throw Exception('Gagal sinkronisasi pemasukan: ${e.toString()}');
    }
  }
}
