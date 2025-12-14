// Model for purchase list items
class PurchaseItemModel {
  final String id;
  final String listId; // Reference to which list this item belongs
  final String name;
  final String amount;
  final String unit;
  final bool isPurchased;
  final DateTime createdAt;

  PurchaseItemModel({
    required this.id,
    required this.listId,
    required this.name,
    required this.amount,
    required this.unit,
    this.isPurchased = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Create from JSON
  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id'] ?? '',
      listId: json['listId'] ?? '',
      name: json['name'] ?? '',
      amount: json['amount'] ?? '',
      unit: json['unit'] ?? '',
      isPurchased: json['isPurchased'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'name': name,
      'amount': amount,
      'unit': unit,
      'isPurchased': isPurchased,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  PurchaseItemModel copyWith({
    String? id,
    String? listId,
    String? name,
    String? amount,
    String? unit,
    bool? isPurchased,
    DateTime? createdAt,
  }) {
    return PurchaseItemModel(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
