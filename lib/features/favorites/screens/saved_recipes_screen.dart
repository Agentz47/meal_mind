import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/favorite_provider.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../recipe_search/widgets/recipe_card_widget.dart';
import '../../recipe_details/screens/recipe_details_screen.dart';

// Screen showing saved/favorite recipes with offline support
// Member 3 - Favorites Feature
class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await Provider.of<FavoriteProvider>(context, listen: false)
        .loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (favoriteProvider.favorites.isEmpty) {
            return const EmptyStateWidget(
              message:
                  'No saved recipes yet.\nSave your favorite recipes to view them here!',
              icon: Icons.favorite_border,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadFavorites,
            child: ListView.builder(
              itemCount: favoriteProvider.favorites.length,
              itemBuilder: (context, index) {
                final recipe = favoriteProvider.favorites[index];
                return Dismissible(
                  key: Key(recipe.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  onDismissed: (direction) {
                    favoriteProvider.removeFromFavorites(recipe.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${recipe.title} removed from favorites'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            favoriteProvider.addToFavorites(recipe);
                          },
                        ),
                      ),
                    );
                  },
                  child: RecipeCardWidget(
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
