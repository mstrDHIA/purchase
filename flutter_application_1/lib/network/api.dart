import 'package:dio/dio.dart';

class APIS {
  final dio = Dio();
  static String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU2NzIxMjc3LCJpYXQiOjE3NTYxMTY0NzcsImp0aSI6IjZmZmQxYTc2ZTMyMzQ2MzQ4MDhiNmZkNTcwNWUxNTRjIiwidXNlcl9pZCI6MX0.TSBnhWs_Fb921qMLRnMmvCcNjy1kbRFHaXugW7e7MFM';

  // APIS() {
  //   dio.interceptors.add(LogInterceptor(
  //     request: true,
  //     requestBody: true,
  //     responseBody: true,
  //     responseHeader: false,
  //     error: true,
  //   ));
  // }

  static const String baseUrl = "http://72.60.90.60:8000/";

  static const String login = "/user/login/";

  static const String register = "user/register/";
  static const String userList = "user/users/";
  static const String updateUser = "user/users-with-details/";
  static const String deleteUser = "user/users/";
  static const String addProfile = "profile/add-profile/";
  static const String viewProfile = 'profile/profiles/';
  static const String addRole = "role/roles/";
  static const String deleteRole = "role/roles/";
  static const String updateRole = "role/roles/";
  static const String viewProfileByUserId = "user/users-with-details/";
  static const String userListDetailed = "user/users-with-details-list/";
  static const String updateProfile = "profile/profiles/";
  static const String changePassword = "user/change-password/";
  static const String viewProfileById = "purchase_request/purchaseRequests/";
  static const String updateAllUsers = "user/users/update-all/";
  static const String deletePurchaseRequest = "purchase_request/purchaseRequests/";
  static const String updatePurchaseRequest = "purchase_request/purchaseRequests/";


   // adapte selon ton endpoint réel

  

  // Add more API endpoints as needed
}