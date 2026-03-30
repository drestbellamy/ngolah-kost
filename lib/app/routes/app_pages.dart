import 'package:get/get.dart';
import '../modules/landing/bindings/landing_binding.dart';
import '../modules/landing/views/landing_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/kost/bindings/kost_binding.dart';
import '../modules/kost/views/kost_view.dart';
import '../modules/penghuni/bindings/penghuni_binding.dart';
import '../modules/penghuni/views/penghuni_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/kelola_tagihan/bindings/kelola_tagihan_binding.dart';
import '../modules/kelola_tagihan/views/kelola_tagihan_view.dart';
import '../modules/kelola_pengumuman/bindings/kelola_pengumuman_binding.dart';
import '../modules/kelola_pengumuman/views/kelola_pengumuman_view.dart';
import '../modules/kelola_peraturan/bindings/kelola_peraturan_binding.dart';
import '../modules/kelola_peraturan/views/kelola_peraturan_view.dart';
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
    ),
    GetPage(
      name: Routes.kost,
      page: () => const KostView(),
      binding: KostBinding(),
    ),
    GetPage(
      name: Routes.penghuni,
      page: () => const PenghuniView(),
      binding: PenghuniBinding(),
    ),
    GetPage(
      name: Routes.profil,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: Routes.kelolaTagihan,
      page: () => const KelolaTagihanView(),
      binding: KelolaTagihanBinding(),
    ),
    GetPage(
      name: Routes.kelolaPengumuman,
      page: () => const KelolaPengumumanView(),
      binding: KelolaPengumumanBinding(),
    ),
    GetPage(
      name: Routes.kelolaPeraturan,
      page: () => const KelolaPeraturanView(),
      binding: KelolaPeraturanBinding(),
    ),
  ];
}
