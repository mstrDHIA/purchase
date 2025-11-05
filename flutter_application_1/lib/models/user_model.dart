import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/models/role.dart';

extension UserComputedFields on User {
  // String get name => '[200m$firstName $lastName[0m';
  String get permission => isSuperuser! ? 'Admin' : 'User';
}
class User {
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final bool? isSuperuser;
  final String? password;
  final int? profileId;
  final int? role_id;
  final Profile? profile;
   Role? role;
   bool? isActive;

  User( {
     this.id,
    this.role_id,
    this.profile,
     this.username,
     this.email,
     this.firstName,
     this.lastName,
     this.isSuperuser,
     this.password,
    this.profileId,
    this.role,
    this.isActive, 
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    final profile = profileJson != null ? Profile.fromJson(Map<String, dynamic>.from(profileJson)) : null;
    final roleJson = json['role'];
    final role = roleJson != null ? Role.fromJson(Map<String, dynamic>.from(roleJson)) : null;
    final firstName = (json['first_name'] != null && json['first_name'] != '')
        ? json['first_name']
        : (profile?.firstName ?? '');
    final lastName = (json['last_name'] != null && json['last_name'] != '')
        ? json['last_name']
        : (profile?.lastName ?? '');
    final profileId = json['profile_id'] ?? (profile?.id);
    final roleId = json['role_id'];
    final isActive = json['is_active'] ?? true; // Default to true if not provided
    // Debug print
    // print('User.fromJson: firstName=$firstName, lastName=$lastName, profileId=$profileId, roleId=$roleId');
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: firstName,
      lastName: lastName,
      isSuperuser: json['is_superuser'] ?? false,
      password: json['password'] ?? '',
      profile: profile,
      profileId: profileId,
      role_id: roleId,
      role: role, // If you want to parse role object, add here,
      isActive: isActive,
    );
  }

  Null get name => null;

  // get bio => null;

  // get location => null;

  // get country => null;

  // get state => null;

  // get city => null;

  // get zipCode => null;

  // get address => null;

  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'username': username,
      'email': email,
      // 'first_name': firstName,
      // 'last_name': lastName,
      // 'is_superuser': isSuperuser,
      if (profileId != null) 'profile_id': profileId,
      if (role != null) 'role': role,
    };
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    return data;
  }
}


