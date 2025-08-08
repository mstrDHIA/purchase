import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:go_router/go_router.dart';

class UserController extends ChangeNotifier {
  // Change password via UserNetwork
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

  UserNetwork userNetwork = UserNetwork();

  List<User> get filteredUsers {
    List<User> filtered = users.where((user) {
      final matchesSearch = searchText.isEmpty ||
          user.email!.toLowerCase().contains(searchText.toLowerCase()) ||
          user.username!.toLowerCase().contains(searchText.toLowerCase());
      final matchesPermission = selectedPermission == null || user.permission == selectedPermission;
      final matchesStatus = selectedStatus == null || user.status == selectedStatus;
      return matchesSearch && matchesPermission && matchesStatus;
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
          filtered.sort((a, b) => sortAscending
              ? a.status.compareTo(b.status)
              : b.status.compareTo(a.status));
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

  Future<void> getUsers() async {
    isLoading = true;
    notifyListeners();
    Response response = await userNetwork.uesresList();
    if (response.statusCode == 200) {
      users = (response.data as List).map((user) => User.fromJson(user)).toList();
      isLoading = false;
      notifyListeners();
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load users');
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


  login(String email, String password,BuildContext context) async {
    isLoading = true;
    notifyListeners();
    Response response = await userNetwork.login(email, password);
    if (response.statusCode == 200) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(response.data['access']);
      currentUserId = decodedToken['user_id'];
      selectedUserId = currentUserId;
      print('current user id: {$currentUserId}');
      context.go('/main_screen');
      print(decodedToken);
      print(response.data);
      // Handle successful login
    } else {
      // Handle login error
    }
    isLoading = false;
    notifyListeners();
    
    }
  Future<User> getDetailedUser(int userId) async {
    isLoading = true;
    notifyListeners();
    // print('getting response for user id: $userId');
    Response response = await userNetwork.getDetailedUser(userId);
    // print('got response: ${response.data}');
    if (response.statusCode == 200) {
      // print('response 200');
      User user = User.fromJson(response.data[0]);
      // print('user name: ${user.profile?.firstName}');
      isLoading = false;
      // nameController.text = user.firstName ?? '';
      selectedUser = user; // Store the user in the controller
      // print( 'User details: ${response.data}');
      notifyListeners();
      return user;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load user details');
    }
  }

   updateAllUser(firstName, lastName, email, username, country, state, city, address, location, zipCode) async {
    print('aaaaa');
  
    isLoading = true;
    print('bbb ');
    notifyListeners();
    try {
      print('ccc');
      final Map<String, dynamic> data ={
      
};
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

print('ddd');
      // Map<String, dynamic> data = user.toJson();
      Response result = await userNetwork.updateAllUsers(data, selectedUserId!);
      print('eee');
      print(result);
      print(result.data);
      // await getUsers(); // Refresh user list after update
      isLoading = false;
      notifyListeners();
      // return result;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Error updating user: $e';
    }
  }

  notify(){
    notifyListeners();
  }
}