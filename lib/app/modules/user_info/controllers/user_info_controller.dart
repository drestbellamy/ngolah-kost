import 'package:get/get.dart';

class UserInfoController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;

  final RxList<Announcement> announcements = [
    Announcement(
      title: 'Pemeliharaan Air',
      content:
          'Air akan dimatikan sementara pada tanggal 22 Maret 2026 pukul 08:00 - 12:00 untuk pemeliharaan rutin sistem water heater di semua kamar. Harap simpan persediaan air.',
      date: '18 Maret 2026',
      type: AnnouncementType.pemeliharaan,
    ),
    Announcement(
      title: 'Libur Lebaran 2026',
      content:
          'Kantor pengelola kost akan tutup pada tanggal 30 Maret - 3 April 2026. Untuk keadaan darurat, hubungi nomor emergency: 0812-3456-7890 (24 jam).',
      date: '15 Maret 2026',
      type: AnnouncementType.libur,
    ),
    Announcement(
      title: 'Pembayaran Bulan April',
      content:
          'Pembayaran sewa bulan April 2026 sudah dapat dilakukan mulai tanggal 15 Maret. Jatuh tempo tetap tanggal 5 April 2026. Mohon segera lakukan pembayaran.',
      date: '14 Maret 2026',
      type: AnnouncementType.pembayaran,
    ),
    Announcement(
      title: 'Perbaikan WIFI Selesai',
      content:
          'Perbaikan jaringan WiFi di lantai 2 dan 3 telah selesai. Kecepatan internet sekarang sudah kembali normal. Terima kasih atas kesabaran Anda.',
      date: '12 Maret 2026',
      type: AnnouncementType.fasilitas,
    ),
    Announcement(
      title: 'Tata Tertib Parkir Baru',
      content:
          'Mulai 1 April 2026, semua kendaraan wajib memiliki stiker parkir. Silakan ambil stiker di kantor pengelola (gratis). Kendaraan tanpa stiker tidak diperkenankan parkir.',
      date: '10 Maret 2026',
      type: AnnouncementType.peraturan,
    ),
  ].obs;

  final RxList<Rule> rules = [
    Rule(
      title: 'Jam Malam & Keamanan',
      items: [
        'Jam malam pukul 22:00 WIB untuk tamu',
        'Pintu utama ditutup pukul 23:00 WIB (gunakan kunci kamar untuk akses)',
        'CCTV aktif 24 jam di area umum',
        'Wajib mengisi buku tamu untuk tamu yang menginap',
        'Maksimal 2 tamu per kamar',
      ],
      type: RuleType.jamMalam,
    ),
    Rule(
      title: 'Kebersihan & Kerapihan',
      items: [
        'Buang sampah di tempat yang telah disediakan',
        'Jaga kebersihan kamar mandi bersama',
        'Tidak boleh menjemur pakaian di balkon depan',
        'Area jemuran tersedia di lantai atas',
        'Pembersihan kamar mandi umum setiap hari pukul 08:00',
      ],
      type: RuleType.kebersihan,
    ),
    Rule(
      title: 'Fasilitas Umum',
      items: [
        'WiFi tersedia 24 jam (username & password di papan pengumuman)',
        'Dapur bersama dapat digunakan hingga pukul 22:00',
        'Ruang tamu dapat digunakan hingga pukul 23:00',
        'Mesin cuci tersedia (Rp 5.000/kali pakai)',
        'Tidak boleh membawa barang elektronik berlebihan ke kamar',
      ],
      type: RuleType.fasilitas,
    ),
    Rule(
      title: 'Parkir & Kendaraan',
      items: [
        'Parkir motor/mobil hanya di area yang ditentukan',
        'Wajib memiliki stiker parkir (ambil di kantor)',
        'Tidak boleh parkir di area jalan atau pintu darurat',
        'Kendaraan tamu wajib lapor ke petugas',
        'Kehilangan kendaraan bukan tanggung jawab pengelola',
      ],
      type: RuleType.kendaraan,
    ),
    Rule(
      title: 'Larangan',
      items: [
        'Dilarang membawa senjata tajam, narkoba, atau minuman keras',
        'Dilarang berjudi atau melakukan kegiatan ilegal',
        'Dilarang membuat keributan setelah pukul 22:00',
        'Dilarang memelihara binatang peliharaan',
        'Dilarang memasak dahi di dalam kamar',
      ],
      type: RuleType.larangan,
    ),
    Rule(
      title: 'Penting!',
      items: [
        'Mohon untuk mematuhi semua peraturan yang berlaku demi kenyamanan bersama. Pelanggaran terhadap peraturan dapat berakibat teguran, denda, hingga pengeluaran dari kost.',
      ],
      type: RuleType.penting,
    ),
  ].obs;

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }
}

enum AnnouncementType { pemeliharaan, libur, pembayaran, fasilitas, peraturan }

enum RuleType { jamMalam, kebersihan, fasilitas, kendaraan, larangan, penting }

class Announcement {
  final String title;
  final String content;
  final String date;
  final AnnouncementType type;

  Announcement({
    required this.title,
    required this.content,
    required this.date,
    required this.type,
  });
}

class Rule {
  final String title;
  final List<String> items;
  final RuleType type;

  Rule({required this.title, required this.items, required this.type});
}
