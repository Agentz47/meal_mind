// API Constants
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Spoonacular API
  static const String spoonacularBaseUrl = 'https://api.spoonacular.com';
  static final spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY'];
  //2051b2555d7340ec9f617b28333e9607 #use this key if the above one stops working
  
  // YouTube API
  static const String youtubeBaseUrl = 'https://www.googleapis.com/youtube/v3';
  static final youtubeApiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  
  // Google Places API (for real restaurants)
  static const String googlePlacesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static final googlePlacesApiKey = dotenv.env['MAPS_API_KEY'] ?? ''; // Same as YouTube key
}

// App Constants
class AppConstants {
  static const String appName = 'MealMind';
  static const double defaultRadius = 5000; // 5km for restaurant search
  static const int recipesPerPage = 20;
}

// Storage Keys
class StorageKeys {
  static const String favoritesBox = 'favorites_box';
  static const String savedRecipesBox = 'saved_recipes_box';
  static const String userNotesBox = 'user_notes_box';
}
