import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:flutter_application_1/models/purchase_request_datasource.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/purchase_request_network.dart';
import 'package:provider/provider.dart';

class PurchaseRequestController extends ChangeNotifier {
  final PurchaseRequestNetwork _network = PurchaseRequestNetwork();
  List<PurchaseRequest> requests = [];
  bool isLoading = false;
  String? _error;
  late PurchaseRequestDataSource dataSource;

  PurchaseRequestController(BuildContext context) {
    dataSource = PurchaseRequestDataSource([], context, 'defaultArgument');
  }

  // List<PurchaseRequest> get requests => _requests;
  String? get error => _error;

  fetchRequests(BuildContext context,User user) async {
    isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final Response response = await _network.fetchPurchaseRequests(user);
      if (response.statusCode != 200) {
        throw Exception('Failed to load purchase requests');
      }
      print('Raw API Response: ${response.data}'); // Log raw API response

    requests.clear();
    requests = response.data
      .map<PurchaseRequest>((json) => PurchaseRequest.fromJson(json))
      .toList();
    // Sort requests by id ascending
      requests.sort((a, b) {
        if (a.id == null && b.id == null) return 0;
        if (a.id == null) return 1;
        if (b.id == null) return -1;
        return a.id!.compareTo(b.id!);
      });
    print('Mapped & Sorted Requests: $requests'); // Log mapped requests

    dataSource = PurchaseRequestDataSource(requests, context, 'someArgument');
    print('DataSource updated with requests: ${requests.length} items'); // Log dataSource update
    } catch (e) {
      _error = e.toString();
      isLoading = false;
      notifyListeners();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addRequest(Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _network.createPurchaseRequest(data);
      if (response != null && response.data != null) {
        PurchaseRequest request = PurchaseRequest.fromJson(response.data);
        requests.add(request);
      } else {
        print('No response or response.data is null');
      }
    } catch (e) {
      print('error: $e');
      _error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateRequest(int id, Map<String, dynamic> data, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      final result = await _network.updatePurchaseRequest(id, data, method: '');
      PurchaseRequest updatedRequest = PurchaseRequest.fromJson(result);
      // int index = requests.indexWhere((r) => r.id == id);
      // if (index != -1) {
      //   requests[index] = updatedRequest;
      //   dataSource = PurchaseRequestDataSource(requests, context, 'someArgument');
      // }
    } catch (e) {
      print('error: $e');
      _error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteRequest(int id, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      await _network.deletePurchaseRequest(id);
      await fetchRequests(context,Provider.of<UserController>(context, listen: false).currentUser); // Rafraîchit la liste après suppression
    } catch (e) {
      print('error: $e');
      _error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  static updatePurchase(Map<String, Object?> updatedRequest) {}

  static updatePurchaseRequest(Map<String, Object?> updatePurchaseRequest) {}

  @override
  String toString() {
    // Customize this to print useful info about your controller
    return 'PurchaseRequestController(requests: $requests, isLoading: $isLoading, error: $_error)';
  }
}