import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/role.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:flutter_application_1/network/api.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserController extends ChangeNotifier {
  bool displaySnackBar = false;
    bool isLoading = false;
  List<User> users = [];
  String searchText = '';
  String? selectedPermission;
  String? selectedStatus;
  int? sortColumnIndex;
  bool sortAscending = true;
  User selectedUser = User();
  User currentUser = User();
  int? currentUserId;
  int? selectedUserId;

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      String result = await userNetwork.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return result;
    } catch (e) {
      return 'Error updating password: $e';
    }
  }
  // Future<String> updateUser(User updatedUser) async {
  //   isLoading = true;
  //   notifyListeners();
  //   try {
  //     String result = await userNetwork.updateUser(updatedUser,selectedUserId);
  //     await getUsers(); // Refresh user list after update
  //     isLoading = false;
  //     notifyListeners();
  //     return result;
  //   } catch (e) {
  //     isLoading = false;
  //     notifyListeners();
  //     return 'Error updating user: $e';
  //   }
  // }


  UserNetwork userNetwork = UserNetwork();

  List<User> get filteredUsers {
    List<User> filtered = users.where((user) {
      final matchesSearch = searchText.isEmpty ||
          user.email!.toLowerCase().contains(searchText.toLowerCase()) ||
          user.username!.toLowerCase().contains(searchText.toLowerCase());
      final matchesPermission = selectedPermission == null || user.permission == selectedPermission;
      
      // Fix: Compare boolean isActive with string selectedStatus
      final statusMatches = selectedStatus == null || 
          (user.isActive == true && selectedStatus == 'Active') ||
          (user.isActive == false && selectedStatus == 'Inactive');
      
      return matchesSearch && matchesPermission && statusMatches;
    }).toList();

    if (sortColumnIndex != null) {
      switch (sortColumnIndex) {
        case 0:
          filtered.sort((a, b) => sortAscending
              ? a.email!.compareTo(b.email!)
              : b.email!.compareTo(a.email!));
          break;
        case 1:
          filtered.sort((a, b) => sortAscending
              ? a.username!.compareTo(b.username!)
              : b.username!.compareTo(a.username!));
          break;
        case 2:
          // filtered.sort((a, b) => sortAscending
          //     ? a.isActive.compareTo(b.status)
          //     : b.status.compareTo(a.status));
          break;
        case 3:
          filtered.sort((a, b) => sortAscending
              ? a.permission.compareTo(b.permission)
              : b.permission.compareTo(a.permission));
          break;
      }
    }
    return filtered;
  }

   getUsers() async {
    users.clear();
    isLoading = true;
    safeNotify();
    try {
      print('🔄 Fetching users from server...');
      Response response = await userNetwork.uesresList();
      print('✅ Response received: Status ${response.statusCode}');
      print('📋 Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          users  =  (response.data as List).map((user) {
            print('👤 Parsing user: $user');
            
            return User.fromJson(user);
          }).toList();
          isLoading = false;
          safeNotify();
          print('✅ Successfully loaded ${users.length} users');
        } else if (response.data is Map && response.data['results'] is List) {
          // Handle paginated response
          users = (response.data['results'] as List).map((user) => User.fromJson(user)).toList();
          isLoading = false;
          safeNotify();
          print('✅ Successfully loaded ${users.length} users (paginated)');
        } else {
          print('⚠️ Unexpected data format: ${response.data.runtimeType}');
        }
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        safeNotify();
        throw Exception('Failed to load users: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      isLoading = false;
      safeNotify();
      print('❌ Dio Error: ${e.message}');
      print('❌ Error type: ${e.type}');
      print('❌ Response status: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
      print('❌ Error detail: ${e.error}');
    } catch (e) {
      isLoading = false;
      safeNotify();
      print('❌ Unexpected error while fetching users: $e');
    }
  }

  void setSearchText(String value) {
    searchText = value;
    notifyListeners();
  }

  void setPermission(String? value) {
    selectedPermission = value == 'All' ? null : value;
    notifyListeners();
  }

  void setStatus(String? value) {
    selectedStatus = value == 'All' ? null : value;
    notifyListeners();
  }

  void sortUsers(int columnIndex, bool ascending) {
    sortColumnIndex = columnIndex;
    sortAscending = ascending;
    notifyListeners();
  }

  Future<void> deleteUser(BuildContext context, User user) async {
    isLoading = true;
    notifyListeners();
    await userNetwork.deleteUser(user.id!);
    users.removeWhere((u) => u.id == user.id);
    isLoading = false;
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.username} deleted')),
    );
  }


  void logout(BuildContext context){
    isLoading = true;
    notifyListeners();
    currentUser = User();
    currentUserId = null;
    selectedUserId = null;
    selectedUser = User();
    clearUserData(); // Effacer les données sauvegardées
    isLoading = false;
    context.go('/login');
    notifyListeners();
  }

  Future<void> login(String email, String password,BuildContext context,GlobalKey<FormState>? _formKey) async {
    try {
      // if ((!(_formKey!.currentState!.validate()))&&_formKey!=null) {
        isLoading = true;
      notifyListeners();
      Response? response = await userNetwork.login(email, password);
      if (response!.statusCode == 200) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(response.data['access']);
        currentUserId = decodedToken['user_id'];
        selectedUserId = currentUserId;
        currentUser = User.fromJson(response.data['user']);
        
        // Sauvegarder les données utilisateur, token d'accès et refresh token
        final refreshToken = response.data['refresh'];
        await saveUserData(response.data['access'], response.data['user'], refreshToken: refreshToken);
        
        // navigation decided by role id
        final int? roleId = currentUser.role?.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final router = GoRouter.of(context);
          if (roleId == 1) {
            router.go('/dashboard'); // Admin goes to dashboard
          } else if (roleId == 3|| roleId == 2|| roleId == 4) {
            router.go('/purchase_requests'); // ensure this route exists in your GoRouter routes
          } else if ( roleId == 6) {
            router.go('/purchase_orders'); // ensure this route exists in your GoRouter routes
          } else {
            router.go('/main_screen');
          }
        });
        isLoading = false;
        notifyListeners();
      } else if (response.statusCode == 401) {
        isLoading = false;
        notifyListeners();
        SnackBar snackBar = SnackBar(
          backgroundColor: Colors.amber,
          content: Text('Invalid email or password. Please try again.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else {
        isLoading = false;
        notifyListeners();
        SnackBar snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred during login. Please try again.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        isLoading = false;
        notifyListeners();
        // return;
      // }
      // else{

      // }
      
    } catch (e) {
      print('Login error: $e');
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred during login'),
        ),
      );
    }
  }

  // Sauvegarder les données utilisateur dans SharedPreferences
  Future<void> saveUserData(String token, Map<String, dynamic> userData, {String? refreshToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_data', jsonEncode(userData));
      if (refreshToken != null) {
        await prefs.setString('refresh_token', refreshToken);
      }
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Charger les données utilisateur depuis SharedPreferences
  Future<bool> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userDataJson = prefs.getString('user_data');

      if (token != null && userDataJson != null) {
        try {
          // Vérifier si le token est expiré
          bool isExpired = JwtDecoder.isExpired(token);
          
          if (!isExpired) {
            Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
            currentUserId = decodedToken['user_id'];
            selectedUserId = currentUserId;
            
            Map<String, dynamic> userData = jsonDecode(userDataJson);
            if (userData.isNotEmpty) {
              currentUser = User.fromJson(userData);
              // Mettre à jour le token global
              APIS.token = token;
              notifyListeners();
              return true;
            }
          } else {
            // Token expiré, essayer de le rafraîchir
            final refreshToken = prefs.getString('refresh_token');
            if (refreshToken != null) {
              return await refreshAccessToken(refreshToken);
            } else {
              // Pas de refresh token, effacer les données
              await clearUserData();
              return false;
            }
          }
        } catch (e) {
          print('Error decoding token or user data: $e');
          await clearUserData();
          return false;
        }
      }
      return false;
    } catch (e) {
      print('Error loading user data: $e');
      return false;
    }
  }

  // Rafraîchir le token d'accès
  Future<bool> refreshAccessToken(String refreshToken) async {
    try {
      print('Attempting to refresh token...');
      final response = await userNetwork.refreshToken(refreshToken);
      if (response != null && response.statusCode == 200) {
        final newToken = response.data['access'];
        if (newToken != null) {
          // Sauvegarder le nouveau token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', newToken);
          APIS.token = newToken;
          
          // Si un nouveau refresh token est fourni
          if (response.data['refresh'] != null) {
            await prefs.setString('refresh_token', response.data['refresh']);
          }
          
          print('Token refreshed successfully');
          notifyListeners();
          return true;
        }
      }
      // Échec du refresh, effacer les données
      await clearUserData();
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      await clearUserData();
      return false;
    }
  }

  // Effacer les données utilisateur
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('refresh_token');
      currentUserId = null;
      selectedUserId = null;
      currentUser = User();
      notifyListeners();
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }

  Future<bool> register(String email, String password, BuildContext context, {bool autoLogin = true}) async {
    try {
      isLoading = true;
      notifyListeners();
      Response response = await userNetwork.register(username: email, password: password);
      if (response.statusCode == 201) {
        isLoading = false;
        notifyListeners();
        if (autoLogin) {
          await login(email, password, context, null);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful. Please sign in.'), backgroundColor: Colors.green),
          );
        }
        return true;
      } else {
        isLoading = false;
        notifyListeners();
        SnackBar snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text('An error occurred during register. Please try again.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print(e);
      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('An error occurred during register'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  }

    Future<void> addUser(String email, String password,BuildContext context) async {
    try{
      isLoading = true;
    notifyListeners();
    Response response = await userNetwork.register(username: email, password: password);
    if (response.statusCode == 201) {
      displaySnackBar = true;
      notifyListeners();

      
      context.pop();
 
    } 
   
    // }
    else {
      isLoading = false;
      notifyListeners();
      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('An error occurred during adding user. Please try again.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
      isLoading = false;
      notifyListeners();
      SnackBar snackBar = SnackBar(

        backgroundColor: Colors.red,
        content: Text('An error occurred during adding user'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }  
    }




  Future<User> getDetailedUser(int userId) async {
    isLoading = true;
    notifyListeners();
    Response? response = await userNetwork.getDetailedUser(userId);
    if (response!.statusCode == 200) {
      User user = User.fromJson(response.data[0]); // <-- Utilise directement response.data
      isLoading = false;
      selectedUser = user;
      notifyListeners();
      return user;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load user details');
    }
  }

  Future<void> toggleUserStatus({required int id, required bool isActive,context}) async {
    isLoading = true;
    notifyListeners();
    Map<String, dynamic> data = {
      'is_active': isActive,
    };
    
    Response response =await userNetwork.updateAllUsers(data, id);
      isLoading = false;
      if(response.statusCode == 200 || response.statusCode == 201){
        users.firstWhere((user) => user.id == id).isActive = isActive;
        ScaffoldMessenger.of(context).showSnackBar(
          
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('User status updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to update user status')),
        );
      }
      
      notifyListeners();

   


  }

   Future<String?> updateAllUser(firstName, lastName, email, username, country, state, city, address, location, zipCode,Role role, dynamic department, BuildContext context) async {
    // Log start
    try {
      // ignore: avoid_print
      print('updateAllUser: start for selectedUserId=$selectedUserId');
    } catch (e) {}

    isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> data ={};
      Map<String,dynamic> profileData={};

      if(username!=selectedUser.username){
        data['username'] = username;
      }
      if(email!=selectedUser.email){
        data['email'] = email;
      }
      if(firstName!=selectedUser.profile?.firstName||lastName!=selectedUser.profile?.lastName||country!=selectedUser.profile?.country||
          state!=selectedUser.profile?.state||city!=selectedUser.profile?.city||
          address!=selectedUser.profile?.address||location!=selectedUser.profile?.location||
          zipCode!=selectedUser.profile?.zipCode){
       if(firstName!=selectedUser.profile?.firstName){
        profileData['first_name'] = firstName;
      }
      if(lastName!=selectedUser.profile?.lastName){
        profileData['last_name'] = lastName;
      }
      if(country!=selectedUser.profile?.country){
        profileData['country'] = country;
      }
      if(state!=selectedUser.profile?.state){
        profileData['state'] = state;
      }
      if(city!=selectedUser.profile?.city){
        profileData['city'] = city;
      }
      if(address!=selectedUser.profile?.address){
        profileData['address'] = address;
      }
      if(location!=selectedUser.profile?.location){
        profileData['location'] = location;
      }
      if(zipCode!=selectedUser.profile?.zipCode){
        profileData['zip_code'] = zipCode;
      }
      data['profile'] = profileData;
      }

      // Always include role_id when a role is provided (server expects a PK)
      try {
        if (role.id != null) data['role_id'] = role.id;
      } catch (e) {}

      // Debug: log department info and payload
      try {
        // ignore: avoid_print
        print('updateAllUser: department -> id=${department?.id}, name=${department?.name}');
        // ignore: avoid_print
        print('updateAllUser: payload before send -> $data');
      } catch (e) {}
      if (department != null) {
        // API expects primary key values for department
        data['dep_id'] = department.id;
        data['department_id'] = department.id;
      }
      // Debug: show payload that will actually be sent
      try {
        // ignore: avoid_print
        print('updateAllUser: sending payload -> $data');
      } catch (e) {}

      final resp = await userNetwork.updateAllUsers(data, selectedUserId!);
      // Debug: log response
      try {
        // ignore: avoid_print
        print('updateAllUser: response status=${resp.statusCode}, data=${resp.data}');
      } catch (e) {}
      // If server returned non-success, show message and abort further processing
      if (!(resp.statusCode == 200 || resp.statusCode == 201)) {
        try {
          final errorMsg = resp.data?.toString() ?? 'Failed to update user';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur serveur: $errorMsg'), backgroundColor: Colors.red));
        } catch (e) {}
        return 'Erreur serveur: ${resp.statusCode}';
      }

      // Refresh the detailed user data using the 'viewUser' endpoint which returns full user info including dep_id
      try {
        var refreshed = await userNetwork.viewUser(selectedUserId!);
        if (refreshed != null) {
          // ignore: avoid_print
          print('updateAllUser: refreshed selectedUser.depId=${refreshed.depId}, role=${refreshed.role?.id}');
          final idx = users.indexWhere((u) => u.id == selectedUserId);
          if (idx != -1) {
            users[idx] = refreshed;
          }
          selectedUser = refreshed;
        }

        // If we requested a department change but the refreshed user doesn't match, try fallback PATCH variants
        if (department != null && (refreshed == null || refreshed.depId == null || refreshed.depId != department.id)) {
          // Inform user we're attempting a fallback update for department
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tentative de mise à jour du département...'), backgroundColor: Colors.orange),
            );
          } catch (e) {}

          final fallbacks = [
            {'dep_id': department.id},
            {'department_id': department.id},
            {'department': department.id},
            {'department': {'id': department.id}},
          ];

          bool patched = false;
          for (final fb in fallbacks) {
            try {
              // ignore: avoid_print
              print('updateAllUser: trying fallback patch -> ${fb.keys.first} = ${fb.values.first}');
              await userNetwork.partialUpdateUser(fb, selectedUserId!);
              // After patch, refresh
              refreshed = await userNetwork.viewUser(selectedUserId!);
              // ignore: avoid_print
              print('updateAllUser: after fallback ${fb.keys.first} -> refreshed.depId=${refreshed?.depId}');
              if (refreshed != null && refreshed.depId == department.id) {
                final idx2 = users.indexWhere((u) => u.id == selectedUserId);
                if (idx2 != -1) users[idx2] = refreshed;
                selectedUser = refreshed;
                patched = true;
                break;
              }
            } catch (e) {
              // ignore
            }
          }

          // Notify user about fallback result
          try {
            if (patched) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Le département a été mis à jour.'), backgroundColor: Colors.green),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Le serveur n\'a pas appliqué le changement de département.'), backgroundColor: Colors.red),
              );
            }
          } catch (e) {}
        }

        // Ensure the users list is refreshed globally so UI shows updated department
        try {
          await getUsers();
        } catch (e) {
          // ignore
        }

        // Show a success SnackBar so the user sees the update result with returned values
        try {
          final msg = 'Mise à jour OK: dep=${selectedUser.depId ?? 'n/a'}, role=${selectedUser.role?.id ?? 'n/a'}';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
        } catch (e) {
          // ignore
        }

      } catch (e) {
        // ignore
      }

      displaySnackBar = true;

      try {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            context.pop(selectedUser);
          } catch (e) {
            // ignore: avoid_print
            print('updateAllUser: pop failed in post-frame: $e');
          }
        });
      } catch (e) {
        // ignore: avoid_print
        print('updateAllUser: scheduling pop failed: $e');
      }

      return null;
    } catch (e) {
      try {
        // ignore: avoid_print
        print('updateAllUser: error -> $e');
      } catch (e) {}
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour')),
        );
      } catch (e) {}
      return 'Error updating user: $e';
    } finally {
      // Ensure loading flag is always cleared
      isLoading = false;
      safeNotify();
      try {
        // ignore: avoid_print
        print('updateAllUser: finished for selectedUserId=$selectedUserId');
      } catch (e) {}
    }
  }

  /// Defer notifications to avoid calling listeners during widget build
  void safeNotify(){
    Future.microtask(() => notifyListeners());
  }

  void notify() {}
}



