
import 'package:dio/dio.dart';
import 'api.dart';

class RoleNetwork {
  // Voir un rôle par id
  Future<Map<String, dynamic>?> viewRole(int id) async {
    try {
      final response = await _dio.get(
        APIS.baseUrl + 'role/roles/$id/',
        options: Options(headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU0MzEyMzYxLCJpYXQiOjE3NTM3MDc1NjEsImp0aSI6ImYzYzg0MmY1OTEwMjQ4YWU5ZjMwYjdmOTc1OGY3YTI3IiwidXNlcl9pZCI6Mzd9.nHBidPRwwtBQ3WloMCMV9p9sQ0Oz7LZlf4rcYUag3_A',
          'ngrok-skip-browser-warning': 'true'}),
      );
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du rôle: $e');
      return null;
    }
  }
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> fetchRoles() async {
    try {
      final response = await _dio.get(
        APIS.baseUrl + 'role/roles/',
        options: Options(headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU0MzEyMzYxLCJpYXQiOjE3NTM3MDc1NjEsImp0aSI6ImYzYzg0MmY1OTEwMjQ4YWU5ZjMwYjdmOTc1OGY3YTI3IiwidXNlcl9pZCI6Mzd9.nHBidPRwwtBQ3WloMCMV9p9sQ0Oz7LZlf4rcYUag3_A',
          'ngrok-skip-browser-warning': 'true'}),
      );
      if (response.statusCode == 200) {
        // Retourne la liste complète des rôles (Map)
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Erreur lors de la récupération des rôles');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Ajouter un rôle
  Future<bool> addRole(String name, String description) async {
    try {
      final response = await _dio.post(
        APIS.baseUrl + 'role/roles/',
        data: {
          'name': name,
          'description': description,
        },
        options: Options(headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU0MzEyMzYxLCJpYXQiOjE3NTM3MDc1NjEsImp0aSI6ImYzYzg0MmY1OTEwMjQ4YWU5ZjMwYjdmOTc1OGY3YTI3IiwidXNlcl9pZCI6Mzd9.nHBidPRwwtBQ3WloMCMV9p9sQ0Oz7LZlf4rcYUag3_A',
          'ngrok-skip-browser-warning': 'true'}),
      );
      print('Status: \\${response.statusCode}, Data: \\${response.data}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Erreur addRole: \\${e}');
      return false;
    }
  }

  // Supprimer un rôle
  Future<bool> deleteRole(dynamic id) async {
    try {
      final response = await _dio.delete(
        APIS.baseUrl + 'role/roles/$id/',
        options: Options(headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU0MzEyMzYxLCJpYXQiOjE3NTM3MDc1NjEsImp0aSI6ImYzYzg0MmY1OTEwMjQ4YWU5ZjMwYjdmOTc1OGY3YTI3IiwidXNlcl9pZCI6Mzd9.nHBidPRwwtBQ3WloMCMV9p9sQ0Oz7LZlf4rcYUag3_A',
          'ngrok-skip-browser-warning': 'true'}),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur lors de la suppression du rôle: $e');
    }
  }

  // Modifier un rôle
  Future<bool> updateRole(int id, String oldRole, String newRole, String description, List<String> permissions) async {
    try {
      final response = await _dio.put(
        APIS.baseUrl + 'role/roles/$id/',
        data: {
          'old_role': oldRole,
          'name': newRole,
          'description': description,
          'permissions': permissions,
        },
        options: Options(headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU0MzEyMzYxLCJpYXQiOjE3NTM3MDc1NjEsImp0aSI6ImYzYzg0MmY1OTEwMjQ4YWU5ZjMwYjdmOTc1OGY3YTI3IiwidXNlcl9pZCI6Mzd9.nHBidPRwwtBQ3WloMCMV9p9sQ0Oz7LZlf4rcYUag3_A',
          'ngrok-skip-browser-warning': 'true'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur lors de la modification du rôle: $e');
    }
  }
  // ...

  // ...
}
