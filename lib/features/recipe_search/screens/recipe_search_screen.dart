import 'package:flutter/material.dart';
import 'package:meal_mind/features/videos/screens/cooking_video_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/recipe_provider.dart';
import '../widgets/recipe_search_bar_widget.dart';
import 'recipe_results_screen.dart';
import '../../favorites/screens/saved_recipes_screen.dart';
import '../../purchase_list/screens/purchase_list_screen.dart';
import '../../restaurants/screens/nearby_restaurants_screen.dart';

// Home screen with recipe search functionality
// Member 1 - Recipe Search Feature (Screen 1 of 2)
class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      Provider.of<RecipeProvider>(context, listen: false).searchRecipes(query);
      // Navigate to results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeResultsScreen(searchQuery: query),
        ),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<RecipeProvider>(context, listen: false).clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MealMind'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo/icon
                Icon(
                  Icons.restaurant_menu,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                // Welcome text
                const Text(
                  'Welcome to MealMind',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your smart cooking assistant',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                // Search bar
                RecipeSearchBarWidget(
                  controller: _searchController,
                  onSearch: _performSearch,
                  onClear: _clearSearch,
                ),
                const SizedBox(height: 32),
                // Motivational Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[200]!, Colors.green[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_emotions, color: Colors.green, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '“Cooking is love made visible. Eat well, live well!”',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Quick Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Icons.play_circle_fill,
                      label: 'Watch Video',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CookingVideoScreen(recipeName: ''),
                          ),
                        );
                      },
                    ),
                    _buildQuickAction(
                      context,
                      icon: Icons.shopping_cart,
                      label: 'Add Shopping List',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PurchaseListScreen(),
                          ),
                        );
                      },
                    ),
                    // _buildQuickAction(
                    //   context,
                    //   icon: Icons.restaurant_menu,
                    //   label: 'Start Cooking',
                    //   color: Colors.orange,
                    //   onTap: () {
                    //     FocusScope.of(context).requestFocus(FocusNode());
                    //   },
                    // ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
