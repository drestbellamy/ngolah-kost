class TagihanModel {
  final String id;
  final String namaPenghuni;
  final String namaKost;
  final String nomorKamar;
  final int bulan;
  final int tahun;
  final String tanggalJatuhTempo;
  final String batasPembayaran;
  final double jumlahTagihan;
  final String
  status; // 'lunas', 'belum_dibayar', 'menunggu_verifikasi', 'terlambat'
  final String? pembayaranId;
  final String? buktiPembayaranUrl;
  final String? metodePembayaran;
  final DateTime? tanggalPembayaran;
  final int hariTerlambat;
  final bool isTerlambat;

  TagihanModel({
    required this.id,
    required this.namaPenghuni,
    required this.namaKost,
    required this.nomorKamar,
    this.bulan = 0,
    this.tahun = 0,
    required this.tanggalJatuhTempo,
    required this.batasPembayaran,
    required this.jumlahTagihan,
    required this.status,
    this.pembayaranId,
    this.buktiPembayaranUrl,
    this.metodePembayaran,
    this.tanggalPembayaran,
    this.hariTerlambat = 0,
    this.isTerlambat = false,
  });
}
