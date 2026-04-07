class Product {
  final int? id;
  final String name;
  final String? description;
  final int subcategory;
  final String? sku;
  final double? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.subcategory,
    this.sku,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      subcategory: json['subcategory'] as int? ?? 0,
      sku: json['sku'] as String?,
      price: json['price'] != null
          ? (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : (json['price'] as double)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subcategory': subcategory,
      if (id != null) 'id': id,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (sku != null && sku!.isNotEmpty) 'sku': sku,
      if (price != null) 'price': price,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    int? subcategory,
    String? sku,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      subcategory: subcategory ?? this.subcategory,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
