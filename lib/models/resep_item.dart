class ResepItem {
  const ResepItem({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    required this.caloriesPerServing,
    required this.tags,
    required this.imageUrl,
    required this.rating,
  });

  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty;
  final String cuisine;
  final int caloriesPerServing;
  final List<String> tags;
  final String imageUrl;
  final double rating;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'ingredients': ingredients,
    'instructions': instructions,
    'prepTimeMinutes': prepTimeMinutes,
    'cookTimeMinutes': cookTimeMinutes,
    'servings': servings,
    'difficulty': difficulty,
    'cuisine': cuisine,
    'caloriesPerServing': caloriesPerServing,
    'tags': tags,
    'imageUrl': imageUrl,
    'rating': rating,
  };

  factory ResepItem.fromJson(Map<String, dynamic> json) => ResepItem(
    id: json['id'] as String,
    title: json['title'] as String,
    ingredients: List<String>.from(json['ingredients'] as List<dynamic>),
    instructions: List<String>.from(json['instructions'] as List<dynamic>),
    prepTimeMinutes: json['prepTimeMinutes'] as int,
    cookTimeMinutes: json['cookTimeMinutes'] as int,
    servings: json['servings'] as int,
    difficulty: json['difficulty'] as String,
    cuisine: json['cuisine'] as String,
    caloriesPerServing: json['caloriesPerServing'] as int,
    tags: List<String>.from(json['tags'] as List<dynamic>),
    imageUrl: json['imageUrl'] as String,
    rating: (json['rating'] as num).toDouble(),
  );
}
