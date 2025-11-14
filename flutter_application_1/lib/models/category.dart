class Category {
  final String? id;
  final String name;
  final String description;
  final DateTime creationDate;
  final int? parentCategory; // Added optional parentCategory field

  Category({
     this.id,
    required this.name,
    required this.description,
    required this.creationDate,
    this.parentCategory, // Initialize parentCategory
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creationDate': creationDate.toIso8601String(),
      'parent_category': parentCategory, // Include parentCategory in JSON
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      creationDate: DateTime.parse(json['creationDate']),
      parentCategory: json['parent_category'], // Parse parentCategory
    );
  }
}