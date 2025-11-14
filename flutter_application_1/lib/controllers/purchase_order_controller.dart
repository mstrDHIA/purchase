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

	Future<void> addOrder(dynamic orderOrJson) async {
		try {
			await _network.createPurchaseOrder(orderOrJson);
			await fetchOrders();
		} catch (e) {
      print('error in addOrder in controller: $e');
			_error = e.toString();
			notifyListeners();
		}
	}

	Future<void> updateOrder(Map<String, dynamic> orderJson) async {
		try {
			await _network.updatePurchaseOrder(orderJson);
			await fetchOrders();
		} catch (e) {
			_error = e.toString();
			notifyListeners();
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
}
