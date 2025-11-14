// class Product {
// 	final int id;
// 	final String name;
// 	final String description;
// 	final double price;
// 	final String category;
// 	final DateTime createdAt;

// 	Product({
// 		required this.id,
// 		required this.name,
// 		required this.description,
// 		required this.price,
// 		required this.category,
// 		required this.createdAt,
// 	});

// 	factory Product.fromJson(Map<String, dynamic> json) {
// 		return Product(
// 			id: json['id'],
// 			name: json['name'],
// 			description: json['description'],
// 			price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'],
// 			category: json['category'],
// 			createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
// 		);
// 	}

// 	Map<String, dynamic> toJson() {
// 		return {
// 			'id': id,
// 			'name': name,
// 			'description': description,
// 			'price': price,
// 			'category': category,
// 			'created_at': createdAt.toIso8601String(),
// 		};
// 	}
// }
