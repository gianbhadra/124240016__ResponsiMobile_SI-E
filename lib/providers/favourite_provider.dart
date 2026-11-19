import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/resep_item.dart';

class FavouriteProvider extends ChangeNotifier {
  FavouriteProvider(this._preferences) {
    final List<String> storedRecipes =
        _preferences.getStringList(_storageKey) ?? const <String>[];
    _favourites = storedRecipes
        .map(
          (String storedRecipe) => ResepItem.fromJson(
            jsonDecode(storedRecipe) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static const String _storageKey = 'favourite_recipes';
  final SharedPreferences _preferences;
  late List<ResepItem> _favourites;

  List<ResepItem> get favourites => List<ResepItem>.unmodifiable(_favourites);

  bool isFavourite(String recipeId) =>
      _favourites.any((ResepItem recipe) => recipe.id == recipeId);

  Future<void> toggleFavourite(ResepItem recipe) async {
    final List<ResepItem> updatedFavourites = List<ResepItem>.of(_favourites);
    final int existingIndex = updatedFavourites.indexWhere(
      (ResepItem favourite) => favourite.id == recipe.id,
    );

    if (existingIndex >= 0) {
      updatedFavourites.removeAt(existingIndex);
    } else {
      updatedFavourites.add(recipe);
    }

    final bool saved = await _preferences.setStringList(
      _storageKey,
      updatedFavourites
          .map((ResepItem favourite) => jsonEncode(favourite.toJson()))
          .toList(),
    );
    if (!saved) {
      throw StateError('Unable to persist favourite recipes.');
    }

    _favourites = updatedFavourites;
    notifyListeners();
  }
}
