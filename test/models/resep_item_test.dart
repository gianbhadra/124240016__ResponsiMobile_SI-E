import 'package:flutter_test/flutter_test.dart';

import 'package:resepin/models/resep_item.dart';

void main() {
  test('parses DummyJSON name field as recipe title', () {
    final recipe = ResepItem.fromJson({
      'id': 1,
      'name': 'Classic Margherita Pizza',
      'ingredients': <dynamic>['Pizza dough'],
      'instructions': <dynamic>['Bake it'],
      'prepTimeMinutes': 20,
      'cookTimeMinutes': 15,
      'servings': 4,
      'difficulty': 'Easy',
      'cuisine': 'Italian',
      'caloriesPerServing': 300,
      'tags': <dynamic>['Pizza'],
      'image': 'https://example.com/pizza.webp',
      'rating': 4.6,
    });

    expect(recipe.id, '1');
    expect(recipe.title, 'Classic Margherita Pizza');
    expect(recipe.cuisine, 'Italian');
    expect(recipe.rating, 4.6);
  });
}
