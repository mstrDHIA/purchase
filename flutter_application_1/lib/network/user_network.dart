import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/api.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';

class UserNetwork {
  // Change password via API user/change-password/
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await api.dio.post(
        '${APIS.baseUrl}user/change-password/',
        data: {
          'old_password': currentPassword,
          'new_password': newPassword,
          // 'confirm_password': confirmPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 200) {
        return 'Password updated successfully';
      }
      else {
        return 'Failed to update password: ${response.statusMessage}';
      }
      }catch (e) {
        return 'Error updating password: $e';
      }
  }
   
   Future<String> updateUser(data,id) async {
    try {
      final response = await api.dio.put(
        '${APIS.baseUrl}${APIS.updateAllUsers}$id/',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
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

  
  APIS api = APIS();

// login
   Future<Response?>? login(String email, String password) async {
  final response = await api.dio.post(

    '${APIS.baseUrl}${APIS.login}',

    data: {'username': email, 'password': password},
    options: Options(
          headers: {
            'ngrok-skip-browser-warning': 'true',
            'Content-Type': 'application/json',

          },
        ),
  );

  if (response.statusCode == 200) {
    APIS.token = response.data['access'];
    final data = response.data;
    final accessToken = data['access'];
    if (accessToken != null) {
      return response; 
    }
  }
  return null;
}
  // register
  Future<dynamic> register({required String username, required String password}) async {
    final response = await api.dio.post(
      '${APIS.baseUrl}${APIS.register}',
      data: {
        'username': username,
        'role_id': 5, 
        // 'email': username, 
        'password': password,
      },
    );
    return response;
  }
  // user list
    Future<Response> uesresList() async {
  
      final response = await api.dio.get(
        '${APIS.baseUrl}${APIS.userListDetailed}',
        options: Options(
            headers: {
              'ngrok-skip-browser-warning': 'true',
              'Authorization': 'Bearer ${APIS.token}',
            }),
      );
      
      print('📡 Network request to: ${APIS.baseUrl}${APIS.userListDetailed}');
      print('🔑 Token: ${APIS.token.substring(0, 20)}...');
      print('📊 Raw response: ${response.data}');
    
    return response;
    }

  void callUser(String email) {}

  // add user
  Future<dynamic> addUser(User user) async {
    try {
      final response = await api.dio.post(
        '${APIS.baseUrl}${APIS.userList}',
        data: user.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',

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
            'Authorization': 'Bearer ${APIS.token}',

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
            'Authorization': 'Bearer ${APIS.token}', // ton token ici

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

  // Future<String> updateUser(User updateUser) async {
  //   try {
  //     final response = await api.dio.put(
  //       '${APIS.baseUrl}${APIS.userList}${updateUser.id}/',
  //       data: updateUser.toJson(),
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer ${APIS.token}',
  //           'ngrok-skip-browser-warning': 'true',
  //         },
  //       ),
  //     );
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return 'User updated successfully.';
  //     } else {
  //       return 'Failed to update user: ${response.statusMessage}';
  //     }
  //   } catch (e) {
  //     return 'Error updating user: $e';
  //   }
  // }

  // addUser(User newUser) {} // Removed duplicate method
  Future<User?> viewUser(int userId) async {
  try {
    final response = await api.dio.get(
      '${APIS.baseUrl}user/users/$userId/',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${APIS.token}',
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


Future<Response?>? getDetailedUser(int userId) async {
    try {
      final response = await api.dio.get(
        '${APIS.baseUrl}${APIS.viewProfileByUserId}$userId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
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

   Future<Response> updateAllUsers( Map<String,dynamic> data, int id) async {
  try {
    // Debug: log request
    try {
      // ignore: avoid_print
      print('UserNetwork.updateAllUsers: PUT ${APIS.baseUrl}${APIS.updateAllUsers}$id/ payload=$data');
    } catch (e) {}

    final response = await api.dio.put(
      '${APIS.baseUrl}${APIS.updateAllUsers}$id/',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${APIS.token}',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    // Debug: log response
    try {
      // ignore: avoid_print
      print('UserNetwork.updateAllUsers: response status=${response.statusCode}, data=${response.data}');
    } catch (e) {}

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      return response;
      // return 'Failed to update all users: ${response.statusMessage}';
    }
  } catch (e) {
    // ignore: avoid_print
    print('UserNetwork.updateAllUsers: error -> $e');
    rethrow;
  }
}
  Future<Response> getUserById(int id) async {
  return await api.dio.get('${APIS.baseUrl}user/$id/');
}

  /// Partially update a user resource (PATCH) at /user/users/<id>/
  Future<Response> partialUpdateUser(Map<String, dynamic> data, int id) async {
    try {
      // Debug
      try {
        // ignore: avoid_print
        print('UserNetwork.partialUpdateUser: PATCH ${APIS.baseUrl}${APIS.userList}$id/ payload=$data');
      } catch (e) {}

      final response = await api.dio.patch(
        '${APIS.baseUrl}${APIS.userList}$id/',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );

      try {
        // ignore: avoid_print
        print('UserNetwork.partialUpdateUser: response status=${response.statusCode}, data=${response.data}');
      } catch (e) {}

      return response;
    } catch (e) {
      // ignore: avoid_print
      print('UserNetwork.partialUpdateUser: error -> $e');
      rethrow;
    }
  }
}
