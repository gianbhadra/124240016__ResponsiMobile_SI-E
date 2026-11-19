import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/resep_item.dart';
import '../providers/favourite_provider.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    required this.recipe,
    required this.favouriteProvider,
    super.key,
  });

  final ResepItem recipe;
  final FavouriteProvider favouriteProvider;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<ResepItem> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _apiService.fetchResepItem(widget.recipe.id);
  }

  void _retryLoading() {
    setState(() {
      _recipeFuture = _apiService.fetchResepItem(widget.recipe.id);
    });
  }

  Future<void> _toggleFavourite(BuildContext context, ResepItem recipe) async {
    final bool wasFavourite = widget.favouriteProvider.isFavourite(recipe.id);
    try {
      await widget.favouriteProvider.toggleFavourite(recipe);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasFavourite ? 'Dihapus dari favorit.' : 'Ditambahkan ke favorit.',
          ),
        ),
      );
    } on PlatformException {
      if (context.mounted) {
        _showFavouriteError(context);
      }
    } on StateError {
      if (context.mounted) {
        _showFavouriteError(context);
      }
    }
  }

  void _showFavouriteError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal memperbarui favorit. Silakan coba lagi.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResepItem>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        final ResepItem? recipe = snapshot.data;
        final bool isLoading =
            snapshot.connectionState == ConnectionState.waiting;

        return Scaffold(
          appBar: AppBar(
            title: Text(recipe?.title ?? widget.recipe.title),
            actions: recipe == null
                ? null
                : [
                    AnimatedBuilder(
                      animation: widget.favouriteProvider,
                      builder: (context, _) {
                        final bool isFavourite = widget.favouriteProvider
                            .isFavourite(recipe.id);
                        return IconButton(
                          onPressed: () => _toggleFavourite(context, recipe),
                          icon: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavourite ? Colors.red : null,
                          ),
                          tooltip: isFavourite
                              ? 'Hapus dari favorit'
                              : 'Tambahkan ke favorit',
                        );
                      },
                    ),
                  ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : snapshot.hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Detail resep gagal dimuat.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _retryLoading,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        recipe!.imageUrl,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 220,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            Text('Cuisine: ${recipe.cuisine}'),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(recipe.rating.toStringAsFixed(1)),
                              ],
                            ),
                            Text('Porsi: ${recipe.servings}'),
                            Text(
                              'Waktu: ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} menit',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bahan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ...recipe.ingredients.map(
                      (String ingredient) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.circle, size: 8),
                        title: Text(ingredient),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cara Membuat',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ...recipe.instructions.asMap().entries.map(
                      (MapEntry<int, String> step) => ListTile(
                        leading: CircleAvatar(child: Text('${step.key + 1}')),
                        title: Text(step.value),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
