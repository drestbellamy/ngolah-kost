import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/modules/kost/models/kost_model.dart';
import '../app/modules/login/models/login_user_model.dart';

class SupabaseService {
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

  // INSERT KOST
  Future<void> createKost({
    required String namaKost,
    required String alamat,
    required int totalKamar,
  }) async {
    await supabase.from('kost').insert({
      'nama_kost': namaKost,
      'alamat': alamat,
      'total_kamar': totalKamar,
    });
  }

  // UPDATE KOST
  Future<void> updateKost({
    required String id,
    required String namaKost,
    required String alamat,
    required int totalKamar,
  }) async {
    await supabase
        .from('kost')
        .update({
          'nama_kost': namaKost,
          'alamat': alamat,
          'total_kamar': totalKamar,
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
    String kamarId,
  ) async {
    try {
      final response = await supabase.rpc(
        'get_penghuni_by_kamar_secure',
        params: {'p_kamar_id': kamarId},
      );

      if (response is List) {
        final rows = response
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        return await _attachSistemPembayaranBulan(rows, kamarId);
      }
    } catch (_) {
      // Fallback to direct join query if RPC is not available yet.
    }

    final List<dynamic> fallback = await supabase
        .from('penghuni')
        .select(
          'id, user_id, kamar_id, durasi_kontrak, sistem_pembayaran_bulan, tanggal_masuk, tanggal_keluar, status, created_at, users:user_id(id, nama, no_tlpn, username)',
        )
        .eq('kamar_id', kamarId)
        .order('created_at', ascending: false);

    return fallback.map((item) => Map<String, dynamic>.from(item)).toList();
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

  // GET PENGHUNI COUNT BY KAMAR
  Future<int> getPenghuniCountByKamarId(String kamarId) async {
    final response = await supabase
        .from('penghuni')
        .select('id')
        .eq('kamar_id', kamarId);

    if (response is List) {
      return response.length;
    }

    return 0;
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

    final siklus = sistemPembayaranBulan <= 0 ? 1 : sistemPembayaranBulan;
    final totalTagihan = (durasiKontrakBulan / siklus).ceil();
    final jumlahPerTagihan = hargaBulanan * siklus;

    final payload = <Map<String, dynamic>>[];
    for (var i = 0; i < totalTagihan; i++) {
      final periode = DateTime(
        tanggalMasuk.year,
        tanggalMasuk.month + (i * siklus),
        1,
      );

      payload.add({
        'penghuni_id': penghuniId,
        'bulan': periode.month,
        'tahun': periode.year,
        'jumlah': jumlahPerTagihan,
        'status': 'belum_dibayar',
      });
    }

    if (payload.isEmpty) return;
    await supabase.from('tagihan').insert(payload);
  }

  // GET TAGIHAN (enriched with penghuni, kamar, and kost labels)
  Future<List<Map<String, dynamic>>> getTagihanList() async {
    final raw = await supabase
        .from('tagihan')
        .select('id, penghuni_id, bulan, tahun, jumlah, status, created_at')
        .order('tahun', ascending: false)
        .order('bulan', ascending: false)
        .order('created_at', ascending: false);

    if (raw is! List) return [];

    final rows = raw.map((item) => Map<String, dynamic>.from(item)).toList();
    if (rows.isEmpty) return rows;

    final penghuniLookup = await _buildPenghuniLookup();

    return rows.map((row) {
      final penghuniId = row['penghuni_id']?.toString() ?? '';
      final info = penghuniLookup[penghuniId] ?? const <String, String>{};

      row['nama_penghuni'] = info['nama'] ?? 'Penghuni';
      row['nomor_kamar'] = info['nomor_kamar'] ?? '-';
      row['nama_kost'] = info['nama_kost'] ?? '-';
      return row;
    }).toList();
  }

  // GET TAGIHAN BY PENGHUNI
  Future<List<Map<String, dynamic>>> getTagihanByPenghuniId(
    String penghuniId,
  ) async {
    if (penghuniId.trim().isEmpty) return [];

    final raw = await supabase
        .from('tagihan')
        .select('id, penghuni_id, bulan, tahun, jumlah, status, created_at')
        .eq('penghuni_id', penghuniId)
        .order('tahun', ascending: false)
        .order('bulan', ascending: false)
        .order('created_at', ascending: false);

    if (raw is! List) return [];
    return raw.map((item) => Map<String, dynamic>.from(item)).toList();
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
}
