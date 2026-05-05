class PengaduanAdminModel {
  final int idLaporan;
  final String kodeLaporan;
  final DateTime tanggal;
  final String deskripsi;
  final String status;
  final List<String> buktiFoto;
  final String namaPenghuni;
  final String namaKost;
  final String nomorKamar;

  PengaduanAdminModel({
    required this.idLaporan,
    required this.kodeLaporan,
    required this.tanggal,
    required this.deskripsi,
    required this.status,
    required this.buktiFoto,
    required this.namaPenghuni,
    required this.namaKost,
    required this.nomorKamar,
  });

  factory PengaduanAdminModel.fromJson(Map<String, dynamic> json) {
    // Parse bukti_foto array
    List<String> buktiFotoList = [];
    if (json['bukti_foto'] != null) {
      if (json['bukti_foto'] is List) {
        buktiFotoList = (json['bukti_foto'] as List)
            .map((e) => e.toString())
            .where((url) => url.isNotEmpty)
            .toList();
      }
    }

    // Fallback to bukti_laporan if bukti_foto is empty
    if (buktiFotoList.isEmpty && json['bukti_laporan'] != null) {
      buktiFotoList = [json['bukti_laporan'].toString()];
    }

    // Extract enriched data
    final penghuniData = json['penghuni_data'] as Map<String, dynamic>?;
    final kostData = json['kost_data'] as Map<String, dynamic>?;

    return PengaduanAdminModel(
      idLaporan: json['id_laporan'] as int,
      kodeLaporan: json['kode_laporan'] ?? '',
      tanggal: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'])
          : DateTime.now(),
      deskripsi: json['deskripsi'] ?? '',
      status: json['status'] ?? 'MENUNGGU',
      buktiFoto: buktiFotoList,
      namaPenghuni: penghuniData?['nama'] ?? 'Penghuni',
      namaKost: kostData?['nama_kost'] ?? '-',
      nomorKamar: '-', // Not used
    );
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'MENUNGGU':
        return 'Menunggu';
      case 'DIPROSES':
        return 'Diproses';
      case 'SELESAI':
        return 'Selesai';
      default:
        return status;
    }
  }

  String get formattedDate {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${tanggal.day} ${months[tanggal.month]} ${tanggal.year}';
  }
}
