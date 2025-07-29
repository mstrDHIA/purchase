extension UserComputedFields on User {
  String get name => '[200m$firstName $lastName[0m';
  String get status => isSuperuser ? 'Active' : 'Inactive';
  String get permission => isSuperuser ? 'Admin' : 'User';
}
class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isSuperuser;
  final String password;
  final int? profileId;
  final String? role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isSuperuser,
    required this.password,
    this.profileId,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isSuperuser: json['is_superuser'] ?? false,
      password: json['password'] ?? '',
      profileId: json['profile_id'] ?? json['profileId'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_superuser': isSuperuser,
      'password': password,
      if (profileId != null) 'profile_id': profileId,
      if (role != null) 'role': role,
    };
  }
}


