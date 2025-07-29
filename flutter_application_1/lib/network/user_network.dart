import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/api.dart';

class UserNetwork {
  APIS api = APIS();

// login
  Future<String> login(String username, String password) async {
    // Simulate a network call
    
    
    // Here you would typically make an HTTP request to the API
    // For example:
    final response = await api.dio.post(
      '${APIS.baseUrl}${APIS.login}',
      data: {'username': username, 'password': password},
    );
    
    // For now, we will just return a success message
    return 'Login successful for user: $username';
  }
  // register
  Future<dynamic> register({required String username, required String password}) async {
    final response = await api.dio.post(
      'https://d2e9d48e4ff7.ngrok-free.app/user/register/', // <-- corrige ici si besoin
      data: {
        'username': username,
        'email': username, // ou un champ séparé si tu veux
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

  // Update user
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

  updateUser(User updatedUser) {}

  // addUser(User newUser) {} // Removed duplicate method
}