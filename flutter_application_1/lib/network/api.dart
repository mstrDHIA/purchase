import 'package:dio/dio.dart';

class APIS {
  final dio = Dio();
  String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU0OTI0MTA0LCJpYXQiOjE3NTQzMTkzMDQsImp0aSI6IjE4YTM4Y2NjYzU0ODRmYmZiZTg0OTRlNDFmZDc0OTY2IiwidXNlcl9pZCI6NjF9.Pb7BL-_D8ycgAMOfrbbjbOnobZ5oowBTB5xgeTswmB4';

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
  static const String updateUser = "user/users/";
  static const String deleteUser = "user/users/";
  static const String addProfile = "profile/add-profile/";
  static const String viewProfile = 'profile/profiles/';
  static const String addRole = "role/roles/";
  static const String deleteRole = "role/roles/";
  static const String updateRole = "role/roles/";
  static const String viewProfileByUserId = "user/users-with-details/";
  static const String updateProfile = "profile/profiles/<profileId>/";
  static const String changePassword = "change-password/";
  static const String viewProfileById = "purchase_request/purchaseRequests/";


   // adapte selon ton endpoint réel

  

  // Add more API endpoints as needed
}