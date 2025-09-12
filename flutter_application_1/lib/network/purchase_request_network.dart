import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/api.dart';

class PurchaseRequestNetwork {
  APIS api = APIS();

  // Fetch all purchase requests
  Future<Response> fetchPurchaseRequests(User user) async {
    Map<String,int> queryParameters = {};
    if(user.role!.id==2){
      queryParameters['requested_by']=user.id!;
    }
    Response response = await api.dio.get(
      '${APIS.baseUrl}/purchase_request/purchaseRequests/',
      queryParameters: queryParameters,
      options: Options(

        headers: {
          'Authorization': 'Bearer ${APIS.token}',
          'ngrok-skip-browser-warning': 'true',
        },
      ),

    );
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load purchase requests');
    }
  }

  // Create a new purchase request
  createPurchaseRequest(Map<String, dynamic> data) async {
    try {
      print(data);
      Response response = await api.dio.post(
        '${APIS.baseUrl}/purchase_request/purchaseRequests/',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      if (response.statusCode == 201) {
        return response;
      } else {
        print('Status: ${response.statusCode}');
        print('Body: ${response.data}');
        throw Exception('Failed to create purchase request');
      }
    } catch (e) {
      print('error network: $e');
    }
  }

  // Update a purchase request
  Future<Map<String, dynamic>> updatePurchaseRequest(int id, Map<String, dynamic> data, {required String method}) async {
    late Response response;
    final url = '${APIS.baseUrl}/purchase_request/purchaseRequests/$id/';
    final options = Options(
      headers: {
        'Authorization': 'Bearer ${APIS.token}',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (method == 'PATCH') {
      response = await api.dio.patch(
        url,
        data: jsonEncode(data),
        options: options,
      );
      print('PATCH update response: status=[32m${response.statusCode}[0m, data=${response.data}');
    } else {
      response = await api.dio.put(
        url,
        data: jsonEncode(data),
        options: options,
      );
      print('PUT update response: status=[32m${response.statusCode}[0m, data=${response.data}');
    }
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to update purchase request: status=${response.statusCode}, body=${response.data}');
    }
  }

  // Delete a purchase request
  Future<void> deletePurchaseRequest(int id) async {
    try {
      final url = '${APIS.baseUrl}/purchase_request/purchaseRequests/$id/';
     
      Response response = await api.dio.delete(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      
      if (response.statusCode != 204 && response.statusCode != 200 && response.statusCode != 202) {
        throw Exception('Failed to delete purchase request');
        
      }
      
    } catch (e) {
      print('Error during delete: $e');
      rethrow;
    }
  }
}