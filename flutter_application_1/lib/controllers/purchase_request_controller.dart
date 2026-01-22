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
      print('DEBUG: Fetching requests for user: ${user.id}, role: ${user.role?.id}, email: ${user.email}');
      final Response response = await _network.fetchPurchaseRequests(user, page: page, pageSize: pageSize);
      print('DEBUG: API Response status: ${response.statusCode}, data: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception('Failed to load purchase requests');
      }

      // Handle DRF paginated response e.g. {count: N, next: url, previous: url, results: [...]}
      var data = response.data;
      List<dynamic> items;

      print('DEBUG: Full API Response: $data');
      print('DEBUG: Response data type: ${data.runtimeType}');

      if (data is Map && data.containsKey('results')) {
        items = data['results'] as List<dynamic>;
        totalCount = data['count'] ?? items.length;
        hasNext = data['next'] != null;
        hasPrevious = data['previous'] != null;
        print('DEBUG: Paginated response detected. Count: $totalCount, Items in results: ${items.length}');
      } else if (data is List) {
        // fallback: unpaginated list
        items = data;
        totalCount = items.length;
        hasNext = false;
        hasPrevious = false;
        print('DEBUG: Unpaginated list response detected. Total items: ${items.length}');
      } else {
        throw Exception('Unexpected response format for purchase requests');
      }
      
      print('DEBUG: Items list before filtering: ${items.length} items');

      requests.clear();
      final currentUser = Provider.of<UserController>(context, listen: false).currentUser;
      print('DEBUG: Current user role ID: ${currentUser.role!.id}');
      
      // Admin (role id 1) sees all requests - no filtering
      if (currentUser.role!.id == 1) {
        print('DEBUG: Admin user detected - showing all requests. Total items: ${items.length}');
      }
      // Supervisor (role id 4) sees only approved requests (existing behavior)
      else if (currentUser.role!.id == 4) {
        print('DEBUG: Supervisor user detected - filtering to approved only');
        items = items.where((item) => item['status'] == 'approved').toList();
        print('DEBUG: After supervisor filter: ${items.length} items');
      }
      // Manager (role id 3) should see only requests where the requester is in the same department
      else if (currentUser.role!.id == 3) {
        print('DEBUG: Manager user detected - filtering by department');
        final managerDepId = currentUser.depId;
        print('DEBUG: Manager department ID: $managerDepId');
        if (managerDepId != null) {
          final usersList = Provider.of<UserController>(context, listen: false).users;
          items = items.where((item) {
            final rb = item['requested_by'];
            int? reqDep;

            // If backend returned a nested user object with department info
            if (rb is Map) {
              reqDep = rb['dep_id'] ?? rb['department_id'] ??
                  (rb['department'] is Map ? rb['department']['id'] : (rb['department'] is int ? rb['department'] : null));
              // If we still don't have department info but have an id, look up the user
              if (reqDep == null && rb['id'] != null) {
                final uid = rb['id'] is int ? rb['id'] : int.tryParse(rb['id'].toString());
                if (uid != null) {
                  final idx = usersList.indexWhere((u) => u.id == uid);
                  if (idx != -1) reqDep = usersList[idx].depId;
                }
              }
            } else {
              // rb might be an int id or string id
              final uid = rb is int ? rb : int.tryParse(rb?.toString() ?? '');
              if (uid != null) {
                final idx = usersList.indexWhere((u) => u.id == uid);
                if (idx != -1) reqDep = usersList[idx].depId;
              }
            }

            return reqDep != null && reqDep == managerDepId;
          }).toList();
          print('DEBUG: After manager department filter: ${items.length} items');
        } else {
          // If manager has no department assigned, do not filter — show all requests
          // (leave `items` unchanged)
          print('DEBUG: Manager has no department assigned - showing all items');
        }
      }
      
      print('DEBUG: Final items after role-based filtering: ${items.length} items');
      print('DEBUG: Items to convert: ${items.map((e) => {'id': e['id'], 'status': e['status']}).toList()}');
      requests = items.map<PurchaseRequest>((json) => PurchaseRequest.fromJson(json)).toList();
    // Sort requests by id ascending
      requests.sort((a, b) {
        if (a.id == null && b.id == null) return 0;
        if (a.id == null) return 1;
        if (b.id == null) return -1;
        return a.id!.compareTo(b.id!);
      });
      
      print('DEBUG: Successfully converted to PurchaseRequest objects: ${requests.length} requests');
      print('DEBUG: Final requests IDs: ${requests.map((r) => r.id).toList()}');

      dataSource = PurchaseRequestDataSource(requests, context, 'someArgument');
      print('DEBUG: DataSource updated with ${requests.length} requests');
    } catch (e) {
      _error = e.toString();
      print('DEBUG: Error in fetchRequests: $_error');
      isLoading = false;
      notifyListeners();
      rethrow;
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
      int index = requests.indexWhere((r) => r.id == id);
      if (index != -1) {
        requests[index] = updatedRequest;
        dataSource = PurchaseRequestDataSource(requests, context, 'someArgument');
      }
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