/// Represents a food shop entry within a meal category.
///
/// Equality is based on [name] using case-insensitive comparison,
/// allowing duplicate detection regardless of casing.
class FoodShop {
  const FoodShop({required this.name, required this.createdAt});

  /// Deserializes a [FoodShop] from a JSON map.
  factory FoodShop.fromJson(Map<String, dynamic> json) {
    return FoodShop(
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String name;
  final DateTime createdAt;

  /// Serializes this shop to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodShop &&
        other.name.toLowerCase() == name.toLowerCase();
  }

  @override
  int get hashCode => name.toLowerCase().hashCode;

  @override
  String toString() => 'FoodShop(name: $name, createdAt: $createdAt)';
}
