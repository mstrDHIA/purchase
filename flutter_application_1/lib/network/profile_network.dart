import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/api.dart';

class ProfileNetwork {
  // View profile (get user profile by userId)
  Future<Profile?> viewProfile(int userId) async {
    try {
      print('Fetching profile with userId: ' + userId.toString());
      final response = await api.dio.get(
        '${APIS.baseUrl}${APIS.viewProfile}',
        queryParameters: {'user': userId},
        options: Options(
          headers: {
            'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzUzNjk4NzEyLCJpYXQiOjE3NTMwOTM5MTIsImp0aSI6ImMyYzNkZDExM2I4MDRmOTFhODZjNmRmMjYxOGE2MjIxIiwidXNlcl9pZCI6Mzd9.zFuZLd3ioapGACZ5X_B1gA27OiIpzZruJ-I-nUhrvBo',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          return Profile.fromJson(data[0]);
        } else if (data is Map && data.isNotEmpty) {
          // Si l'API retourne un seul objet
          return Profile.fromJson(Map<String, dynamic>.from(data));
        } else {
          print('No profile found for userId: $userId');
          return null;
        }
      } else {
        print('Profile fetch failed: status ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Profile fetch error: $e');
      return null;
    }
  }
  APIS api = APIS();

  // Add profile (create user profile)
  Future<String> addProfile(Profile profile) async {
    try {
      final response = await api.dio.post(
        '${APIS.baseUrl}${APIS.addProfile}',
        data: profile.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzUzNjk4NzEyLCJpYXQiOjE3NTMwOTM5MTIsImp0aSI6ImMyYzNkZDExM2I4MDRmOTFhODZjNmRmMjYxOGE2MjIxIiwidXNlcl9pZCI6Mzd9.zFuZLd3ioapGACZ5X_B1gA27OiIpzZruJ-I-nUhrvBo', // Remplace par ton vrai token
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return 'Profile added successfully.';
      } else {
        return 'Failed to add profile: \\${response.statusMessage}';
      }
    } catch (e) {
      return 'Error adding profile: $e';
    }
  }
}
