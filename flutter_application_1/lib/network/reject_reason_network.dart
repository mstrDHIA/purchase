import 'package:dio/dio.dart';
import 'api.dart';

class RejectReasonNetwork {
  final APIS api = APIS();

  Future<List<dynamic>> fetchRejectReasons() async {
    try {
      final response = await api.dio.get(
        APIS.baseUrl + APIS.fetchRejectReasons,
        options: Options(headers: {'Authorization': 'Bearer ${APIS.token}'}),
      );

      if (response.statusCode == 200) {
        if (response.data is List) return response.data as List<dynamic>;
        if (response.data is Map && response.data.containsKey('results')) return response.data['results'] as List<dynamic>;
        return [];
      } else {
        throw Exception('Failed to fetch reject reasons: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createRejectReason({required String reason, String? description}) async {
    final payload = {'reason': reason};
    if (description != null && description.isNotEmpty) payload['description'] = description;

    final Response response = await api.dio.post(
      APIS.baseUrl + APIS.createRejectReason,
      data: payload,
      options: Options(headers: {'Authorization': 'Bearer ${APIS.token}'}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) return response.data as Map<String, dynamic>;
    throw Exception('Failed to create reject reason');
  }

  Future<Map<String, dynamic>> editRejectReason({required int id, required String reason, String? description}) async {
    final payload = {'reason': reason};
    if (description != null && description.isNotEmpty) payload['description'] = description;

    final Response response = await api.dio.put(
      '${APIS.baseUrl}${APIS.editRejectReason}$id/',
      data: payload,
      options: Options(headers: {'Authorization': 'Bearer ${APIS.token}'}),
    );

    if (response.statusCode == 200) return response.data as Map<String, dynamic>;
    throw Exception('Failed to update reject reason');
  }

  Future<void> deleteRejectReason(int id) async {
    final Response response = await api.dio.delete(
      '${APIS.baseUrl}${APIS.deleteRejectReason}$id/',
      options: Options(headers: {'Authorization': 'Bearer ${APIS.token}'}),
    );

    if (response.statusCode == 204 || response.statusCode == 200) return;
    throw Exception('Failed to delete reject reason');
  }
}
