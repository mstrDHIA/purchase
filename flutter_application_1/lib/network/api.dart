import 'package:dio/dio.dart';

class APIS {
  final dio = Dio();

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

  static var viewProfileByUserId; // adapte selon ton endpoint réel

  

  // Add more API endpoints as needed
}