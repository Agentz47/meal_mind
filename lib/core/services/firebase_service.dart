import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Service for Firebase Firestore operations
class FirebaseService {
  FirebaseFirestore? _firestore;
  
  FirebaseService() {
    try {
      // Only initialize if Firebase app exists
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      // Firebase not initialized, will work in offline mode
      _firestore = null;
    }
  }
  
  bool get isAvailable => _firestore != null;
  
  // Collection references
  final String savedRecipesCollection = 'saved_recipes';
  final String userNotesCollection = 'user_notes';
  
  // Create - Save a recipe
  Future<void> saveRecipe(Map<String, dynamic> recipeData) async {
    if (_firestore == null) return; // Skip if Firebase not available
    try {
      await _firestore!
          .collection(savedRecipesCollection)
          .doc(recipeData['id'].toString())
          .set(recipeData);
    } catch (e) {
      throw Exception('Error saving recipe: $e');
    }
  }
  
  // Read - Get all saved recipes
  Future<List<Map<String, dynamic>>> getSavedRecipes() async {
    if (_firestore == null) return []; // Return empty if Firebase not available
    try {
      final snapshot = await _firestore!
          .collection(savedRecipesCollection)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Error getting saved recipes: $e');
    }
  }
  
  // Update - Update recipe data
  Future<void> updateRecipe(String recipeId, Map<String, dynamic> updates) async {
    if (_firestore == null) return; // Skip if Firebase not available
    try {
      await _firestore!
          .collection(savedRecipesCollection)
          .doc(recipeId)
          .update(updates);
    } catch (e) {
      throw Exception('Error updating recipe: $e');
    }
  }
  
  // Delete - Remove a saved recipe
  Future<void> deleteRecipe(String recipeId) async {
    if (_firestore == null) return; // Skip if Firebase not available
    try {
      await _firestore!
          .collection(savedRecipesCollection)
          .doc(recipeId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting recipe: $e');
    }
  }
  
  // Create/Update - Save user note for a recipe
  Future<void> saveUserNote(String recipeId, String note) async {
    if (_firestore == null) return; // Skip if Firebase not available
    try {
      await _firestore!
          .collection(userNotesCollection)
          .doc(recipeId)
          .set({
        'recipeId': recipeId,
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error saving note: $e');
    }
  }
  
  // Read - Get user note for a recipe
  Future<String?> getUserNote(String recipeId) async {
    if (_firestore == null) return null; // Return null if Firebase not available
    try {
      final doc = await _firestore!
          .collection(userNotesCollection)
          .doc(recipeId)
          .get();
      
      if (doc.exists) {
        return doc.data()?['note'];
      }
      return null;
    } catch (e) {
      throw Exception('Error getting note: $e');
    }
  }
  
  // Delete - Remove user note
  Future<void> deleteUserNote(String recipeId) async {
    if (_firestore == null) return; // Skip if Firebase not available
    try {
      await _firestore!
          .collection(userNotesCollection)
          .doc(recipeId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting note: $e');
    }
  }
}
