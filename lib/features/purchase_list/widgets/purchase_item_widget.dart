import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/purchase_item_model.dart';
import '../../../providers/purchase_list_provider.dart';
import 'edit_item_dialog.dart';

/// Widget displaying a single purchase list item
class PurchaseItemWidget extends StatelessWidget {
  final PurchaseItemModel item;
  final String listId;

  const PurchaseItemWidget({
    super.key,
    required this.item,
    required this.listId,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Item?'),
            content: Text('Remove "${item.name}" from your purchase list?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<PurchaseListProvider>(context, listen: false)
            .deleteItem(listId, item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} removed')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: item.isPurchased,
            onChanged: (value) {
              Provider.of<PurchaseListProvider>(context, listen: false)
                  .toggleItemPurchased(listId, item.id);
            },
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              decoration: item.isPurchased
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: item.isPurchased ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.amount} ${item.unit}',
                style: TextStyle(
                  color: item.isPurchased ? Colors.grey : null,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.isPurchased)
                const Icon(Icons.check_circle, color: Colors.green)
              else
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => EditItemDialog(
                        item: item,
                        listId: listId,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
