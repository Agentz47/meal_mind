import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/recipe_model.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/recipe_provider.dart';
import '../../../providers/purchase_list_provider.dart';
import '../widgets/ingredient_list_item_widget.dart';
import 'cooking_instructions_screen.dart';
// import '../../videos/screens/cooking_video_screen.dart';

// Screen showing detailed recipe information
// Member 2 - Recipe Details Feature
class RecipeDetailsScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final TextEditingController _noteController = TextEditingController();
  RecipeModel? _fullRecipe;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
    _loadFullRecipeDetails();
  }

  void _loadNote() async {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    final note = await favoriteProvider.getUserNote(
      widget.recipe.id.toString(),
    );
    if (note != null) {
      _noteController.text = note;
    }
  }

  void _loadFullRecipeDetails() async {
    setState(() => _isLoadingDetails = true);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final fullRecipe = await recipeProvider.getRecipeDetails(widget.recipe.id);
    setState(() {
      _fullRecipe = fullRecipe ?? widget.recipe;
      _isLoadingDetails = false;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    await favoriteProvider.saveUserNote(
      widget.recipe.id.toString(),
      _noteController.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note saved!')));
    }
  }

  void _toggleFavorite() async {
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    if (favoriteProvider.isFavorite(widget.recipe.id)) {
      await favoriteProvider.removeFromFavorites(widget.recipe.id);
    } else {
      await favoriteProvider.addToFavorites(widget.recipe);
    }
  }

  void _addAllToPurchaseList() async {
    final purchaseProvider = Provider.of<PurchaseListProvider>(
      context,
      listen: false,
    );

    // Prepare ingredients list
    final ingredients = widget.recipe.ingredients
        .map(
          (ing) => {
            'name': ing.name,
            'amount': ing.amount.toString(),
            'unit': ing.unit,
          },
        )
        .toList();

    try {
      // Create new list with all ingredients
      await purchaseProvider.createListFromRecipe(
        recipeName: widget.recipe.title,
        recipeId: widget.recipe.id.toString(),
        ingredients: ingredients,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created shopping list: ${widget.recipe.title}'),
            action: SnackBarAction(
              label: 'VIEW',
              onPressed: () {
                // Navigate to purchase list tab (index 2)
                DefaultTabController.of(context)?.animateTo(2);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create list: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              final isFavorite = favoriteProvider.isFavorite(widget.recipe.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            Image.network(
              widget.recipe.image,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 100),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe title
                  Text(
                    widget.recipe.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Recipe info
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        '${widget.recipe.readyInMinutes} min',
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.restaurant_menu,
                        '${widget.recipe.servings} servings',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Ingredients section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.recipe.ingredients.isNotEmpty)
                        TextButton.icon(
                          onPressed: _addAllToPurchaseList,
                          icon: const Icon(Icons.add_shopping_cart, size: 20),
                          label: const Text('Add All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.recipe.ingredients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No ingredients available'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.recipe.ingredients.length,
                      itemBuilder: (context, index) {
                        return IngredientListItemWidget(
                          ingredient: widget.recipe.ingredients[index],
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoadingDetails
                              ? null
                              : () {
                                  final recipe = _fullRecipe ?? widget.recipe;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CookingInstructionsScreen(
                                            recipe: recipe,
                                          ),
                                    ),
                                  );
                                },
                          icon: _isLoadingDetails
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.menu_book),
                          label: Text(
                            _isLoadingDetails ? 'Loading...' : 'Instructions',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Notes section
                  const Text(
                    'My Notes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add your notes here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveNote,
                      child: const Text('Save Note'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Colors.grey[200],
    );
  }
}
