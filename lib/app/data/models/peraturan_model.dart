class PeraturanModel {
  final String id;
  final String kostId;
  final String judul;
  final String isi;
  final String createdAt;

  PeraturanModel({
    required this.id,
    required this.kostId,
    required this.judul,
    required this.isi,
    required this.createdAt,
  });

  factory PeraturanModel.fromMap(Map<String, dynamic> map) {
    // Handle created_at safely
    String createdAtValue = '';
    if (map['created_at'] != null) {
      final createdAtStr = map['created_at'].toString();
      createdAtValue = createdAtStr.contains('T')
          ? createdAtStr.split('T').first
          : createdAtStr;
    }

    return PeraturanModel(
      id: map['id']?.toString() ?? '',
      kostId: map['kost_id']?.toString() ?? map['id_kost']?.toString() ?? '',
      judul: map['judul']?.toString() ?? map['title']?.toString() ?? '',
      isi:
          map['isi']?.toString() ??
          map['deskripsi']?.toString() ??
          map['content']?.toString() ??
          map['description']?.toString() ??
          '',
      createdAt: createdAtValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kost_id': kostId,
      'judul': judul,
      'isi': isi,
      'created_at': createdAt,
    };
  }
}
