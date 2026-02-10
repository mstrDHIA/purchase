import 'package:flutter/material.dart';
import '../network/stats_network.dart';

class StatsController extends ChangeNotifier {
  final StatsNetwork _network = StatsNetwork();

  // PO totals
  Map<String, int> poTotalsByDepartment = {};
  Map<String, int> poTotalsByRequester = {};
  Map<String, int> poTotalsByCategory = {};
  Map<String, int> poTotalsBySubcategory = {};
  Map<String, int> poTotalsBySupplier = {};

  // Rejection counts (actual number of rejected items per group)
  Map<String, int> rejectedCountByDepartment = {};
  Map<String, int> rejectedCountByRequester = {};
  Map<String, int> rejectedCountByCategory = {};
  Map<String, int> rejectedCountBySubcategory = {};
  Map<String, int> rejectedCountBySupplier = {};

  // Rejection rates (percent)
  Map<String, double> rejectionRateByDepartment = {};
  Map<String, double> rejectionRateByRequester = {};

  // Summary totals (extracted directly from first API response entry)
  int summaryTotal = 0;
  int summaryRejected = 0;
  double summaryRejectionRate = 0.0;

  bool loading = false;
  String? error;

  Future<void> fetchAll({required DateTime start, required DateTime end, String? department, String? requester, String? category, String? subcategory, String? supplier, bool? excludeNullDept, String? groupBy, List<String>? groupByList}) async {
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
    summaryTotal = 0;
    summaryRejected = 0;
    summaryRejectionRate = 0.0;

    try {
      // Determine group_by: use custom if provided, otherwise auto-detect
      String finalGroupBy = 'department'; // default
      if (groupBy != null && groupBy.isNotEmpty) {
        finalGroupBy = groupBy;
      } else if (groupByList != null && groupByList.isNotEmpty) {
        finalGroupBy = groupByList.join(',');
      } else if (supplier != null && supplier.isNotEmpty) {
        finalGroupBy = 'supplier';
      } else if (subcategory != null && subcategory.isNotEmpty) {
        finalGroupBy = 'subcategory';
      } else if (category != null && category.isNotEmpty) {
        finalGroupBy = 'category';
      } else if (requester != null && requester.isNotEmpty) {
        finalGroupBy = 'requester';
      }

      // Make a single optimized API call
      final response = await _network.fetchTotals(
        groupBy: finalGroupBy,
        start: startStr,
        end: endStr,
        department: department,
        requester: requester,
        category: category,
        subcategory: subcategory,
        supplier: supplier,
        excludeNullDept: excludeNullDept,
      );

      // Parse response and populate the appropriate map(s) based on final group_by
      try {
        final dataList = response is List ? response : (response is Map ? [response] : []);
        
        // Extract summary from first entry (backend already calculated)
        if (dataList.isNotEmpty && dataList[0] is Map) {
          summaryTotal = ((dataList[0]['total'] as num?) ?? 0).toInt();
          summaryRejected = ((dataList[0]['rejected'] as num?) ?? 0).toInt();
          summaryRejectionRate = (((dataList[0]['rejection_rate'] as num?)?.toDouble()) ?? 0.0);
        }
        
        for (var e in dataList) {
          if (e is! Map) continue;
          final total = ((e['total'] as num?) ?? 0).toInt();
          final rejected = ((e['rejected'] as num?) ?? 0).toInt();
          final rejRate = (((e['rejection_rate'] as num?)?.toDouble()) ?? 0.0);
          
          // Build composite key for multi-criteria group_by
          String compositeKey = '';
          if (finalGroupBy.contains(',')) {
            // Multiple grouping criteria
            final criteria = finalGroupBy.split(',').map((s) => s.trim()).toList();
            final keyParts = <String>[];
            for (final criterion in criteria) {
              if (criterion == 'department') {
                keyParts.add(e['department']?.toString() ?? 'Unknown');
              } else if (criterion == 'requester') {
                keyParts.add(e['requester']?.toString() ?? 'Unknown');
              } else if (criterion == 'supplier') {
                keyParts.add(e['supplier']?.toString() ?? 'Unknown');
              } else if (criterion == 'category') {
                keyParts.add(e['category']?.toString() ?? e['name']?.toString() ?? 'Unknown');
              } else if (criterion == 'subcategory') {
                keyParts.add(e['subcategory']?.toString() ?? e['name']?.toString() ?? 'Unknown');
              }
            }
            compositeKey = keyParts.join(' - ');
          }
          
          if (finalGroupBy == 'department') {
            final key = (e['department'] ?? e['name'] ?? 'Unknown').toString();
            poTotalsByDepartment[key] = total;
            rejectedCountByDepartment[key] = rejected;
            rejectionRateByDepartment[key] = rejRate;
          } else if (finalGroupBy == 'requester') {
            final key = (e['requester'] ?? e['name'] ?? 'Unknown').toString();
            poTotalsByRequester[key] = total;
            rejectedCountByRequester[key] = rejected;
            rejectionRateByRequester[key] = rejRate;
          } else if (finalGroupBy == 'category') {
            final key = (e['name'] ?? 'Unknown').toString();
            poTotalsByCategory[key] = total;
            rejectedCountByCategory[key] = rejected;
          } else if (finalGroupBy == 'subcategory') {
            final key = (e['name'] ?? 'Unknown').toString();
            poTotalsBySubcategory[key] = total;
            rejectedCountBySubcategory[key] = rejected;
          } else if (finalGroupBy == 'supplier') {
            final key = (e['name'] ?? e['supplier'] ?? 'Unknown').toString();
            poTotalsBySupplier[key] = total;
            rejectedCountBySupplier[key] = rejected;
          } else if (finalGroupBy.contains(',')) {
            // Multi-criteria: store in the most relevant map
            if (finalGroupBy.contains('supplier')) {
              poTotalsBySupplier[compositeKey] = total;
              rejectedCountBySupplier[compositeKey] = rejected;
            } else if (finalGroupBy.contains('department')) {
              poTotalsByDepartment[compositeKey] = total;
              rejectedCountByDepartment[compositeKey] = rejected;
            }
          }
        }
      } catch (e) {
        print('Error parsing stats data: $e');
      }

    } catch (e) {
      error = e.toString();
      print('StatsController Error: $error');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
