import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/resep_item.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/recipes';

  Future<List<ResepItem>> fetchResepItems() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> recipesJson = data['recipes'] as List<dynamic>;

      return recipesJson.map((dynamic recipe) {
        final Map<String, dynamic> recipeJson = recipe as Map<String, dynamic>;
        return ResepItem(
          id: recipeJson['id'].toString(),
          title: recipeJson['title'] as String,
          ingredients: List<String>.from(recipeJson['ingredients']),
          instructions: List<String>.from(recipeJson['instructions']),
          prepTimeMinutes: recipeJson['prepTimeMinutes'] as int,
          cookTimeMinutes: recipeJson['cookTimeMinutes'] as int,
          servings: recipeJson['servings'] as int,
          difficulty: recipeJson['difficulty'] as String,
          cuisine: recipeJson['cuisine'] as String,
          caloriesPerServing: recipeJson['caloriesPerServing'] as int,
          tags: List<String>.from(recipeJson['tags']),
          imageUrl: recipeJson['image'] as String,
          rating: (recipeJson['rating'] as num).toDouble(),
        );
      }).toList();
    } else {
      throw Exception('Failed to load recipes (HTTP ${response.statusCode}).');
    }
  }
}
