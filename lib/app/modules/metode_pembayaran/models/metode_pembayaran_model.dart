class MetodePembayaranModel {
  final String id;
  final String kostId;
  final String nama;
  final String jenis; // 'bank', 'cash', 'qris'
  final String nomorRekening;
  final String atasNama;
  final String namaKost;
  final bool isActive;
  final String? qrisImagePath; // Path for QRIS image

  MetodePembayaranModel({
    required this.id,
    required this.kostId,
    required this.nama,
    required this.jenis,
    required this.nomorRekening,
    required this.atasNama,
    required this.namaKost,
    this.isActive = true,
    this.qrisImagePath,
  });

  MetodePembayaranModel copyWith({
    String? id,
    String? kostId,
    String? nama,
    String? jenis,
    String? nomorRekening,
    String? atasNama,
    String? namaKost,
    bool? isActive,
    String? qrisImagePath,
  }) {
    return MetodePembayaranModel(
      id: id ?? this.id,
      kostId: kostId ?? this.kostId,
      nama: nama ?? this.nama,
      jenis: jenis ?? this.jenis,
      nomorRekening: nomorRekening ?? this.nomorRekening,
      atasNama: atasNama ?? this.atasNama,
      namaKost: namaKost ?? this.namaKost,
      isActive: isActive ?? this.isActive,
      qrisImagePath: qrisImagePath ?? this.qrisImagePath,
    );
  }

  factory MetodePembayaranModel.fromMap(
    Map<String, dynamic> map, {
    Map<String, String> kostNameById = const {},
  }) {
    final kostId = (map['kost_id'] ?? '').toString();
    final kostJoin = map['kost'];
    final kostMap = kostJoin is Map
        ? Map<String, dynamic>.from(kostJoin)
        : null;

    final rawJenis = (map['tipe'] ?? map['jenis'] ?? '').toString();
    final jenis = normalizeJenis(rawJenis);

    final namaKost =
        (kostMap?['nama_kost'] ??
                map['nama_kost'] ??
                kostNameById[kostId] ??
                'Kost tidak diketahui')
            .toString();

    final qrisImage = (map['qr_image'] ?? map['qris_image'])?.toString();
    final nomorRekening = (map['no_rek'] ?? map['nomor_rekening'] ?? '-')
        .toString();

    return MetodePembayaranModel(
      id: (map['id'] ?? '').toString(),
      kostId: kostId,
      nama: (map['nama'] ?? '').toString(),
      jenis: jenis,
      nomorRekening: nomorRekening,
      atasNama: (map['atas_nama'] ?? '').toString(),
      namaKost: namaKost,
      isActive: _toBool(map['is_active'], fallback: true),
      qrisImagePath: qrisImage,
    );
  }

  static String normalizeJenis(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'cash' || normalized == 'tunai') return 'cash';
    if (normalized == 'qris' || normalized == 'qr') return 'qris';
    return 'bank';
  }

  static bool _toBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is int) return value == 1;

    final text = value?.toString().trim().toLowerCase() ?? '';
    if (text == 'true' || text == '1' || text == 'yes') return true;
    if (text == 'false' || text == '0' || text == 'no') return false;

    return fallback;
  }
}
