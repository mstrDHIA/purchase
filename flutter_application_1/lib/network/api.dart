import 'package:dio/dio.dart';

class APIS {
  final dio = Dio();
  String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU1MTgyNzYzLCJpYXQiOjE3NTQ1Nzc5NjMsImp0aSI6IjNlMjk3OTA0YzZiMTRhNjJiMjZkYWNiNmEyNjU3Y2RlIiwidXNlcl9pZCI6NjV9.KRB51RlLQ-StiC4dIJr-8PDulUokqp5tsPDoHBJJGdo';

  APIS() {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));
  }

  static const String baseUrl = "https://d2e9d48e4ff7.ngrok-free.app/";

  static const String login = "user/login/";

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
  static const String updateProfile = "profile/profiles/";
  static const String changePassword = "user/change-password/";
  static const String viewProfileById = "purchase_request/purchaseRequests/";
  static const String updateAllUsers = "user/users/update-all/";


   // adapte selon ton endpoint réel

  

  // Add more API endpoints as needed
}