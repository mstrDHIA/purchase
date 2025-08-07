import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/change_password.dart';
import 'package:flutter_application_1/network/change_password.dart';
import 'package:flutter_application_1/network/user_network.dart';

class ChangePasswordController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<bool> changePassword(ChangePasswordRequest request, dynamic api) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
    try {
      final result = await ChangePasswordNetwork(api: api).updatePassword(request, api);
      if (result) {
        successMessage = 'Password updated successfully';
      } else {
        errorMessage = 'Failed to update password';
      }
      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      errorMessage = 'Error: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
