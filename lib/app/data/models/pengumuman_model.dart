class PengumumanModel {
  final String id;
  final String kostId;
  final String judul;
  final String isi;
  final String tanggal;

  PengumumanModel({
    required this.id,
    required this.kostId,
    required this.judul,
    required this.isi,
    required this.tanggal,
  });

  factory PengumumanModel.fromMap(Map<String, dynamic> map) {
    // Handle tanggal/created_at safely
    String tanggalValue = '';
    if (map['tanggal'] != null) {
      final tanggalStr = map['tanggal'].toString();
      tanggalValue = tanggalStr.contains('T')
          ? tanggalStr.split('T').first
          : tanggalStr;
    } else if (map['created_at'] != null) {
      final createdAtStr = map['created_at'].toString();
      tanggalValue = createdAtStr.contains('T')
          ? createdAtStr.split('T').first
          : createdAtStr;
    }

    return PengumumanModel(
      id: map['id']?.toString() ?? '',
      kostId: map['kost_id']?.toString() ?? map['id_kost']?.toString() ?? '',
      judul: map['judul']?.toString() ?? map['title']?.toString() ?? '',
      isi:
          map['isi']?.toString() ??
          map['deskripsi']?.toString() ??
          map['content']?.toString() ??
          map['description']?.toString() ??
          '',
      tanggal: tanggalValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kost_id': kostId,
      'judul': judul,
      'isi': isi,
      'tanggal': tanggal,
    };
  }
}
