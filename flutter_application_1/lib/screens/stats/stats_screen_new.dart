import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
// supplier_controller is no longer required here because stats are loaded from the API
import '../../controllers/department_controller.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/stats_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/supplier_controller.dart';
import '../../utils/file_download.dart';
import '../../widgets/standard_header.dart';
import '../../l10n/app_localizations.dart';

class StatsScreenNew extends StatefulWidget {
  const StatsScreenNew({super.key});

  @override
  State<StatsScreenNew> createState() => _StatsScreenNewState();
}

class _StatsScreenNewState extends State<StatsScreenNew> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _endDate = DateTime.now();

  // Statistics data structures (summary after applying filters)
  int _totalPO = 0;
  int _totalRejected = 0;
  double _rejectionRate = 0.0;

  bool _loading = true;
  // Filter UI state
  List<Map<String, dynamic>> _departmentList = [];
  List<Map<String, dynamic>> _userList = [];
  // Categories: families -> list of subcategories (use ids and names)
  Map<String, List<Map<String, dynamic>>> _categoryFamilies = {};
  List<Map<String, dynamic>> _familyList = [];
  List<Map<String, dynamic>> _supplierList = [];
  String? _selectedDepartment; // can be id (as string) or name
  String? _selectedRequester; // id or username
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedSupplier;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final statsCtrl = Provider.of<StatsController>(context, listen: false);
      final dc = Provider.of<DepartmentController>(context, listen: false);
      final uc = Provider.of<UserController>(context, listen: false);

      // Ensure we have departments and users for filter dropdowns
      try {
        await Future.wait<dynamic>([dc.fetchDepartments(), uc.getUsers()]);
      } catch (_) {
        // ignore; lists may still be empty
      }

      // build simple lists for dropdowns
      _departmentList = dc.departments
          .map((d) => {'id': d.id?.toString() ?? '', 'name': d.name})
          .toList();
      // Show only users with role id == 2 in the requester dropdown
      final filteredUsers = uc.users
          .where((u) => (u.role_id == 2) || (u.role != null && u.role!.id == 2))
          .toList();
      _userList = filteredUsers
          .map((u) => {
                'id': u.id?.toString() ?? '',
                'name': u.username ?? u.name ?? 'Unknown'
              })
          .toList();

      // Fetch categories (families + subcategories)
      try {
        final pc = Provider.of<ProductController>(context, listen: false);
        final categories = await pc.getCategoriesWithoutQuery();
        if (categories is List) {
          final allCats = categories.cast<Map<String, dynamic>>();
          final parents =
              allCats.where((c) => c['parent_category'] == null).toList();
          final families = <String, List<Map<String, dynamic>>>{};
          final familyListTmp = <Map<String, dynamic>>[];
          for (final p in parents) {
            final familyId = p['id']?.toString() ?? '';
            final familyName = p['name']?.toString() ?? 'Unknown';
            familyListTmp.add({'id': familyId, 'name': familyName});
            final subs = allCats
                .where((c) => c['parent_category'] == p['id'])
                .map((c) => {
                      'id': c['id']?.toString() ?? '',
                      'name': c['name']?.toString() ?? ''
                    })
                .where((m) => (m['name'] as String).isNotEmpty)
                .toList();
            families[familyId] = subs.isNotEmpty
                ? subs
                : [
                    {'id': familyId, 'name': familyName}
                  ];
          }
          _categoryFamilies = families;
          _familyList = familyListTmp;
        }
      } catch (e) {
        // ignore category load errors; dropdowns remain empty
      }

      // Fetch suppliers for supplier dropdown
      try {
        final sc = Provider.of<SupplierController>(context, listen: false);
        final suppliers = await sc.fetchSuppliers();
        _supplierList = suppliers.map((s) {
          if (s is Map) return Map<String, dynamic>.from(s as Map);
          // Supplier model -> convert
          try {
            return {
              'id': s.id?.toString() ?? '',
              'name': s.name ?? s.toString()
            };
          } catch (_) {
            return {'id': '', 'name': s.toString()};
          }
        }).toList();
      } catch (e) {
        // ignore supplier errors
      }

      await statsCtrl.fetchAll(
          start: _startDate, end: _endDate);
      setState(() {
        _loading = statsCtrl.loading;
      });
    });
  }

  // local loader removed; statistics are now fetched via StatsController API integration.

  // Local computation removed. Stats are fetched from the server via StatsController.

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) _endDate = _startDate;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        if (_endDate.isBefore(_startDate)) _startDate = _endDate;
      });
    }
  }

  Future<void> _exportCsv() async {
    try {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc?.generatingCSV ?? 'Generating CSV...')),
      );

      final buffer = StringBuffer();
      buffer.writeln('Statistics Summary');
      buffer.writeln('Total PO,Total Rejected,Rejection Rate (%)');
      buffer.writeln(
          '$_totalPO,$_totalRejected,${(_rejectionRate * 100).toStringAsFixed(2)}');

      final bytes = utf8.encode(buffer.toString());
      final fname =
          'stats_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final path = await saveFile(bytes, fname);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc?.exportedTo ?? "Exported to"} $path')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: const StandardHeader(title: 'Statistics'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<StatsController>(
              builder: (context, statsCtrl, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Show error message if any
                      if (statsCtrl.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            'Error: ${statsCtrl.error}',
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                      // Filters Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc?.filters ?? 'Filters',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              // Dates row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(loc?.startDate ?? 'Start Date'),
                                        const SizedBox(height: 4),
                                        InkWell(
                                          onTap: _selectStartDate,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              DateFormat('yyyy-MM-dd')
                                                  .format(_startDate),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(loc?.endDate ?? 'End Date'),
                                        const SizedBox(height: 4),
                                        InkWell(
                                          onTap: _selectEndDate,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              DateFormat('yyyy-MM-dd')
                                                  .format(_endDate),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Department & Requester filters
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedDepartment ?? '',
                                      decoration: InputDecoration(
                                          labelText:
                                              loc?.department ?? 'Department'),
                                      items: [
                                        const DropdownMenuItem<String>(
                                            value: '', child: Text('All')),
                                        ..._departmentList.map((d) =>
                                            DropdownMenuItem<String>(
                                                value:
                                                    d['id']?.toString() ?? '',
                                                child: Text(
                                                    d['name'] ?? 'Unknown'))),
                                      ],
                                      onChanged: (v) => setState(() =>
                                          _selectedDepartment =
                                              (v == '' ? null : v)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedRequester ?? '',
                                      decoration: InputDecoration(
                                          labelText:
                                              loc?.requester ?? 'Requester'),
                                      items: [
                                        const DropdownMenuItem<String>(
                                            value: '', child: Text('All')),
                                        ..._userList.map((u) =>
                                            DropdownMenuItem<String>(
                                                value:
                                                    u['id']?.toString() ?? '',
                                                child: Text(
                                                    u['name'] ?? 'Unknown'))),
                                      ],
                                      onChanged: (v) => setState(() =>
                                          _selectedRequester =
                                              (v == '' ? null : v)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Category & Subcategory & Supplier filters
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedCategory ?? '',
                                      decoration: InputDecoration(
                                          labelText:
                                              loc?.category ?? 'Category'),
                                      items: [
                                        const DropdownMenuItem<String>(
                                            value: '', child: Text('All')),
                                        ..._familyList.map((c) =>
                                            DropdownMenuItem<String>(
                                                value:
                                                    c['id']?.toString() ?? '',
                                                child: Text(
                                                    c['name']?.toString() ??
                                                        'Unknown'))),
                                      ],
                                      onChanged: (v) => setState(() {
                                        _selectedCategory =
                                            (v == '' ? null : v);
                                        // reset subcategory when family changes
                                        _selectedSubcategory = null;
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedSubcategory ?? '',
                                      decoration: InputDecoration(
                                          labelText: loc?.subcategory ??
                                              'Subcategory'),
                                      items: [
                                        const DropdownMenuItem<String>(
                                            value: '', child: Text('All')),
                                        ...((_selectedCategory != null &&
                                                    _categoryFamilies
                                                        .containsKey(
                                                            _selectedCategory))
                                                ? _categoryFamilies[
                                                    _selectedCategory]!
                                                : [])
                                            .map((s) =>
                                                DropdownMenuItem<String>(
                                                    value:
                                                        s['id']?.toString() ??
                                                            '',
                                                    child: Text(
                                                        s['name']?.toString() ??
                                                            ''))),
                                      ],
                                      onChanged: (v) => setState(() =>
                                          _selectedSubcategory =
                                              (v == '' ? null : v)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _selectedSupplier ?? '',
                                decoration: InputDecoration(
                                    labelText: loc?.supplier ?? 'Supplier'),
                                items: [
                                  const DropdownMenuItem<String>(
                                      value: '', child: Text('All')),
                                  ..._supplierList.map((s) => DropdownMenuItem<
                                          String>(
                                      value: s['id']?.toString() ?? s['name'],
                                      child: Text(
                                          s['name']?.toString() ?? 'Unknown'))),
                                ],
                                onChanged: (v) => setState(() =>
                                    _selectedSupplier = (v == '' ? null : v)),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.refresh),
                                    label: Text(loc?.apply ?? 'Apply'),
                                    onPressed: () async {
                                      final statsCtrl =
                                          Provider.of<StatsController>(context,
                                              listen: false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  loc?.filtersApplied ??
                                                      'Applying filters...')));
                                      // Map selected ids to the parameter values expected by the API
                                      String? categoryParam;
                                      String? subcategoryParam;
                                      String? supplierParam;

                                      if (_selectedCategory != null &&
                                          _selectedCategory!.isNotEmpty) {
                                        Map<String, dynamic> fam;
                                        try {
                                          fam = _familyList.firstWhere((f) =>
                                              (f['id']?.toString() ?? '') ==
                                              _selectedCategory);
                                        } catch (_) {
                                          fam = <String, dynamic>{};
                                        }
                                        categoryParam = fam.isNotEmpty
                                            ? fam['name']?.toString()
                                            : _selectedCategory;
                                      }

                                      if (_selectedSubcategory != null &&
                                          _selectedSubcategory!.isNotEmpty &&
                                          _selectedCategory != null) {
                                        final subs = _categoryFamilies[
                                                _selectedCategory] ??
                                            [];
                                        Map<String, dynamic> sub;
                                        try {
                                          sub = subs.firstWhere((s) =>
                                              (s['id']?.toString() ?? '') ==
                                              _selectedSubcategory);
                                        } catch (_) {
                                          sub = <String, dynamic>{};
                                        }
                                        subcategoryParam = sub.isNotEmpty
                                            ? sub['name']?.toString()
                                            : _selectedSubcategory;
                                      }

                                      if (_selectedSupplier != null &&
                                          _selectedSupplier!.isNotEmpty) {
                                        Map<String, dynamic> sup;
                                        try {
                                          sup = _supplierList.firstWhere((s) =>
                                              (s['id']?.toString() ?? '') ==
                                                  _selectedSupplier ||
                                              (s['name']?.toString() ?? '') ==
                                                  _selectedSupplier);
                                        } catch (_) {
                                          sup = <String, dynamic>{};
                                        }
                                        // Backend filters on supplier name, not id
                                        supplierParam = sup.isNotEmpty
                                            ? sup['name']?.toString()
                                            : _selectedSupplier;
                                      }

                                      await statsCtrl.fetchAll(
                                        start: _startDate,
                                        end: _endDate,
                                        department: (_selectedDepartment !=
                                                    null &&
                                                _selectedDepartment!.isNotEmpty)
                                            ? _selectedDepartment
                                            : null,
                                        requester: (_selectedRequester !=
                                                    null &&
                                                _selectedRequester!.isNotEmpty)
                                            ? _selectedRequester
                                            : null,
                                        category: (categoryParam != null &&
                                                categoryParam.isNotEmpty)
                                            ? categoryParam
                                            : null,
                                        subcategory:
                                            (subcategoryParam != null &&
                                                    subcategoryParam.isNotEmpty)
                                                ? subcategoryParam
                                                : null,
                                        supplier: (supplierParam != null &&
                                                supplierParam.isNotEmpty)
                                            ? supplierParam
                                            : null,
                                      );
                                      setState(() {
                                        // Use summary totals extracted directly from API response (backend already calculated)
                                        _totalPO = statsCtrl.summaryTotal;
                                        _totalRejected =
                                            statsCtrl.summaryRejected;
                                        _rejectionRate =
                                            statsCtrl.summaryRejectionRate;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(loc?.filtersApplied ??
                                                'Filters applied')),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.download),
                                    label: Text(loc?.exportCSV ?? 'Export CSV'),
                                    onPressed: _exportCsv,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Summary Results
                      Text(
                        loc?.poStatistics ?? 'Summary Results',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      // Results cards
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total PO',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _totalPO.toString(),
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              color: Colors.orange.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Rejected',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _totalRejected.toString(),
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              color: Colors.red.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rejection Rate',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${(_rejectionRate * 100).toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
