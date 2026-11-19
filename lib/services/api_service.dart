import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/resep_item.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/recipes';
  static const Duration requestTimeout = Duration(seconds: 15);

  Future<List<ResepItem>> fetchResepItems() async {
    try {
      final response = await http
          .get(
            Uri.parse(baseUrl),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(requestTimeout);

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memuat daftar resep '
          '(HTTP ${response.statusCode}).',
        );
      }

      final dynamic decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format respons daftar resep tidak valid.');
      }

      final dynamic recipesValue = decoded['recipes'];
      if (recipesValue is! List) {
        throw const FormatException('Data "recipes" tidak ditemukan.');
      }

      return recipesValue
          .whereType<Map>()
          .map(
            (Map recipe) => _parseResepItem(Map<String, dynamic>.from(recipe)),
          )
          .toList();
    } on http.ClientException catch (error) {
      throw Exception('Tidak dapat terhubung ke API: ${error.message}');
    } on FormatException catch (error) {
      throw Exception('Respons API tidak valid: ${error.message}');
    } on Exception catch (error) {
      if (error.toString().contains('TimeoutException')) {
        throw Exception(
          'Permintaan API terlalu lama. Periksa koneksi internet.',
        );
      }
      rethrow;
    }
  }

  Future<ResepItem> fetchResepItem(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/$id'),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(requestTimeout);

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memuat detail resep '
          '(HTTP ${response.statusCode}).',
        );
      }

      final dynamic decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format respons detail resep tidak valid.');
      }

      return _parseResepItem(decoded);
    } on http.ClientException catch (error) {
      throw Exception('Tidak dapat terhubung ke API: ${error.message}');
    } on FormatException catch (error) {
      throw Exception('Respons API tidak valid: ${error.message}');
    } on Exception catch (error) {
      if (error.toString().contains('TimeoutException')) {
        throw Exception(
          'Permintaan API terlalu lama. Periksa koneksi internet.',
        );
      }
      rethrow;
    }
  }

  ResepItem _parseResepItem(Map<String, dynamic> recipeJson) => ResepItem(
    id: recipeJson['id'].toString(),
    title: (recipeJson['name'] ?? recipeJson['title'] ?? 'Resep tanpa nama')
        .toString(),
    ingredients: _stringList(recipeJson['ingredients']),
    instructions: _stringList(recipeJson['instructions']),
    prepTimeMinutes: _intValue(recipeJson['prepTimeMinutes']),
    cookTimeMinutes: _intValue(recipeJson['cookTimeMinutes']),
    servings: _intValue(recipeJson['servings']),
    difficulty: recipeJson['difficulty']?.toString() ?? 'Tidak diketahui',
    cuisine: recipeJson['cuisine']?.toString() ?? 'Tidak diketahui',
    caloriesPerServing: _intValue(recipeJson['caloriesPerServing']),
    tags: _stringList(recipeJson['tags']),
    imageUrl: recipeJson['image']?.toString() ?? '',
    rating: _doubleValue(recipeJson['rating']),
  );

  List<String> _stringList(dynamic value) => value is List
      ? value.map((item) => item.toString()).toList()
      : <String>[];

  int _intValue(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  double _doubleValue(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;
}
