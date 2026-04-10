class TagihanModel {
  final String id;
  final String namaPenghuni;
  final String namaKost;
  final String nomorKamar;
  final int bulan;
  final int tahun;
  final String tanggalJatuhTempo;
  final double jumlahTagihan;
  final String status; // 'lunas', 'belum_dibayar', 'menunggu_verifikasi'

  TagihanModel({
    required this.id,
    required this.namaPenghuni,
    required this.namaKost,
    required this.nomorKamar,
    this.bulan = 0,
    this.tahun = 0,
    required this.tanggalJatuhTempo,
    required this.jumlahTagihan,
    required this.status,
  });
}
