import 'package:get/get.dart';
import '../../../../repositories/repository_factory.dart';
import '../../../../repositories/kost_repository.dart';
import '../../../../repositories/pengumuman_repository.dart';

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
  final KostRepository _kostRepo;
  final PengumumanRepository _pengumumanRepo;

  KelolaPengumumanController({
    KostRepository? kostRepository,
    PengumumanRepository? pengumumanRepository,
  }) : _kostRepo = kostRepository ?? RepositoryFactory.instance.kostRepository,
       _pengumumanRepo =
           pengumumanRepository ??
           RepositoryFactory.instance.pengumumanRepository;

  final gedungKostList = <GedungKostModel>[].obs;

  final selectedGedung = Rxn<GedungKostModel>();
  final pengumumanList = <PengumumanModel>[].obs;
  final pengumumanCountByKost = <String, int>{}.obs;
  final isLoadingGedung = false.obs;
  final isLoadingPengumuman = false.obs;
  final isSavingPengumuman = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadGedungKost();
  }

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

  Future<void> loadGedungKost() async {
    isLoadingGedung.value = true;
    errorMessage.value = null;

    try {
      final kosts = await _kostRepo.getKostList();
      final mapped = kosts
          .map(
            (kost) => GedungKostModel(
              id: kost.id,
              nama: kost.name.trim().isEmpty ? 'Kost' : kost.name.trim(),
              alamat: kost.address.trim().isEmpty ? '-' : kost.address.trim(),
              totalKamar: kost.roomCount,
            ),
          )
          .toList();

      gedungKostList.assignAll(mapped);
      await _loadPengumumanCounts(mapped);

      final activeGedung = selectedGedung.value;
      if (activeGedung != null) {
        final refreshed = mapped.firstWhereOrNull(
          (item) => item.id == activeGedung.id,
        );
        if (refreshed == null) {
          kembaliKePilihGedung();
        } else {
          selectedGedung.value = refreshed;
        }
      }
    } catch (_) {
      errorMessage.value = 'Gagal memuat daftar kost.';
      gedungKostList.clear();
      pengumumanCountByKost.clear();
      kembaliKePilihGedung();
    } finally {
      isLoadingGedung.value = false;
    }
  }

  Future<void> _loadPengumumanCounts(List<GedungKostModel> gedungList) async {
    if (gedungList.isEmpty) {
      pengumumanCountByKost.clear();
      return;
    }

    final pairs = await Future.wait(
      gedungList.map((gedung) async {
        final count = await _pengumumanRepo.getPengumumanCountByKostId(
          gedung.id,
        );
        return MapEntry(gedung.id, count);
      }),
    );

    pengumumanCountByKost.assignAll({
      for (final pair in pairs) pair.key: pair.value,
    });
  }

  Future<void> pilihGedungKost(GedungKostModel gedung) async {
    selectedGedung.value = gedung;
    await _loadPengumumanByGedung(gedung);
  }

  void kembaliKePilihGedung() {
    selectedGedung.value = null;
    pengumumanList.clear();
    errorMessage.value = null;
  }

  Future<void> refreshPengumumanAktif() async {
    final gedung = selectedGedung.value;
    if (gedung == null) return;

    await _loadPengumumanByGedung(gedung);
  }

  Future<void> _loadPengumumanByGedung(GedungKostModel gedung) async {
    isLoadingPengumuman.value = true;
    errorMessage.value = null;

    try {
      final rows = await _pengumumanRepo.getPengumumanList(kostId: gedung.id);
      final mapped = rows
          .map((row) {
            final title = (row['judul'] ?? row['title'] ?? '')
                .toString()
                .trim();
            final description =
                (row['deskripsi'] ??
                        row['description'] ??
                        row['isi'] ??
                        row['content'] ??
                        '')
                    .toString()
                    .trim();

            final rawKostName = (row['nama_kost'] ?? row['kost_name'] ?? '')
                .toString()
                .trim();
            final kostName = rawKostName.isEmpty ? gedung.nama : rawKostName;

            final createdAtRaw =
                row['tanggal']?.toString() ??
                row['created_at']?.toString() ??
                '';
            final createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();

            return PengumumanModel(
              id: row['id']?.toString() ?? '',
              kostName: kostName,
              title: title,
              description: description,
              date: _formatDate(createdAt),
            );
          })
          .where((item) => item.id.isNotEmpty)
          .toList();

      pengumumanList.assignAll(mapped);
      pengumumanCountByKost[gedung.id] = mapped.length;
    } catch (_) {
      errorMessage.value = 'Gagal memuat data pengumuman.';
      pengumumanList.clear();
    } finally {
      isLoadingPengumuman.value = false;
    }
  }

  int getPengumumanCountForKost(String kostId) {
    return pengumumanCountByKost[kostId] ?? 0;
  }

  Future<bool> addPengumuman(String title, String description) async {
    final selected = selectedGedung.value;
    if (selected == null) {
      Get.snackbar('Error', 'Pilih gedung kost terlebih dahulu');
      return false;
    }

    final judul = title.trim();
    final deskripsi = description.trim();
    if (judul.isEmpty || deskripsi.isEmpty) {
      Get.snackbar('Error', 'Judul dan deskripsi wajib diisi');
      return false;
    }

    try {
      isSavingPengumuman.value = true;
      await _pengumumanRepo.createPengumuman(
        kostId: selected.id,
        judul: judul,
        isi: deskripsi,
      );
      await _loadPengumumanByGedung(selected);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        _resolveErrorMessage(e, 'Gagal menambahkan pengumuman'),
      );
      return false;
    } finally {
      isSavingPengumuman.value = false;
    }
  }

  Future<bool> editPengumuman(
    String id,
    String title,
    String description,
  ) async {
    final selected = selectedGedung.value;
    if (selected == null) {
      Get.snackbar('Error', 'Pilih gedung kost terlebih dahulu');
      return false;
    }

    final judul = title.trim();
    final deskripsi = description.trim();
    if (judul.isEmpty || deskripsi.isEmpty) {
      Get.snackbar('Error', 'Judul dan deskripsi wajib diisi');
      return false;
    }

    try {
      isSavingPengumuman.value = true;
      await _pengumumanRepo.updatePengumuman(
        id: id,
        judul: judul,
        isi: deskripsi,
      );
      await _loadPengumumanByGedung(selected);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        _resolveErrorMessage(e, 'Gagal memperbarui pengumuman'),
      );
      return false;
    } finally {
      isSavingPengumuman.value = false;
    }
  }

  Future<bool> deletePengumuman(String id) async {
    final selected = selectedGedung.value;
    if (selected == null) {
      Get.snackbar('Error', 'Pilih gedung kost terlebih dahulu');
      return false;
    }

    try {
      isSavingPengumuman.value = true;
      await _pengumumanRepo.deletePengumuman(id);
      await _loadPengumumanByGedung(selected);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        _resolveErrorMessage(e, 'Gagal menghapus pengumuman'),
      );
      return false;
    } finally {
      isSavingPengumuman.value = false;
    }
  }

  String _resolveErrorMessage(Object error, String fallback) {
    final raw = error.toString().trim();
    if (raw.isEmpty) return fallback;

    var message = raw;
    if (message.startsWith('Exception:')) {
      message = message.substring('Exception:'.length).trim();
    }

    if (message.length > 180) {
      message = '${message.substring(0, 180)}...';
    }

    return message.isEmpty ? fallback : message;
  }
}
