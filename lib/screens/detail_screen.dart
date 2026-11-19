import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/resep_item.dart';
import '../providers/favourite_provider.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    required this.recipe,
    required this.favouriteProvider,
    super.key,
  });

  final ResepItem recipe;
  final FavouriteProvider favouriteProvider;

  Future<void> _toggleFavourite(BuildContext context) async {
    final bool wasFavourite = favouriteProvider.isFavourite(recipe.id);
    try {
      await favouriteProvider.toggleFavourite(recipe);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          AnimatedBuilder(
            animation: favouriteProvider,
            builder: (context, _) {
              final bool isFavourite = favouriteProvider.isFavourite(recipe.id);
              return IconButton(
                onPressed: () => _toggleFavourite(context),
                icon: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              recipe.imageUrl,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 220,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(recipe.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Asal: ${recipe.cuisine}'),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(recipe.rating.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 20),
          Text('Bahan', style: Theme.of(context).textTheme.titleLarge),
          ...recipe.ingredients.map(
            (String ingredient) => ListTile(
              dense: true,
              leading: const Icon(Icons.circle, size: 8),
              title: Text(ingredient),
            ),
          ),
          const SizedBox(height: 12),
          Text('Cara Membuat', style: Theme.of(context).textTheme.titleLarge),
          ...recipe.instructions.asMap().entries.map(
            (MapEntry<int, String> step) => ListTile(
              leading: CircleAvatar(child: Text('${step.key + 1}')),
              title: Text(step.value),
            ),
          ),
        ],
      ),
    );
  }
}
