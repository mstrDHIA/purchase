import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import '../../controllers/purchase_order_controller.dart';
import '../../controllers/supplier_controller.dart';
import '../../utils/file_download.dart';

// shared header
import '../../widgets/standard_header.dart';

// Extracted widgets
import 'widgets/summary_card.dart';
import 'widgets/filters_card.dart';
import 'widgets/spend_chart.dart';
import 'widgets/supplier_bar_chart.dart';
import 'widgets/top_suppliers_list.dart';
import 'widgets/top_products_by_supplier.dart';
import 'widgets/details_table.dart';

// Maquette UI pour l'écran Statistiques
// - Cartes de synthèse (total, commandes en attente, dépenses mensuelles...)
// - Filtres (période, fournisseur, département)
// - Emplacements pour graphiques (line, bar, pie)
// - Tableau / liste détaillée

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  // Date range selectors (two dates)
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  String _selectedSupplier = 'All';

  final List<String> _supplierOptions = ['All'];

  // Computed stats
  double _totalSpend = 0.0;
  int _poCount = 0;
  int _pendingApprovals = 0;
  double _avgLeadDays = 0.0;
  Map<String, double> _supplierSpend = {};
  Map<String, int> _supplierPoCount = {};

  // Time series for spend chart (daily)
  List<FlSpot> _spendSpots = [];
  DateTime? _spendAnchorDate;
  Map<int, String> _spendLabels = {};
  // Number of orders aggregated per day (keyed by x days from anchor)
  Map<int, int> _spendCounts = {};

  // Most ordered products per supplier: supplier -> product -> quantity
  Map<String, Map<String, int>> _supplierProductCounts = {};

  // Monthly growth comparison (current month vs previous month)
  double _monthlyGrowthPct = 0.0;
  double _currentMonthSpend = 0.0;
  double _previousMonthSpend = 0.0;

  bool _loading = true;
  VoidCallback? _pocListener;
  VoidCallback? _supListener;

  // Populate supplier dropdown options from SupplierController
  void _refreshSupplierOptions() {
    final sc = Provider.of<SupplierController>(context, listen: false);
    final names = sc.suppliers
        .map((s) => s.name?.toString() ?? 'Unknown')
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();
    names.sort((a, b) => a.compareTo(b));
    setState(() {
      _supplierOptions.clear();
      _supplierOptions.add('All');
      _supplierOptions.addAll(names);
      if (!_supplierOptions.contains(_selectedSupplier)) _selectedSupplier = 'All';
    });
  }

  @override
  void initState() {
    super.initState();
    // Listen to PurchaseOrderController and SupplierController for local data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final poc = Provider.of<PurchaseOrderController>(context, listen: false);
      final sc = Provider.of<SupplierController>(context, listen: false);

      // Ensure orders are fetched at least once
      poc.fetchOrders().whenComplete(() {
        _computeStats();
        setState(() => _loading = false);
      });
      // register listener and keep a reference so it can be removed later
      _pocListener = () => _computeStats();
      poc.addListener(_pocListener!);

      // Fetch suppliers and refresh options
      sc.fetchSuppliers().whenComplete(() {
        _refreshSupplierOptions();
      });
      _supListener = () => _refreshSupplierOptions();
      sc.addListener(_supListener!);
    });
  }

  @override
  void dispose() {
    final poc = Provider.of<PurchaseOrderController>(context, listen: false);
    if (_pocListener != null) poc.removeListener(_pocListener!);

    final sc = Provider.of<SupplierController>(context, listen: false);
    if (_supListener != null) sc.removeListener(_supListener!);

    super.dispose();
  }

  void _computeStats() {
    final poc = Provider.of<PurchaseOrderController>(context, listen: false);
    final orders = poc.orders;

    final filtered = orders.where((o) {
      final date = o.createdAt ?? o.startDate ?? o.endDate;
      if (date == null) return false;
      if (date.isBefore(_startDate) || date.isAfter(_endDate)) return false;

      if (_selectedSupplier == 'All') return true;

      // filter by selected supplier: check product lines
      if (o.products != null) {
        for (final p in o.products!) {
          final sname = (() {
            final sp = p.supplier;
            if (sp == null) return '';
            if (sp is String) return sp;
            try {
              return sp.toString();
            } catch (_) {
              return '';
            }
          })();
          if (sname == _selectedSupplier) return true;
        }
      }
      return false;
    }).toList();

    double total = 0.0;
    int pending = 0;
    double totalLead = 0.0;
    int leadCount = 0;
    final Map<String, double> supplierMap = {};
    final Map<String, int> supplierCount = {};
    final Map<DateTime, double> dailyMap = {};
    final Map<DateTime, int> dailyOrderCount = {};

    for (final o in filtered) {
      // count pending
      final status = o.status?.toLowerCase() ?? '';
      if (status.contains('pending') || status.contains('waiting') || status.contains('for approval')) pending++;

      // normalize order date for daily aggregation
      final orderDateRaw = o.createdAt ?? o.startDate ?? o.endDate;
      final DateTime? orderDate = orderDateRaw != null ? DateTime(orderDateRaw.year, orderDateRaw.month, orderDateRaw.day) : null;

      // count the order towards the day's order count once
      if (orderDate != null) {
        dailyOrderCount[orderDate] = (dailyOrderCount[orderDate] ?? 0) + 1;
      }

      // collect unique suppliers in this PO to count PO per supplier once
      final Set<String> suppliersInOrder = {};

      // compute total for this PO from products
      if (o.products != null) {
        for (final p in o.products!) {
          try {
            final dynamic qtyRaw = (p.quantity ?? 1);
            final int qtyInt = (qtyRaw is int) ? qtyRaw : (qtyRaw is double ? qtyRaw.toInt() : int.tryParse(qtyRaw.toString()) ?? 1);
            final num price = (p.unitPrice ?? p.price ?? 0.0) as num;
            final num lineTotal = qtyInt * price;
            total += lineTotal.toDouble();

            final supp = (p.supplier ?? 'Unknown').toString();
            supplierMap[supp] = (supplierMap[supp] ?? 0.0) + lineTotal.toDouble();
            suppliersInOrder.add(supp);

            // track most-ordered products per supplier
            final prodName = (p.product ?? p.brand ?? 'Unknown product').toString();
            _supplierProductCounts[supp] = _supplierProductCounts[supp] ?? {};
            _supplierProductCounts[supp]![prodName] = (_supplierProductCounts[supp]![prodName] ?? 0) + qtyInt;

            // add to daily totals if we have a date
            if (orderDate != null) {
              dailyMap[orderDate] = (dailyMap[orderDate] ?? 0.0) + lineTotal.toDouble();
            }
          } catch (_) {
            // ignore malformed product lines
          }
        }
      }

      // increment PO count per supplier for suppliers seen in this PO
      for (final s in suppliersInOrder) {
        supplierCount[s] = (supplierCount[s] ?? 0) + 1;
      }

      // lead time
      if (o.startDate != null && o.endDate != null) {
        final diff = o.endDate!.difference(o.startDate!).inDays.toDouble();
        totalLead += diff;
        leadCount++;
      }
    }

    // Build time series spots from dailyMap
    final List<DateTime> dates = dailyMap.keys.toList()..sort();
    final List<FlSpot> spots = [];
    final Map<int, String> labels = {};
    Map<int, int> countsByX = {};
    if (dates.isNotEmpty) {
      final anchor = dates.first;
      for (int i = 0; i < dates.length; i++) {
        final d = dates[i];
        final x = d.difference(anchor).inDays.toDouble();
        final y = dailyMap[d] ?? 0.0;
        spots.add(FlSpot(x, y));
        // Label first, middle and last
        if (i == 0 || i == dates.length - 1 || i == (dates.length ~/ 2)) {
          labels[x.toInt()] = DateFormat('dd-MM').format(d);
        }
        // map counts for tooltip
        countsByX[x.toInt()] = dailyOrderCount[d] ?? 0;
      }
    }

    // Monthly totals (group by year*100 + month)
    final Map<int, double> monthlyTotals = {};
    dailyMap.forEach((d, v) {
      final key = d.year * 100 + d.month;
      monthlyTotals[key] = (monthlyTotals[key] ?? 0.0) + v;
    });

    final currentKey = _endDate.year * 100 + _endDate.month;
    final prevDate = DateTime(_endDate.year, _endDate.month - 1);
    final prevKey = prevDate.year * 100 + prevDate.month;
    final currentMonth = monthlyTotals[currentKey] ?? 0.0;
    final previousMonth = monthlyTotals[prevKey] ?? 0.0;

    double growthPct;
    if (previousMonth == 0) {
      growthPct = (currentMonth == 0) ? 0.0 : 100.0;
    } else {
      growthPct = ((currentMonth - previousMonth) / previousMonth) * 100.0;
    }

    setState(() {
      _totalSpend = total;
      _poCount = filtered.length;
      _pendingApprovals = pending;
      _avgLeadDays = leadCount > 0 ? (totalLead / leadCount) : 0.0;
      _supplierSpend = supplierMap;
      _supplierPoCount = supplierCount;
      _spendSpots = spots;
      _spendAnchorDate = dates.isNotEmpty ? dates.first : null;
      _spendLabels = labels;
      _spendCounts = countsByX;

      // monthly metrics
      _currentMonthSpend = currentMonth;
      _previousMonthSpend = previousMonth;
      _monthlyGrowthPct = growthPct;
    });
  }

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
        _computeStats();
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
        _computeStats();
      });
    }
  }

  // Export helpers
  Future<void> _onExportPressed() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export'),
        content: const Text('Select export format'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop('csv'), child: const Text('CSV')),
          TextButton(onPressed: () => Navigator.of(context).pop('pdf'), child: const Text('PDF')),
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
        ],
      ),
    );

    if (choice == 'csv') {
      await _exportCsv();
    } else if (choice == 'pdf') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF export is not implemented yet')));
    }
  }

  Future<void> _exportCsv() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating CSV...')));

      final buffer = StringBuffer();
      buffer.writeln('Metric,Value');
      buffer.writeln('Total Spend,${_totalSpend.toStringAsFixed(2)}');
      buffer.writeln('PO Count,${_poCount}');
      buffer.writeln('Pending Approvals,${_pendingApprovals}');
      buffer.writeln('Avg Lead Time(days),${_avgLeadDays.toStringAsFixed(1)}');
      buffer.writeln('Date Range,${DateFormat('yyyy-MM-dd').format(_startDate)} to ${DateFormat('yyyy-MM-dd').format(_endDate)}');
      buffer.writeln('Supplier Filter,${_selectedSupplier}');
      buffer.writeln();

      buffer.writeln('Supplier,PO Count,Spend');
      final entries = _supplierSpend.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final e in entries) {
        final count = _supplierPoCount[e.key] ?? 0;
        buffer.writeln('${e.key},$count,${e.value.toStringAsFixed(2)}');
      }

      buffer.writeln();
      buffer.writeln('Date,Spend');
      if (_spendSpots.isNotEmpty && _spendAnchorDate != null) {
        for (final s in _spendSpots) {
          final date = _spendAnchorDate!.add(Duration(days: s.x.toInt()));
          buffer.writeln('${DateFormat('yyyy-MM-dd').format(date)},${s.y.toStringAsFixed(2)}');
        }
      }

      final bytes = utf8.encode(buffer.toString());
      final fname = 'stats_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final path = await saveFile(bytes, fname);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export saved: $path')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StandardHeader(title: 'Statistics'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filters
                  FiltersCard(
                    startDate: _startDate,
                    endDate: _endDate,
                    supplierOptions: _supplierOptions,
                    selectedSupplier: _selectedSupplier,
                    onSelectStart: _selectStartDate,
                    onSelectEnd: _selectEndDate,
                    onSupplierChanged: (v) => setState(() => _selectedSupplier = v ?? 'All'),
                    onApply: () {
                      _computeStats();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filters applied')));
                    },
                    onExport: _onExportPressed,
                  ),
                  const SizedBox(height: 12),

                  // Responsive content
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      // Prepare growth label
                      String growthLabel;
                      Color growthColor;
                      IconData growthIcon;
                      if (_previousMonthSpend == 0) {
                        if (_currentMonthSpend == 0) {
                          growthLabel = '0%';
                          growthColor = Colors.grey;
                          growthIcon = Icons.trending_flat;
                        } else {
                          growthLabel = 'New';
                          growthColor = Colors.green;
                          growthIcon = Icons.trending_up;
                        }
                      } else {
                        final sign = _monthlyGrowthPct >= 0 ? '+' : '';
                        growthLabel = '$sign${_monthlyGrowthPct.toStringAsFixed(0)}%';
                        growthColor = _monthlyGrowthPct >= 0 ? Colors.green : Colors.red;
                        growthIcon = _monthlyGrowthPct >= 0 ? Icons.trending_up : Icons.trending_down;
                      }

                      final summaryWidgets = [
                        SummaryCard(title: 'Total Spend', value: '\$ ${_totalSpend.toStringAsFixed(2)}', color: Colors.indigo),
                        SummaryCard(title: 'POs (count)', value: '$_poCount', color: Colors.orange, icon: Icons.receipt_long),
                        SummaryCard(title: 'Pending Approvals', value: '$_pendingApprovals', color: Colors.red, icon: Icons.pending_actions),
                        SummaryCard(title: 'Avg Lead Time', value: '${_avgLeadDays.toStringAsFixed(1)}d', color: Colors.green, icon: Icons.timer),
                        SummaryCard(title: 'Monthly Growth', value: growthLabel, color: growthColor, icon: growthIcon),
                      ];

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: charts
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Summary grid
                                  Wrap(spacing: 8, runSpacing: 8, children: summaryWidgets.map((w) => SizedBox(width: (constraints.maxWidth * 0.6 - 24) / 2, height: 100, child: w)).toList()),
                                  const SizedBox(height: 12),

                                  // Make charts area scrollable vertically so they don't force the whole column to overflow
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          SpendChart(spots: _spendSpots, anchorDate: _spendAnchorDate, labels: _spendLabels, counts: _spendCounts, dateRange: '${DateFormat('yyyy-MM-dd').format(_startDate)} → ${DateFormat('yyyy-MM-dd').format(_endDate)}', dateNote: 'Date used: createdAt → startDate → endDate'),
                                          const SizedBox(height: 12),
                                          SupplierBarChart(supplierSpend: _supplierSpend, topN: 8, onBarTap: (supplier) { setState(() { _selectedSupplier = supplier; }); }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Right: top suppliers + details
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TopSuppliersList(supplierSpend: _supplierSpend),
                                  const SizedBox(height: 12),
                                  TopProductsBySupplier(supplierProductCounts: _supplierProductCounts, selectedSupplier: _selectedSupplier),
                                  const SizedBox(height: 12),
                                  Expanded(child: DetailsTable(supplierSpend: _supplierSpend, supplierPoCount: _supplierPoCount)),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      // Narrow layout: tabs
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(spacing: 8, runSpacing: 8, children: summaryWidgets.map((w) => SizedBox(width: (constraints.maxWidth - 24) / 2, height: 100, child: w)).toList()),
                          const SizedBox(height: 12),
                          Expanded(
                            child: DefaultTabController(
                              length: 3,
                              child: Column(
                                children: [
                                  const TabBar(tabs: [Tab(text: 'Spend'), Tab(text: 'Suppliers'), Tab(text: 'Details')]),
                                  Expanded(
                                    child: TabBarView(
                                      children: [
                                        SingleChildScrollView(child: SpendChart(spots: _spendSpots, anchorDate: _spendAnchorDate, labels: _spendLabels, counts: _spendCounts, dateRange: '${DateFormat('yyyy-MM-dd').format(_startDate)} → ${DateFormat('yyyy-MM-dd').format(_endDate)}', dateNote: 'Date used: createdAt → startDate → endDate')),
                                        SingleChildScrollView(child: SupplierBarChart(supplierSpend: _supplierSpend, topN: 8, onBarTap: (supplier) { setState(() { _selectedSupplier = supplier; }); })),
                                        
                                        SingleChildScrollView(child: TopProductsBySupplier(supplierProductCounts: _supplierProductCounts, selectedSupplier: _selectedSupplier)),
                                        SingleChildScrollView(child: DetailsTable(supplierSpend: _supplierSpend, supplierPoCount: _supplierPoCount)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
    );
  }
}