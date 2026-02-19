// File: lib/controllers/stats_controller.dart
import 'package:flutter/material.dart';
import '../network/stats_network.dart';

class StatsController extends ChangeNotifier {

    // Total price dinar
    double? totalPriceDinar;
    bool loadingTotalPriceDinar = false;
    String? errorTotalPriceDinar;

    Future<void> fetchTotalPriceDinar({
      required String token,
      required String startDate,
      required String endDate,
      String? department,
      String? requester,
      String? supplier,
      String? family,
      String? subfamily,
      bool? excludeNullDept,
    }) async {
      loadingTotalPriceDinar = true;
      errorTotalPriceDinar = null;
      notifyListeners();
      try {
        totalPriceDinar = await _network.fetchTotalPriceDinar(
          token: token,
          startDate: startDate,
          endDate: endDate,
          department: department,
          requester: requester,
          supplier: supplier,
          family: family,
          subfamily: subfamily,
          excludeNullDept: excludeNullDept,
        );
      } catch (e) {
        errorTotalPriceDinar = e.toString();
        totalPriceDinar = null;
      }
      loadingTotalPriceDinar = false;
      notifyListeners();
    }
  final StatsNetwork _network = StatsNetwork();

  // PO totals
  Map<String, int> poTotalsByDepartment = {};
  Map<String, int> poTotalsByRequester = {};
  Map<String, int> poTotalsByCategory = {};
  Map<String, int> poTotalsBySubcategory = {};
  Map<String, int> poTotalsBySupplier = {};
  Map<String, int> poTotalsByFamily = {};
  Map<String, int> poTotalsBySubfamily = {};

  // Rejection counts (actual number of rejected items per group)
  Map<String, int> rejectedCountByDepartment = {};
  Map<String, int> rejectedCountByRequester = {};
  Map<String, int> rejectedCountByCategory = {};
  Map<String, int> rejectedCountBySubcategory = {};
  Map<String, int> rejectedCountBySupplier = {};
  Map<String, int> rejectedCountByFamily = {};
  Map<String, int> rejectedCountBySubfamily = {};

  // Rejection rates (percent)
  Map<String, double> rejectionRateByDepartment = {};
  Map<String, double> rejectionRateByRequester = {};
  Map<String, double> rejectionRateByFamily = {};
  Map<String, double> rejectionRateBySubfamily = {};

  // Summary totals
  int summaryTotal = 0;
  int summaryRejected = 0;
  double summaryRejectionRate = 0.0;

  bool loading = false;
  String? error;

  Future<void> fetchAll({
    required DateTime start,
    required DateTime end,
    String? department,
    String? requester,
    String? category,
    String? subcategory,
    String? supplier,
    String? family,
    String? subfamily,
    bool? excludeNullDept,
    String? groupBy,
    List<String>? groupByList,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    final startStr = DateTime(start.year, start.month, start.day).toIso8601String().split('T').first;
    final endStr = DateTime(end.year, end.month, end.day).toIso8601String().split('T').first;

    // Clear all maps
    poTotalsByDepartment = {};
    rejectedCountByDepartment = {};
    rejectionRateByDepartment = {};
    poTotalsByRequester = {};
    rejectedCountByRequester = {};
    rejectionRateByRequester = {};
    poTotalsByCategory = {};
    rejectedCountByCategory = {};
    poTotalsBySubcategory = {};
    rejectedCountBySubcategory = {};
    poTotalsBySupplier = {};
    rejectedCountBySupplier = {};
    poTotalsByFamily = {};
    rejectedCountByFamily = {};
    rejectionRateByFamily = {};
    poTotalsBySubfamily = {};
    rejectedCountBySubfamily = {};
    rejectionRateBySubfamily = {};
    summaryTotal = 0;
    summaryRejected = 0;
    summaryRejectionRate = 0.0;

    try {
      // Determine group_by: use custom if provided, otherwise default to summary
      String finalGroupBy = 'summary';
      if (groupBy != null && groupBy.isNotEmpty) {
        finalGroupBy = groupBy;
      } else if (groupByList != null && groupByList.isNotEmpty) {
        finalGroupBy = groupByList.join(',');
      }
      final primaryGroup = finalGroupBy.split(',').first.trim();

      final response = await _network.fetchTotals(
        groupBy: finalGroupBy,
        start: startStr,
        end: endStr,
        department: department,
        requester: requester,
        category: category,
        subcategory: subcategory,
        supplier: supplier,
        family: family,
        subfamily: subfamily,
        excludeNullDept: excludeNullDept,
      );

      final dataList = response is List ? response : (response is Map ? [response] : []);
      debugPrint('📊 StatsController: Parsed response length=${dataList.length}, primaryGroup=$primaryGroup');

      if (dataList.isEmpty) {
        summaryTotal = 0;
        summaryRejected = 0;
        summaryRejectionRate = 0.0;
      } else {
        summaryTotal = ((dataList[0]['total'] as num?) ?? 0).toInt();
        summaryRejected = ((dataList[0]['rejected'] as num?) ?? 0).toInt();
        summaryRejectionRate = (((dataList[0]['rejection_rate'] as num?)?.toDouble()) ?? 0.0);
      }

      for (var e in dataList) {
        if (e is! Map) continue;
        final total = ((e['total'] as num?) ?? 0).toInt();
        final rejected = ((e['rejected'] as num?) ?? 0).toInt();
        final rejRate = (((e['rejection_rate'] as num?)?.toDouble()) ?? 0.0);

        // Safe key extraction
        String extractKey(Map m) {
          final candidates = <String>[
            primaryGroup,
            '${primaryGroup}_id',
            '${primaryGroup}_name',
            'name',
            'department',
            'requester',
            'supplier',
            'family',
            'subfamily',
          ];
          for (var k in candidates) {
            final v = m[k];
            if (v != null) return v.toString();
          }
          return 'Unknown';
        }

        final key = extractKey(e);

        switch (primaryGroup) {
          case 'department':
            poTotalsByDepartment[key] = total;
            rejectedCountByDepartment[key] = rejected;
            rejectionRateByDepartment[key] = rejRate;
            break;
          case 'requester':
            poTotalsByRequester[key] = total;
            rejectedCountByRequester[key] = rejected;
            rejectionRateByRequester[key] = rejRate;
            break;
          case 'category':
            poTotalsByCategory[key] = total;
            rejectedCountByCategory[key] = rejected;
            break;
          case 'subcategory':
            poTotalsBySubcategory[key] = total;
            rejectedCountBySubcategory[key] = rejected;
            break;
          case 'family':
            poTotalsByFamily[key] = total;
            rejectedCountByFamily[key] = rejected;
            rejectionRateByFamily[key] = rejRate;
            break;
          case 'subfamily':
            poTotalsBySubfamily[key] = total;
            rejectedCountBySubfamily[key] = rejected;
            rejectionRateBySubfamily[key] = rejRate;
            break;
          case 'supplier':
            poTotalsBySupplier[key] = total;
            rejectedCountBySupplier[key] = rejected;
            break;
          default:
            // summary or unknown -> already handled above
            break;
        }
      }
    } catch (e) {
      error = e.toString();
      debugPrint('StatsController Error: $error');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}