import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/recipe_provider.dart';
import '../widgets/recipe_card_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../recipe_details/screens/recipe_details_screen.dart';

// Recipe results screen showing search results
// Member 1 - Recipe Search Feature (Screen 2 of 2)
class RecipeResultsScreen extends StatelessWidget {
  final String searchQuery;

  const RecipeResultsScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "$searchQuery"'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (recipeProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (recipeProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      recipeProvider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        recipeProvider.searchRecipes(searchQuery);
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (recipeProvider.recipes.isEmpty) {
            return const EmptyStateWidget(
              message: 'No recipes found.\nTry a different search term!',
              icon: Icons.search_off,
            );
          }

          return Column(
            children: [
              // Results summary
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Found ${recipeProvider.recipes.length} recipes',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Results list
              Expanded(
                child: ListView.builder(
                  itemCount: recipeProvider.recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipeProvider.recipes[index];
                    return RecipeCardWidget(
                      recipe: recipe,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailsScreen(recipe: recipe),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
