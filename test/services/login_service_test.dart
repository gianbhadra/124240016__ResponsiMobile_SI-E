import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:resepin/services/login_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('accepts gian/016 and keeps the session in preferences', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = LoginService(preferences);

    expect(await service.login(username: 'gian', password: '016'), isTrue);
    expect(LoginService(preferences).isLoggedIn(), isTrue);

    await service.logout();
    expect(service.isLoggedIn(), isFalse);
  });

  test('rejects credentials that do not match', () async {
    final preferences = await SharedPreferences.getInstance();
    final service = LoginService(preferences);

    expect(await service.login(username: 'gian', password: '16'), isFalse);
    expect(service.isLoggedIn(), isFalse);
  });
}
