import 'package:dio/dio.dart';
import 'api.dart';

class StatsNetwork {
  final Dio dio = APIS().dio;
  static String get totalsEndpoint => APIS.baseUrl + APIS.poTotals;
  static String get rejectionEndpoint => APIS.baseUrl + APIS.poRejectionRate;

  Future<dynamic> fetchTotals({required String groupBy, String? start, String? end, String? department, String? requester, bool? excludeNullDept, String? category, String? subcategory, String? supplier}) async {
    final params = <String, dynamic>{'group_by': groupBy};
    if (start != null) params['start_date'] = start;
    if (end != null) params['end_date'] = end;
    if (department != null) params['department'] = department;
    if (requester != null) params['requester'] = requester;
    if (excludeNullDept != null) params['exclude_null_dept'] = excludeNullDept ? 'true' : 'false';
    if (category != null) {
      // Some backends expect family/subfamily parameter names — include both to be compatible
      params['category'] = category;
      params['family'] = category;
    }
    if (subcategory != null) {
      params['subcategory'] = subcategory;
      params['subfamily'] = subcategory;
    }
    if (supplier != null) params['supplier'] = supplier;

    print('StatsNetwork DEBUG: Calling $totalsEndpoint with params: $params');

    final response = await dio.get(totalsEndpoint,
      queryParameters: params,
      options: Options(headers: {
        'Authorization': 'Bearer ${APIS.token}',
        'ngrok-skip-browser-warning': 'true',
      }),
    );

    print('StatsNetwork DEBUG: Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      // Response can be either a list or a single object depending on whether a specific filter was applied
      return response.data;
    }

    throw Exception('Failed to fetch stats totals: ${response.statusCode}');
  }

  Future<dynamic> fetchRejectionRates({required String groupBy, String? start, String? end, String? department, String? requester}) async {
    final params = <String, dynamic>{'group_by': groupBy};
    if (start != null) params['start_date'] = start;
    if (end != null) params['end_date'] = end;
    if (department != null) params['department'] = department;
    if (requester != null) params['requester'] = requester;

    print('StatsNetwork DEBUG: Calling $rejectionEndpoint with params: $params');

    final response = await dio.get(rejectionEndpoint,
      queryParameters: params,
      options: Options(headers: {
        'Authorization': 'Bearer ${APIS.token}',
        'ngrok-skip-browser-warning': 'true',
      }),
    );

    print('StatsNetwork DEBUG: Response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      // Response can be either a list or a single object depending on whether a specific filter was applied
      return response.data;
    }

    throw Exception('Failed to fetch rejection rates: ${response.statusCode}');
  }
}
