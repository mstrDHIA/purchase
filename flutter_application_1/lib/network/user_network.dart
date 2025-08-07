import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/api.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';

class UserNetwork {
  // Récupère les détails d'un utilisateur via l'API user/users-with-details/{id}/
  Future<User?> getUserDetails(int userId) async {
    try {
      final response = await api.dio.get(
        '${APIS.baseUrl}user/users-with-details/$userId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS().token}',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return User.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des détails utilisateur: $e');
      return null;
    }
  }
  APIS api = APIS();

// login
   login(String email, String password) async {
  final response = await api.dio.post(
    '${APIS.baseUrl}${APIS.login}',
    data: {'username': email, 'password': password},
  );
  // print(response.data);
  // print(response.statusCode);

  if (response.statusCode == 200) {
    final data = response.data;
    final accessToken = data['access'];
    if (accessToken != null) {
      // Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      return response; // Retourne les données de l'utilisateur
      // return decodedToken['user_id'];
    }
  }
  return null;
}
  // register
  Future<dynamic> register({required String username, required String password}) async {
    final response = await api.dio.post(
      'https://d2e9d48e4ff7.ngrok-free.app/user/register/',
      data: {
        'username': username,
        'email': username, 
        'password': password,
      },
    );
    return response.data;
  }
  // user list
    uesresList() async {
  
      final response = await api.dio.get(
        options: Options(
            headers: {
              'ngrok-skip-browser-warning': 'true',
              'Authorization':' Bearer ${APIS().token}',


            }),
        '${APIS.baseUrl}user/users/',
      );
      
   
    
    return response;
    }

  callUser(String email) {}

  // add user
  Future<dynamic> addUser(User user) async {
    try {
      final response = await api.dio.post(
        '${APIS.baseUrl}${APIS.userList}',
        data: user.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS().token}',

            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        return {'error': 'Failed to add user', 'status': response.statusCode, 'message': response.statusMessage};
      }
    } catch (e) {
      return {'error': 'Error adding user', 'details': e.toString()};
    }
  }

  // Delete user
  Future<String> deleteUser(int userId) async {
    try {
      final response = await api.dio.delete(
        '${APIS.baseUrl}${APIS.deleteUser}$userId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS().token}',

            'ngrok-skip-browser-warning': 'true'
          },
        ),
      );

      if (response.statusCode == 204) {
        return 'User deleted successfully.';
      } else {
        return 'Failed to delete user: ${response.statusMessage}';
      }
    } catch (e) {
      return 'Error deleting user: $e';
    }
  }

  Future<String> addProfile(User user) async {
    try {
      final response = await api.dio.post(
        '${APIS.baseUrl}${APIS.addProfile}', // adapte le endpoint si besoin
        data: user.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS().token}', // ton token ici

            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return 'User added successfully.';
      } else {
        return 'Failed to add user: ${response.statusMessage}';
      }
    } catch (e) {
      return 'Error adding user: $e';
    }
  }

  Future<String> updateUser(User updatedUser) async {
    try {
      final response = await api.dio.put(
        '${APIS.baseUrl}${APIS.userList}${updatedUser.id}/',
        data: updatedUser.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS().token}',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return 'User updated successfully.';
      } else {
        return 'Failed to update user: ${response.statusMessage}';
      }
    } catch (e) {
      return 'Error updating user: $e';
    }
  }

  // addUser(User newUser) {} // Removed duplicate method
  Future<User?> viewUser(int userId) async {
  try {
    final response = await api.dio.get(
      '${APIS.baseUrl}user/users/$userId/',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${APIS().token}',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );
    if (response.statusCode == 200) {
      
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return User.fromJson(data[0]);
      } else if (data is Map<String, dynamic>) {
        return User.fromJson(data);
      }
    }
    return null;
  } catch (e) {
    print('Erreur lors de la récupération de l\'utilisateur: $e');
    return null;
  }
}


getDetailedUser(int userId) async {
    try {
      final response = await api.dio.get(
        '${APIS.baseUrl}${APIS.viewProfileByUserId}$userId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS().token}',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }
}