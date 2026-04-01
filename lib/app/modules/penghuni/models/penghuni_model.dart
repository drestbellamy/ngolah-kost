class PenghuniModel {
  final String id;
  final String nama;
  final String noTelepon;
  final String nomorKamar;
  final String namaKost;
  final double sewaBulanan;
  final String tanggalMasuk;
  final int durasiKontrak; // dalam bulan
  final String sistemPembayaran;
  final String tanggalBerakhir;
  final double totalNilaiKontrak;

  PenghuniModel({
    required this.id,
    required this.nama,
    required this.noTelepon,
    required this.nomorKamar,
    required this.namaKost,
    required this.sewaBulanan,
    required this.tanggalMasuk,
    required this.durasiKontrak,
    required this.sistemPembayaran,
    required this.tanggalBerakhir,
    required this.totalNilaiKontrak,
  });
}
