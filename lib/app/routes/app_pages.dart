import 'package:get/get.dart';
import '../modules/landing/bindings/landing_binding.dart';
import '../modules/landing/views/landing_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/kost/bindings/kost_binding.dart';
import '../modules/kost/views/kost_view.dart';
import '../modules/kamar/bindings/kamar_binding.dart';
import '../modules/kamar/views/kamar_view.dart';
import '../modules/penghuni/bindings/penghuni_binding.dart';
import '../modules/penghuni/views/penghuni_view.dart';
import '../modules/penghuni/views/penghuni_detail_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/kelola_tagihan/bindings/kelola_tagihan_binding.dart';
import '../modules/kelola_tagihan/views/kelola_tagihan_view.dart';
import '../modules/metode_pembayaran/bindings/metode_pembayaran_binding.dart';
import '../modules/metode_pembayaran/views/metode_pembayaran_view.dart';
import '../modules/metode_pembayaran/controllers/tambah_metode_pembayaran_controller.dart';
import '../modules/metode_pembayaran/views/tambah_metode_pembayaran_view.dart';
import '../modules/ringkasan_keuangan/bindings/ringkasan_keuangan_binding.dart';
import '../modules/ringkasan_keuangan/views/ringkasan_keuangan_view.dart';
import '../modules/ringkasan_keuangan/bindings/detail_keuangan_kost_binding.dart';
import '../modules/ringkasan_keuangan/views/detail_keuangan_kost_view.dart';
import '../modules/kelola_pengumuman/bindings/kelola_pengumuman_binding.dart';
import '../modules/kelola_pengumuman/views/kelola_pengumuman_view.dart';
import '../modules/kelola_peraturan/bindings/kelola_peraturan_binding.dart';
import '../modules/kelola_peraturan/views/kelola_peraturan_view.dart';
import '../modules/kamar/bindings/informasi_kamar_binding.dart';
import '../modules/kamar/views/informasi_kamar_view.dart';
import '../modules/kamar/bindings/tambah_penghuni_binding.dart';
import '../modules/kamar/views/tambah_penghuni_view.dart';
import '../modules/user_home/bindings/user_home_binding.dart';
import '../modules/user_home/views/user_home_view.dart';
import '../modules/user_history_pembayaran/bindings/user_history_pembayaran_binding.dart';
import '../modules/user_history_pembayaran/views/user_history_pembayaran_view.dart';
import '../modules/user_tagihan/bindings/user_tagihan_binding.dart';
import '../modules/user_tagihan/views/user_tagihan_view.dart';
import '../modules/user_info/bindings/user_info_binding.dart';
import '../modules/user_info/views/user_info_view.dart';
import '../modules/user_profil/bindings/user_profil_binding.dart';
import '../modules/user_profil/views/user_profil_view.dart';
import '../core/middleware/auth_middleware.dart';
import '../core/middleware/role_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.landing;

  static final routes = [
    GetPage(
      name: Routes.landing,
      page: () => const LandingView(),
      binding: LandingBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.kost,
      page: () => const KostView(),
      binding: KostBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.kamar,
      page: () => const KamarView(),
      binding: KamarBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.penghuni,
      page: () => const PenghuniView(),
      binding: PenghuniBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.penghuniDetail,
      page: () => const PenghuniDetailView(),
      binding: PenghuniBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.profil,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.kelolaTagihan,
      page: () => const KelolaTagihanView(),
      binding: KelolaTagihanBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.metodePembayaran,
      page: () => const MetodePembayaranView(),
      binding: MetodePembayaranBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.tambahMetodePembayaran,
      page: () => const TambahMetodePembayaranView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TambahMetodePembayaranController>(
          () => TambahMetodePembayaranController(),
        );
      }),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.editMetodePembayaran,
      page: () => const TambahMetodePembayaranView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TambahMetodePembayaranController>(
          () => TambahMetodePembayaranController(),
        );
      }),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.kelolaPengumuman,
      page: () => const KelolaPengumumanView(),
      binding: KelolaPengumumanBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.kelolaPeraturan,
      page: () => const KelolaPeraturanView(),
      binding: KelolaPeraturanBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.informasiKamar,
      page: () => const InformasiKamarView(),
      binding: InformasiKamarBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.tambahPenghuni,
      page: () => const TambahPenghuniView(),
      binding: TambahPenghuniBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.userHome,
      page: () => const UserHomeView(),
      binding: UserHomeBinding(),
      middlewares: [AuthMiddleware(), UserOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.userHistoryPembayaran,
      page: () => const UserHistoryPembayaranView(),
      binding: UserHistoryPembayaranBinding(),
      middlewares: [AuthMiddleware(), UserOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.ringkasanKeuangan,
      page: () => const RingkasanKeuanganView(),
      binding: RingkasanKeuanganBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.detailKeuanganKost,
      page: () => const DetailKeuanganKostView(),
      binding: DetailKeuanganKostBinding(),
      middlewares: [AuthMiddleware(), AdminOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.userTagihan,
      page: () => const UserTagihanView(),
      binding: UserTagihanBinding(),
      middlewares: [AuthMiddleware(), UserOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.userInfo,
      page: () => const UserInfoView(),
      binding: UserInfoBinding(),
      middlewares: [AuthMiddleware(), UserOnlyMiddleware()],
    ),
    GetPage(
      name: Routes.userProfil,
      page: () => const UserProfilView(),
      binding: UserProfilBinding(),
      middlewares: [AuthMiddleware(), UserOnlyMiddleware()],
    ),
  ];
}
