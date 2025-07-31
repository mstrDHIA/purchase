import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/models/role.dart';

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
  final int? role_id;
  final Profile? profile;
  final Role? role;

  User( {
    required this.id,
    this.role_id,
    this.profile,
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
      profile: json['profile_id'] != null
          ? Profile.fromJson(Map<String, dynamic>.from(json['profile_id']))
          : null,
      // profileId: json['profile_id'] ?? json['profileId'],
      // role: json['role'],
    );
  }

  get bio => null;

  get location => null;

  get country => null;

  get state => null;

  get city => null;

  get zipCode => null;

  get address => null;

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


