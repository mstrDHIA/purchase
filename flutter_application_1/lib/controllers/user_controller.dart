import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/role.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
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


  UserNetwork userNetwork = UserNetwork();

  List<User> get filteredUsers {
    List<User> filtered = users.where((user) {
      final matchesSearch = searchText.isEmpty ||
          user.email!.toLowerCase().contains(searchText.toLowerCase()) ||
          user.username!.toLowerCase().contains(searchText.toLowerCase());
      final matchesPermission = selectedPermission == null || user.permission == selectedPermission;
      final matchesStatus = selectedStatus == null || user.isActive == selectedStatus;
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

  Future<void> getUsers() async {
    users.clear();
    isLoading = true;
    notifyListeners();
    try {
      Response response = await userNetwork.uesresList();
      print('API Response status: \\${response.statusCode}');
      print('API Response data: \\${response.data}');
      if (response.statusCode == 200) {
        if (response.data is List) {
          users = (response.data as List).map((user) => User.fromJson(user)).toList();
          print('Parsed users count: \\${users.length}');
          for (var u in users) {
            print('User: id=\\${u.id}, username=\\${u.username}, email=\\${u.email}, isActive=\\${u.isActive}, role=\\${u.role}');
          }
        } else {
          print('Response data is not a List.');
        }
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        throw Exception('Failed to load users');
      }
    } on DioError catch (e) {
      isLoading = false;
      notifyListeners();
      print('Erreur Dio : ${e.message}, type: ${e.type}, data: ${e.response?.data}, error: ${e.error}');
      // Optionnel : afficher un message utilisateur
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print('Erreur inattendue lors de la récupération des utilisateurs : $e');
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


  logout(BuildContext context){
    isLoading = true;
    notifyListeners();
    // userNetwork.logout();
    currentUser = User();
    currentUserId = null;
    selectedUserId = null;
    selectedUser = User();
    isLoading = false;
    context.go('/login');
    // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>SignInPage()), (route) => false);
    notifyListeners();
  }

  login(String email, String password,BuildContext context) async {
  try {
    isLoading = true;
    notifyListeners();
    Response response = await userNetwork.login(email, password);
    print('Login response: ${response.data}');
    if (response.statusCode == 200) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(response.data['access']);
      print('Decoded token: $decodedToken');
      currentUserId = decodedToken['user_id'];
      selectedUserId = currentUserId;
      currentUser = User.fromJson(response.data['user']);
      print('current user id: {$currentUserId}');
  context.go('/main_screen');
      print(decodedToken);
      print(response.data);
      isLoading = false;
      notifyListeners();
      // Handle successful login
    } else if (response.statusCode == 401) {
      isLoading = false;
      notifyListeners();
      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.amber,
        content: Text('Invalid email or password. Please try again.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Handle login error
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
    //  else {
    //   print('Login failed: ${response.statusCode}');
    //   isLoading = false;
    //   notifyListeners();
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       backgroundColor: Colors.red,
    //       content: Text('An error occurred during login. Please try again.'),
    //     ),
    //   );
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
   register(String email, String password,BuildContext context) async {
    try{
      isLoading = true;
    notifyListeners();
    print(email);
    print(password);
    Response response = await userNetwork.register(username: email, password: password);
    if (response.statusCode == 201) {
      login(email, password, context);
      // isLoading = false;
      // notifyListeners();
      // Handle successful login
    } 
   
    // }
    else {
      isLoading = false;
      notifyListeners();
      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('An error occurred during register. Please try again.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      // Handle unexpected error
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print(e);
      SnackBar snackBar = SnackBar(

        backgroundColor: Colors.red,
        content: Text('An error occurred during register'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Handle unexpected error
    }  
    }

    addUser(String email, String password,BuildContext context) async {
    try{
      isLoading = true;
    notifyListeners();
    Response response = await userNetwork.register(username: email, password: password);
    if (response.statusCode == 201) {
      displaySnackBar = true;
      notifyListeners();
      // login(email, password, context);
      // isLoading = false;
      
      context.pop();
      // notifyListeners();
      
      // Handle successful login
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
      // Handle unexpected error
    } catch (e) {
      print(e);
      isLoading = false;
      notifyListeners();
      SnackBar snackBar = SnackBar(

        backgroundColor: Colors.red,
        content: Text('An error occurred during adding user'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Handle unexpected error
    }  
    }




  Future<User> getDetailedUser(int userId) async {
    isLoading = true;
    notifyListeners();
    // print('getting response for user id: $userId');
    Response response = await userNetwork.getDetailedUser(userId);
    // print('got response: ${response.data}');
    if (response.statusCode == 200) {
      // print('response 200');
      print('aaa');
      print(response.data);
      User user = User.fromJson(response.data[0]); // <-- Utilise directement response.data
      print('bbb');
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

  toggleUserStatus({required int id, required bool isActive,context}) async {
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
      // if (displaySnackBar) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('User status updated successfully')),
      //   );
      // }
   


  }

   updateAllUser(firstName, lastName, email, username, country, state, city, address, location, zipCode,Role role,BuildContext context) async {
    // print('aaaaa');
  
    isLoading = true;
    // print('bbb ');
    notifyListeners();
    try {
      // print('ccc');
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
// print(role.id);
// print(selectedUser.role?.id);
if(role!=null){
  print('changing role');
  if(role.id!=selectedUser.role!.id){
  data['role_id'] = role.id;
}
}


// print('ddd');
      // Map<String, dynamic> data = user.toJson();
      print('starting update');
      Response result = await userNetwork.updateAllUsers(data, selectedUserId!);
      print('ending update');
      displaySnackBar = true;
      notifyListeners();
      // print('eee');
      // print(result);
      // print(result.data);
      // await getUsers(); // Refresh user list after update
      // isLoading = false;
      // notifyListeners();
      context.pop();
      // return result;
    } catch (e) {
      print('problem $e');
      isLoading = false;
      notifyListeners();
      return 'Error updating user: $e';
    }
  }

  notify(){
    notifyListeners();
  }
}


  // void register(String text, String text2, BuildContext context) {}

  // getDetailedUser(int userId) {}

  // updateAllUser(String text, String text2, String text3, String text4, String text5, String text6, String text7, String text8, String text9, int? tryParse, BuildContext context) {}
// }
