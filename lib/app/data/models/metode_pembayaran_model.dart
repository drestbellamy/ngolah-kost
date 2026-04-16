class MetodePembayaranModel {
  final String id;
  final String kostId;
  final String tipe;
  final String nama;
  final String noRek;
  final String? atasNama;
  final String? qrImage;
  final bool isActive;
  final String? namaKost;

  MetodePembayaranModel({
    required this.id,
    required this.kostId,
    required this.tipe,
    required this.nama,
    required this.noRek,
    this.atasNama,
    this.qrImage,
    required this.isActive,
    this.namaKost,
  });

  factory MetodePembayaranModel.fromMap(Map<String, dynamic> map) {
    // Handle nested kost data
    final kostData = map['kost'] as Map<String, dynamic>?;

    return MetodePembayaranModel(
      id: map['id']?.toString() ?? '',
      kostId: map['kost_id']?.toString() ?? '',
      tipe: map['tipe']?.toString() ?? '',
      nama: map['nama']?.toString() ?? '',
      noRek: map['no_rek']?.toString() ?? '',
      atasNama: map['atas_nama']?.toString(),
      qrImage: map['qr_image']?.toString(),
      isActive: map['is_active'] == true,
      namaKost: kostData?['nama_kost']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kost_id': kostId,
      'tipe': tipe,
      'nama': nama,
      'no_rek': noRek,
      'atas_nama': atasNama,
      'qr_image': qrImage,
      'is_active': isActive,
    };
  }
}
