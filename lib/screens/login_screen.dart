// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../providers/favourite_provider.dart';
import '../services/login_service.dart';
import 'list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.loginService,
    required this.favouriteProvider,
    super.key,
  });

  final LoginService loginService;
  final FavouriteProvider favouriteProvider;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final bool loggedIn = await widget.loginService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;

      if (!loggedIn) {
        _showError('Username atau password salah.');
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ListScreen(
            loginService: widget.loginService,
            favouriteProvider: widget.favouriteProvider,
          ),
        ),
      );
    } on PlatformException {
      if (mounted) {
        _showError('Terjadi kesalahan saat login. Silakan coba lagi.');
      }
    } on StateError {
      if (mounted) {
        _showError('Terjadi kesalahan saat login. Silakan coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onSubmitted: (_) => _isLoading ? null : _login(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
