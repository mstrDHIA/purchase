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

  bool loading = false;
  String? error;

  Future<void> fetchAll({required DateTime start, required DateTime end, String? department, String? requester, String? category, String? subcategory, String? supplier, bool? excludeNullDept}) async {
    loading = true;
    error = null;
    notifyListeners();

    final startStr = DateTime(start.year, start.month, start.day).toIso8601String().split('T').first;
    final endStr = DateTime(end.year, end.month, end.day).toIso8601String().split('T').first;

    try {
      // Totals by department (always fetch for display, respects department filter)
      final dept = await _network.fetchTotals(groupBy: 'department', start: startStr, end: endStr, department: department, requester: requester, excludeNullDept: excludeNullDept);
      poTotalsByDepartment = {};
      rejectedCountByDepartment = {};
      rejectionRateByDepartment = {};
      
      try {
        // Handle both single object (when dept_filter applied) and list responses
        final deptList = dept is List ? dept : (dept is Map ? [dept] : []);
        for (var e in deptList) {
          if (e is! Map) continue;
          final key = (e['department'] ?? e['name'] ?? 'Unknown').toString();
          poTotalsByDepartment[key] = ((e['total'] as num?) ?? 0).toInt();
          rejectedCountByDepartment[key] = ((e['rejected'] as num?) ?? 0).toInt();
          rejectionRateByDepartment[key] = (((e['rejection_rate'] as num?)?.toDouble()) ?? 0.0);
        }
      } catch (e) {
        print('Error parsing department data: $e');
      }

      // Totals by requester (respects requester filter)
      final req = await _network.fetchTotals(groupBy: 'requester', start: startStr, end: endStr, department: department, requester: requester, excludeNullDept: excludeNullDept);
      poTotalsByRequester = {};
      rejectedCountByRequester = {};
      rejectionRateByRequester = {};
      
      try {
        final reqList = req is List ? req : (req is Map ? [req] : []);
        for (var e in reqList) {
          if (e is! Map) continue;
          final key = (e['requester'] ?? e['name'] ?? 'Unknown').toString();
          poTotalsByRequester[key] = ((e['total'] as num?) ?? 0).toInt();
          rejectedCountByRequester[key] = ((e['rejected'] as num?) ?? 0).toInt();
          rejectionRateByRequester[key] = (((e['rejection_rate'] as num?)?.toDouble()) ?? 0.0);
        }
      } catch (e) {
        print('Error parsing requester data: $e');
      }

      // Totals by category (respects category filter + other filters)
      final cat = await _network.fetchTotals(groupBy: 'category', start: startStr, end: endStr, department: department, requester: requester, category: category, excludeNullDept: excludeNullDept);
      poTotalsByCategory = {};
      rejectedCountByCategory = {};
      
      try {
        final catList = cat is List ? cat : (cat is Map ? [cat] : []);
        for (var e in catList) {
          if (e is! Map) continue;
          final key = (e['name'] ?? 'Unknown').toString();
          poTotalsByCategory[key] = ((e['total'] as num?) ?? 0).toInt();
          rejectedCountByCategory[key] = ((e['rejected'] as num?) ?? 0).toInt();
        }
      } catch (e) {
        print('Error parsing category data: $e');
      }

      // Totals by subcategory (respects subcategory filter + other filters)
      final sub = await _network.fetchTotals(groupBy: 'subcategory', start: startStr, end: endStr, department: department, requester: requester, subcategory: subcategory, excludeNullDept: excludeNullDept);
      poTotalsBySubcategory = {};
      rejectedCountBySubcategory = {};
      
      try {
        final subList = sub is List ? sub : (sub is Map ? [sub] : []);
        for (var e in subList) {
          if (e is! Map) continue;
          final key = (e['name'] ?? 'Unknown').toString();
          poTotalsBySubcategory[key] = ((e['total'] as num?) ?? 0).toInt();
          rejectedCountBySubcategory[key] = ((e['rejected'] as num?) ?? 0).toInt();
        }
      } catch (e) {
        print('Error parsing subcategory data: $e');
      }

      // Totals by supplier (respects supplier filter + other filters)
      final sup = await _network.fetchTotals(groupBy: 'supplier', start: startStr, end: endStr, department: department, requester: requester, supplier: supplier, excludeNullDept: excludeNullDept);
      poTotalsBySupplier = {};
      rejectedCountBySupplier = {};
      
      try {
        final supList = sup is List ? sup : (sup is Map ? [sup] : []);
        for (var e in supList) {
          if (e is! Map) continue;
          final key = (e['name'] ?? e['supplier'] ?? 'Unknown').toString();
          poTotalsBySupplier[key] = ((e['total'] as num?) ?? 0).toInt();
          rejectedCountBySupplier[key] = ((e['rejected'] as num?) ?? 0).toInt();
        }
      } catch (e) {
        print('Error parsing supplier data: $e');
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
