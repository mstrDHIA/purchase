import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:flutter_application_1/models/purchase_request_datasource.dart';
import 'package:flutter_application_1/network/purchase_request_network.dart';

class PurchaseRequestController extends ChangeNotifier {
  final PurchaseRequestNetwork _network = PurchaseRequestNetwork();
  List<PurchaseRequest> requests = [];
  bool isLoading = false;
  String? _error;
  late PurchaseRequestDataSource dataSource;

  // List<PurchaseRequest> get requests => _requests;
  String? get error => _error;

   fetchRequests(context) async {
    isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final Response response = await _network.fetchPurchaseRequests();
      if (response.statusCode != 200) {
        throw Exception('Failed to load purchase requests');
      }
      requests.clear();

      requests = response.data.map<PurchaseRequest>((json) => PurchaseRequest.fromJson(json)).toList();
      dataSource = PurchaseRequestDataSource(requests, context);
    } catch (e) {
      _error = e.toString();
      isLoading = false;
      notifyListeners();
    }
    isLoading = false;
    notifyListeners();
  }

  // Future<void> addRequest(PurchaseRequest request) async {
  //   _isLoading = true;
  //   notifyListeners();
  //   try {
  //     final data = await _network.createPurchaseRequest(request.toJson());
  //     requests.add(PurchaseRequest.fromJson(data));
  //   } catch (e) {
  //     _error = e.toString();
  //   }
  //   _isLoading = false;
  //   notifyListeners();
  // }
}