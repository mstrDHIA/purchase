import 'package:flutter/material.dart';
import '../models/purchase_order.dart';
import '../network/purchase_order_network.dart';

class PurchaseOrderController extends ChangeNotifier {
  final PurchaseOrderNetwork _network = PurchaseOrderNetwork();
  List<PurchaseOrder> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<PurchaseOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  notify() {
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _network.fetchPurchaseOrders();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrdersFiltered(
      {String? department,
      String? requester,
      String? supplier,
      String? category,
      String? subcategory,
      DateTime? start,
      DateTime? end}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final startStr = start != null
          ? DateTime(start.year, start.month, start.day)
              .toIso8601String()
              .split('T')
              .first
          : null;
      final endStr = end != null
          ? DateTime(end.year, end.month, end.day)
              .toIso8601String()
              .split('T')
              .first
          : null;
      _orders = await _network.fetchPurchaseOrdersFiltered(
        department: department,
        requester: requester,
        supplier: supplier,
        category: category,
        subcategory: subcategory,
        start: startStr,
        end: endStr,
      );
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrder(dynamic orderOrJson) async {
    try {
      await _network.createPurchaseOrder(orderOrJson);
      await fetchOrders();
    } catch (e) {
      print('error in addOrder in controller: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateOrder(Map<String, dynamic> orderJson) async {
    try {
      await _network.updatePurchaseOrder(orderJson);
      await fetchOrders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await _network.deletePurchaseOrder(id);
      await fetchOrders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> archivePurchaseOrder(dynamic id) async {
    try {
      _isLoading = true;
      notifyListeners();
      final idInt = id is int ? id : int.parse(id.toString());
      await _network.archivePurchaseOrder(idInt);
      await fetchOrders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> unarchivePurchaseOrder(dynamic id) async {
    try {
      _isLoading = true;
      notifyListeners();
      final idInt = id is int ? id : int.parse(id.toString());
      await _network.unarchivePurchaseOrder(idInt);
      await fetchOrders();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }
}
