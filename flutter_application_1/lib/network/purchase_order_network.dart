
import 'package:dio/dio.dart';
import '../models/purchase_order.dart';
import 'api.dart';

class PurchaseOrderNetwork {
	final Dio dio = APIS().dio;
	static String get endpoint => APIS.baseUrl + APIS.purchaseOrderList;

		Future<List<PurchaseOrder>> fetchPurchaseOrders() async {
			final response = await dio.get(endpoint,
				options: Options(headers: {
					'Authorization': 'Bearer ${APIS.token}',
					'ngrok-skip-browser-warning': 'true',
				}),
			);
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
}
