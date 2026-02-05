import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:excel/excel.dart' as ex;
import 'package:open_file/open_file.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/supplier_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/reset_notifier.dart';
import 'package:flutter_application_1/models/user_model.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_application_1/widgets/standard_header.dart';
import 'package:flutter_application_1/utils/file_download.dart' show saveFile;

class PurchaseDashboardPage extends StatefulWidget {
  const PurchaseDashboardPage({super.key});

  @override
  State<PurchaseDashboardPage> createState() => _PurchaseDashboardPageState();
}

class _PurchaseDashboardPageState extends State<PurchaseDashboardPage> with WidgetsBindingObserver {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load orders immediately on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final poController = context.read<PurchaseOrderController>();
      poController.fetchOrders();
      _startAutoRefresh();

      // Register reset listener
      final resetNotifier = Provider.of<ResetNotifier>(context, listen: false);
      resetNotifier.addListener(() {
        final target = resetNotifier.lastTarget;
        if (target == 'PO Dashboard') {
          _resetToInitial();
          resetNotifier.clear();
        }
      });
    });
  }

  void _startAutoRefresh() {
    // Refresh purchase orders every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        context.read<PurchaseOrderController>().fetchOrders();
      }
    });
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh orders when returning to this screen
      context.read<PurchaseOrderController>().fetchOrders();
    }
  }

  String _safeString(String? value) => value ?? '';

  String _currencySymbol(String? currencyRaw) {
    if (currencyRaw == null || currencyRaw.isEmpty) return '';
    final code = currencyRaw.toUpperCase();
    final Map<String, String> codeToSymbol = {'USD': '\$', 'EUR': '€', 'TND': 'DT', 'DZD': 'DT'};
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

  void _showOrderDetailsDialog(BuildContext context, dynamic order, UserController userController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        AppLocalizations.of(context)!.viewPurchaseOrder(order.id),
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
                        _buildInfoRow(AppLocalizations.of(context)!.id, order.id.toString()),
                        _buildInfoRow(AppLocalizations.of(context)!.title, _safeString(order.title)),
                        _buildInfoRow(
                          AppLocalizations.of(context)!.date,
                          order.startDate != null
                              ? DateFormat('yyyy-MM-dd').format(order.startDate!)
                              : '-',
                        ),
                        _buildInfoRow(
                          AppLocalizations.of(context)!.requester,
                          _getRequesterName(order, userController),
                        ),
                        _buildStatusRow(AppLocalizations.of(context)!.status, _localizedStatus(context, order.status)),
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
                              final unitPrice = product.unitPrice ?? product.price ?? 0;
                              final quantity = product.quantity ?? 0;
                              final totalAmount = (quantity is int ? quantity.toDouble() : quantity as double) *
                                  (unitPrice is int ? unitPrice.toDouble() : unitPrice as double);
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(AppLocalizations.of(context)!.product, _safeString(product.product)),
                                    _buildInfoRow(AppLocalizations.of(context)!.supplier, _safeString(product.supplier)),
                                    _buildInfoRow(AppLocalizations.of(context)!.unitPrice, unitPrice.toString()),
                                    _buildInfoRow(AppLocalizations.of(context)!.quantity, quantity.toString()),
                                    _buildInfoRow(AppLocalizations.of(context)!.totalPrice, totalAmount.toStringAsFixed(2) + (_currencySymbol(order.currency).isNotEmpty ? ' ' + _currencySymbol(order.currency) : '')),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(AppLocalizations.of(context)!.close, style: const TextStyle(color: Colors.white)),
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
          if (f != null && f.toString().trim().isNotEmpty) families.add(f.toString().trim());
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
            if (family == null || (f != null && f.toString().trim() == family)) {
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
          comparison = (dateA ?? DateTime(2000)).compareTo(dateB ?? DateTime(2000));
          break;
        case 'status':
          comparison = _safeString(a.status).compareTo(_safeString(b.status));
          break;
        case 'title':
          comparison = _safeString(a.title).compareTo(_safeString(b.title));
          break;
        case 'product':
          // Sort by product name from first product
          final prodA = a.products?.isNotEmpty == true ? _safeString(a.products!.first.product) : '';
          final prodB = b.products?.isNotEmpty == true ? _safeString(b.products!.first.product) : '';
          comparison = prodA.compareTo(prodB);
          break;
        case 'supplier':
          // Sort by supplier from first product
          final supA = a.products?.isNotEmpty == true ? _safeString(a.products!.first.supplier) : '';
          final supB = b.products?.isNotEmpty == true ? _safeString(b.products!.first.supplier) : '';
          comparison = supA.compareTo(supB);
          break;
        case 'quantity':
          final qtyA = a.products?.isNotEmpty == true ? a.products!.first.quantity ?? 0 : 0;
          final qtyB = b.products?.isNotEmpty == true ? b.products!.first.quantity ?? 0 : 0;
          comparison = qtyA.compareTo(qtyB);
          break;
        case 'totalAmount':
          // Calculate total amount for first product
          final amountA = a.products?.isNotEmpty == true 
              ? ((a.products!.first.quantity ?? 0) * (a.products!.first.unitPrice ?? a.products!.first.price ?? 0)).toDouble()
              : 0.0;
          final amountB = b.products?.isNotEmpty == true
              ? ((b.products!.first.quantity ?? 0) * (b.products!.first.unitPrice ?? b.products!.first.price ?? 0)).toDouble()
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

    if (!_initialLoadDone && poController.orders.isEmpty && !poController.isLoading) {
      _initialLoadDone = true;
      Future.microtask(() {
        poController.fetchOrders();
        supplierController.fetchSuppliers();
      });
    }

    // Filter approved orders only
    final approvedOrders = poController.orders
        .where((order) => order.status == 'approved')
        .toList();

    // Get suppliers list for dropdown
    // Combine suppliers present in approved orders with suppliers from SupplierController
    final controllerApproved = supplierController.suppliers
        .where((s) => (s.approvalStatus ?? '').toLowerCase() == 'approved' && (s.name?.isNotEmpty ?? false))
        .map((s) => s.name!.trim())
        .toSet();
    final ordersSuppliers = _getSuppliers(approvedOrders).toSet();
    final suppliers = (controllerApproved..addAll(ordersSuppliers)).toList()..sort();

    // Families and Subfamilies for filters
    final families = _getFamilies(approvedOrders);
    final subfamilies = _getSubFamilies(approvedOrders, _selectedFamily);

    // Apply filters (search, supplier and date range)
    final filter = _searchCtrl.text.toLowerCase();
    final filteredOrders = approvedOrders.where((order) {
      // Filter by search text
      final title = _safeString(order.title).toLowerCase();
      final status = _safeString(order.status).toLowerCase();
      final id = order.id.toString().toLowerCase();
      if (!title.contains(filter) && !status.contains(filter) && !id.contains(filter)) {
        return false;
      }

      // Filter by supplier if selected
      if (_selectedSupplier != null && _selectedSupplier!.isNotEmpty) {
        final hasSupplier = order.products?.any((p) => p.supplier == _selectedSupplier) ?? false;
        if (!hasSupplier) return false;
      }

      // Filter by family if selected
      if (_selectedFamily != null && _selectedFamily!.isNotEmpty) {
        final hasFamily = order.products?.any((p) => (p.family ?? '').toString().trim() == _selectedFamily) ?? false;
        if (!hasFamily) return false;
      }

      // Filter by subfamily if selected
      if (_selectedSubFamily != null && _selectedSubFamily!.isNotEmpty) {
        final hasSub = order.products?.any((p) => (p.subFamily ?? '').toString().trim() == _selectedSubFamily) ?? false;
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

    // Apply sorting
    _sortOrders(filteredOrders, _sortBy, _sortAscending);

    // Calculate pagination
    final totalPages = (filteredOrders.isEmpty) ? 1 : (filteredOrders.length / _itemsPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage) > filteredOrders.length
        ? filteredOrders.length
        : (startIndex + _itemsPerPage);
    final paginatedOrders = filteredOrders.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: StandardHeader(title: AppLocalizations.of(context)!.poDashboardTitle),
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          // Search and Filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                // Search bar
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.search,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF7F3FF),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _currentPage = 1);
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() => _currentPage = 1),
                  ),
                ),
                const SizedBox(width: 8),

                // Supplier Filter
                Expanded(
                  flex: 1,
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _selectedSupplier,
                    hint: Text(AppLocalizations.of(context)!.selectSupplier, style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(AppLocalizations.of(context)!.allSuppliers, style: const TextStyle(fontSize: 13)),
                      ),
                      ...suppliers.map((supplier) =>
                          DropdownMenuItem<String>(
                            value: supplier,
                            child: Text(supplier, style: const TextStyle(fontSize: 13)),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSupplier = value;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Family Filter
                Expanded(
                  flex: 1,
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _selectedFamily,
                    hint: Text(AppLocalizations.of(context)!.familyLabel, style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(AppLocalizations.of(context)!.allFamilies, style: const TextStyle(fontSize: 13)),
                      ),
                      ...families.map((f) => DropdownMenuItem<String>(value: f, child: Text(f, style: const TextStyle(fontSize: 13)))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFamily = value;
                        _selectedSubFamily = null; // reset subfamily when family changes
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Subfamily Filter
                Expanded(
                  flex: 1,
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _selectedSubFamily,
                    hint: Text(AppLocalizations.of(context)!.subfamilyLabel, style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(AppLocalizations.of(context)!.allSubfamilies, style: const TextStyle(fontSize: 13)),
                      ),
                      ...subfamilies.map((sf) => DropdownMenuItem<String>(value: sf, child: Text(sf, style: const TextStyle(fontSize: 13)))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSubFamily = value;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Start Date Filter
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        helpText: AppLocalizations.of(context)!.selectFromDate,
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                          _currentPage = 1;
                        });

                        // Automatically open To Date picker after selecting From Date
                        final endInitial = (_endDate != null && !_endDate!.isBefore(picked)) ? _endDate! : picked;
                        final pickedEnd = await showDatePicker(
                          context: context,
                          initialDate: endInitial,
                          firstDate: picked,
                          lastDate: DateTime.now(),
                          helpText: 'Select To Date',
                        );
                        if (pickedEnd != null) {
                          setState(() {
                            _endDate = pickedEnd;
                            _currentPage = 1;
                          });
                        }
                      }
                    },
                    child: Text(
                      _startDate != null 
                          ? AppLocalizations.of(context)!.fromPrefix + DateFormat('yyyy-MM-dd').format(_startDate!)
                          : AppLocalizations.of(context)!.fromDate,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // End Date Filter
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                          helpText: AppLocalizations.of(context)!.selectToDate,
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                          _currentPage = 1;
                        });
                      }
                    },
                    child: Text(
                      _endDate != null
                          ? AppLocalizations.of(context)!.toPrefix + DateFormat('yyyy-MM-dd').format(_endDate!)
                          : AppLocalizations.of(context)!.toDate,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Export button (exports current filtered PO list)
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {
                        _currentPage = 1;
                        _selectedSupplier = null;
                        _selectedFamily = null;
                        _selectedSubFamily = null;
                        _startDate = null;
                        _endDate = null;
                        _sortBy = 'id';
                        _sortAscending = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.file_download, size: 18),
                    label: Text(AppLocalizations.of(context)!.exportExcel),
                    onPressed: () async {
                      final ordersToExport = filteredOrders;
                      if (ordersToExport.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.noOrdersToExportForCurrentFilters)));
                        return;
                      }

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(AppLocalizations.of(context)!.exportConfirmTitle(ordersToExport.length)),
                          content: Text(AppLocalizations.of(context)!.exportConfirmContent(ordersToExport.length)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(AppLocalizations.of(context)!.cancel)),
                            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(AppLocalizations.of(context)!.export)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),

                // Reset button
                
              ],
            ),
          ),

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
                                onPressed: () => poController.fetchOrders(),
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
                                    columnSpacing: 97,
                                    horizontalMargin: 12,
                                    columns: [
                                    DataColumn(
                                      label: GestureDetector(
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
                                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: GestureDetector(
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
                                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: GestureDetector(
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
                                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: GestureDetector(
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
                                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: GestureDetector(
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
                                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: GestureDetector(
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
                                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: GestureDetector(
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
                                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: GestureDetector(
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
                                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataColumn(label: Text(AppLocalizations.of(context)!.requester)),
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
                                            Text(AppLocalizations.of(context)!.status),
                                            if (_sortBy == 'status')
                                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataColumn(label: Text('')),
                                  ],
                                  rows: paginatedOrders.expand((order) {
                                    // Create a row for each product in the order
                                    if (order.products == null || order.products!.isEmpty) {
                                      // If no products, show one empty row for the order
                                      return [
                                        DataRow(cells: [
                                          DataCell(Text(order.id.toString())),
                                          DataCell(Text(_safeString(order.title ?? ''))),
                                          DataCell(const Text('-')),
                                          DataCell(const Text('-')),
                                          DataCell(const Text('-')),
                                          DataCell(const Text('-')),
                                          DataCell(const Text('-')),
                                          DataCell(Text(order.startDate != null
                                              ? DateFormat('yyyy-MM-dd').format(order.startDate!)
                                              : '-')),
                                          DataCell(Text(_getRequesterName(order, userController))),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: order.status == 'approved'
                                                    ? Colors.green.withOpacity(0.2)
                                                    : Colors.orange.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _localizedStatus(context, order.status),
                                                style: TextStyle(
                                                  color: order.status == 'approved' ? Colors.green : Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(Icons.visibility, color: Colors.blue),
                                              onPressed: () => _showOrderDetailsDialog(context, order, userController),
                                            ),
                                          ),
                                        ]),
                                      ];
                                    }
                                    
                                    return order.products!.map((product) {
                                      final unitPrice = product.unitPrice ?? product.price ?? 0;
                                      final quantity = product.quantity ?? 0;
                                      final totalAmount = (quantity is int ? quantity.toDouble() : quantity as double) * 
                                          (unitPrice is int ? unitPrice.toDouble() : unitPrice as double);
                                      
                                      return DataRow(cells: [
                                        DataCell(Text(order.id.toString())),
                                        DataCell(Text(_safeString(order.title ?? ''))),
                                        DataCell(Text(_safeString(product.product ?? ''))),
                                        DataCell(Text(_safeString(product.supplier ?? '-'))),
                                        DataCell(Text(quantity.toString())),
                                        DataCell(Text(unitPrice.toString())),
                                        DataCell(Text(totalAmount.toStringAsFixed(2) + (_currencySymbol(order.currency).isNotEmpty ? ' ' + _currencySymbol(order.currency) : ''))),
                                        DataCell(Text(order.startDate != null
                                            ? DateFormat('yyyy-MM-dd').format(order.startDate!)
                                            : '-')),
                                        DataCell(Text(_getRequesterName(order, userController))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: order.status == 'approved'
                                                  ? Colors.green.withOpacity(0.2)
                                                  : Colors.orange.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                                _localizedStatus(context, order.status),
                                              style: TextStyle(
                                                color: order.status == 'approved' ? Colors.green : Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.visibility, color: Colors.blue),
                                            onPressed: () => _showOrderDetailsDialog(context, order, userController),
                                          ),
                                        ),
                                      ]);
                                    }).toList();
                                  }).toList(),                                  ),                                ),
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
      if (orders.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.noOrdersToExportForSelectedRange)));
        return;
      }

      final excel = ex.Excel.createExcel();
      final sheet = excel[AppLocalizations.of(context)!.poDashboardTitle];

      // Header row (styled)
      final headerStyle = ex.CellStyle(bold: true, backgroundColorHex: "#6A1B9A", fontColorHex: "#FFFFFF");
      final idCellStyle = ex.CellStyle(bold: true, backgroundColorHex: "#EDE7F6", fontColorHex: "#4A148C");
      final titleCellStyle = ex.CellStyle(fontColorHex: "#1E88E5");

      final loc = AppLocalizations.of(context)!;
      sheet.appendRow([
        loc.id,
        loc.title,
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
      for (var c = 0; c < 10; c++) {
        final cell = sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
        cell.cellStyle = headerStyle;
      }
      // Override ID and Title header styles for improved readability
      sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = idCellStyle;
      sheet.cell(ex.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).cellStyle = titleCellStyle;
      // Set some reasonable column widths
      sheet.setColWidth(0, 8); // ID
      sheet.setColWidth(1, 30); // Title
      sheet.setColWidth(2, 30); // Product
      sheet.setColWidth(3, 20); // Supplier
      sheet.setColWidth(4, 10); // Quantity
      sheet.setColWidth(5, 12); // Unit Price
      sheet.setColWidth(6, 14); // Total Amount
      sheet.setColWidth(7, 12); // Date
      sheet.setColWidth(8, 18); // Requester
      sheet.setColWidth(9, 12); // Status



      for (var order in orders) {
        final products = order.products;
        final orderDate = order.startDate != null ? DateFormat('yyyy-MM-dd').format(order.startDate!) : '-';

        if (products == null || products.isEmpty) {
          // Single row when no products
          sheet.appendRow([
            order.id?.toString() ?? '-',
            (order.title?.toString() ?? '-'),
            '-', // Product
            '-', // Supplier
            0, // Quantity
            0, // Unit Price
            0.0, // Total Amount
            orderDate,
            _getRequesterName(order, context.read<UserController>()),
            _localizedStatus(context, order.status),
          ]);
        } else {
          for (var product in products) {
            final unitPrice = product.unitPrice ?? product.price ?? 0;
            final quantity = product.quantity ?? 0;
            final totalAmount = ((quantity is int ? quantity.toDouble() : quantity as double) * (unitPrice is int ? unitPrice.toDouble() : unitPrice as double));
            // Each product line repeats the PO ID and Title (previous behavior)
            sheet.appendRow([
              order.id?.toString() ?? '-',
              (order.title?.toString() ?? '-'),
              product.product?.toString() ?? '-',
              product.supplier?.toString() ?? '-',
              quantity, // numeric
              unitPrice, // numeric
              totalAmount, // numeric
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.downloadedFile(fileName))));
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.exportFailed(e.toString()))));
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
      _startDate = null;
      _endDate = null;
    });
    try {
      context.read<PurchaseOrderController>().fetchOrders();
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
}
