class RingkasanKeuanganModel {
  final String kostId;
  final String kostName;
  final String kostAddress;
  final double pemasukan;
  final double pengeluaran;
  final double labaBersih;

  RingkasanKeuanganModel({
    required this.kostId,
    required this.kostName,
    required this.kostAddress,
    required this.pemasukan,
    required this.pengeluaran,
    required this.labaBersih,
  });
}

class TransaksiModel {
  final String id;
  final String type; // 'pemasukan' or 'pengeluaran'
  final String description;
  final double amount;
  final DateTime date;

  TransaksiModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
  });
}
