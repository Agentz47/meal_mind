import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/purchase_list_model.dart';
import '../../../providers/purchase_list_provider.dart';

/// Dialog for editing an existing purchase list
class EditListDialog extends StatefulWidget {
  final PurchaseListModel list;

  const EditListDialog({super.key, required this.list});

  @override
  State<EditListDialog> createState() => _EditListDialogState();
}

class _EditListDialogState extends State<EditListDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.list.name);
    _descriptionController =
        TextEditingController(text: widget.list.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateList() async {
    if (_formKey.currentState!.validate()) {
      final updatedList = widget.list.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await Provider.of<PurchaseListProvider>(context, listen: false)
          .updateList(updatedList);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('List updated')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit List'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a list name';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateList,
          child: const Text('Update'),
        ),
      ],
    );
  }
}
