import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../core/services/api_service.dart';

// Provider for managing recipe search state
class RecipeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<RecipeModel> _recipes = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';

  // Getters
  List<RecipeModel> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;

  // Search for recipes
  Future<void> searchRecipes(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _error = null;
    _currentQuery = query;
    notifyListeners();

    try {
      final result = await _apiService.searchRecipes(query);
      _recipes = (result['results'] as List)
          .map((json) => RecipeModel.fromJson(json))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to search recipes. Please check your API key and internet connection.';
      _isLoading = false;
      _recipes = [];
      notifyListeners();
    }
  }

  // Load more recipes (pagination)
  Future<void> loadMoreRecipes() async {
    if (_currentQuery.isEmpty || _isLoading) return;

    try {
      final offset = _recipes.length;
      final result = await _apiService.searchRecipes(_currentQuery, offset: offset);
      final newRecipes = (result['results'] as List)
          .map((json) => RecipeModel.fromJson(json))
          .toList();
      _recipes.addAll(newRecipes);
      notifyListeners();
    } catch (e) {
      // Silently fail for pagination
      debugPrint('Error loading more recipes: $e');
    }
  }

  // Get detailed recipe information
  Future<RecipeModel?> getRecipeDetails(int recipeId) async {
    try {
      final result = await _apiService.getRecipeDetails(recipeId);
      return RecipeModel.fromJson(result);
    } catch (e) {
      _error = 'Failed to get recipe details';
      notifyListeners();
      return null;
    }
  }

  // Clear search results
  void clearSearch() {
    _recipes = [];
    _currentQuery = '';
    _error = null;
    notifyListeners();
  }
}
