import 'package:dio/dio.dart';
import 'package:flutter_application_1/network/api.dart';
import 'package:flutter_application_1/models/change_password.dart';

class ChangePasswordNetwork {
  final Dio _dio;

  ChangePasswordNetwork({Dio? dio, required dynamic api}) : _dio = dio ?? api.dio;

  Future<bool> updatePassword(ChangePasswordRequest request, dynamic api) async {
    try {
      final response = await _dio.post(
        '${APIS.baseUrl}user/change-password/', // adapte l'URL à ton endpoint
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${api.token}',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors du changement de mot de passe: $e');
      return false;
    }
  }
}