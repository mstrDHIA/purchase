import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:flutter_application_1/models/datasources/purchase_request_datasource.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/purchase_request_network.dart';
import 'package:provider/provider.dart';

class PurchaseRequestController extends ChangeNotifier {
  final PurchaseRequestNetwork _network = PurchaseRequestNetwork();
  List<PurchaseRequest> requests = [];
  bool isLoading = false;
  String? _error;
  late PurchaseRequestDataSource dataSource;
  // Pagination state
  int currentPage = 1;
  int pageSize = 10;
  int totalCount = 0;
  bool hasNext = false;
  bool hasPrevious = false;

  PurchaseRequestController(BuildContext context) {
    dataSource = PurchaseRequestDataSource([], context, 'defaultArgument');
  }

  String? get error => _error;

  Future<void> fetchRequests(BuildContext context, User user, {int page = 1, int pageSizeParam = 10}) async {
    isLoading = true;
    _error = null;
    notifyListeners();
    try {
      currentPage = page;
      pageSize = pageSizeParam;
      final Response response = await _network.fetchPurchaseRequests(user, page: page, pageSize: pageSize);
      if (response.statusCode != 200) {
        throw Exception('Failed to load purchase requests');
      }

      // Handle DRF paginated response e.g. {count: N, next: url, previous: url, results: [...]}
      var data = response.data;
      List<dynamic> items;
      if (data is Map && data.containsKey('results')) {
        items = data['results'] as List<dynamic>;
        totalCount = data['count'] ?? items.length;
        hasNext = data['next'] != null;
        hasPrevious = data['previous'] != null;
      } else if (data is List) {
        // fallback: unpaginated list
        items = data;
        totalCount = items.length;
        hasNext = false;
        hasPrevious = false;
      } else {
        throw Exception('Unexpected response format for purchase requests');
      }

      requests.clear();
      requests = items.map<PurchaseRequest>((json) => PurchaseRequest.fromJson(json)).toList();
    // Sort requests by id ascending
      requests.sort((a, b) {
        if (a.id == null && b.id == null) return 0;
        if (a.id == null) return 1;
        if (b.id == null) return -1;
        return a.id!.compareTo(b.id!);
      });

    dataSource = PurchaseRequestDataSource(requests, context, 'someArgument');
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
      if (response.data != null) {
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

  static void updatePurchase(Map<String, Object?> updatedRequest) {}

  static void updatePurchaseRequest(Map<String, Object?> updatePurchaseRequest) {}

  Future<void> archivePurchaseRequest(dynamic id) async {
    try {
      isLoading = true;
      notifyListeners();
      final idInt = id is int ? id : int.parse(id.toString());
      await _network.archivePurchaseRequest(idInt);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> unarchivePurchaseRequest(dynamic id) async {
    try {
      isLoading = true;
      notifyListeners();
      final idInt = id is int ? id : int.parse(id.toString());
      await _network.unarchivePurchaseRequest(idInt);
      // After unarchiving, refresh list if needed by caller
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    isLoading = false;
    notifyListeners();
  }

  @override
  String toString() {
    return 'PurchaseRequestController(requests: $requests, isLoading: $isLoading, error: $_error)';
  }
}