import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

// Service for handling API calls to Spoonacular and YouTube
class ApiService {
  // Search recipes using Spoonacular API with instructions
  Future<Map<String, dynamic>> searchRecipes(String query, {int offset = 0}) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.spoonacularBaseUrl}/recipes/complexSearch'
        '?apiKey=${ApiConstants.spoonacularApiKey}'
        '&query=$query'
        '&number=${AppConstants.recipesPerPage}'
        '&offset=$offset'
        '&addRecipeInformation=true'
        '&fillIngredients=true'
        '&instructionsRequired=true'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search recipes');
      }
    } catch (e) {
      throw Exception('Error searching recipes: $e');
    }
  }
  
  // Get recipe details by ID including cooking instructions
  Future<Map<String, dynamic>> getRecipeDetails(int recipeId) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.spoonacularBaseUrl}/recipes/$recipeId/information'
        '?apiKey=${ApiConstants.spoonacularApiKey}'
        '&includeNutrition=false'
        '&addWinePairing=false'
        '&addTasteData=false'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get recipe details');
      }
    } catch (e) {
      throw Exception('Error getting recipe details: $e');
    }
  }
  
  // Search cooking videos on YouTube
  Future<Map<String, dynamic>> searchCookingVideos(String recipeName) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.youtubeBaseUrl}/search'
        '?part=snippet'
        '&q=$recipeName cooking'
        '&type=video'
        '&maxResults=10'
        '&key=${ApiConstants.youtubeApiKey}'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search videos');
      }
    } catch (e) {
      throw Exception('Error searching videos: $e');
    }
  }
}
