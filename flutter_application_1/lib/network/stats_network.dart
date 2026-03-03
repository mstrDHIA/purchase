// File: lib/network/stats_network.dart
import 'package:dio/dio.dart';
import 'api.dart';

class StatsNetwork {
    /// Fetches total prices grouped by currency from the backend.
    ///
    /// The endpoint now returns a JSON object containing keys such as
    /// `total_price_tnd`, `total_price_usd` and `total_price_eur` with numeric
    /// values. The method returns a map from the response keys to doubles.
    Future<Map<String, double>> fetchTotalPriceDinar({
      required String token,
      required String startDate,
      required String endDate,
      String? department,
      String? requester,
      String? supplier,
      String? family,
      String? subfamily,
      bool? excludeNullDept,
    }) async {
      try {
        final queryParams = {
          'start_date': startDate,
          'end_date': endDate,
        };
        if (department != null && department.isNotEmpty) queryParams['department'] = department;
        if (requester != null && requester.isNotEmpty) queryParams['requester'] = requester;
        if (supplier != null && supplier.isNotEmpty) queryParams['supplier'] = supplier;
        if (family != null && family.isNotEmpty) queryParams['family'] = family;
        if (subfamily != null && subfamily.isNotEmpty) queryParams['subfamily'] = subfamily;
        if (excludeNullDept != null) queryParams['exclude_null_dept'] = excludeNullDept ? 'true' : 'false';
        print('🔎 fetchTotalPriceDinar: URL=http://72.60.90.60:8000/stats/po/total-price-dinar/');
        print('🔎 fetchTotalPriceDinar: queryParams=$queryParams');
        final response = await dio.get(
          'http://72.60.90.60:8000/stats/po/total-price-dinar/',
          queryParameters: queryParams,
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          ),
        );
        print('📥 Response status: ${response.statusCode}');
        print('📥 Raw response data: ${response.data}');
        if (response.statusCode == 200) {
          if (response.data is Map) {
            // convert any numeric values to double (backend sometimes sends
            // numbers as strings so handle both cases).
            final Map<String, double> result = {};
            response.data.forEach((key, value) {
              if (value is num) {
                result[key.toString()] = value.toDouble();
              } else if (value is String) {
                // try parsing strings like "123.45" or "0" etc.
                final parsed = double.tryParse(value.replaceAll(',', ''));
                if (parsed != null) {
                  result[key.toString()] = parsed;
                }
              }
            });
            print('✅ Parsed total price map: $result');
            return result;
          } else {
            throw Exception('Format de réponse inattendu: ${response.data}');
          }
        } else {
          throw Exception('Erreur lors de la récupération du total price dinar');
        }
      } catch (e) {
        throw Exception('Erreur lors de la récupération du total price dinar: $e');
      }
    }
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
    String? status,
  }) async {
    final params = <String, dynamic>{'group_by': groupBy};
    if (start != null && start.isNotEmpty) params['start_date'] = start;
    if (end != null && end.isNotEmpty) params['end_date'] = end;
    if (department != null && department.isNotEmpty) params['department'] = department;
    if (requester != null && requester.isNotEmpty) params['requester'] = requester;
    if (excludeNullDept != null) params['exclude_null_dept'] = excludeNullDept ? 'true' : 'false';
    if (status != null && status.isNotEmpty) params['status'] = status;

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