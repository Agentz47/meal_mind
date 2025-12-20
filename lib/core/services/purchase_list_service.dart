import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/purchase_item_model.dart';
import '../../models/purchase_list_model.dart';

/// Service for managing multiple purchase lists with Firestore and offline Hive storage
class PurchaseListService {
  FirebaseFirestore? _firestore;
  static const String _listsBoxName = 'purchase_lists';
  static const String _itemsBoxName = 'purchase_items';
  Box<Map>? _listsBox;
  Box<Map>? _itemsBox;

  PurchaseListService() {
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      _firestore = null;
    }
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      _listsBox = await Hive.openBox<Map>(_listsBoxName);
      _itemsBox = await Hive.openBox<Map>(_itemsBoxName);
    } catch (e) {
      debugPrint('Error initializing purchase list Hive boxes: $e');
    }
  }

  bool get isAvailable => _firestore != null;

  // ===== LIST OPERATIONS =====

  /// Get all purchase lists
  Future<List<PurchaseListModel>> getAllLists() async {
    if (_firestore != null) {
      try {
        final snapshot = await _firestore!
            .collection('purchase_lists')
            .orderBy('updatedAt', descending: true)
            .get();

        final lists = snapshot.docs
            .map((doc) => PurchaseListModel.fromJson(doc.data()))
            .toList();

        await _cacheListsToHive(lists);
        return lists;
      } catch (e) {
        debugPrint('Firestore error, using offline data: $e');
      }
    }
    return _getListsFromHive();
  }

  /// Create new list
  Future<void> createList(PurchaseListModel list) async {
    // Save to Hive first (immediate, works offline)
    await _addListToHive(list);
    
    // Sync to Firebase in background (don't wait)
    if (_firestore != null) {
      _firestore!
          .collection('purchase_lists')
          .doc(list.id)
          .set(list.toJson())
          .catchError((e) => debugPrint('Error creating list in Firestore: $e'));
    }
  }

  /// Update list
  Future<void> updateList(PurchaseListModel list) async {
    final updatedList = list.copyWith(updatedAt: DateTime.now());
    
    // Save to Hive first (immediate, works offline)
    await _updateListInHive(updatedList);
    
    // Sync to Firebase in background (don't wait)
    if (_firestore != null) {
      _firestore!
          .collection('purchase_lists')
          .doc(list.id)
          .update(updatedList.toJson())
          .catchError((e) => debugPrint('Error updating list in Firestore: $e'));
    }
  }

  /// Delete list and all its items
  Future<void> deleteList(String listId) async {
    // Delete all items in the list first
    final items = await getItemsByList(listId);
    for (var item in items) {
      await deleteItem(item.id);
    }

    // Delete from Hive first (immediate, works offline)
    await _deleteListFromHive(listId);
    
    // Delete from Firebase in background (don't wait)
    if (_firestore != null) {
      _firestore!
          .collection('purchase_lists')
          .doc(listId)
          .delete()
          .catchError((e) => debugPrint('Error deleting list from Firestore: $e'));
    }
  }

  // ===== ITEM OPERATIONS =====

  /// Get all items for a specific list
  Future<List<PurchaseItemModel>> getItemsByList(String listId) async {
    if (_firestore != null) {
      try {
        final snapshot = await _firestore!
            .collection('purchase_items')
            .where('listId', isEqualTo: listId)
            .orderBy('createdAt', descending: false)
            .get();

        final items = snapshot.docs
            .map((doc) => PurchaseItemModel.fromJson(doc.data()))
            .toList();

        await _cacheItemsToHive(items);
        return items;
      } catch (e) {
        debugPrint('Firestore error, using offline data: $e');
      }
    }
    return _getItemsFromHive(listId);
  }

  /// Add item to a list
  Future<void> addItem(PurchaseItemModel item) async {
    // Save to Hive first (immediate, works offline)
    await _addItemToHive(item);
    
    // Sync to Firebase in background (don't wait)
    if (_firestore != null) {
      _firestore!
          .collection('purchase_items')
          .doc(item.id)
          .set(item.toJson())
          .then((_) {
            // Update list's updatedAt timestamp
            return _firestore!
                .collection('purchase_lists')
                .doc(item.listId)
                .update({'updatedAt': DateTime.now().toIso8601String()});
          })
          .catchError((e) => debugPrint('Error adding item to Firestore: $e'));
    }
  }

  /// Update item (full replacement)
  Future<void> updateItem(PurchaseItemModel item) async {
    // Save to Hive first (immediate, works offline)
    await _updateItemInHive(item);
    
    // Sync to Firebase in background (don't wait)
    if (_firestore != null) {
      _firestore!
          .collection('purchase_items')
          .doc(item.id)
          .set(item.toJson()) // Use set instead of update to replace fully
          .then((_) {
            // Update list's updatedAt timestamp
            return _firestore!
                .collection('purchase_lists')
                .doc(item.listId)
                .update({'updatedAt': DateTime.now().toIso8601String()});
          })
          .catchError((e) => debugPrint('Error updating item in Firestore: $e'));
    }
  }

  /// Delete item
  Future<void> deleteItem(String itemId) async {
    // Delete from Hive first (immediate, works offline)
    await _deleteItemFromHive(itemId);
    
    // Delete from Firebase in background (don't wait)
    if (_firestore != null) {
      _firestore!
          .collection('purchase_items')
          .doc(itemId)
          .get()
          .then((doc) {
            if (doc.exists) {
              final listId = doc.data()?['listId'];
              return _firestore!.collection('purchase_items').doc(itemId).delete()
                  .then((_) {
                    // Update list's updatedAt timestamp
                    if (listId != null) {
                      return _firestore!
                          .collection('purchase_lists')
                          .doc(listId)
                          .update({'updatedAt': DateTime.now().toIso8601String()});
                    }
                  });
            }
          })
          .catchError((e) => debugPrint('Error deleting item from Firestore: $e'));
    }
  }

  /// Delete all purchased items in a list
  Future<void> deleteAllPurchasedInList(String listId) async {
    final items = await getItemsByList(listId);
    final purchasedItems = items.where((item) => item.isPurchased).toList();

    for (var item in purchasedItems) {
      await deleteItem(item.id);
    }
  }

  // ===== HIVE OPERATIONS FOR LISTS =====

  Future<void> _cacheListsToHive(List<PurchaseListModel> lists) async {
    if (_listsBox == null) return;
    
    for (var list in lists) {
      await _listsBox!.put(list.id, list.toJson());
    }
  }

  Future<List<PurchaseListModel>> _getListsFromHive() async {
    if (_listsBox == null) return [];

    return _listsBox!.values
        .map((json) => PurchaseListModel.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _addListToHive(PurchaseListModel list) async {
    if (_listsBox == null) return;
    await _listsBox!.put(list.id, list.toJson());
  }

  Future<void> _updateListInHive(PurchaseListModel list) async {
    if (_listsBox == null) return;
    await _listsBox!.put(list.id, list.toJson());
  }

  Future<void> _deleteListFromHive(String listId) async {
    if (_listsBox == null) return;
    await _listsBox!.delete(listId);
  }

  // ===== HIVE OPERATIONS FOR ITEMS =====

  Future<void> _cacheItemsToHive(List<PurchaseItemModel> items) async {
    if (_itemsBox == null) return;
    
    for (var item in items) {
      await _itemsBox!.put(item.id, item.toJson());
    }
  }

  Future<List<PurchaseItemModel>> _getItemsFromHive(String listId) async {
    if (_itemsBox == null) return [];

    return _itemsBox!.values
        .map((json) => PurchaseItemModel.fromJson(Map<String, dynamic>.from(json)))
        .where((item) => item.listId == listId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> _addItemToHive(PurchaseItemModel item) async {
    if (_itemsBox == null) return;
    await _itemsBox!.put(item.id, item.toJson());
  }

  Future<void> _updateItemInHive(PurchaseItemModel item) async {
    if (_itemsBox == null) return;
    await _itemsBox!.put(item.id, item.toJson());
  }

  Future<void> _deleteItemFromHive(String itemId) async {
    if (_itemsBox == null) return;
    await _itemsBox!.delete(itemId);
  }
}
