import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe_model.dart';
import '../core/services/firebase_service.dart';
import '../core/constants/app_constants.dart';

// Provider for managing favorite recipes with offline support
class FavoriteProvider with ChangeNotifier {
  FirebaseService? _firebaseService;
  
  // Lazy initialization of Firebase service
  FirebaseService get _firebase {
    _firebaseService ??= FirebaseService();
    return _firebaseService!;
  }
  
  List<RecipeModel> _favorites = [];
  bool _isLoading = false;
  Box? _favoritesBox;
  Box? _notesBox;

  // Getters
  List<RecipeModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  // Initialize Hive for offline storage
  Future<void> initHive() async {
    try {
      await Hive.initFlutter();
      _favoritesBox = await Hive.openBox(StorageKeys.favoritesBox);
      _notesBox = await Hive.openBox(StorageKeys.userNotesBox);
      await loadFavorites();
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  // Check if recipe is favorite
  bool isFavorite(int recipeId) {
    return _favorites.any((recipe) => recipe.id == recipeId);
  }

  // Add recipe to favorites
  Future<void> addToFavorites(RecipeModel recipe) async {
    try {
      debugPrint('Adding to favorites: ${recipe.id}');
      // Add to local storage first for offline support
      await _favoritesBox?.put(recipe.id.toString(), recipe.toJson());
      debugPrint('Saved to Hive: ${_favoritesBox?.get(recipe.id.toString())}');

      // Add to Firebase if available
      try {
        if (_firebase.isAvailable) {
          await _firebase.saveRecipe(recipe.toJson());
        }
      } catch (e) {
        debugPrint('Firebase save failed, using local storage: $e');
      }

      _favorites.add(recipe);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
    }
  }

  // Remove recipe from favorites
  Future<void> removeFromFavorites(int recipeId) async {
    try {
      // Remove from local storage
      await _favoritesBox?.delete(recipeId.toString());
      
      // Remove from Firebase if available
      try {
        if (_firebase.isAvailable) {
          await _firebase.deleteRecipe(recipeId.toString());
        }
      } catch (e) {
        debugPrint('Firebase delete failed, using local storage: $e');
      }

      _favorites.removeWhere((recipe) => recipe.id == recipeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
    }
  }

  // Load favorites from local storage and Firebase
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load from local storage first (offline support)
      if (_favoritesBox != null) {
        debugPrint('Loading favorites from Hive. Keys: ${_favoritesBox!.keys}');
        debugPrint('Raw Hive values: ${_favoritesBox!.values.toList()}');
        try {
          _favorites = _favoritesBox!.values
              .map((json) => RecipeModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        } catch (e) {
          debugPrint('Error mapping Hive data to RecipeModel: $e');
          _favorites = [];
        }
        debugPrint('Loaded favorites count: ${_favorites.length}');
      }

      // Try to sync with Firebase if available
        /// Utility: Clear all favorites from Hive (for troubleshooting)
        Future<void> clearFavoritesBox() async {
          try {
            await _favoritesBox?.clear();
            debugPrint('Favorites box cleared.');
            _favorites = [];
            notifyListeners();
          } catch (e) {
            debugPrint('Error clearing favorites box: $e');
          }
        }
      try {
        if (_firebase.isAvailable) {
          final firebaseRecipes = await _firebase.getSavedRecipes();
          
          // Merge with local storage
          for (var recipeData in firebaseRecipes) {
            final recipe = RecipeModel.fromJson(recipeData);
            if (!isFavorite(recipe.id)) {
              _favorites.add(recipe);
              await _favoritesBox?.put(recipe.id.toString(), recipe.toJson());
            }
          }
        }
      } catch (e) {
        debugPrint('Firebase sync failed, using local storage: $e');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading favorites: $e');
    }
  }

  // Save user note for a recipe
  Future<void> saveUserNote(String recipeId, String note) async {
    try {
      // Save to local storage first (offline support)
      await _notesBox?.put(recipeId, note);
      
      // Try to sync to Firebase if available
      if (_firebase.isAvailable) {
        try {
          await _firebase.saveUserNote(recipeId, note);
        } catch (e) {
          debugPrint('Firebase note save failed, using local storage: $e');
        }
      }
    } catch (e) {
      debugPrint('Error saving note: $e');
      rethrow;
    }
  }

  // Get user note for a recipe
  Future<String?> getUserNote(String recipeId) async {
    try {
      // Try local storage first (offline support)
      final localNote = _notesBox?.get(recipeId);
      if (localNote != null) {
        return localNote as String;
      }
      
      // Try Firebase if available
      if (_firebase.isAvailable) {
        final firebaseNote = await _firebase.getUserNote(recipeId);
        if (firebaseNote != null) {
          // Cache it locally
          await _notesBox?.put(recipeId, firebaseNote);
          return firebaseNote;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting note: $e');
      return null;
    }
  }

  // Delete user note
  Future<void> deleteUserNote(String recipeId) async {
    try {
      // Delete from local storage
      await _notesBox?.delete(recipeId);
      
      // Try to delete from Firebase if available
      if (_firebase.isAvailable) {
        try {
          await _firebase.deleteUserNote(recipeId);
        } catch (e) {
          debugPrint('Firebase note delete failed, using local storage: $e');
        }
      }
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }

  // Sync local favorites to Firebase
  Future<void> syncToFirebase() async {
    if (_favoritesBox == null || !_firebase.isAvailable) return;

    try {
      for (var key in _favoritesBox!.keys) {
        final recipeData = _favoritesBox!.get(key);
        if (recipeData != null) {
          await _firebase.saveRecipe(
            Map<String, dynamic>.from(recipeData),
          );
        }
      }
    } catch (e) {
      debugPrint('Error syncing to Firebase: $e');
    }
  }
}
