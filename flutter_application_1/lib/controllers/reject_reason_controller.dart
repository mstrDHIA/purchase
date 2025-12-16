import 'package:flutter/material.dart';
import '../network/reject_reason_network.dart';
import '../models/reject_reason.dart';

class RejectReasonController extends ChangeNotifier {
  final RejectReasonNetwork _network = RejectReasonNetwork();

  List<RejectReason> reasons = [];
  bool isLoading = false;
  String? errorMessage;

  Future<List<RejectReason>> fetchReasons() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _network.fetchRejectReasons();
      reasons = List<RejectReason>.from(
        data.map((item) => RejectReason.fromJson(item as Map<String, dynamic>)),
      );

      isLoading = false;
      notifyListeners();
      return reasons;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to fetch reject reasons: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<RejectReason> createReason({required String reason, String? description}) async {
    try {
      final resp = await _network.createRejectReason(reason: reason, description: description);
      final rr = RejectReason.fromJson(resp);
      reasons.add(rr);
      notifyListeners();
      return rr;
    } catch (e) {
      errorMessage = 'Failed to create reject reason: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<RejectReason> updateReason({required int id, required String reason, String? description}) async {
    try {
      final resp = await _network.editRejectReason(id: id, reason: reason, description: description);
      final rr = RejectReason.fromJson(resp);
      final idx = reasons.indexWhere((r) => r.id == id);
      if (idx != -1) reasons[idx] = rr;
      notifyListeners();
      return rr;
    } catch (e) {
      errorMessage = 'Failed to update reject reason: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteReason(int id) async {
    try {
      await _network.deleteRejectReason(id);
      reasons.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete reject reason: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
