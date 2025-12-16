import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/recipe_note_card_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../models/recipe_model.dart';
import '../../providers/favorite_provider.dart';
import '../recipe_details/screens/recipe_details_screen.dart';

// Screen for displaying saved/favorite recipes with notes
class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load favorites when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteProvider>().loadFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecipeModel> _filterRecipes(List<RecipeModel> recipes) {
    if (_searchQuery.isEmpty) {
      return recipes;
    }
    
    return recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             recipe.summary.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _navigateToRecipeDetails(RecipeModel recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(recipe: recipe),
      ),
    );
  }

  void _removeFromFavorites(RecipeModel recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Recipe'),
          content: Text('Remove "${recipe.title}" from your saved recipes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<FavoriteProvider>().removeFromFavorites(recipe.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${recipe.title} removed from favorites'),
                    backgroundColor: Colors.orange,
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        context.read<FavoriteProvider>().addToFavorites(recipe);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _syncWithFirebase() async {
    try {
      await context.read<FavoriteProvider>().syncToFirebase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synced with cloud successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearAllFavorites() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Saved Recipes'),
          content: const Text(
            'Are you sure you want to remove all saved recipes? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<FavoriteProvider>().clearFavoritesBox();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All saved recipes cleared'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _RecipeSearchDelegate(),
              );
            },
          ),
          
          // Sync button
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncWithFirebase,
            tooltip: 'Sync with cloud',
          ),
          
          // Menu for additional options
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'clear_all':
                  _clearAllFavorites();
                  break;
                case 'refresh':
                  context.read<FavoriteProvider>().loadFavorites();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (favoriteProvider.favorites.isEmpty) {
            return const EmptyStateWidget(
              message: 'No Saved Recipes\n\nStart exploring recipes and save your favorites here!',
              icon: Icons.bookmark_border,
            );
          }

          final filteredRecipes = _filterRecipes(favoriteProvider.favorites);

          if (filteredRecipes.isEmpty && _searchQuery.isNotEmpty) {
            return const EmptyStateWidget(
              message: 'No recipes found\n\nTry adjusting your search terms',
              icon: Icons.search_off,
            );
          }

          return Column(
            children: [
              // Search bar
              if (favoriteProvider.favorites.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search saved recipes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              
              // Recipe count
              if (filteredRecipes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${filteredRecipes.length} saved recipe${filteredRecipes.length != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              
              // Recipe list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return RecipeNoteCardWidget(
                      recipe: recipe,
                      onTap: () => _navigateToRecipeDetails(recipe),
                      onRemove: () => _removeFromFavorites(recipe),
                      showNote: true,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      
      // Floating action button for quick actions
      floatingActionButton: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.favorites.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return FloatingActionButton(
            onPressed: _syncWithFirebase,
            tooltip: 'Sync with cloud',
            child: const Icon(Icons.cloud_sync),
          );
        },
      ),
    );
  }
}

// Custom search delegate for recipe search
class _RecipeSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final filteredRecipes = favoriteProvider.favorites.where((recipe) {
          return recipe.title.toLowerCase().contains(query.toLowerCase()) ||
                 recipe.summary.toLowerCase().contains(query.toLowerCase());
        }).toList();

        if (filteredRecipes.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              message: 'No recipes found\n\nTry different search terms',
              icon: Icons.search_off,
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredRecipes.length,
          itemBuilder: (context, index) {
            final recipe = filteredRecipes[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
              title: Text(recipe.title),
              subtitle: Text(
                '${recipe.readyInMinutes} min • ${recipe.servings} servings',
                style: TextStyle(color: Colors.grey[600]),
              ),
              onTap: () {
                close(context, recipe.title);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailsScreen(recipe: recipe),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}