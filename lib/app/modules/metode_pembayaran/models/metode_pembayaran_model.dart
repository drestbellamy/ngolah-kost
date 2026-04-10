class MetodePembayaranModel {
  final String id;
  final String nama;
  final String jenis; // 'bank', 'cash', 'qris'
  final String nomorRekening;
  final String namaKost;
  final bool isActive;
  final String? qrisImagePath; // Path for QRIS image

  MetodePembayaranModel({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.nomorRekening,
    required this.namaKost,
    this.isActive = true,
    this.qrisImagePath,
  });
}
