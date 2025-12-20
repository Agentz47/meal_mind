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

    // Update local state immediately for instant UI response
    _lists.add(list);
    _itemsByList[list.id] = [];
    notifyListeners();

    try {
      await _service.createList(list);
      return list.id;
    } catch (e) {
      // Rollback on error
      _lists.removeWhere((l) => l.id == list.id);
      _itemsByList.remove(list.id);
      _error = 'Failed to create list: $e';
      notifyListeners();
      throw Exception('Failed to create list');
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
    // Find and update local state immediately
    final index = _lists.indexWhere((l) => l.id == list.id);
    final oldList = index >= 0 ? _lists[index] : null;
    
    if (index >= 0) {
      _lists[index] = list;
      notifyListeners();
    }

    try {
      await _service.updateList(list);
    } catch (e) {
      // Rollback on error
      if (index >= 0 && oldList != null) {
        _lists[index] = oldList;
      }
      _error = 'Failed to update list: $e';
      notifyListeners();
      throw Exception('Failed to update list');
    }
  }

  /// Delete list
  Future<void> deleteList(String listId) async {
    // Remove from local state immediately
    final removedList = _lists.firstWhere((l) => l.id == listId);
    final removedItems = _itemsByList[listId];
    
    _lists.removeWhere((l) => l.id == listId);
    _itemsByList.remove(listId);
    notifyListeners();

    try {
      await _service.deleteList(listId);
    } catch (e) {
      // Rollback on error
      _lists.add(removedList);
      if (removedItems != null) {
        _itemsByList[listId] = removedItems;
      }
      _error = 'Failed to delete list: $e';
      notifyListeners();
      throw Exception('Failed to delete list');
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

    // Add to local state immediately
    if (_itemsByList[listId] == null) {
      _itemsByList[listId] = [];
    }
    _itemsByList[listId]!.add(item);
    notifyListeners();

    try {
      await _service.addItem(item);
    } catch (e) {
      // Rollback on error
      _itemsByList[listId]?.removeWhere((i) => i.id == item.id);
      _error = 'Failed to add item: $e';
      notifyListeners();
      throw Exception('Failed to add item');
    }
  }

  /// Toggle item purchased status
  Future<void> toggleItemPurchased(String listId, String itemId) async {
    final items = _itemsByList[listId] ?? [];
    final index = items.indexWhere((i) => i.id == itemId);
    if (index < 0) return;
    
    final item = items[index];
    final updatedItem = item.copyWith(isPurchased: !item.isPurchased);
    
    // Update local state immediately
    _itemsByList[listId]![index] = updatedItem;
    notifyListeners();

    try {
      await _service.updateItem(updatedItem);
    } catch (e) {
      // Rollback on error
      _itemsByList[listId]![index] = item;
      _error = 'Failed to update item: $e';
      notifyListeners();
      throw Exception('Failed to toggle item');
    }
  }

  /// Update item (for editing name, amount, unit)
  Future<void> updateItem(String listId, PurchaseItemModel item) async {
    final items = _itemsByList[listId] ?? [];
    final index = items.indexWhere((i) => i.id == item.id);
    final oldItem = index >= 0 ? items[index] : null;
    
    // Update local state immediately
    if (index >= 0) {
      _itemsByList[listId]![index] = item;
      notifyListeners();
    }

    try {
      await _service.updateItem(item);
    } catch (e) {
      // Rollback on error
      if (index >= 0 && oldItem != null) {
        _itemsByList[listId]![index] = oldItem;
      }
      _error = 'Failed to update item: $e';
      notifyListeners();
      throw Exception('Failed to update item');
    }
  }

  /// Delete item
  Future<void> deleteItem(String listId, String itemId) async {
    final items = _itemsByList[listId] ?? [];
    final removedItem = items.firstWhere((i) => i.id == itemId);
    
    // Remove from local state immediately
    _itemsByList[listId]?.removeWhere((i) => i.id == itemId);
    notifyListeners();

    try {
      await _service.deleteItem(itemId);
    } catch (e) {
      // Rollback on error
      _itemsByList[listId]?.add(removedItem);
      _error = 'Failed to delete item: $e';
      notifyListeners();
      throw Exception('Failed to delete item');
    }
  }

  /// Delete all purchased items in a list
  Future<void> deleteAllPurchasedInList(String listId) async {
    final items = _itemsByList[listId] ?? [];
    final removedItems = items.where((i) => i.isPurchased).toList();
    
    // Remove from local state immediately
    _itemsByList[listId]?.removeWhere((i) => i.isPurchased);
    notifyListeners();

    try {
      await _service.deleteAllPurchasedInList(listId);
    } catch (e) {
      // Rollback on error
      _itemsByList[listId]?.addAll(removedItems);
      _error = 'Failed to clear purchased items: $e';
      notifyListeners();
      throw Exception('Failed to clear purchased items');
    }
  }
}
