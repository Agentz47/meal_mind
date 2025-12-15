import 'package:flutter/material.dart';
import '../../../models/recipe_model.dart';
import '../widgets/cooking_step_widget.dart';

// Screen showing step-by-step cooking instructions
// Member 2 - Recipe Details Feature
class CookingInstructionsScreen extends StatelessWidget {
  final RecipeModel recipe;

  const CookingInstructionsScreen({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Instructions'),
      ),
      body: recipe.steps.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No cooking instructions available for this recipe.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${recipe.steps.length} steps',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipe.steps.length,
                  itemBuilder: (context, index) {
                    return CookingStepWidget(
                      step: recipe.steps[index],
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
