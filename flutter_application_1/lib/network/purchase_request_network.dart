import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/network/api.dart';

class PurchaseRequestNetwork {

  APIS api = APIS();

  // Fetch all purchase requests
 fetchPurchaseRequests() async {
    Response response = await api.dio.get(
      '${APIS.baseUrl}/purchase_request/purchaseRequests/',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${APIS.token}',
          'ngrok-skip-browser-warning': 'true',
        },
      ));
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load purchase requests');
    }
  }

  // // Fetch a single purchase request by ID
  // Future<Map<String, dynamic>> fetchPurchaseRequestById(int id) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/purchase_request/purchaseRequests/$id'),
  //     headers: _headers,
  //   );
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to load purchase request');
  //   }
  // }

  // // Create a new purchase request
  // Future<Map<String, dynamic>> createPurchaseRequest(Map<String, dynamic> data) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/purchase_request/purchaseRequests/'),
  //     headers: _headers,
  //     body: jsonEncode(data),
  //   );
  //   if (response.statusCode == 201) {
  //     return jsonDecode(response.body);
  //   } else {
  //     print('Status: ${response.statusCode}');
  //     print('Body: ${response.body}');
  //     throw Exception('Failed to create purchase request');
  //   }
  // }

  // // Update a purchase request
  // Future<Map<String, dynamic>> updatePurchaseRequest(int id, Map<String, dynamic> data) async {
  //   final response = await http.put(
  //     Uri.parse('$baseUrl/purchase_request/purchaseRequests/$id'),
  //     headers: _headers,
  //     body: jsonEncode(data),
  //   );
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to update purchase request');
  //   }
  // }

  // // Delete a purchase request
  // Future<void> deletePurchaseRequest(int id) async {
  //   final response = await http.delete(
  //     Uri.parse('$baseUrl/purchase_request/purchaseRequests/$id'),
  //     headers: _headers,
  //   );
  //   if (response.statusCode != 204) {
  //     throw Exception('Failed to delete purchase request');
  //   }
  // }
}