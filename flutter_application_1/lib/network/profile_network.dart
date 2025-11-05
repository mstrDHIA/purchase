import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/network/api.dart';

class ProfileNetwork {
  // View profile (get user profile by userId)
  Future<Profile?> viewProfile(int userId) async {
    try {
      final response = await api.dio.get(
        '${APIS.baseUrl}${APIS.viewProfile}$userId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU0OTE1NzQzLCJpYXQiOjE3NTQzMTA5NDMsImp0aSI6IjNjMDAyMjA4N2YxMTQyNjI5NmM4MmNlZTI0ZmQ0NDIzIiwidXNlcl9pZCI6NjF9.XwwEPGmilSuj-5tp-1IrTYkDxvr2hw6F4VRmo21VL9g',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.isNotEmpty) {
          // Si l'API retourne un seul objet
          return Profile.fromJson(Map<String, dynamic>.from(data));
        } else {
          print('No profile found for profileId: $userId');
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
  Future<String> addProfile(Profile profile,int userId) async {
    try {
      Map<String,dynamic> data=profile.toJson();
      data['user_id'] = userId; // Ajoute l'ID de l'utilisateur au profil
      final response = await api.dio.post(
        '${APIS.baseUrl}${APIS.addProfile}',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU0OTE1NzQzLCJpYXQiOjE3NTQzMTA5NDMsImp0aSI6IjNjMDAyMjA4N2YxMTQyNjI5NmM4MmNlZTI0ZmQ0NDIzIiwidXNlcl9pZCI6NjF9.XwwEPGmilSuj-5tp-1IrTYkDxvr2hw6F4VRmo21VL9g', // Remplace par ton vrai token
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

  Future<String> updateProfile(Profile profile, int profileId) async {
    try {
      final data = profile.toJson();
      final response = await api.dio.patch(
        '${APIS.baseUrl}profile/profiles/$profileId/',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 200) {
        return 'Profile updated successfully.';
      } else {
        return 'Failed to update profile: ${response.statusMessage}';
      }
    } catch (e) {
      return 'Error updating profile: $e';
    }
  }

  void createProfile(Profile profile) {}
}
