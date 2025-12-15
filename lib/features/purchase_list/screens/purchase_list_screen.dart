import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/purchase_list_provider.dart';
import '../../../models/purchase_list_model.dart';
import 'list_details_screen.dart';
import '../widgets/create_list_dialog.dart';
import '../widgets/shopping_list_card_widget.dart';

/// Screen showing all purchase lists
/// Member 4 - Purchase List Feature
class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseListProvider>(context, listen: false).loadLists();
    });
  }

  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateListDialog(),
    );
  }

  void _showDeleteDialog(PurchaseListModel list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text('Delete "${list.name}" and all its items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PurchaseListProvider>(context, listen: false)
                  .deleteList(list.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
      ),
      body: Consumer<PurchaseListProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadLists(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.lists.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No shopping lists yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a list or add ingredients from recipes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.lists.length,
            itemBuilder: (context, index) {
              final list = provider.lists[index];
              final totalItems = provider.getItemsForList(list.id).length;
              final purchasedItems = provider.getPurchasedCount(list.id);

              // Using Custom Component - Student 4 (Component 2 of 2)
              return ShoppingListCardWidget(
                listName: list.name,
                description: list.description,
                totalItems: totalItems,
                completedItems: purchasedItems,
                createdAt: list.createdAt.toIso8601String(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListDetailsScreen(list: list),
                    ),
                  );
                },
                onDelete: () => _showDeleteDialog(list),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateListDialog,
        icon: const Icon(Icons.add),
        label: const Text('New List'),
      ),
    );
  }

}
