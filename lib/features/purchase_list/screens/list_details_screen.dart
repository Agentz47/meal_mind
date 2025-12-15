import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/purchase_list_provider.dart';
import '../../../models/purchase_list_model.dart';
import '../widgets/purchase_item_widget.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/edit_list_dialog.dart';

/// Screen showing items in a specific purchase list
class ListDetailsScreen extends StatefulWidget {
  final PurchaseListModel list;

  const ListDetailsScreen({super.key, required this.list});

  @override
  State<ListDetailsScreen> createState() => _ListDetailsScreenState();
}

class _ListDetailsScreenState extends State<ListDetailsScreen> {
  bool _showPurchased = true;

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(listId: widget.list.id),
    );
  }

  void _showEditListDialog() {
    showDialog(
      context: context,
      builder: (context) => EditListDialog(list: widget.list),
    );
  }

  void _showDeletePurchasedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchased Items?'),
        content: const Text('This will remove all items marked as purchased.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PurchaseListProvider>(context, listen: false)
                  .deleteAllPurchasedInList(widget.list.id);
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
        title: Text(widget.list.name),
        actions: [
          IconButton(
            icon: Icon(_showPurchased ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() => _showPurchased = !_showPurchased);
            },
            tooltip: _showPurchased ? 'Hide Purchased' : 'Show Purchased',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit List'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_purchased',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep),
                    SizedBox(width: 8),
                    Text('Delete Purchased'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _showEditListDialog();
              } else if (value == 'delete_purchased') {
                _showDeletePurchasedDialog();
              }
            },
          ),
        ],
      ),
      body: Consumer<PurchaseListProvider>(
        builder: (context, provider, child) {
          final allItems = provider.getItemsForList(widget.list.id);
          final itemsToShow = _showPurchased
              ? allItems
              : allItems.where((item) => !item.isPurchased).toList();

          if (itemsToShow.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showPurchased ? 'No items in this list' : 'No pending items',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Summary card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Total',
                      allItems.length.toString(),
                      Icons.list,
                    ),
                    _buildStat(
                      'Pending',
                      provider.getUnpurchasedCount(widget.list.id).toString(),
                      Icons.shopping_cart,
                    ),
                    _buildStat(
                      'Done',
                      provider.getPurchasedCount(widget.list.id).toString(),
                      Icons.check_circle,
                    ),
                  ],
                ),
              ),
              // Items list
              Expanded(
                child: ListView.builder(
                  itemCount: itemsToShow.length,
                  itemBuilder: (context, index) {
                    return PurchaseItemWidget(
                      item: itemsToShow[index],
                      listId: widget.list.id,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
