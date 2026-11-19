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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        scaffoldBackgroundColor: const Color(0xFFF7FBF7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF1B5E20),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
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
