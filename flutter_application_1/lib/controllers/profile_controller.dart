
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/profile_network.dart';

class ProfileController extends ChangeNotifier {
  User? _profile;
  bool _isLoading = false;
  String? _error;

  User? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final profile = await ProfileNetwork().viewProfile(userId);
      _profile = profile as User?;
    } catch (e) {
      _error = 'Erreur lors de la récupération du profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(User updatedProfile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Remplace par ton appel réseau réel pour update
      final result = await ProfileNetwork().updateProfile(updatedProfile as Profile, updatedProfile.id!);
      if (result == 'User updated successfully.') {
        _profile = updatedProfile;
      } else {
        _error = result;
      }
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du profil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
