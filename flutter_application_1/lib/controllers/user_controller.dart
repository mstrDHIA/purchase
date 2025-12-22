import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/role.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:go_router/go_router.dart';

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
    isLoading = false;
    notifyListeners();

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
    isLoading = false;
    notifyListeners();
    return filtered;
  }

   getUsers() async {
    users.clear();
    isLoading = true;
    notifyListeners();
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
          notifyListeners();
          print('✅ Successfully loaded ${users.length} users');
        } else if (response.data is Map && response.data['results'] is List) {
          // Handle paginated response
          users = (response.data['results'] as List).map((user) => User.fromJson(user)).toList();
          isLoading = false;
          notifyListeners();
          print('✅ Successfully loaded ${users.length} users (paginated)');
        } else {
          print('⚠️ Unexpected data format: ${response.data.runtimeType}');
        }
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        throw Exception('Failed to load users: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      isLoading = false;
      notifyListeners();
      print('❌ Dio Error: ${e.message}');
      print('❌ Error type: ${e.type}');
      print('❌ Response status: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
      print('❌ Error detail: ${e.error}');
    } catch (e) {
      isLoading = false;
      notifyListeners();
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
        // navigation decided by role id
        final int? roleId = currentUser.role?.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final router = GoRouter.of(context);
          if (roleId == 1 || roleId == 3|| roleId == 2|| roleId == 4) {
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

  Future<void> register(String email, String password,BuildContext context) async {
    try{
      isLoading = true;
    notifyListeners();
    Response response = await userNetwork.register(username: email, password: password);
    if (response.statusCode == 201) {
      login(email, password, context,null);

    } 
   
    else {
      isLoading = false;
      notifyListeners();
      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('An error occurred during register. Please try again.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

      if(role.id!=selectedUser.role!.id){
      data['role_id'] = role.id;
      }
      // Debug: log department info and payload
      try {
        // ignore: avoid_print
        print('updateAllUser: department -> id=${department?.id}, name=${department?.name}');
        // ignore: avoid_print
        print('updateAllUser: payload before send -> $data');
      } catch (e) {}
      if (department != null) {
        // API may accept multiple keys; include them all to maximize compatibility
        data['dep_id'] = department.id;
        data['department_id'] = department.id;
        data['department'] = department.id; // some backends accept department as id
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

      // Refresh the detailed user data using the 'viewUser' endpoint which returns full user info including dep_id
      try {
        var refreshed = await userNetwork.viewUser(selectedUserId!);
        if (refreshed != null) {
          // ignore: avoid_print
          print('updateAllUser: refreshed selectedUser.depId=${refreshed.depId}');
          final idx = users.indexWhere((u) => u.id == selectedUserId);
          if (idx != -1) {
            users[idx] = refreshed;
          }
          selectedUser = refreshed;
        }

        // If depId still null but we tried to set department, attempt fallback PATCH variants
        if ((refreshed == null || refreshed.depId == null) && department != null) {
          final fallbacks = [
            {'dep_id': department.id},
            {'department_id': department.id},
            {'department': department.id},
            {'department': {'id': department.id}},
          ];
          for (final fb in fallbacks) {
            try {
              await userNetwork.partialUpdateUser(fb, selectedUserId!);
              // refresh
              refreshed = await userNetwork.viewUser(selectedUserId!);
              // ignore: avoid_print
              print('updateAllUser: after fallback ${fb.keys.first} -> refreshed.depId=${refreshed?.depId}');
              if (refreshed != null && refreshed.depId != null) {
                final idx2 = users.indexWhere((u) => u.id == selectedUserId);
                if (idx2 != -1) users[idx2] = refreshed;
                selectedUser = refreshed;
                break;
              }
            } catch (e) {
              // ignore
            }
          }
        }
      } catch (e) {
        // ignore
      }

      displaySnackBar = true;

      try {
        context.pop();
      } catch (e) {
        // ignore: avoid_print
        print('updateAllUser: pop failed: $e');
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
      notifyListeners();
      try {
        // ignore: avoid_print
        print('updateAllUser: finished for selectedUserId=$selectedUserId');
      } catch (e) {}
    }
  }

  void notify(){
    notifyListeners();
  }
}



