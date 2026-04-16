class UserProfileModel {
  final String id;
  final String nama;
  final String noTelepon;
  final String nomorKamar;
  final int hargaPerBulan;
  final String tanggalMasuk;
  final String tanggalKeluar;
  final int durasiKontrak;
  final int sistemPembayaranBulan;
  final String status;

  UserProfileModel({
    required this.id,
    required this.nama,
    required this.noTelepon,
    required this.nomorKamar,
    required this.hargaPerBulan,
    required this.tanggalMasuk,
    required this.tanggalKeluar,
    required this.durasiKontrak,
    required this.sistemPembayaranBulan,
    required this.status,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id']?.toString() ?? '',
      nama: map['nama']?.toString() ?? '',
      noTelepon: map['no_tlpn']?.toString() ?? '',
      nomorKamar: map['nomor_kamar']?.toString() ?? '',
      hargaPerBulan: _toInt(map['harga']),
      tanggalMasuk: map['tanggal_masuk']?.toString() ?? '',
      tanggalKeluar: map['tanggal_keluar']?.toString() ?? '',
      durasiKontrak: _toInt(map['durasi_kontrak']),
      sistemPembayaranBulan: _toInt(map['sistem_pembayaran_bulan']),
      status: map['status']?.toString() ?? 'aktif',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get sistemPembayaranText {
    if (sistemPembayaranBulan <= 0) return '1 Bulan Sekali';
    return '$sistemPembayaranBulan Bulan Sekali';
  }

  String get durasiKontrakText {
    return '$durasiKontrak Bulan';
  }

  int get totalNilaiKontrak {
    return hargaPerBulan * durasiKontrak;
  }

  int get jumlahPerTagihan {
    final siklus = sistemPembayaranBulan <= 0 ? 1 : sistemPembayaranBulan;
    return hargaPerBulan * siklus;
  }

  int get totalTagihan {
    final siklus = sistemPembayaranBulan <= 0 ? 1 : sistemPembayaranBulan;
    return (durasiKontrak / siklus).ceil();
  }
}
