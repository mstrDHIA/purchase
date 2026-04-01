
import 'package:dio/dio.dart';
import '../models/purchase_order.dart';
import 'api.dart';

class PurchaseOrderNetwork {
	final Dio dio = APIS().dio;
	// Use the standard purchase order endpoint for fetching lists
	static String get listEndpoint => APIS.baseUrl + APIS.purchaseOrderList;
	// New datatable endpoint for paginated list
	static String get datatableEndpoint => APIS.baseUrl + APIS.datatablePoList;
	// For create/update/delete we use the same CRUD endpoint
	static String get crudEndpoint => APIS.baseUrl + APIS.purchaseOrderList;

	// when the backend returns a paginated response we record the total here
	int? lastTotal;

	Future<List<PurchaseOrder>> fetchPurchaseOrders({
		String? startDate,
		String? endDate,
		String? department,
		String? requester,
		String? family,
		String? subfamily,
		String? supplier,
		bool? excludeNullDept,
		String? search,
		String? status,
	  int? page,
	  int? pageSize,
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
		// Handle status - convert comma-separated to list for proper query param formatting
		if (status != null) {
			final statusList = status.split(',').map((s) => s.trim()).toList();
			params['status'] = statusList;
			print('📌 PO STATUS FILTER: statusList=$statusList');
		}
		if (page != null) params['page'] = page;
		if (pageSize != null) params['page_size'] = pageSize;
		if (search != null) params['search'] = search;

		// choose endpoint based on pagination
		final endpoint = (page != null && pageSize != null)
			? datatableEndpoint
			: listEndpoint;
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
		print('🔥 PO RESPONSE DEBUG: Full response = ${response.data}');
	
		if (response.statusCode == 200) {
			// Support both older list responses and the new datatable response structure
			final respData = response.data;
			List<dynamic> items;
			if (respData is Map && respData.containsKey('results')) {
				items = respData['results'] as List<dynamic>;
				// record total count for controller to consume
				if (respData.containsKey('total')) {
					lastTotal = respData['total'] as int;
				} else {
					lastTotal = null;
				}
			} else if (respData is List) {
				items = respData;
				lastTotal = null;
			} else {
				items = [];
				lastTotal = null;
			}
			print('📥 PO Response items: ${items.length}');
			return items.map((json) => PurchaseOrder.fromJson(json)).toList();
		} else {
			throw Exception('Failed to load purchase orders');
		}
	}

	Future<void> createPurchaseOrder(dynamic orderOrJson) async {
		final dynamic dataToSend = orderOrJson is Map<String, dynamic>
			? orderOrJson
			: (orderOrJson.toJson != null ? orderOrJson.toJson() : orderOrJson);
		// debugging information
		print('🌐 PO Network (create): POST $crudEndpoint');
		print('📤 Payload: $dataToSend');
		final response = await dio.post(crudEndpoint,
			data: dataToSend,
			options: Options(headers: {
				'Authorization': 'Bearer ${APIS.token}',
				'Content-Type': 'application/json',
				'ngrok-skip-browser-warning': 'true',
			}),
		);
		print('📥 PO create status: ${response.statusCode}');
		print('📥 PO create response: ${response.data}');
		if (response.statusCode != 201) {
			throw Exception('Failed to create purchase order: status=${response.statusCode}, data=${response.data}');
		}
	}

	Future<void> updatePurchaseOrder(Map<String, dynamic> orderJson) async {
		final url = '$crudEndpoint${orderJson['id']}/';
		print('🌐 PO Network (update): PUT $url');
		print('📤 Payload: $orderJson');
		final response = await dio.put(url,
			data: orderJson,
			options: Options(headers: {
				'Authorization': 'Bearer ${APIS.token}',
				'Content-Type': 'application/json',
				'ngrok-skip-browser-warning': 'true',
			}),
		);
		print('📥 PO update status: ${response.statusCode}');
		print('📥 PO update response: ${response.data}');
		if (response.statusCode != 200) {
			throw Exception('Failed to update purchase order: status=${response.statusCode}, data=${response.data}');
		}
	}

	Future<void> deletePurchaseOrder(String id) async {
		final response = await dio.delete('$crudEndpoint$id/',
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
		final response = await dio.patch('$crudEndpoint$id/',
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
		final response = await dio.patch('$crudEndpoint$id/',
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

	/// Créer plusieurs PO à partir d'une PR (une par une)
	Future<List<PurchaseOrder>> createMultiplePOs(int prId, List<Map<String, dynamic>> poList) async {
		final createdPOs = <PurchaseOrder>[];
		
		for (int i = 0; i < poList.length; i++) {
			final poData = poList[i];
			
			// Build products array from individual product data
			final products = [];
			if (poData['product'] != null) {
				products.add({
					'name': poData['product'],
					'quantity': poData['quantity'] ?? 1,
				});
			}
			
			// Map currency values: "Dollar" -> "USD", etc.
			String mappedCurrency = poData['currency'] ?? 'TND';
			if (mappedCurrency == 'Dollar') {
				mappedCurrency = 'USD';
			} else if (mappedCurrency == 'Euro') {
				mappedCurrency = 'EUR';
			} else if (mappedCurrency == 'Dinar') {
				mappedCurrency = 'TND';
			}
			
			// Préparer les données de la PO avec les champs requis
			final payload = {
				'title': poData['title'] ?? 'Purchase Order ${i + 1}',
				'description': poData['description'] ?? '',
				'products': products,
				'purchase_request': prId,
				'requested_by_user': poData['requested_by_user'],
				'priority': poData['priority'] ?? 'medium',
				'currency': mappedCurrency,
				'statuss': poData['statuss'] ?? 'pending',
			};
			
			print('🌐 PO Network (create #${i+1}): POST $crudEndpoint');
			print('📤 Payload: $payload');
			
			final response = await dio.post(
				crudEndpoint,
				data: payload,
				options: Options(headers: {
					'Authorization': 'Bearer ${APIS.token}',
					'Content-Type': 'application/json',
					'ngrok-skip-browser-warning': 'true',
				}),
			);
			
			print('📥 PO create #${i+1} status: ${response.statusCode}');
			print('📥 PO create #${i+1} response: ${response.data}');
			
			if (response.statusCode == 201) {
				final po = PurchaseOrder.fromJson(response.data as Map<String, dynamic>);
				createdPOs.add(po);
			} else {
				throw Exception('Failed to create purchase order #${i+1}: status=${response.statusCode}, data=${response.data}');
			}
		}
		
		return createdPOs;
	}

	/// Récupérer les PO liées à une PR
	Future<List<PurchaseOrder>> getPOsByPR(int prId) async {
		final endpoint = listEndpoint;
		final params = {'purchase_request_id': prId};
		
		print('🌐 PO Network (get by PR): GET $endpoint');
		print('📤 Query params: $params');
		
		final response = await dio.get(
			endpoint,
			queryParameters: params,
			options: Options(headers: {
				'Authorization': 'Bearer ${APIS.token}',
				'ngrok-skip-browser-warning': 'true',
			}),
		);
		
		print('📥 PO get by PR status: ${response.statusCode}');
		print('📥 PO get by PR response: ${response.data}');
		
		if (response.statusCode == 200) {
			final respData = response.data;
			List<dynamic> items;
			
			if (respData is Map && respData.containsKey('results')) {
				items = respData['results'] as List<dynamic>;
			} else if (respData is List) {
				items = respData;
			} else {
				items = [];
			}
			
			return items.map((json) => PurchaseOrder.fromJson(json as Map<String, dynamic>)).toList();
		} else {
			throw Exception('Failed to load purchase orders: status=${response.statusCode}');
		}
	}
}

