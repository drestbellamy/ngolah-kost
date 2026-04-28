class PembayaranModel {
  final String bulan;
  final double jumlah;
  final String jatuhTempo;
  final String status;
  final String? tanggalBayar;

  PembayaranModel({
    required this.bulan,
    required this.jumlah,
    required this.jatuhTempo,
    required this.status,
    this.tanggalBayar,
  });
}

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
  final List<PembayaranModel> historyPembayaran;
  // New fields
  final String? nomorKtp;
  final String? jenisKelamin;
  final String? tanggalLahir;
  final String? alamatAsal;
  final String? namaKontakDarurat;
  final String? teleponKontakDarurat;
  final String? hubunganKontakDarurat;

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
    this.historyPembayaran = const [],
    // New fields
    this.nomorKtp,
    this.jenisKelamin,
    this.tanggalLahir,
    this.alamatAsal,
    this.namaKontakDarurat,
    this.teleponKontakDarurat,
    this.hubunganKontakDarurat,
  });
}
