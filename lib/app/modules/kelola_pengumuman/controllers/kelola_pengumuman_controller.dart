import 'package:get/get.dart';

class GedungKostModel {
  final String id;
  final String nama;
  final String alamat;
  final int totalKamar;

  const GedungKostModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.totalKamar,
  });
}

class PengumumanModel {
  final String id;
  final String kostName;
  final String title;
  final String description;
  final String date;

  const PengumumanModel({
    required this.id,
    required this.kostName,
    required this.title,
    required this.description,
    required this.date,
  });

  PengumumanModel copyWith({
    String? id,
    String? kostName,
    String? title,
    String? description,
    String? date,
  }) {
    return PengumumanModel(
      id: id ?? this.id,
      kostName: kostName ?? this.kostName,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}

class KelolaPengumumanController extends GetxController {
  final gedungKostList = const <GedungKostModel>[
    GedungKostModel(
      id: '1',
      nama: 'Sunrise Boarding House',
      alamat: 'Jl. Gatot Subroto No. 45, Jakarta',
      totalKamar: 8,
    ),
    GedungKostModel(
      id: '2',
      nama: 'Peaceful Haven Kost',
      alamat: 'Jl. Thamrin No. 67, Jakarta',
      totalKamar: 10,
    ),
    GedungKostModel(
      id: '3',
      nama: 'Urban Residence',
      alamat: 'Jl. HR Rasuna Said No. 89, Jakarta',
      totalKamar: 15,
    ),
    GedungKostModel(
      id: '4',
      nama: 'Green Valley Kost',
      alamat: 'Jl. Sudirman No. 123, Jakarta',
      totalKamar: 12,
    ),
  ];

  final selectedGedung = Rxn<GedungKostModel>();
  final pengumumanList = <PengumumanModel>[].obs;
  final Map<String, List<PengumumanModel>> _pengumumanByGedung = {};

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  List<PengumumanModel> _seedPengumuman(String kostName) {
    return [
      PengumumanModel(
        id: '1',
        kostName: kostName,
        title: 'Pemeliharaan Air',
        description:
            'Air akan dimatikan sementara pada tanggal 22 Maret 2026 pukul 08:00 - 12:00 untuk pemeliharaan rutin sistem water heater di semua kamar.',
        date: '18 Maret 2026',
      ),
      PengumumanModel(
        id: '2',
        kostName: kostName,
        title: 'Libur Lebaran 2026',
        description:
            'Kantor pengelola kost akan tutup pada tanggal 30 Maret - 3 April 2026. Untuk keadaan darurat, hubungi nomor emergency.',
        date: '18 Maret 2026',
      ),
      PengumumanModel(
        id: '3',
        kostName: kostName,
        title: 'Perbaikan WiFi Selesai',
        description:
            'Perbaikan jaringan WiFi di lantai 2 dan 3 telah selesai. Kecepatan internet sekarang sudah kembali normal.',
        date: '12 Maret 2026',
      ),
    ];
  }

  List<PengumumanModel> _clonePengumuman(List<PengumumanModel> source) {
    return source.map((item) => item.copyWith()).toList();
  }

  void pilihGedungKost(GedungKostModel gedung) {
    selectedGedung.value = gedung;

    _pengumumanByGedung.putIfAbsent(
      gedung.id,
      () => _seedPengumuman(gedung.nama),
    );
    pengumumanList.value = _clonePengumuman(_pengumumanByGedung[gedung.id]!);
  }

  void kembaliKePilihGedung() {
    selectedGedung.value = null;
    pengumumanList.clear();
  }

  void _sinkronkanPengumumanKeGedungAktif() {
    final gedung = selectedGedung.value;
    if (gedung == null) {
      return;
    }

    _pengumumanByGedung[gedung.id] = _clonePengumuman(pengumumanList);
  }

  void addPengumuman(String title, String description) {
    final selected = selectedGedung.value;
    if (selected == null) {
      return;
    }

    if (title.trim().isEmpty || description.trim().isEmpty) {
      return;
    }

    pengumumanList.insert(
      0,
      PengumumanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        kostName: selected.nama,
        title: title.trim(),
        description: description.trim(),
        date: _formatDate(DateTime.now()),
      ),
    );
    _sinkronkanPengumumanKeGedungAktif();
  }

  void editPengumuman(String id, String title, String description) {
    final selected = selectedGedung.value;
    if (selected == null) {
      return;
    }

    if (title.trim().isEmpty || description.trim().isEmpty) {
      return;
    }

    final index = pengumumanList.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    pengumumanList[index] = pengumumanList[index].copyWith(
      kostName: selected.nama,
      title: title.trim(),
      description: description.trim(),
    );
    _sinkronkanPengumumanKeGedungAktif();
  }

  void deletePengumuman(String id) {
    if (selectedGedung.value == null) {
      return;
    }

    pengumumanList.removeWhere((item) => item.id == id);
    _sinkronkanPengumumanKeGedungAktif();
  }
}
