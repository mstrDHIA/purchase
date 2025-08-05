import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:flutter_application_1/network/purchase_request_network.dart';

class PurchaseRequestController extends ChangeNotifier {
  final PurchaseRequestNetwork _network = PurchaseRequestNetwork();
  List<PurchaseRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  List<PurchaseRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _network.fetchPurchaseRequests();
      _requests = data.map<PurchaseRequest>((json) => PurchaseRequest.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRequest(PurchaseRequest request) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _network.createPurchaseRequest(request.toJson());
      _requests.add(PurchaseRequest.fromJson(data));
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}