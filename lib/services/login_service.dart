import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  LoginService(this._preferences);

  static const String _loginKey = 'is_logged_in';
  final SharedPreferences _preferences;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    if (username != 'gian' || password != '016') {
      return false;
    }

    final bool saved = await _preferences.setBool(_loginKey, true);
    if (!saved) {
      throw StateError('Unable to persist the login session.');
    }
    return true;
  }

  bool isLoggedIn() => _preferences.getBool(_loginKey) ?? false;

  Future<bool> logout() => _preferences.remove(_loginKey);
}
