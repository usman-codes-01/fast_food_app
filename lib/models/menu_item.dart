class MenuItem {
  final String? id;
  final String name;
  final double price;
  final String image;
  final String category;
  final bool inStock;
  final String description;

  MenuItem({
    this.id,
    required this.name,
    required this.price,
    required this.image,
    this.category = "Snacks",
    this.inStock = true,
    this.description = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'inStock': inStock,
      'description': description,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map, String docId) {
    return MenuItem(
      id: docId,
      name: map['name'] ?? 'Unknown',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0).toDouble(),
      image: map['image'] ?? '',
      category: map['category'] ?? 'Snacks',
      inStock: map['inStock'] ?? true,
      description: map['description'] ?? '',
    );
  }

  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    String? category,
    bool? inStock,
    String? description,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      inStock: inStock ?? this.inStock,
      description: description ?? this.description,
    );
  }
}
