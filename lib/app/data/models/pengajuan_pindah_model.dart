class PengajuanPindahModel {
  final String id;
  final String penghuniId;
  final String kamarTujuanId;
  final DateTime tanggalPindah;
  final String? alasan;
  final String status;
  final String? keteranganAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields for convenience in UI
  final String? noKamarTujuan;
  final String? namaKostTujuan;
  final String? namaPenghuni;
  final String? noTeleponPenghuni;
  final String? noKamarAsal;
  final String? namaKostAsal;
  final String? alamatKostAsal;
  final String? alamatKostTujuan;
  final int? hargaKamarTujuan;

  PengajuanPindahModel({
    required this.id,
    required this.penghuniId,
    required this.kamarTujuanId,
    required this.tanggalPindah,
    this.alasan,
    required this.status,
    this.keteranganAdmin,
    required this.createdAt,
    required this.updatedAt,
    this.noKamarTujuan,
    this.namaKostTujuan,
    this.namaPenghuni,
    this.noTeleponPenghuni,
    this.noKamarAsal,
    this.namaKostAsal,
    this.alamatKostAsal,
    this.alamatKostTujuan,
    this.hargaKamarTujuan,
  });

  factory PengajuanPindahModel.fromMap(Map<String, dynamic> map) {
    // Nested data parsing if using joins (kamar and kost)
    final kamarTujuan = map['kamar'] as Map<String, dynamic>?;
    final kostTujuan = kamarTujuan?['kost'] as Map<String, dynamic>?;
    final penghuni = map['penghuni'] as Map<String, dynamic>?;
    
    // Parse users safely
    Map<String, dynamic>? user;
    if (penghuni?['users'] is Map) {
      user = penghuni?['users'] as Map<String, dynamic>;
    } else if (penghuni?['users'] is List && (penghuni?['users'] as List).isNotEmpty) {
      user = (penghuni?['users'] as List).first as Map<String, dynamic>;
    }

    final kamarAsal = penghuni?['kamar'] as Map<String, dynamic>?;
    final kostAsal = kamarAsal?['kost'] as Map<String, dynamic>?;

    final hargaKamar = kamarTujuan?['harga'];
    final parsedHarga = hargaKamar is int ? hargaKamar : int.tryParse(hargaKamar?.toString() ?? '');

    return PengajuanPindahModel(
      id: map['id']?.toString() ?? '',
      penghuniId: map['penghuni_id']?.toString() ?? '',
      kamarTujuanId: map['kamar_tujuan_id']?.toString() ?? '',
      tanggalPindah: map['tanggal_pindah'] != null 
          ? DateTime.parse(map['tanggal_pindah']) 
          : DateTime.now(),
      alasan: map['alasan']?.toString(),
      status: map['status']?.toString() ?? 'menunggu',
      keteranganAdmin: map['keterangan_admin']?.toString(),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
      noKamarTujuan: kamarTujuan?['no_kamar']?.toString(),
      namaKostTujuan: kostTujuan?['nama_kost']?.toString(),
      namaPenghuni: user?['nama']?.toString(),
      noTeleponPenghuni: user?['no_tlpn']?.toString(),
      noKamarAsal: kamarAsal?['no_kamar']?.toString(),
      namaKostAsal: kostAsal?['nama_kost']?.toString(),
      alamatKostAsal: kostAsal?['alamat']?.toString(),
      alamatKostTujuan: kostTujuan?['alamat']?.toString(),
      hargaKamarTujuan: parsedHarga,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'penghuni_id': penghuniId,
      'kamar_tujuan_id': kamarTujuanId,
      'tanggal_pindah': tanggalPindah.toIso8601String().split('T').first, // YYYY-MM-DD
      'alasan': alasan,
      'status': status,
      'keterangan_admin': keteranganAdmin,
    };
  }
}
