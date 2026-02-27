import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:excel/excel.dart' as ex;
import 'package:open_file/open_file.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/supplier_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/department_controller.dart';
import 'package:flutter_application_1/controllers/stats_controller.dart';
import 'package:flutter_application_1/controllers/reset_notifier.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/models/department.dart';
import 'package:flutter_application_1/network/api.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_application_1/widgets/standard_header.dart';
import 'package:flutter_application_1/utils/file_download.dart' show saveFile;

class PurchaseDashboardPage extends StatefulWidget {
  const PurchaseDashboardPage({super.key});

  @override
  State<PurchaseDashboardPage> createState() => _PurchaseDashboardPageState();
}

class _PurchaseDashboardPageState extends State<PurchaseDashboardPage>
    with WidgetsBindingObserver {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _initialLoadDone = false;
  Timer? _refreshTimer;

  // Pagination state
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Sorting state
  String _sortBy = 'id'; // Default sort by ID
  bool _sortAscending = false; // Default descending

  // Filter states
  String? _selectedSupplier;
  String? _selectedFamily;
  String? _selectedSubFamily;
  DateTime? _startDate;
  DateTime? _endDate;
  // currency filter (for both UI and export)
  String? _selectedCurrency;
  // Shared stats filters
  String? _selectedDepartment;
  String? _selectedRequester;
  bool _excludeNullDept = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load orders immediately on init
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure users and departments are loaded for filter dropdowns
      try {
        await Future.wait<dynamic>([
          context.read<UserController>().getUsers(),
          context.read<DepartmentController>().fetchDepartments(),
        ]);
      } catch (_) {}

      if (!mounted) return;

      // Trigger initial stats load with defaults (also fetches PO with filters)
      await _applySharedFilters();

      if (!mounted) return;

      _startAutoRefresh();

      // Register reset listener
      final resetNotifier = Provider.of<ResetNotifier>(context, listen: false);
      resetNotifier.addListener(() {
        final target = resetNotifier.lastTarget;
        if (target == 'PO Dashboard') {
          if (mounted) {
            _resetToInitial();
            resetNotifier.clear();
          }
        }
      });
    });
  }

  void _startAutoRefresh() {
    // Refresh purchase orders every 30 seconds with current filters
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        final start =
            _startDate ?? DateTime.now().subtract(const Duration(days: 90));
        final end = _endDate ?? DateTime.now();
        final startStr = DateTime(start.year, start.month, start.day)
            .toIso8601String()
            .split('T')
            .first;
        final endStr = DateTime(end.year, end.month, end.day)
            .toIso8601String()
            .split('T')
            .first;

        context.read<PurchaseOrderController>().fetchOrders(
              startDate: startStr,
              endDate: endStr,
              department: _selectedDepartment,
              requester: _selectedRequester,
              family: _selectedFamily,
              subfamily: _selectedSubFamily,
              supplier: _selectedSupplier,
              currency: _selectedCurrency,
              excludeNullDept: _excludeNullDept,
              silent: true, // don't show loading indicator for background refresh
            );
      }
    });
  }

  // Apply shared filters: refresh stats and update UI
  Future<void> _applySharedFilters() async {
    if (!mounted) return;

    try {
      final statsCtrl = context.read<StatsController>();
      final poCtrl = context.read<PurchaseOrderController>();

      final start = _startDate ?? DateTime.now().subtract(const Duration(days: 90));
      final end = _endDate ?? DateTime.now();
      final startStr = DateTime(start.year, start.month, start.day).toIso8601String().split('T').first;
      final endStr = DateTime(end.year, end.month, end.day).toIso8601String().split('T').first;

      // Fetch stats (other than total dinar)
      try {
        await statsCtrl.fetchAll(
          start: start,
          end: end,
          department: _selectedDepartment,
          requester: _selectedRequester,
          family: _selectedFamily,
          subfamily: _selectedSubFamily,
          supplier: _selectedSupplier,
          currency: _selectedCurrency,
          excludeNullDept: _excludeNullDept,
        );
      } catch (statsError) {
        debugPrint('⚠️ Stats fetch error (continuing with PO): $statsError');
      }

      // Force refresh of totalPriceDinar
      try {
        await statsCtrl.fetchTotalPriceDinar(
          token: APIS.token,
          startDate: startStr,
          endDate: endStr,
          department: _selectedDepartment,
          requester: _selectedRequester,
          supplier: _selectedSupplier,
          family: _selectedFamily,
          subfamily: _selectedSubFamily,
          currency: _selectedCurrency,
          excludeNullDept: _excludeNullDept,
        );
      } catch (totalError) {
        debugPrint('❌ Total Dinar fetch error: $totalError');
      }

      if (!mounted) return;

      // Fetch PO list with same filters - continue even if stats failed
      try {
        await poCtrl.fetchOrders(
          startDate: startStr,
          endDate: endStr,
          department: _selectedDepartment,
          requester: _selectedRequester,
          family: _selectedFamily,
          subfamily: _selectedSubFamily,
          supplier: _selectedSupplier,
          currency: _selectedCurrency,
          excludeNullDept: _excludeNullDept,
        );
      } catch (poError) {
        debugPrint('❌ PO fetch error: $poError');
      }

    } catch (e) {
      debugPrint('❌ Error in _applySharedFilters: $e');
    }

    // Ne pas appeler setState ici pour éviter de bloquer l'UI :
    // L'UI sera rafraîchie automatiquement via Provider/Consumer quand les données changent.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-apply current filters when returning to this screen
      if (mounted) _applySharedFilters();
    }
  }

  String _safeString(String? value) => value ?? '';

  String _currencySymbol(String? currencyRaw) {
    if (currencyRaw == null || currencyRaw.isEmpty) return '';
    final code = currencyRaw.toUpperCase();
    final Map<String, String> codeToSymbol = {
      'USD': '\$',
      'EUR': '€',
      'TND': 'DT',
      'DZD': 'DT'
    };
    if (codeToSymbol.containsKey(code)) return codeToSymbol[code]!;
    final low = currencyRaw.toLowerCase();
    if (low.contains('dinar')) return 'DT';
    if (low.contains('dollar')) return '\$';
    if (low.contains('euro')) return '€';
    if (currencyRaw.length <= 4) return currencyRaw;
    return '';
  }

  String _getRequesterName(dynamic order, UserController userController) {
    // Prefer explicit requester username if provided by API
    try {
      final reqName = (order.requestedByUsername ?? '').toString().trim();
      if (reqName.isNotEmpty) return reqName;
    } catch (_) {}

    // Fallback: try to resolve from loaded users by id
    try {
      final uid = order.requestedByUser;
      if (uid != null) {
        // Attempt to find a matching user; if username is empty, return placeholder instead of raw id
        final found = userController.users.firstWhere(
          (u) => u.id == uid,
          orElse: () => User(id: uid, username: ''),
        );
        final username = (found.username ?? '').toString().trim();
        if (username.isNotEmpty) return username;
        // If users are not yet resolved, show a friendly placeholder
        return '-';
      }
    } catch (_) {}
    return '-';
  }

  String _localizedStatus(BuildContext context, String? status) {
    final s = (status ?? '').toLowerCase();
    final loc = AppLocalizations.of(context)!;
    if (s == 'approved') return loc.approved;
    if (s == 'pending') return loc.pending;
    if (s == 'rejected') return loc.rejected;
    // fallback to raw status or dash
    return status ?? '-';
  }

  void _showOrderDetailsDialog(
      BuildContext context, dynamic order, UserController userController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .viewPurchaseOrder(order.id),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Info
                        _buildInfoRow(AppLocalizations.of(context)!.id,
                            order.id.toString()),
                        _buildInfoRow(AppLocalizations.of(context)!.title,
                            _safeString(order.title)),
                        _buildInfoRow(
                          AppLocalizations.of(context)!.date,
                          order.startDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(order.startDate!)
                              : '-',
                        ),
                        _buildInfoRow(
                          AppLocalizations.of(context)!.requester,
                          _getRequesterName(order, userController),
                        ),
                        _buildStatusRow(AppLocalizations.of(context)!.status,
                            _localizedStatus(context, order.status)),
                        const SizedBox(height: 20),

                        // Products Section
                        Text(
                          AppLocalizations.of(context)!.products,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (order.products == null || order.products!.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              AppLocalizations.of(context)!.noProducts,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          Column(
                            children: order.products!.map<Widget>((product) {
                              final unitPrice =
                                  product.unitPrice ?? product.price ?? 0;
                              final quantity = product.quantity ?? 0;
                              final totalAmount = (quantity is int
                                      ? quantity.toDouble()
                                      : quantity as double) *
                                  (unitPrice is int
                                      ? unitPrice.toDouble()
                                      : unitPrice as double);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                        AppLocalizations.of(context)!.product,
                                        _safeString(product.product)),
                                    _buildInfoRow(
                                        AppLocalizations.of(context)!.supplier,
                                        _safeString(product.supplier)),
                                    _buildInfoRow(
                                        AppLocalizations.of(context)!.unitPrice,
                                        unitPrice.toString()),
                                    _buildInfoRow(
                                        AppLocalizations.of(context)!.quantity,
                                        quantity.toString()),
                                    _buildInfoRow(
                                        AppLocalizations.of(context)!
                                            .totalPrice,
                                        totalAmount.toStringAsFixed(2) +
                                            (_currencySymbol(order.currency)
                                                    .isNotEmpty
                                                ? ' ' +
                                                    _currencySymbol(
                                                        order.currency)
                                                : '')),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(AppLocalizations.of(context)!.close,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'approved'
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'approved' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get all unique suppliers from orders
  List<String> _getSuppliers(List orders) {
    final suppliers = <String>{};
    for (var order in orders) {
      if (order.products != null) {
        for (var product in order.products!) {
          if (product.supplier != null && product.supplier!.isNotEmpty) {
            suppliers.add(product.supplier!);
          }
        }
      }
    }
    return suppliers.toList()..sort();
  }

  // Get all unique families from orders
  List<String> _getFamilies(List orders) {
    final families = <String>{};
    for (var order in orders) {
      if (order.products != null) {
        for (var product in order.products!) {
          final f = product.family;
          if (f != null && f.toString().trim().isNotEmpty)
            families.add(f.toString().trim());
        }
      }
    }
    return families.toList()..sort();
  }

  // Get subfamilies optionally filtered by family
  List<String> _getSubFamilies(List orders, String? family) {
    final sub = <String>{};
    for (var order in orders) {
      if (order.products != null) {
        for (var product in order.products!) {
          final sf = product.subFamily;
          final f = product.family;
          if (sf != null && sf.toString().trim().isNotEmpty) {
            if (family == null ||
                (f != null && f.toString().trim() == family)) {
              sub.add(sf.toString().trim());
            }
          }
        }
      }
    }
    return sub.toList()..sort();
  }

  void _sortOrders(List orders, String sortBy, bool ascending) {
    orders.sort((a, b) {
      int comparison = 0;

      switch (sortBy) {
        case 'id':
          comparison = (a.id ?? 0).compareTo(b.id ?? 0);
          break;
        case 'date':
          final dateA = a.startDate;
          final dateB = b.startDate;
          comparison =
              (dateA ?? DateTime(2000)).compareTo(dateB ?? DateTime(2000));
          break;
        case 'status':
          comparison = _safeString(a.status).compareTo(_safeString(b.status));
          break;
        case 'title':
          comparison = _safeString(a.title).compareTo(_safeString(b.title));
          break;
        case 'product':
          // Sort by product name from first product
          final prodA = a.products?.isNotEmpty == true
              ? _safeString(a.products!.first.product)
              : '';
          final prodB = b.products?.isNotEmpty == true
              ? _safeString(b.products!.first.product)
              : '';
          comparison = prodA.compareTo(prodB);
          break;
        case 'supplier':
          // Sort by supplier from first product
          final supA = a.products?.isNotEmpty == true
              ? _safeString(a.products!.first.supplier)
              : '';
          final supB = b.products?.isNotEmpty == true
              ? _safeString(b.products!.first.supplier)
              : '';
          comparison = supA.compareTo(supB);
          break;
        case 'quantity':
          final qtyA = a.products?.isNotEmpty == true
              ? a.products!.first.quantity ?? 0
              : 0;
          final qtyB = b.products?.isNotEmpty == true
              ? b.products!.first.quantity ?? 0
              : 0;
          comparison = qtyA.compareTo(qtyB);
          break;
        case 'totalAmount':
          // Calculate total amount for first product
          final amountA = a.products?.isNotEmpty == true
              ? ((a.products!.first.quantity ?? 0) *
                      (a.products!.first.unitPrice ??
                          a.products!.first.price ??
                          0))
                  .toDouble()
              : 0.0;
          final amountB = b.products?.isNotEmpty == true
              ? ((b.products!.first.quantity ?? 0) *
                      (b.products!.first.unitPrice ??
                          b.products!.first.price ??
                          0))
                  .toDouble()
              : 0.0;
          comparison = amountA.compareTo(amountB);
          break;
        default:
          comparison = 0;
      }

      return ascending ? comparison : -comparison;
    });
  }

  @override
  Widget build(BuildContext context) {
    final poController = context.watch<PurchaseOrderController>();
    final supplierController = context.watch<SupplierController>();
    // Use watch so the UI rebuilds when the users list is loaded/updated
    final userController = context.watch<UserController>();

    if (!_initialLoadDone &&
        poController.orders.isEmpty &&
        !poController.isLoading) {
      _initialLoadDone = true;
      Future.microtask(() {
        // Fetch suppliers and users only; orders will be fetched via _applySharedFilters()
        supplierController.fetchSuppliers();
        try {
          userController.getUsers();
        } catch (_) {}
      });
    }

    // Backend now returns only approved/rejected orders, so use them directly
    final ordersFromServer = poController.orders;


    // Apply filters (search, supplier and date range)
    final filter = _searchCtrl.text.toLowerCase();
    final filteredOrders = ordersFromServer.where((order) {
      // Filter by search text
      final title = _safeString(order.title).toLowerCase();
      final status = _safeString(order.status).toLowerCase();
      final id = order.id.toString().toLowerCase();
      if (!title.contains(filter) &&
          !status.contains(filter) &&
          !id.contains(filter)) {
        return false;
      }

      // Filter by supplier if selected
      if (_selectedSupplier != null && _selectedSupplier!.isNotEmpty) {
        final hasSupplier =
            order.products?.any((p) => p.supplier == _selectedSupplier) ??
                false;
        if (!hasSupplier) return false;
      }

      // Filter by currency if selected
      if (_selectedCurrency != null && _selectedCurrency!.isNotEmpty) {
        final curr = (order.currency ?? '').toString().trim();
        if (curr != _selectedCurrency) return false;
      }

      // Filter by family if selected
      if (_selectedFamily != null && _selectedFamily!.isNotEmpty) {
        final hasFamily = order.products?.any(
                (p) => (p.family ?? '').toString().trim() == _selectedFamily) ??
            false;
        if (!hasFamily) return false;
      }

      // Filter by subfamily if selected
      if (_selectedSubFamily != null && _selectedSubFamily!.isNotEmpty) {
        final hasSub = order.products?.any((p) =>
                (p.subFamily ?? '').toString().trim() == _selectedSubFamily) ??
            false;
        if (!hasSub) return false;
      }

      // Filter by date range if set
      if (_startDate != null && order.startDate != null) {
        if (order.startDate!.isBefore(_startDate!)) return false;
      }
      if (_endDate != null && order.startDate != null) {
        if (order.startDate!.isAfter(_endDate!)) return false;
      }

      return true;
    }).toList();

    // Recompute dropdown options from filtered data so filters cascade properly
    final controllerApproved = supplierController.suppliers
        .where((s) =>
            (s.approvalStatus ?? '').toLowerCase() == 'approved' &&
            (s.name?.isNotEmpty ?? false))
        .map((s) => s.name!.trim())
        .toSet();
    final ordersSuppliers = _getSuppliers(filteredOrders).toSet();
    List<String> suppliers;
    if (ordersSuppliers.isNotEmpty) {
      // when we have orders after filtering, show only the suppliers actually
      // present in those orders (cascade behaviour)
      suppliers = ordersSuppliers.toList();
    } else {
      // no orders yet (initial state or filters removed) – fall back to all
      // approved suppliers so dropdown isn't empty
      suppliers = controllerApproved.toList();
    }
    suppliers.sort();

    // families/subfamilies cascade like suppliers: use filteredOrders when
    // available, otherwise fall back to the master list (ordersFromServer).
    final families = (filteredOrders.isNotEmpty)
        ? _getFamilies(filteredOrders)
        : _getFamilies(ordersFromServer);
    final subfamilies = (filteredOrders.isNotEmpty)
        ? _getSubFamilies(filteredOrders, _selectedFamily)
        : _getSubFamilies(ordersFromServer, _selectedFamily);

    // currencies cascade similar to other dropdowns
    final ordersCurrencies = filteredOrders
        .map((o) => (o.currency ?? '').toString().trim())
        .where((c) => c.isNotEmpty)
        .toSet();
    List<String> currencies;
    if (ordersCurrencies.isNotEmpty) {
      currencies = ordersCurrencies.toList();
    } else {
      final masterCurrencies = ordersFromServer
          .map((o) => (o.currency ?? '').toString().trim())
          .where((c) => c.isNotEmpty)
          .toSet();
      currencies = masterCurrencies.toList();
    }
    currencies.sort();

    // Build requester list based primarily on department users, then narrow
    // to those having a PO if possible. This ensures the dropdown isn’t empty
    // even when filteredOrders doesn’t reference any of them.
    final deptUsers = userController.users.where((u) {
      final isReq = ((u.role_id == 2) ||
          (u.role != null && u.role!.id == 2));
      if (!isReq) return false;
      if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
        return u.depId?.toString() == _selectedDepartment;
      }
      return true;
    }).toList();

    List<User> filteredRequesters;
    if (filteredOrders.isNotEmpty) {
      // gather requester ids from orders (stringified for safety)
      final orderIds = filteredOrders
          .map((o) => o.requestedByUser?.toString())
          .where((id) => id != null)
          .toSet();
      final matched = deptUsers
          .where((u) => orderIds.contains(u.id?.toString()))
          .toList();
      filteredRequesters = matched.isNotEmpty ? matched : deptUsers;
    } else {
      filteredRequesters = deptUsers;
    }
    filteredRequesters.sort((a, b) {
      final aName = (a.username ?? a.name ?? '').toLowerCase();
      final bName = (b.username ?? b.name ?? '').toLowerCase();
      return aName.compareTo(bName);
    });
    // reset selection if no longer valid
    if (_selectedRequester != null &&
        !filteredRequesters
            .any((u) => u.id?.toString() == _selectedRequester)) {
      _selectedRequester = null;
    }

    // Apply sorting
    _sortOrders(filteredOrders, _sortBy, _sortAscending);

    // Build flat list of product rows (one row per product line)
    final List<Map<String, dynamic>> productRows = [];
    for (final order in filteredOrders) {
      if (order.products == null || order.products!.isEmpty) {
        productRows.add({'order': order, 'product': null});
      } else {
        for (final product in order.products!) {
          // Apply product-level filters
          bool matchesFamily = true;
          bool matchesSubfamily = true;

          if (_selectedFamily != null && _selectedFamily!.isNotEmpty) {
            matchesFamily = (product.family ?? '').toString().trim() == _selectedFamily;
          }
          if (_selectedSubFamily != null && _selectedSubFamily!.isNotEmpty) {
            matchesSubfamily = (product.subFamily ?? '').toString().trim() == _selectedSubFamily;
          }

          if (matchesFamily && matchesSubfamily) {
            productRows.add({'order': order, 'product': product});
          }
        }
      }
    }

    // Apply pagination on product rows (not orders)
    final totalPages = (productRows.isEmpty)
        ? 1
        : (productRows.length / _itemsPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage) > productRows.length
        ? productRows.length
        : (startIndex + _itemsPerPage);
    final paginatedProductRows = productRows.sublist(startIndex, endIndex);

    return Scaffold(
      appBar:
          StandardHeader(title: AppLocalizations.of(context)!.poDashboardTitle),
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          // ========== STATS FILTERS (top) ==========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Première ligne : tous les filtres principaux
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - all filter dropdowns in a SingleChildScrollView
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Date range
                            SizedBox(
                              width: 180,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _startDate = picked);
                                    // Ouvre automatiquement le calendrier To Date
                                    final endInitial =
                                        (_endDate != null && !_endDate!.isBefore(picked))
                                            ? _endDate!
                                            : picked;
                                    final pickedEnd = await showDatePicker(
                                      context: context,
                                      initialDate: endInitial,
                                      firstDate: picked,
                                      lastDate: DateTime.now(),
                                      helpText: AppLocalizations.of(context)!.selectToDate,
                                    );
                                    if (pickedEnd != null) {
                                      setState(() => _endDate = pickedEnd);
                                    }
                                    // auto apply filters
                                    _applySharedFilters();
                                  }
                                },
                                child: Text(_startDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_startDate!)
                                    : AppLocalizations.of(context)!.fromDate),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 180,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _endDate = picked);
                                    _applySharedFilters();
                                  }
                                },
                                child: Text(_endDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                    : AppLocalizations.of(context)!.toDate),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Currency dropdown
                            SizedBox(
                              width: 120,
                              child: DropdownButton<String?>(
                                isExpanded: true,
                                value: _selectedCurrency,
                                hint: Text(AppLocalizations.of(context)!.currency),
                                items: [
                                  DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(AppLocalizations.of(context)!.all)),
                                  ...currencies.map((c) => DropdownMenuItem<String?>(
                                      value: c, child: Text(c))),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCurrency = val;
                                  });
                                  _applySharedFilters();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Department dropdown
                            SizedBox(
                              width: 200,
                              child: Consumer<DepartmentController>(builder: (context, dc, _) {
                                final depts = dc.departments
                                    .map((d) =>
                                        {'id': d.id?.toString() ?? '', 'name': d.name})
                                    .toList();
                                return DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedDepartment,
                                  hint: Text(AppLocalizations.of(context)!.all),
                                  items: [
                                    DropdownMenuItem(
                                        value: null,
                                        child: Text(AppLocalizations.of(context)!.all)),
                                    ...depts.map((dept) => DropdownMenuItem(
                                        value: dept['id'] as String,
                                        child: Text(dept['name'] as String))),
                                  ],
                                  onChanged: (val) {
                                      setState(() {
                                        _selectedDepartment = val;
                                        // clearing requester whenever department changes
                                        _selectedRequester = null;
                                      });
                                      _applySharedFilters();
                                    },
                                );
                              }),
                            ),
                            const SizedBox(width: 12),
                            // Requester dropdown – options derived from filteredOrders
                            SizedBox(
                              width: 200,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedRequester,
                                hint: Text(AppLocalizations.of(context)!.all),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(AppLocalizations.of(context)!.all),
                                  ),
                                  ...filteredRequesters.map((u) => DropdownMenuItem(
                                      value: u.id?.toString(),
                                      child:
                                          Text(u.username ?? u.name ?? 'Unknown'))),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedRequester = val);
                                  _applySharedFilters();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Supplier (shared)
                            SizedBox(
                              width: 150,
                              child: DropdownButton<String?>(
                                isExpanded: true,
                                value: _selectedSupplier,
                                hint:
                                    Text(AppLocalizations.of(context)!.selectSupplier),
                                items: [
                                  DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                          AppLocalizations.of(context)!.allSuppliers)),
                                  ...suppliers.map((s) => DropdownMenuItem<String>(
                                      value: s, child: Text(s))),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedSupplier = val);
                                  _applySharedFilters();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Family filter for stats
                            SizedBox(
                              width: 200,
                              child: DropdownButton<String?>(
                                isExpanded: true,
                                value: _selectedFamily,
                                hint: Text(AppLocalizations.of(context)!.familyLabel),
                                items: [
                                  DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                          AppLocalizations.of(context)!.allFamilies)),
                                  ...families.map((f) => DropdownMenuItem<String>(
                                      value: f, child: Text(f))),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedFamily = val;
                                    _selectedSubFamily = null; // Reset subfamily when family changes
                                  });
                                  _applySharedFilters();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Subfamily filter for stats
                            SizedBox(
                              width: 200,
                              child: DropdownButton<String?>(
                                isExpanded: true,
                                value: _selectedSubFamily,
                                hint: Text(AppLocalizations.of(context)!.subfamilyLabel),
                                items: [
                                  DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(AppLocalizations.of(context)!
                                          .allSubfamilies)),
                                  ...subfamilies.map((sf) => DropdownMenuItem<String>(
                                      value: sf, child: Text(sf))),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedSubFamily = val);
                                  _applySharedFilters();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Right side - action buttons
                    Column(
                      children: [
                        Row(
                          children: [
                            // Apply button is no longer needed; filters run automatically.
                            /*
                            ElevatedButton.icon(
                              onPressed: _applySharedFilters,
                              icon: const Icon(Icons.refresh),
                              label: Text(AppLocalizations.of(context)!.apply),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            */
                            const SizedBox(width: 8),
                            // Clear Filters button - seulement l'icône X
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                  _selectedDepartment = null;
                                  _selectedRequester = null;
                                  _selectedSupplier = null;
                                  _selectedFamily = null;
                                  _selectedSubFamily = null;
                                  _excludeNullDept = false;
                                });
                                _applySharedFilters();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.all(12),
                                minimumSize: const Size(48, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Icon(Icons.clear, size: 20, semanticLabel: AppLocalizations.of(context)!.clearFilters),
                            ),
                            const SizedBox(width: 8),
                            // Export Excel button - seulement le texte
                            Builder(
                              builder: (context) => ElevatedButton(
                                onPressed: () async {
                                  final ordersToExport = filteredOrders;
                                  if (ordersToExport.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(AppLocalizations.of(context)!.noOrdersToExportForSelectedRange)));
                                    return;
                                  }
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(AppLocalizations.of(context)!.exportConfirmTitle(ordersToExport.length)),
                                      content: Text(AppLocalizations.of(context)!.exportConfirmContent(ordersToExport.length)),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text(AppLocalizations.of(context)!.cancel)),
                                        ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: Text(AppLocalizations.of(context)!.export)),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await _exportOrdersToExcel(ordersToExport);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: Text(AppLocalizations.of(context)!.export),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Deuxième ligne : bouton Include/Exclude Null Dept tout seul
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Exclude Null Dept toggle
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _excludeNullDept = !_excludeNullDept;
                        });
                        _applySharedFilters();
                      },
                      icon: Icon(
                        _excludeNullDept ? Icons.filter_alt_off : Icons.filter_alt,
                        size: 18,
                      ),
                        label: Text(_excludeNullDept
                          ? AppLocalizations.of(context)!.excludePoWithoutDepartment
                          : AppLocalizations.of(context)!.includePoWithoutDepartment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _excludeNullDept ? Colors.orange.shade100 : Colors.grey.shade100,
                        foregroundColor: _excludeNullDept ? Colors.orange.shade900 : Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Petit texte d'information
                    if (_excludeNullDept)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Text(
                          'Les PO sans département sont exclus',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                // Stats summary cards
                Consumer2<StatsController, UserController>(builder: (context, statsCtrl, userCtrl, _) {
                  // trigger fetch once when necessary
                  if ((statsCtrl.totalPriceByCurrency == null) &&
                      !statsCtrl.loadingTotalPriceDinar) {
                    final token = APIS.token;
                    final start = _startDate ?? DateTime.now().subtract(const Duration(days: 90));
                    final end = _endDate ?? DateTime.now();
                    final startStr = DateTime(start.year, start.month, start.day)
                        .toIso8601String()
                        .split('T')
                        .first;
                    final endStr = DateTime(end.year, end.month, end.day)
                        .toIso8601String()
                        .split('T')
                        .first;
                    Future.microtask(() => statsCtrl.fetchTotalPriceDinar(
                          token: token,
                          startDate: startStr,
                          endDate: endStr,
                          department: _selectedDepartment,
                          requester: _selectedRequester,
                          supplier: _selectedSupplier,
                          family: _selectedFamily,
                          subfamily: _selectedSubFamily,
                          excludeNullDept: _excludeNullDept,
                        ));
                  }
                  // build basic cards and then currency cards
                  // debug log current stats map each rebuild
                  print('🔢 stats map inside widget: ${statsCtrl.totalPriceByCurrency}');
                  return Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(children: [
                              Text(AppLocalizations.of(context)!.poStatistics),
                              const SizedBox(height: 8),
                              Text(statsCtrl.summaryTotal.toString(),
                                  style: const TextStyle(fontSize: 18, color: Colors.blue))
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(children: [
                              Text(AppLocalizations.of(context)!.statusRejected),
                              const SizedBox(height: 8),
                              Text(statsCtrl.summaryRejected.toString(),
                                  style: const TextStyle(fontSize: 18, color: Colors.red))
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(children: [
                              Text(AppLocalizations.of(context)!.rejectionRate),
                              const SizedBox(height: 8),
                              Text('${(statsCtrl.summaryRejectionRate * 100).toStringAsFixed(2)}%',
                                  style: const TextStyle(fontSize: 18, color: Colors.orange))
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // single horizontal card for all currencies with heading
                      Expanded(
                        child: Card(
                          color: Colors.green[50],
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Total price of approved PO ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[900])),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (statsCtrl.loadingTotalPriceDinar)
                                      const CircularProgressIndicator(
                                          strokeWidth: 2)
                                    else if (statsCtrl.errorTotalPriceDinar != null)
                                      Text(AppLocalizations.of(context)!.error,
                                          style: TextStyle(
                                              color: Colors.red[700]))
                                    else if (statsCtrl.totalPriceByCurrency != null)
                                      for (var currency in ['TND', 'USD', 'EUR'])
                                        Builder(builder: (context) {
                                          final key =
                                              'total_price_${currency.toLowerCase()}';
                                          final value = statsCtrl
                                              .totalPriceByCurrency![key];
                                          // display symbol if available
                                          final symbol =
                                              _currencySymbol(currency);
                                          final suffix =
                                              symbol.isNotEmpty ? symbol : currency;
                                          return Text(
                                            value != null
                                                ? '${value.toStringAsFixed(2)} $suffix'
                                                : '- $suffix',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.green),
                                          );
                                        })
                                    else
                                      const Text('-',
                                          style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 8),

          // Table
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF7F4FA),
              child: poController.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : poController.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                poController.error!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _applySharedFilters(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.deepPurple.withOpacity(0.1),
                                    ),
                                    columnSpacing: 60,
                                    horizontalMargin: 6,
                                    columns: [
                                      DataColumn(
                                        label: SizedBox(
                                          width: 40,
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              if (_sortBy == 'id') {
                                                _sortAscending = !_sortAscending;
                                              } else {
                                                _sortBy = 'id';
                                                _sortAscending = false;
                                              }
                                            }),
                                            child: Row(
                                              children: [
                                                Text(AppLocalizations.of(context)!.id),
                                                if (_sortBy == 'id')
                                                  Icon(
                                                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                                    size: 14),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 90,
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              if (_sortBy == 'title') {
                                                _sortAscending = !_sortAscending;
                                              } else {
                                                _sortBy = 'title';
                                                _sortAscending = false;
                                              }
                                            }),
                                            child: Row(
                                              children: [
                                                Text(AppLocalizations.of(context)!.title),
                                                if (_sortBy == 'title')
                                                  Icon(
                                                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                                    size: 14),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 125,
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              if (_sortBy == 'product') {
                                                _sortAscending = !_sortAscending;
                                              } else {
                                                _sortBy = 'product';
                                                _sortAscending = false;
                                              }
                                            }),
                                            child: Row(
                                              children: [
                                                Text(AppLocalizations.of(context)!.product),
                                                if (_sortBy == 'product')
                                                  Icon(
                                                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                                    size: 14),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 123,
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              if (_sortBy == 'supplier') {
                                                _sortAscending = !_sortAscending;
                                              } else {
                                                _sortBy = 'supplier';
                                                _sortAscending = false;
                                              }
                                            }),
                                            child: Row(
                                              children: [
                                                Text(AppLocalizations.of(context)!.supplier),
                                                if (_sortBy == 'supplier')
                                                  Icon(
                                                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                                    size: 14),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 125,
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              if (_sortBy == 'quantity') {
                                                _sortAscending = !_sortAscending;
                                              } else {
                                                _sortBy = 'quantity';
                                                _sortAscending = false;
                                              }
                                            }),
                                            child: Row(
                                              children: [
                                                Text(AppLocalizations.of(context)!.quantity),
                                                if (_sortBy == 'quantity')
                                                  Icon(
                                                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                                    size: 14),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 125,
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              if (_sortBy == 'unitPrice') {
                                                _sortAscending = !_sortAscending;
                                              } else {
                                                _sortBy = 'unitPrice';
                                                _sortAscending = false;
                                              }
                                            }),
                                            child: Row(
                                              children: [
                                                Text(AppLocalizations.of(context)!.unitPrice),
                                                if (_sortBy == 'unitPrice')
                                                  Icon(
                                                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                                    size: 14),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 125,
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              if (_sortBy == 'totalAmount') {
                                                _sortAscending = !_sortAscending;
                                              } else {
                                                _sortBy = 'totalAmount';
                                                _sortAscending = false;
                                              }
                                            }),
                                            child: Row(
                                              children: [
                                                Text(AppLocalizations.of(context)!.totalPrice),
                                                if (_sortBy == 'totalAmount')
                                                  Icon(
                                                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                                    size: 14),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 125,
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              if (_sortBy == 'date') {
                                                _sortAscending = !_sortAscending;
                                              } else {
                                                _sortBy = 'date';
                                                _sortAscending = false;
                                              }
                                            }),
                                            child: Row(
                                              children: [
                                                Text(AppLocalizations.of(context)!.date),
                                                if (_sortBy == 'date')
                                                  Icon(
                                                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                                    size: 14),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 125,
                                          child: Text(AppLocalizations.of(context)!.requester),
                                        ),
                                      ),
                                      DataColumn(
                                        label: GestureDetector(
                                          onTap: () => setState(() {
                                            if (_sortBy == 'status') {
                                              _sortAscending = !_sortAscending;
                                            } else {
                                              _sortBy = 'status';
                                              _sortAscending = false;
                                            }
                                          }),
                                          child: Row(
                                            children: [
                                              Text(AppLocalizations.of(context)!
                                                  .status),
                                              if (_sortBy == 'status')
                                                Icon(
                                                    _sortAscending
                                                        ? Icons.arrow_upward
                                                        : Icons.arrow_downward,
                                                    size: 14),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataColumn(label: Text('')),
                                    ],
                                    rows: paginatedProductRows.map((row) {
                                      final order = row['order'];
                                      final product = row['product'];

                                      if (product == null) {
                                        return DataRow(cells: [
                                          DataCell(Text(order.id.toString())),
                                          DataCell(Text(_safeString(order.title ?? ''))),
                                          DataCell(const Text('-')),
                                          DataCell(const Text('-')),
                                          DataCell(const Text('-')),
                                          DataCell(const Text('-')),
                                          DataCell(const Text('-')),
                                          DataCell(Text(order.startDate != null ? DateFormat('yyyy-MM-dd').format(order.startDate!) : '-')),
                                          DataCell(Text(_getRequesterName(order, userController))),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: order.status == 'approved'
                                                    ? const Color.fromARGB(255, 233, 236, 233).withOpacity(0.2)
                                                    : order.status == 'rejected'
                                                        ? Colors.red[400]
                                                        : Colors.orange.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _localizedStatus(context, order.status),
                                                style: TextStyle(
                                                  color: order.status == 'approved'
                                                      ? const Color.fromARGB(255, 255, 255, 255)
                                                      : order.status == 'rejected'
                                                          ? Colors.white
                                                          : Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), onPressed: () => _showOrderDetailsDialog(context, order, userController))),
                                        ]);
                                      }

                                      final unitPrice = product.unitPrice ?? product.price ?? 0;
                                      final quantity = product.quantity ?? 0;
                                      final totalAmount = (quantity is int ? quantity.toDouble() : quantity as double) * (unitPrice is int ? unitPrice.toDouble() : unitPrice as double);

                                      return DataRow(cells: [
                                        DataCell(Text(order.id.toString())),
                                        DataCell(Text(_safeString(order.title ?? ''))),
                                        DataCell(Text(_safeString(product.product ?? ''))),
                                        DataCell(Text(_safeString(product.supplier ?? '-'))),
                                        DataCell(Text(quantity.toString())),
                                        DataCell(Text(unitPrice.toString())),
                                        DataCell(Text(totalAmount.toStringAsFixed(2) + (_currencySymbol(order.currency).isNotEmpty ? ' ' + _currencySymbol(order.currency) : ''))),
                                        DataCell(Text(order.startDate != null ? DateFormat('yyyy-MM-dd').format(order.startDate!) : '-')),
                                        DataCell(Text(_getRequesterName(order, userController))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: order.status == 'approved'
                                                  ? Colors.green
                                                  : order.status == 'rejected'
                                                    ? Colors.red[400]
                                                    : Colors.orange.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _localizedStatus(context, order.status),
                                              style: TextStyle(
                                                  color: order.status == 'approved'
                                                    ? Colors.white
                                                    : order.status == 'rejected'
                                                      ? Colors.white
                                                      : Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), onPressed: () => _showOrderDetailsDialog(context, order, userController))),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: _currentPage > 1
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),
                                  Text('Page $_currentPage of $totalPages'),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: _currentPage < totalPages
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportOrdersToExcel(List orders) async {
    // Build excel file with same columns as the datatable
    try {
      // reapply currency filter just in case caller passed unfiltered list
      if (_selectedCurrency != null && _selectedCurrency!.isNotEmpty) {
        orders = orders
            .where((o) => (o.currency ?? '').toString().trim() == _selectedCurrency)
            .toList();
      }
      if (orders.isEmpty) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.noOrdersToExportForSelectedRange)));
        return;
      }

      final excel = ex.Excel.createExcel();
      final sheetName = AppLocalizations.of(context)!.poDashboardTitle;
      final sheet = excel[sheetName];
      excel.setDefaultSheet(sheetName);

      // Header row (styled)
      final headerStyle = ex.CellStyle(
          bold: true, backgroundColorHex: "#6A1B9A", fontColorHex: "#FFFFFF");
      final idCellStyle = ex.CellStyle(
          bold: true, backgroundColorHex: "#EDE7F6", fontColorHex: "#4A148C");
      final titleCellStyle = ex.CellStyle(fontColorHex: "#1E88E5");

      final loc = AppLocalizations.of(context)!;
      sheet.appendRow([
        loc.id,
        loc.department,
        loc.currency,
        loc.product,
        loc.supplier,
        loc.quantity,
        loc.unitPrice,
        loc.totalPrice,
        loc.date,
        loc.requester,
        loc.status,
      ]);

      // Apply header style and set column widths for readability
      for (var c = 0; c < 11; c++) {
        final cell = sheet
            .cell(ex.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
        cell.cellStyle = headerStyle;
      }
      // Override ID and Title header styles for improved readability
      sheet
          .cell(ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .cellStyle = idCellStyle;
      sheet
          .cell(ex.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .cellStyle = titleCellStyle;
      // Set some reasonable column widths
      sheet.setColWidth(0, 8); // ID
      sheet.setColWidth(1, 30); // Title
      sheet.setColWidth(2, 10); // Currency
      sheet.setColWidth(3, 30); // Product
      sheet.setColWidth(4, 20); // Supplier
      sheet.setColWidth(5, 10); // Quantity
      sheet.setColWidth(6, 12); // Unit Price
      sheet.setColWidth(7, 14); // Total Amount
      sheet.setColWidth(8, 12); // Date
      sheet.setColWidth(9, 18); // Requester
      sheet.setColWidth(10, 12); // Status

      for (var order in orders) {
        final products = order.products;
        final orderDate = order.startDate != null
            ? DateFormat('yyyy-MM-dd').format(order.startDate!)
            : '-';
        // Determine department name to export. Prefer explicit field on order (parsed
        // by the model); if missing, fall back to currently selected department
        // filter or try to resolve from the requester user's department.
        String deptName = '';
        try {
          if (order.department != null &&
              order.department.toString().trim().isNotEmpty) {
            deptName = order.department.toString();
          } else if (_selectedDepartment != null &&
              _selectedDepartment!.isNotEmpty) {
            // manually search to avoid null-returning orElse closure
            Department? deptObj;
            for (var d
                in context.read<DepartmentController>().departments) {
              if (d.id?.toString() == _selectedDepartment) {
                deptObj = d;
                break;
              }
            }
            if (deptObj != null) deptName = deptObj.name;
          } else {
            // last-chance: lookup via the requester user's department id
            final uid = order.requestedByUser;
            if (uid != null) {
              User? user;
              for (var u in context.read<UserController>().users) {
                if (u.id == uid) {
                  user = u;
                  break;
                }
              }
              if (user != null && user.depId != null) {
                Department? deptObj;
                for (var d
                    in context.read<DepartmentController>().departments) {
                  if (d.id == user.depId) {
                    deptObj = d;
                    break;
                  }
                }
                if (deptObj != null) deptName = deptObj.name;
              }
            }
          }
        } catch (_) {
          deptName = '';
        }

        if (products == null || products.isEmpty) {
          // Single row when no products
          final currSym = _currencySymbol(order.currency);
          sheet.appendRow([
            order.id?.toString() ?? '-',
            deptName,
            order.currency?.toString() ?? '',
            '-', // Product
            '-', // Supplier
            0, // Quantity
            currSym + '0', // Unit Price
            currSym + '0.0', // Total Amount
            orderDate,
            _getRequesterName(order, context.read<UserController>()),
            _localizedStatus(context, order.status),
          ]);
        } else {
          for (var product in products) {
            final unitPrice = product.unitPrice ?? product.price ?? 0;
            final quantity = product.quantity ?? 0;
            final totalAmount =
                ((quantity is int ? quantity.toDouble() : quantity as double) *
                    (unitPrice is int
                        ? unitPrice.toDouble()
                        : unitPrice as double));
            final currSym = _currencySymbol(order.currency);
            // Each product line repeats the PO ID (dept, product rows)
            sheet.appendRow([
              order.id?.toString() ?? '-',
              deptName,
              order.currency?.toString() ?? '',
              product.product?.toString() ?? '-',
              product.supplier?.toString() ?? '-',
              quantity, // numeric
              currSym + unitPrice.toString(),
              currSym + totalAmount.toString(),
              orderDate,
              _getRequesterName(order, context.read<UserController>()),
              _localizedStatus(context, order.status),
            ]);
          }
        }
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) throw Exception('Failed to encode Excel file');

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'PO-Export-$timestamp.xlsx';

      // Use platform-specific saver (web triggers download, others save to Documents)
      final saved = await saveFile(fileBytes, fileName);

      if (mounted) {
        if (saved == 'downloaded') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.downloadedFile(fileName))));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(loc.exportedToPath(saved)),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                await OpenFile.open(saved);
              },
            ),
          ));
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context)!.exportFailed(e.toString()))));
    }
  }

  void _resetToInitial() {
    setState(() {
      _searchCtrl.clear();
      _currentPage = 1;
      _sortBy = 'id';
      _sortAscending = false;
      _selectedSupplier = null;
      _selectedFamily = null;
      _selectedSubFamily = null;
      _selectedCurrency = null;
      _startDate = null;
      _endDate = null;
    });
    try {
      _applySharedFilters();
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
}