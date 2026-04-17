import 'package:supabase_flutter/supabase_flutter.dart';

// Debug script to check tagihan and penghuni data
// Run this with: dart run check_tagihan_debug.dart

void main() async {
  // Initialize Supabase (you'll need to add your credentials)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  final supabase = Supabase.instance.client;

  print('=== CHECKING PENGHUNI STATUS ===');

  // Check penghuni status
  final penghuniData = await supabase
      .from('penghuni')
      .select('id, status, tanggal_keluar, users:user_id(nama)');

  print('Total penghuni: ${penghuniData.length}');

  for (final penghuni in penghuniData) {
    final status = penghuni['status'];
    final tanggalKeluar = penghuni['tanggal_keluar'];
    final nama = penghuni['users']?['nama'] ?? 'Unknown';

    print('Penghuni: $nama, Status: $status, Tanggal Keluar: $tanggalKeluar');
  }

  print('\n=== CHECKING TAGIHAN FOR ENDED CONTRACTS ===');

  // Check tagihan for ended contracts
  final endedPenghuni = penghuniData
      .where((p) => p['status'] == 'berakhir' || p['status'] == 'tidak_aktif')
      .toList();

  for (final penghuni in endedPenghuni) {
    final penghuniId = penghuni['id'];
    final nama = penghuni['users']?['nama'] ?? 'Unknown';

    final tagihan = await supabase
        .from('tagihan')
        .select('id, bulan, tahun, status, jumlah')
        .eq('penghuni_id', penghuniId);

    if (tagihan.isNotEmpty) {
      print(
        '\nPenghuni: $nama (ID: $penghuniId) - Status: ${penghuni['status']}',
      );
      print('Tagihan yang masih ada:');

      for (final bill in tagihan) {
        print(
          '  - ${bill['bulan']}/${bill['tahun']}: ${bill['status']} - Rp ${bill['jumlah']}',
        );
      }
    }
  }
}
