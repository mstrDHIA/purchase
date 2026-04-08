import 'package:flutter/material.dart';
import '../models/purchase_order.dart';
import '../network/purchase_order_network.dart';

class PurchaseOrderController extends ChangeNotifier {
	final PurchaseOrderNetwork _network = PurchaseOrderNetwork();
	List<PurchaseOrder> _orders = [];
	bool _isLoading = false;
	String? _error;
	int? _total;

	List<PurchaseOrder> get orders => _orders;
	bool get isLoading => _isLoading;
	String? get error => _error;
	int? get total => _total;


  notify() {
    notifyListeners();
  }

	Future<void> fetchOrders({
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
			bool silent = false, // true = don't show loading indicator
		}) async {
			print('📡 PurchaseOrderController.fetchOrders called page=$page pageSize=$pageSize status=$status');
			if (!silent) {
				_isLoading = true;
				notifyListeners();
			}
			_error = null;
			try {
				_orders = await _network.fetchPurchaseOrders(
					startDate: startDate,
					endDate: endDate,
					department: department,
					requester: requester,
					family: family,
					subfamily: subfamily,
					supplier: supplier,
					excludeNullDept: excludeNullDept,
					search: search,
					status: status,
					page: page,
					pageSize: pageSize,
				);
				// Capture the total from the network's last response (if paginated)
				_total = _network.lastTotal;
				print('➡️ fetched ${_orders.length} purchase orders, total=$_total');
				if (!silent) notifyListeners();
			} catch (e) {
				_error = e.toString();
				print('❌ fetchOrders error: $_error');
				if (!silent) notifyListeners();
			}
			if (!silent) {
				_isLoading = false;
				notifyListeners();
			} else {
				notifyListeners();
			}
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

	Future<void> approvePurchaseOrderLine(int lineId) async {
		try {
			await _network.approvePurchaseOrderLine(lineId);
			await fetchOrders(); // Refresh to get updated line status
		} catch (e) {
			_error = e.toString();
			notifyListeners();
			rethrow;
		}
	}

	Future<void> rejectPurchaseOrderLine(int lineId, {int? rejectedReason, String? rejectComment}) async {
		try {
			await _network.rejectPurchaseOrderLine(lineId, rejectedReason: rejectedReason, rejectComment: rejectComment);
			await fetchOrders(); // Refresh to get updated line status
		} catch (e) {
			_error = e.toString();
			notifyListeners();
			rethrow;
		}
	}
}
