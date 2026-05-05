class PengaduanModel {
  final int? idLaporan;
  final String kodeLaporan;
  final DateTime tanggal;
  final String deskripsi;
  final String status;
  final String? buktiLaporan; // Legacy: single photo URL
  final List<String>? buktiFoto; // New: multiple photos URLs
  final String? penghuniId; // Penghuni ID who created the report

  PengaduanModel({
    this.idLaporan,
    required this.kodeLaporan,
    required this.tanggal,
    required this.deskripsi,
    required this.status,
    this.buktiLaporan,
    this.buktiFoto,
    this.penghuniId,
  });

  // Get all photo URLs (combine legacy and new)
  List<String> get allPhotos {
    final photos = <String>[];

    // Add from new field (array)
    if (buktiFoto != null && buktiFoto!.isNotEmpty) {
      photos.addAll(buktiFoto!);
    }

    // Add from legacy field (single) if not already in list
    if (buktiLaporan != null &&
        buktiLaporan!.isNotEmpty &&
        !photos.contains(buktiLaporan)) {
      photos.add(buktiLaporan!);
    }

    return photos;
  }

  factory PengaduanModel.fromJson(Map<String, dynamic> json) {
    // Parse bukti_foto array if exists
    List<String>? buktiFotoList;
    if (json['bukti_foto'] != null) {
      if (json['bukti_foto'] is List) {
        buktiFotoList = (json['bukti_foto'] as List)
            .map((e) => e.toString())
            .where((url) => url.isNotEmpty)
            .toList();
      } else if (json['bukti_foto'] is String) {
        // If it's a JSON string, try to parse it
        buktiFotoList = [json['bukti_foto'] as String];
      }
    }

    return PengaduanModel(
      idLaporan: json['id_laporan'] as int?,
      kodeLaporan: json['kode_laporan'] ?? '',
      tanggal: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'])
          : DateTime.now(),
      deskripsi: json['deskripsi'] ?? '',
      status: json['status'] ?? 'MENUNGGU',
      buktiLaporan: json['bukti_laporan'] as String?,
      buktiFoto: buktiFotoList,
      penghuniId: json['penghuni_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'kode_laporan': kodeLaporan,
      'tanggal': tanggal.toIso8601String(),
      'deskripsi': deskripsi,
      'status': status,
    };

    // Add penghuni_id if available
    if (penghuniId != null) {
      data['penghuni_id'] = penghuniId;
    }

    // Use new field if available
    if (buktiFoto != null && buktiFoto!.isNotEmpty) {
      data['bukti_foto'] = buktiFoto;
    } else if (buktiLaporan != null) {
      // Fallback to legacy field
      data['bukti_laporan'] = buktiLaporan;
    }

    return data;
  }
}
