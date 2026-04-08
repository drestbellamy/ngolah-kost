import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../modules/login/models/login_user_model.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  static const _keyId = 'auth_user_id';
  static const _keyUsername = 'auth_username';
  static const _keyRole = 'auth_role';
  static const _keyIsActive = 'auth_is_active';

  final Rxn<LoginUserModel> _currentUser = Rxn<LoginUserModel>();

  LoginUserModel? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;
  bool get isAdmin => _currentUser.value?.isAdmin ?? false;
  bool get isUser => _currentUser.value?.isUser ?? false;
  String get initialRoute {
    if (!isLoggedIn) return Routes.landing;
    if (isAdmin) return Routes.home;
    return Routes.userHome;
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyId);
    final username = prefs.getString(_keyUsername);
    final role = prefs.getString(_keyRole);
    final isActive = prefs.getBool(_keyIsActive);

    if (id == null || username == null || role == null) {
      _currentUser.value = null;
      return;
    }

    _currentUser.value = LoginUserModel(
      id: id,
      username: username,
      role: role,
      isActive: isActive ?? true,
    );
  }

  Future<void> setUser(LoginUserModel user) async {
    _currentUser.value = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyId, user.id);
    await prefs.setString(_keyUsername, user.username);
    await prefs.setString(_keyRole, user.role);
    await prefs.setBool(_keyIsActive, user.isActive);
  }

  Future<void> clearUser() async {
    _currentUser.value = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyIsActive);
  }
}
