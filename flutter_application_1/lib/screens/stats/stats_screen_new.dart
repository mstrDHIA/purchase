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

  // Statistics data structures
  Map<String, int> _poTotalsByDepartment = {};
  Map<String, int> _poTotalsByRequester = {};
  Map<String, int> _poTotalsByCategory = {};
  Map<String, int> _poTotalsBySubcategory = {};
  Map<String, int> _poTotalsBySupplier = {};

  Map<String, double> _rejectionRateByDepartment = {};
  Map<String, double> _rejectionRateByRequester = {};

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
  bool _excludeNullDept = false;

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
      _departmentList = dc.departments.map((d) => {'id': d.id?.toString() ?? '', 'name': d.name}).toList();
      _userList = uc.users.map((u) => {'id': u.id?.toString() ?? '', 'name': u.username ?? u.name ?? 'Unknown'}).toList();

      // Fetch categories (families + subcategories)
      try {
        final pc = Provider.of<ProductController>(context, listen: false);
        final categories = await pc.getCategoriesWithoutQuery();
        if (categories is List) {
          final allCats = categories.cast<Map<String, dynamic>>();
          final parents = allCats.where((c) => c['parent_category'] == null).toList();
          final families = <String, List<Map<String, dynamic>>>{};
          final familyListTmp = <Map<String, dynamic>>[];
          for (final p in parents) {
            final familyId = p['id']?.toString() ?? '';
            final familyName = p['name']?.toString() ?? 'Unknown';
            familyListTmp.add({'id': familyId, 'name': familyName});
            final subs = allCats
                .where((c) => c['parent_category'] == p['id'])
                .map((c) => {'id': c['id']?.toString() ?? '', 'name': c['name']?.toString() ?? ''})
                .where((m) => (m['name'] as String).isNotEmpty)
                .toList();
            families[familyId] = subs.isNotEmpty ? subs : [{'id': familyId, 'name': familyName}];
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
            return {'id': s.id?.toString() ?? '', 'name': s.name ?? s.toString()};
          } catch (_) {
            return {'id': '', 'name': s.toString()};
          }
        }).toList();
      } catch (e) {
        // ignore supplier errors
      }

      await statsCtrl.fetchAll(start: _startDate, end: _endDate, excludeNullDept: _excludeNullDept);
      setState(() {
        // copy values locally for backward compatibility with existing UI
        _poTotalsByDepartment = Map.from(statsCtrl.poTotalsByDepartment);
        _poTotalsByRequester = Map.from(statsCtrl.poTotalsByRequester);
        _poTotalsByCategory = Map.from(statsCtrl.poTotalsByCategory);
        _poTotalsBySubcategory = Map.from(statsCtrl.poTotalsBySubcategory);
        _poTotalsBySupplier = Map.from(statsCtrl.poTotalsBySupplier);

        _rejectionRateByDepartment = Map.from(statsCtrl.rejectionRateByDepartment);
        _rejectionRateByRequester = Map.from(statsCtrl.rejectionRateByRequester);
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

      // PO Totals by Department
      buffer.writeln('${loc?.poTotalsByDept ?? "PO Totals by Department"}');
        buffer.writeln('${loc?.department ?? "Department"},${loc?.total ?? "Total"}');
        final deptEntries = _poTotalsByDepartment.entries.toList();
        deptEntries.sort((a, b) => b.value.compareTo(a.value));
        for (final e in deptEntries) buffer.writeln('${e.key},${e.value}');
      buffer.writeln();

      // PO Totals by Requester
      buffer.writeln('${loc?.poTotalsByRequester ?? "PO Totals by Requester"}');
        buffer.writeln('${loc?.requester ?? "Requester"},${loc?.total ?? "Total"}');
        final requesterEntries = _poTotalsByRequester.entries.toList();
        requesterEntries.sort((a, b) => b.value.compareTo(a.value));
        for (final e in requesterEntries) buffer.writeln('${e.key},${e.value}');
      buffer.writeln();

      // PO Totals by Category
      buffer.writeln('${loc?.poTotalsByCategory ?? "PO Totals by Category"}');
        buffer.writeln('${loc?.category ?? "Category"},${loc?.total ?? "Total"}');
        final categoryEntries = _poTotalsByCategory.entries.toList();
        categoryEntries.sort((a, b) => b.value.compareTo(a.value));
        for (final e in categoryEntries) buffer.writeln('${e.key},${e.value}');
      buffer.writeln();

      // PO Totals by Supplier
      buffer.writeln('${loc?.poTotalsBySupplier ?? "PO Totals by Supplier"}');
        buffer.writeln('${loc?.supplier ?? "Supplier"},${loc?.total ?? "Total"}');
        final supplierEntries = _poTotalsBySupplier.entries.toList();
        supplierEntries.sort((a, b) => b.value.compareTo(a.value));
        for (final e in supplierEntries) buffer.writeln('${e.key},${e.value}');
      buffer.writeln();

      // Rejection Rates by Requester
      buffer.writeln('${loc?.rejectionRateByRequester ?? "Rejection Rate by Requester"}');
      buffer.writeln('${loc?.requester ?? "Requester"},${loc?.rejectionRate ?? "Rejection Rate (%)"}');
        final rejEntries = _rejectionRateByRequester.entries.toList();
        rejEntries.sort((a, b) => b.value.compareTo(a.value));
        for (final e in rejEntries) buffer.writeln('${e.key},${e.value.toStringAsFixed(2)}');
      buffer.writeln();

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

  Widget _buildStatTable(String title, Map<String, dynamic> data, String valueLabel) {
    final entries = data.entries.toList()
      ..sort((a, b) {
        final aVal = a.value is int ? a.value : (a.value as double).toInt();
        final bVal = b.value is int ? b.value : (b.value as double).toInt();
        return bVal.compareTo(aVal);
      });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              Text(AppLocalizations.of(context)?.noDataAvailable ?? 'No data available')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(entries[0].key.runtimeType.toString().contains('Department') ? (AppLocalizations.of(context)?.department ?? 'Department') : (AppLocalizations.of(context)?.name ?? 'Name'))),
                    DataColumn(label: Text(valueLabel)),
                  ],
                  rows: entries
                      .map((e) => DataRow(
                            cells: [
                              DataCell(Text(e.key)),
                              DataCell(Text(e.value is double
                                  ? '${(e.value as double).toStringAsFixed(2)}%'
                                  : '${e.value}')),
                            ],
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(loc?.startDate ?? 'Start Date'),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: _selectStartDate,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          DateFormat('yyyy-MM-dd').format(_startDate),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(loc?.endDate ?? 'End Date'),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: _selectEndDate,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          DateFormat('yyyy-MM-dd').format(_endDate),
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
                                  decoration: InputDecoration(labelText: loc?.department ?? 'Department'),
                                  items: [
                                    const DropdownMenuItem<String>(value: '', child: Text('All')),
                                    ..._departmentList.map((d) => DropdownMenuItem<String>(value: d['id']?.toString() ?? '', child: Text(d['name'] ?? 'Unknown'))),
                                  ],
                                  onChanged: (v) => setState(() => _selectedDepartment = (v == '' ? null : v)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedRequester ?? '',
                                  decoration: InputDecoration(labelText: loc?.requester ?? 'Requester'),
                                  items: [
                                    const DropdownMenuItem<String>(value: '', child: Text('All')),
                                    ..._userList.map((u) => DropdownMenuItem<String>(value: u['id']?.toString() ?? '', child: Text(u['name'] ?? 'Unknown'))),
                                  ],
                                  onChanged: (v) => setState(() => _selectedRequester = (v == '' ? null : v)),
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
                                  decoration: InputDecoration(labelText: loc?.category ?? 'Category'),
                                  items: [
                                    const DropdownMenuItem<String>(value: '', child: Text('All')),
                                    ..._familyList.map((c) => DropdownMenuItem<String>(value: c['id']?.toString() ?? '', child: Text(c['name']?.toString() ?? 'Unknown'))),
                                  ],
                                  onChanged: (v) => setState(() {
                                    _selectedCategory = (v == '' ? null : v);
                                    // reset subcategory when family changes
                                    _selectedSubcategory = null;
                                  }),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedSubcategory ?? '',
                                  decoration: InputDecoration(labelText: loc?.subcategory ?? 'Subcategory'),
                                  items: [
                                    const DropdownMenuItem<String>(value: '', child: Text('All')),
                                    ...((_selectedCategory != null && _categoryFamilies.containsKey(_selectedCategory)) ? _categoryFamilies[_selectedCategory]! : []).map((s) => DropdownMenuItem<String>(value: s['id']?.toString() ?? '', child: Text(s['name']?.toString() ?? ''))),
                                  ],
                                  onChanged: (v) => setState(() => _selectedSubcategory = (v == '' ? null : v)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedSupplier ?? '',
                            decoration: InputDecoration(labelText: loc?.supplier ?? 'Supplier'),
                            items: [
                              const DropdownMenuItem<String>(value: '', child: Text('All')),
                              ..._supplierList.map((s) => DropdownMenuItem<String>(value: s['id']?.toString() ?? s['name'], child: Text(s['name']?.toString() ?? 'Unknown'))),
                            ],
                            onChanged: (v) => setState(() => _selectedSupplier = (v == '' ? null : v)),
                          ),
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _excludeNullDept,
                            title: const Text('Exclude PO without department'),
                            onChanged: (v) => setState(() => _excludeNullDept = v ?? false),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: Text(loc?.apply ?? 'Apply'),
                                onPressed: () async {
                                  final statsCtrl = Provider.of<StatsController>(context, listen: false);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc?.filtersApplied ?? 'Applying filters...')));
                                  // Map selected ids to the parameter values expected by the API
                                  String? categoryParam;
                                  String? subcategoryParam;
                                  String? supplierParam;

                                  if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
                                    final fam = _familyList.firstWhere(
                                        (f) => (f['id']?.toString() ?? '') == _selectedCategory,
                                        orElse: () => {});
                                    categoryParam = fam is Map && fam.isNotEmpty ? fam['name']?.toString() : _selectedCategory;
                                  }

                                  if (_selectedSubcategory != null && _selectedSubcategory!.isNotEmpty && _selectedCategory != null) {
                                    final subs = _categoryFamilies[_selectedCategory] ?? [];
                                    final sub = subs.firstWhere((s) => (s['id']?.toString() ?? '') == _selectedSubcategory, orElse: () => {});
                                    subcategoryParam = sub is Map && sub.isNotEmpty ? sub['name']?.toString() : _selectedSubcategory;
                                  }

                                  if (_selectedSupplier != null && _selectedSupplier!.isNotEmpty) {
                                    final sup = _supplierList.firstWhere(
                                        (s) => (s['id']?.toString() ?? '') == _selectedSupplier || (s['name']?.toString() ?? '') == _selectedSupplier,
                                        orElse: () => {});
                                    // Backend filters on supplier name, not id
                                    supplierParam = sup is Map && sup.isNotEmpty ? sup['name']?.toString() : _selectedSupplier;
                                  }

                                  await statsCtrl.fetchAll(
                                    start: _startDate,
                                    end: _endDate,
                                    department: (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) ? _selectedDepartment : null,
                                    requester: (_selectedRequester != null && _selectedRequester!.isNotEmpty) ? _selectedRequester : null,
                                    category: (categoryParam != null && categoryParam.isNotEmpty) ? categoryParam : null,
                                    subcategory: (subcategoryParam != null && subcategoryParam.isNotEmpty) ? subcategoryParam : null,
                                    supplier: (supplierParam != null && supplierParam.isNotEmpty) ? supplierParam : null,
                                    excludeNullDept: _excludeNullDept,
                                  );
                                  setState(() {
                                    _poTotalsByDepartment = Map.from(statsCtrl.poTotalsByDepartment);
                                    _poTotalsByRequester = Map.from(statsCtrl.poTotalsByRequester);
                                    _poTotalsByCategory = Map.from(statsCtrl.poTotalsByCategory);
                                    _poTotalsBySubcategory = Map.from(statsCtrl.poTotalsBySubcategory);
                                    _poTotalsBySupplier = Map.from(statsCtrl.poTotalsBySupplier);
                                    _rejectionRateByDepartment = Map.from(statsCtrl.rejectionRateByDepartment);
                                    _rejectionRateByRequester = Map.from(statsCtrl.rejectionRateByRequester);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(loc?.filtersApplied ?? 'Filters applied')),
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

                  // PO Totals Tables
                  Text(
                    loc?.poStatistics ?? 'PO Statistics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),

                  _buildStatTable(
                    loc?.poTotalsByDept ?? 'PO Totals by Department',
                    _poTotalsByDepartment,
                    loc?.total ?? 'Total',
                  ),
                  const SizedBox(height: 16),

                  _buildStatTable(
                    loc?.poTotalsByRequester ?? 'PO Totals by Requester',
                    _poTotalsByRequester,
                    loc?.total ?? 'Total',
                  ),
                  const SizedBox(height: 16),

                  _buildStatTable(
                    loc?.poTotalsByCategory ?? 'PO Totals by Category',
                    _poTotalsByCategory,
                    loc?.total ?? 'Total',
                  ),
                  const SizedBox(height: 16),

                  _buildStatTable(
                    loc?.poTotalsBySubcategory ?? 'PO Totals by Subcategory',
                    _poTotalsBySubcategory,
                    loc?.total ?? 'Total',
                  ),
                  const SizedBox(height: 16),

                  _buildStatTable(
                    loc?.poTotalsBySupplier ?? 'PO Totals by Supplier',
                    _poTotalsBySupplier,
                    loc?.total ?? 'Total',
                  ),
                  const SizedBox(height: 24),

                  // Rejection Rates
                  Text(
                    loc?.rejectionStatistics ?? 'Rejection Statistics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),

                  _buildStatTable(
                    loc?.rejectionRateByRequester ?? 'Rejection Rate by Requester',
                    _rejectionRateByRequester,
                    loc?.rejectionRate ?? 'Rejection Rate (%)',
                  ),
                  const SizedBox(height: 16),
                  _buildStatTable(
                    'Rejection Rate by Department',
                    _rejectionRateByDepartment,
                    loc?.rejectionRate ?? 'Rejection Rate (%)',
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
