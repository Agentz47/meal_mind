// Model for purchase list (container for items)
class PurchaseListModel {
  final String id;
  final String name;
  final String? description;
  final String? recipeId;
  final String? recipeName;
  final DateTime createdAt;
  final DateTime updatedAt;

  PurchaseListModel({
    required this.id,
    required this.name,
    this.description,
    this.recipeId,
    this.recipeName,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Create from JSON
  factory PurchaseListModel.fromJson(Map<String, dynamic> json) {
    return PurchaseListModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      recipeId: json['recipeId'],
      recipeName: json['recipeName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  PurchaseListModel copyWith({
    String? id,
    String? name,
    String? description,
    String? recipeId,
    String? recipeName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
