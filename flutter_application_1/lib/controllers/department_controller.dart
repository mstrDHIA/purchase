import 'package:flutter/material.dart';
import '../network/department_network.dart';
import '../models/department.dart';

class DepartmentController extends ChangeNotifier {
  final DepartmentNetwork _network = DepartmentNetwork();

  List<Department> departments = [];
  bool isLoading = false;
  String? errorMessage;

  Future<List<Department>> fetchDepartments() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _network.fetchDepartments();
      departments = List<Department>.from(
        data.map((item) => Department.fromJson(item as Map<String, dynamic>)),
      );

      isLoading = false;
      notifyListeners();
      return departments;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to fetch departments: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<Department> createDepartment({required String name, String? description}) async {
    try {
      final resp = await _network.createDepartment(name: name, description: description);
      final dept = Department.fromJson(resp);
      departments.insert(0, dept);
      notifyListeners();
      return dept;
    } catch (e) {
      errorMessage = 'Failed to create department: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<Department> updateDepartment({required int id, required String name, String? description}) async {
    try {
      final resp = await _network.editDepartment(id: id, name: name, description: description);
      final dept = Department.fromJson(resp);
      final idx = departments.indexWhere((d) => d.id == id);
      if (idx != -1) departments[idx] = dept;
      notifyListeners();
      return dept;
    } catch (e) {
      errorMessage = 'Failed to update department: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteDepartment(int id) async {
    try {
      await _network.deleteDepartment(id);
      departments.removeWhere((d) => d.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete department: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
