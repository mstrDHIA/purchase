import 'package:dio/dio.dart';
import 'api.dart';

class DepartmentNetwork {
  final APIS api = APIS();

  Future<List<dynamic>> fetchDepartments() async {
    try {
      final response = await api.dio.get(
        APIS.baseUrl + APIS.fetchDepartments,
        options: Options(headers: {'Authorization': 'Bearer ${APIS.token}'}),
      );

      if (response.statusCode == 200) {
        if (response.data is List) return response.data as List<dynamic>;
        if (response.data is Map && response.data.containsKey('results')) return response.data['results'] as List<dynamic>;
        return [];
      } else {
        throw Exception('Failed to fetch departments: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createDepartment({required String name, String? description}) async {
    final payload = {'name': name};
    if (description != null && description.isNotEmpty) payload['description'] = description;

    final Response response = await api.dio.post(
      APIS.baseUrl + APIS.createDepartment,
      data: payload,
      options: Options(headers: {'Authorization': 'Bearer ${APIS.token}'}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) return response.data as Map<String, dynamic>;
    throw Exception('Failed to create department');
  }

  Future<Map<String, dynamic>> editDepartment({required int id, required String name, String? description}) async {
    final payload = {'name': name};
    if (description != null && description.isNotEmpty) payload['description'] = description;

    final Response response = await api.dio.put(
      '${APIS.baseUrl}${APIS.editDepartment}$id/',
      data: payload,
      options: Options(headers: {'Authorization': 'Bearer ${APIS.token}'}),
    );

    if (response.statusCode == 200) return response.data as Map<String, dynamic>;
    throw Exception('Failed to update department');
  }

  Future<void> deleteDepartment(int id) async {
    final Response response = await api.dio.delete(
      '${APIS.baseUrl}${APIS.deleteDepartment}$id/',
      options: Options(headers: {'Authorization': 'Bearer ${APIS.token}'}),
    );

    if (response.statusCode == 204 || response.statusCode == 200) return;
    throw Exception('Failed to delete department');
  }
}
