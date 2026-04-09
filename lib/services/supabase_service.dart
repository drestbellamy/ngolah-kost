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
  Future<void> createPenghuni({
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

    try {
      await supabase.from('penghuni').insert(payload);
    } on PostgrestException catch (e) {
      final message = '${e.message} ${e.details}'.toLowerCase();

      // Backward compatibility for DB schema that does not have
      // sistem_pembayaran_bulan yet.
      if (payload.containsKey('sistem_pembayaran_bulan') &&
          message.contains('sistem_pembayaran_bulan')) {
        payload.remove('sistem_pembayaran_bulan');
        await supabase.from('penghuni').insert(payload);
      } else {
        rethrow;
      }
    }
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
}
