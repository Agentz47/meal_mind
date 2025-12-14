import 'package:flutter/foundation.dart';
import '../models/purchase_item_model.dart';
import '../models/purchase_list_model.dart';
import '../core/services/purchase_list_service.dart';

/// Provider for managing multiple purchase lists state
class PurchaseListProvider with ChangeNotifier {
  final PurchaseListService _service = PurchaseListService();

  List<PurchaseListModel> _lists = [];
  Map<String, List<PurchaseItemModel>> _itemsByList = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PurchaseListModel> get lists => _lists;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAvailable => _service.isAvailable;

  /// Get items for a specific list
  List<PurchaseItemModel> getItemsForList(String listId) {
    return _itemsByList[listId] ?? [];
  }

  /// Get unpurchased items count for a list
  int getUnpurchasedCount(String listId) {
    final items = _itemsByList[listId] ?? [];
    return items.where((item) => !item.isPurchased).length;
  }

  /// Get purchased items count for a list
  int getPurchasedCount(String listId) {
    final items = _itemsByList[listId] ?? [];
    return items.where((item) => item.isPurchased).length;
  }

  /// Load all lists
  Future<void> loadLists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lists = await _service.getAllLists();
      // Load items for each list
      for (var list in _lists) {
        _itemsByList[list.id] = await _service.getItemsByList(list.id);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load lists: $e';
      _isLoading = false;
      _lists = [];
      notifyListeners();
    }
  }

  /// Create a new list
  Future<String> createList(String name, {String? description, String? recipeId, String? recipeName}) async {
    final list = PurchaseListModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      recipeId: recipeId,
      recipeName: recipeName,
    );

    try {
      await _service.createList(list);
      await loadLists();
      return list.id;
    } catch (e) {
      _error = 'Failed to create list: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Create list from recipe with all ingredients
  Future<void> createListFromRecipe({
    required String recipeName,
    required String recipeId,
    required List<Map<String, String>> ingredients,
  }) async {
    // Create the list
    final listId = await createList(
      recipeName,
      description: 'Shopping list for $recipeName',
      recipeId: recipeId,
      recipeName: recipeName,
    );

    // Add all ingredients to the list
    for (var ingredient in ingredients) {
      await addItemToList(
        listId: listId,
        name: ingredient['name']!,
        amount: ingredient['amount']!,
        unit: ingredient['unit']!,
      );
    }
  }

  /// Update list
  Future<void> updateList(PurchaseListModel list) async {
    try {
      await _service.updateList(list);
      await loadLists();
    } catch (e) {
      _error = 'Failed to update list: $e';
      notifyListeners();
    }
  }

  /// Delete list
  Future<void> deleteList(String listId) async {
    try {
      await _service.deleteList(listId);
      await loadLists();
    } catch (e) {
      _error = 'Failed to delete list: $e';
      notifyListeners();
    }
  }

  /// Add item to a list
  Future<void> addItemToList({
    required String listId,
    required String name,
    required String amount,
    required String unit,
  }) async {
    final item = PurchaseItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + name.hashCode.toString(),
      listId: listId,
      name: name,
      amount: amount,
      unit: unit,
    );

    try {
      await _service.addItem(item);
      _itemsByList[listId] = await _service.getItemsByList(listId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add item: $e';
      notifyListeners();
    }
  }

  /// Toggle item purchased status
  Future<void> toggleItemPurchased(String listId, String itemId) async {
    final items = _itemsByList[listId] ?? [];
    final item = items.firstWhere((i) => i.id == itemId);
    final updatedItem = item.copyWith(isPurchased: !item.isPurchased);

    try {
      await _service.updateItem(updatedItem);
      _itemsByList[listId] = await _service.getItemsByList(listId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update item: $e';
      notifyListeners();
    }
  }

  /// Update item (for editing name, amount, unit)
  Future<void> updateItem(String listId, PurchaseItemModel item) async {
    try {
      await _service.updateItem(item);
      _itemsByList[listId] = await _service.getItemsByList(listId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update item: $e';
      notifyListeners();
    }
  }

  /// Delete item
  Future<void> deleteItem(String listId, String itemId) async {
    try {
      await _service.deleteItem(itemId);
      _itemsByList[listId] = await _service.getItemsByList(listId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete item: $e';
      notifyListeners();
    }
  }

  /// Delete all purchased items in a list
  Future<void> deleteAllPurchasedInList(String listId) async {
    try {
      await _service.deleteAllPurchasedInList(listId);
      _itemsByList[listId] = await _service.getItemsByList(listId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear purchased items: $e';
      notifyListeners();
    }
  }
}
