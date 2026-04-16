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
      createdAt: map['created_at']?.toString().split('T').first ?? '',
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
