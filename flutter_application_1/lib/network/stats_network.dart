// File: lib/network/stats_network.dart
import 'package:dio/dio.dart';
import 'api.dart';

class StatsNetwork {
  final Dio dio = APIS().dio;
  static String get totalsEndpoint => APIS.baseUrl + APIS.poTotals;
  static String get rejectionEndpoint => APIS.baseUrl + APIS.poRejectionRate;

  Future<dynamic> fetchTotals({
    required String groupBy,
    String? start,
    String? end,
    String? department,
    String? requester,
    bool? excludeNullDept,
    String? category,
    String? subcategory,
    String? supplier,
    String? family,
    String? subfamily,
  }) async {
    final params = <String, dynamic>{'group_by': groupBy};
    if (start != null && start.isNotEmpty) params['start_date'] = start;
    if (end != null && end.isNotEmpty) params['end_date'] = end;
    if (department != null && department.isNotEmpty) params['department'] = department;
    if (requester != null && requester.isNotEmpty) params['requester'] = requester;
    if (excludeNullDept != null) params['exclude_null_dept'] = excludeNullDept ? 'true' : 'false';

    // Respect both keys if provided; backend supports filtering by any of these
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (family != null && family.isNotEmpty) params['family'] = family;
    if (subcategory != null && subcategory.isNotEmpty) params['subcategory'] = subcategory;
    if (subfamily != null && subfamily.isNotEmpty) params['subfamily'] = subfamily;

    if (supplier != null && supplier.isNotEmpty) {
      print('🔴 SUPPLIER FILTER: Adding supplier=$supplier to params');
      params['supplier'] = supplier;
    } else {
      print('🟡 SUPPLIER FILTER: supplier is null or empty, not adding to params');
    }

    print('🌐 StatsNetwork: Calling $totalsEndpoint');
    print('📤 Query params: $params');
    print('🔥 SUPPLIER DEBUG: supplier parameter in request = ${params['supplier']}');

    final response = await dio.get(
      totalsEndpoint,
      queryParameters: params,
      options: Options(headers: {
        'Authorization': 'Bearer ${APIS.token}',
        'ngrok-skip-browser-warning': 'true',
      }),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response data length: ${response.data.toString().length}');
    print('📥 Response data: ${response.data}');

    if (response.statusCode == 200) {
      return response.data;
    }

    throw Exception('Failed to fetch stats totals: ${response.statusCode}');
  }

  Future<dynamic> fetchRejectionRates({
    required String groupBy,
    String? start,
    String? end,
    String? department,
    String? requester,
  }) async {
    final params = <String, dynamic>{'group_by': groupBy};
    if (start != null && start.isNotEmpty) params['start_date'] = start;
    if (end != null && end.isNotEmpty) params['end_date'] = end;
    if (department != null && department.isNotEmpty) params['department'] = department;
    if (requester != null && requester.isNotEmpty) params['requester'] = requester;

    print('StatsNetwork DEBUG: Calling $rejectionEndpoint with params: $params');

    final response = await dio.get(
      rejectionEndpoint,
      queryParameters: params,
      options: Options(headers: {
        'Authorization': 'Bearer ${APIS.token}',
        'ngrok-skip-browser-warning': 'true',
      }),
    );

    print('StatsNetwork DEBUG: Response status: ${response.statusCode}');
    print('StatsNetwork DEBUG: Response data: ${response.data}');

    if (response.statusCode == 200) {
      return response.data;
    }

    throw Exception('Failed to fetch rejection rates: ${response.statusCode}');
  }
}