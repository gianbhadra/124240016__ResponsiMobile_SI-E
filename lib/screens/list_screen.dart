import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/resep_item.dart';
import '../providers/favourite_provider.dart';
import '../services/api_service.dart';
import '../services/login_service.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({
    required this.loginService,
    required this.favouriteProvider,
    super.key,
  });

  final LoginService loginService;
  final FavouriteProvider favouriteProvider;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<ResepItem>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = _apiService.fetchResepItems();
  }

  void _retryLoading() {
    setState(() {
      _recipesFuture = _apiService.fetchResepItems();
    });
  }

  Future<void> _logout() async {
    try {
      final bool removed = await widget.loginService.logout();
      if (!removed) {
        throw StateError('Unable to remove the login session.');
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => LoginScreen(
            loginService: widget.loginService,
            favouriteProvider: widget.favouriteProvider,
          ),
        ),
        (_) => false,
      );
    } on PlatformException {
      if (mounted) {
        _showLogoutError();
      }
    } on StateError {
      if (mounted) {
        _showLogoutError();
      }
    }
  }

  void _showLogoutError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terjadi kesalahan saat logout. Silakan coba lagi.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _removeFavourite(ResepItem recipe) async {
    try {
      await widget.favouriteProvider.toggleFavourite(recipe);
    } on PlatformException {
      if (mounted) {
        _showFavouriteError();
      }
    } on StateError {
      if (mounted) {
        _showFavouriteError();
      }
    }
  }

  void _showFavouriteError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal memperbarui favorit. Silakan coba lagi.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildRecipeList(
    List<ResepItem> recipes, {
    bool showRemoveButton = false,
  }) {
    if (recipes.isEmpty) {
      return const Center(child: Text('Belum ada resep yang tersedia.'));
    }

    return ListView.separated(
      itemCount: recipes.length,
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final ResepItem recipe = recipes[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DetailScreen(
                    recipe: recipe,
                    favouriteProvider: widget.favouriteProvider,
                  ),
                ),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                recipe.imageUrl,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _imagePlaceholder(),
              ),
            ),
            trailing: showRemoveButton
                ? IconButton(
                    onPressed: () => _removeFavourite(recipe),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Hapus dari favorit',
                  )
                : null,
            title: Text(
              recipe.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Asal: ${recipe.cuisine}'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(recipe.rating.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 76,
      height: 76,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            const Text('Data resep gagal dimuat.', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _retryLoading,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resepin'),
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semua Resep'),
              Tab(text: 'Favorit'),
            ],
          ),
        ),
        body: FutureBuilder<List<ResepItem>>(
          future: _recipesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildLoadError();
            }
            final List<ResepItem> recipes =
                snapshot.data ?? const <ResepItem>[];
            return TabBarView(
              children: [
                _buildRecipeList(recipes),
                AnimatedBuilder(
                  animation: widget.favouriteProvider,
                  builder: (context, _) => _buildRecipeList(
                    widget.favouriteProvider.favourites,
                    showRemoveButton: true,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
