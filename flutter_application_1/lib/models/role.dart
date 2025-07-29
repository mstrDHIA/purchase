
class Role {
  final int? id;
  final String name;
  final String description;

  Role({this.id, required this.name, required this.description});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'] ?? json['role'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
    };
  }
}
