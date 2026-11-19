import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/favourite_provider.dart';
import 'screens/list_screen.dart';
import 'screens/login_screen.dart';
import 'services/login_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final LoginService loginService = LoginService(preferences);
  final FavouriteProvider favouriteProvider = FavouriteProvider(preferences);

  runApp(
    MyApp(
      loginService: loginService,
      favouriteProvider: favouriteProvider,
      isLoggedIn: loginService.isLoggedIn(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.loginService,
    required this.favouriteProvider,
    required this.isLoggedIn,
    super.key,
  });

  final LoginService loginService;
  final FavouriteProvider favouriteProvider;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resepin',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoggedIn
          ? ListScreen(
              loginService: loginService,
              favouriteProvider: favouriteProvider,
            )
          : LoginScreen(
              loginService: loginService,
              favouriteProvider: favouriteProvider,
            ),
    );
  }
}
