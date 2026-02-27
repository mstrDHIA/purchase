
import 'package:dio/dio.dart';
import '../models/purchase_order.dart';
import 'api.dart';

class PurchaseOrderNetwork {
	final Dio dio = APIS().dio;
	static String get endpoint => APIS.baseUrl + APIS.purchaseOrderList;

		Future<List<PurchaseOrder>> fetchPurchaseOrders({
			String? startDate,
			String? endDate,
			String? department,
			String? requester,
			String? family,
			String? subfamily,
			String? supplier,
			String? currency,
			bool? excludeNullDept,
			String? search, int? page, int? pageSize,
		}) async {
			final params = <String, dynamic>{};
			if (startDate != null) params['start_date'] = startDate;
			if (endDate != null) params['end_date'] = endDate;
			if (department != null) params['department'] = department;
			if (requester != null) params['requester'] = requester;
			if (family != null) params['family'] = family;
			if (subfamily != null) params['subfamily'] = subfamily;
			if (supplier != null) {
				print('🔴 PO SUPPLIER FILTER: Adding supplier=$supplier to params');
				params['supplier'] = supplier;
			} else {
				print('🟡 PO SUPPLIER FILTER: supplier is null, not adding to params');
			}
			if (excludeNullDept != null) params['exclude_null_dept'] = excludeNullDept ? 'true' : 'false';
			if (search != null) params['search'] = search;

			print('🌐 PO Network: Calling $endpoint');
			print('📤 Query params: $params');
			print('🔥 PO SUPPLIER DEBUG: supplier parameter in request = ${params['supplier']}');

			final response = await dio.get(endpoint,
				queryParameters: params.isEmpty ? null : params,
				options: Options(headers: {
					'Authorization': 'Bearer ${APIS.token}',
					'ngrok-skip-browser-warning': 'true',
				}),
			);
			
			print('📥 PO Response status: ${response.statusCode}');
			print('📥 PO Response items: ${(response.data as List?)?.length ?? 0}');
			print('🔥 PO RESPONSE DEBUG: Full response = ${response.data}');
			
			if (response.statusCode == 200) {
				final List<dynamic> data = response.data;
				return data.map((json) => PurchaseOrder.fromJson(json)).toList();
			} else {
				throw Exception('Failed to load purchase orders');
			}
		}

	Future<void> createPurchaseOrder(dynamic orderOrJson) async {
		final dynamic dataToSend = orderOrJson is Map<String, dynamic>
			? orderOrJson
			: (orderOrJson.toJson != null ? orderOrJson.toJson() : orderOrJson);
		final response = await dio.post(endpoint,
			data: dataToSend,
			options: Options(headers: {
				'Authorization': 'Bearer ${APIS.token}',
				'Content-Type': 'application/json',
				'ngrok-skip-browser-warning': 'true',
			}),
		);
		if (response.statusCode != 201) {
			throw Exception('Failed to create purchase order');
		}
	}

	Future<void> updatePurchaseOrder(Map<String, dynamic> orderJson) async {
		final response = await dio.put('$endpoint${orderJson['id']}/',
			data: orderJson,
			options: Options(headers: {
				'Authorization': 'Bearer ${APIS.token}',
				'Content-Type': 'application/json',
				'ngrok-skip-browser-warning': 'true',
			}),
		);
		if (response.statusCode != 200) {
			throw Exception('Failed to update purchase order: status=${response.statusCode}, data=${response.data}');
		}
	}

	Future<void> deletePurchaseOrder(String id) async {
		final response = await dio.delete('$endpoint$id/',
			options: Options(headers: {
				'Authorization': 'Bearer ${APIS.token}',
				'ngrok-skip-browser-warning': 'true',
			}),
		);
		if (response.statusCode != 204) {
			throw Exception('Failed to delete purchase order');
		}
	}

	Future<void> archivePurchaseOrder(int id) async {
		final response = await dio.patch('$endpoint$id/',
			data: {'is_archived': true},
			options: Options(headers: {
				'Authorization': 'Bearer ${APIS.token}',
				'Content-Type': 'application/json',
				'ngrok-skip-browser-warning': 'true',
			}),
		);
		if (response.statusCode != 200) {
			throw Exception('Failed to archive purchase order: status=${response.statusCode}');
		}
	}

	Future<void> unarchivePurchaseOrder(int id) async {
		final response = await dio.patch('$endpoint$id/',
			data: {'is_archived': false},
			options: Options(headers: {
				'Authorization': 'Bearer ${APIS.token}',
				'Content-Type': 'application/json',
				'ngrok-skip-browser-warning': 'true',
			}),
		);
		if (response.statusCode != 200) {
			throw Exception('Failed to unarchive purchase order: status=${response.statusCode}');
		}
	}
}
