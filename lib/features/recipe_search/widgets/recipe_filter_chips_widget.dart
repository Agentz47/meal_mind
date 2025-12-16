import 'package:flutter/material.dart';

/// Custom Component - Member 1 (Component 2 of 2)
/// Filter chips for recipe search (diet, cuisine, meal type)
class RecipeFilterChipsWidget extends StatelessWidget {
  final String? selectedDiet;
  final String? selectedCuisine;
  final Function(String?) onDietChanged;
  final Function(String?) onCuisineChanged;

  const RecipeFilterChipsWidget({
    super.key,
    this.selectedDiet,
    this.selectedCuisine,
    required this.onDietChanged,
    required this.onCuisineChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Diet filters
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Diet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildFilterChip('All', null, selectedDiet, onDietChanged, Colors.blue),
              _buildFilterChip('Vegetarian', 'vegetarian', selectedDiet, onDietChanged, Colors.green),
              _buildFilterChip('Vegan', 'vegan', selectedDiet, onDietChanged, Colors.lightGreen),
              _buildFilterChip('Gluten Free', 'gluten free', selectedDiet, onDietChanged, Colors.orange),
              _buildFilterChip('Ketogenic', 'ketogenic', selectedDiet, onDietChanged, Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Cuisine filters
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Cuisine',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildFilterChip('All', null, selectedCuisine, onCuisineChanged, Colors.purple),
              _buildFilterChip('Italian', 'italian', selectedCuisine, onCuisineChanged, Colors.deepOrange),
              _buildFilterChip('Chinese', 'chinese', selectedCuisine, onCuisineChanged, Colors.red),
              _buildFilterChip('Indian', 'indian', selectedCuisine, onCuisineChanged, Colors.orange),
              _buildFilterChip('Mexican', 'mexican', selectedCuisine, onCuisineChanged, Colors.amber),
              _buildFilterChip('American', 'american', selectedCuisine, onCuisineChanged, Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String? value,
    String? selectedValue,
    Function(String?) onChanged,
    Color color,
  ) {
    final isSelected = selectedValue == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => onChanged(selected ? value : null),
        backgroundColor: Colors.grey[200],
        selectedColor: color.withOpacity(0.3),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: isSelected ? color : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
    );
  }
}
