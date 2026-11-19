import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:resepin/models/resep_item.dart';
import 'package:resepin/providers/favourite_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('favourites persist and can be removed from the stored list', () async {
    final preferences = await SharedPreferences.getInstance();
    final provider = FavouriteProvider(preferences);
    final recipe = ResepItem(
      id: '1',
      title: 'Test recipe',
      ingredients: const ['rice'],
      instructions: const ['Cook it'],
      prepTimeMinutes: 5,
      cookTimeMinutes: 10,
      servings: 2,
      difficulty: 'Easy',
      cuisine: 'Test',
      caloriesPerServing: 100,
      tags: const ['test'],
      imageUrl: 'https://example.com/image.jpg',
      rating: 4.5,
    );

    await provider.toggleFavourite(recipe);
    final restoredProvider = FavouriteProvider(preferences);
    expect(restoredProvider.favourites, hasLength(1));
    expect(restoredProvider.favourites.single.title, 'Test recipe');

    await restoredProvider.toggleFavourite(recipe);
    expect(restoredProvider.favourites, isEmpty);
    expect(FavouriteProvider(preferences).favourites, isEmpty);
  });
}
