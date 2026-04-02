class TagihanModel {
  final String id;
  final String namaPenghuni;
  final String namaKost;
  final String nomorKamar;
  final String tanggalJatuhTempo;
  final double jumlahTagihan;
  final String status; // 'lunas', 'belum_dibayar', 'menunggu_verifikasi'

  TagihanModel({
    required this.id,
    required this.namaPenghuni,
    required this.namaKost,
    required this.nomorKamar,
    required this.tanggalJatuhTempo,
    required this.jumlahTagihan,
    required this.status,
  });
}
