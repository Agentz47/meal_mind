import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/recipe_model.dart';
import '../../../providers/favorite_provider.dart';

// A card widget for displaying recipe with note functionality
class RecipeNoteCardWidget extends StatefulWidget {
  final RecipeModel recipe;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showNote;

  const RecipeNoteCardWidget({
    super.key,
    required this.recipe,
    this.onTap,
    this.onRemove,
    this.showNote = true,
  });

  @override
  State<RecipeNoteCardWidget> createState() => _RecipeNoteCardWidgetState();
}

class _RecipeNoteCardWidgetState extends State<RecipeNoteCardWidget> {
  final TextEditingController _noteController = TextEditingController();
  bool _isEditingNote = false;
  String? _currentNote;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    if (widget.showNote) {
      final favoriteProvider = context.read<FavoriteProvider>();
      final note = await favoriteProvider.getUserNote(widget.recipe.id.toString());
      setState(() {
        _currentNote = note;
        _noteController.text = note ?? '';
      });
    }
  }

  Future<void> _saveNote() async {
    final favoriteProvider = context.read<FavoriteProvider>();
    try {
      await favoriteProvider.saveUserNote(
        widget.recipe.id.toString(),
        _noteController.text.trim(),
      );
      setState(() {
        _currentNote = _noteController.text.trim();
        _isEditingNote = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNote() async {
    final favoriteProvider = context.read<FavoriteProvider>();
    try {
      await favoriteProvider.deleteUserNote(widget.recipe.id.toString());
      setState(() {
        _currentNote = null;
        _noteController.clear();
        _isEditingNote = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note deleted successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image and Basic Info
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    widget.recipe.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                // Remove button
                if (widget.onRemove != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: widget.onRemove,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Recipe Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipe.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Time and Servings
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.recipe.readyInMinutes} min',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.recipe.servings} servings',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  
                  // Note Section
                  if (widget.showNote) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Personal Notes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isEditingNote && _currentNote != null)
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _isEditingNote = true;
                                  });
                                },
                              ),
                            if (!_isEditingNote && _currentNote == null)
                              IconButton(
                                icon: const Icon(Icons.add_comment, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _isEditingNote = true;
                                  });
                                },
                              ),
                            if (_currentNote != null)
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Delete Note'),
                                        content: const Text('Are you sure you want to delete this note?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _deleteNote();
                                            },
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    if (_isEditingNote)
                      Column(
                        children: [
                          TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              hintText: 'Add your personal notes about this recipe...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditingNote = false;
                                    _noteController.text = _currentNote ?? '';
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _saveNote,
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      )
                    else if (_currentNote != null && _currentNote!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          _currentNote!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          'No notes added yet. Tap the + icon to add your thoughts!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}