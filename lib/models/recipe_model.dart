// Model class representing a recipe
class RecipeModel {
  final int id;
  final String title;
  final String image;
  final int readyInMinutes;
  final int servings;
  final String summary;
  final List<Ingredient> ingredients;
  final List<CookingStep> steps;
  final bool isFavorite;

  RecipeModel({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.summary,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false,
  });

  // Create RecipeModel from JSON
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredientsList = [];
    if (json['extendedIngredients'] != null) {
      ingredientsList = (json['extendedIngredients'] as List)
          .map((i) => Ingredient.fromJson(i))
          .toList();
    }

    List<CookingStep> stepsList = [];
    if (json['analyzedInstructions'] != null &&
        (json['analyzedInstructions'] as List).isNotEmpty) {
      final instructions = json['analyzedInstructions'][0];
      if (instructions['steps'] != null) {
        stepsList = (instructions['steps'] as List)
            .map((s) => CookingStep.fromJson(s))
            .toList();
      }
    }

    return RecipeModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 1,
      summary: json['summary'] ?? '',
      ingredients: ingredientsList,
      steps: stepsList,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Convert RecipeModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'readyInMinutes': readyInMinutes,
      'servings': servings,
      'summary': summary,
      'extendedIngredients': ingredients.map((i) => i.toJson()).toList(),
      'analyzedInstructions': [
        {
          'steps': steps.map((s) => s.toJson()).toList(),
        }
      ],
      'isFavorite': isFavorite,
    };
  }

  // Create a copy with modified fields
  RecipeModel copyWith({
    int? id,
    String? title,
    String? image,
    int? readyInMinutes,
    int? servings,
    String? summary,
    List<Ingredient>? ingredients,
    List<CookingStep>? steps,
    bool? isFavorite,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      readyInMinutes: readyInMinutes ?? this.readyInMinutes,
      servings: servings ?? this.servings,
      summary: summary ?? this.summary,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Model for recipe ingredients
class Ingredient {
  final int id;
  final String name;
  final double amount;
  final String unit;

  Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }
}

// Model for cooking steps
class CookingStep {
  final int number;
  final String step;

  CookingStep({
    required this.number,
    required this.step,
  });

  factory CookingStep.fromJson(Map<String, dynamic> json) {
    return CookingStep(
      number: json['number'] ?? 0,
      step: json['step'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'step': step,
    };
  }
}
