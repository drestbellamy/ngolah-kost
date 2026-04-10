class TagihanUserModel {
  final String id;
  final String nomorKamar;
  final String periodePenagihan;
  final DateTime jatuhTempo;
  final double totalBayar;
  final String status; // 'Belum Dibayar', 'Lunas'

  TagihanUserModel({
    required this.id,
    required this.nomorKamar,
    required this.periodePenagihan,
    required this.jatuhTempo,
    required this.totalBayar,
    required this.status,
  });
}
