import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/role.dart';
import '../network/role_network.dart';

class RoleController extends ChangeNotifier {
  List<Role> roles = [];
  bool isLoading = false;
  String? error;

  // Pour la vue d'un rôle
  Map<String, dynamic>? viewedRole;
  bool isViewing = false;
  String? viewError;

  Future<void> fetchRoles() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final Response response = await RoleNetwork().fetchRoles();
      if(response.statusCode == 200) {
        roles = (response.data as List)
            .map((roleData) => Role.fromJson(Map<String, dynamic>.from(roleData)))
            .toList();

        isLoading = false;
        
        notifyListeners();
        // return;
      }
      else{
        error = 'Failed to load roles';
        isLoading = false;
        notifyListeners();
        // return;
      }
      
      // roles = rolesFromApi;
      isLoading = false;
      error = null;
    } catch (e) {
      error = 'Erreur lors du chargement des rôles';
      isLoading = false;
    }
    notifyListeners();
  }

  Future<bool> deleteRole(dynamic roleId) async {
    if (roleId == null || roleId is! int) {
      error = 'ID du rôle invalide';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();
    final success = await RoleNetwork().deleteRole(roleId);
    if (success) {
      await fetchRoles();
    } else {
      error = 'Failed to delete role!';
      isLoading = false;
      notifyListeners();
    }
    return success;
  }

  Future<bool> addRole(String name, String description) async {
    isLoading = true;
    notifyListeners();
    final success = await RoleNetwork().addRole(name, description);
    if (success) {
      await fetchRoles();
    } else {
      error = 'Failed to add role!';
      isLoading = false;
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateRole(int id, String oldRole, String newRole, String description, List<String> permissions) async {
    isLoading = true;
    notifyListeners();
    final success = await RoleNetwork().updateRole(id, oldRole, newRole, description, permissions);
    if (success) {
      await fetchRoles();
    } else {
      error = 'Failed to update role!';
      isLoading = false;
      notifyListeners();
    }
    return success;
  }

  Future<Map<String, dynamic>?> viewRole(int id) async {
    isViewing = true;
    viewError = null;
    viewedRole = null;
    notifyListeners();
    final data = await RoleNetwork().viewRole(id);
    isViewing = false;
    if (data == null) {
      viewError = 'Erreur lors du chargement du rôle';
    } else {
      viewedRole = data;
    }
    notifyListeners();
    return data;
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}