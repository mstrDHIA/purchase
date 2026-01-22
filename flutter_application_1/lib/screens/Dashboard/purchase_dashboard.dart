import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/supplier_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import '../../l10n/app_localizations.dart';

class PurchaseDashboardPage extends StatefulWidget {
  const PurchaseDashboardPage({super.key});

  @override
  State<PurchaseDashboardPage> createState() => _PurchaseDashboardPageState();
}

class _PurchaseDashboardPageState extends State<PurchaseDashboardPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _initialLoadDone = false;
  
  // Pagination state
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  
  // Sorting state
  String _sortBy = 'id'; // Default sort by ID
  bool _sortAscending = false; // Default descending

  // Filter states
  String? _selectedSupplier;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
  }

  String _safeString(String? value) => value ?? '';

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
                        'Purchase Order #${order.id}',
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
                        _buildInfoRow('Order ID', order.id.toString()),
                        _buildInfoRow('Title', _safeString(order.title)),
                        _buildInfoRow(
                          'Date',
                          order.startDate != null
                              ? DateFormat('yyyy-MM-dd').format(order.startDate!)
                              : '-',
                        ),
                        _buildInfoRow(
                          'Requester',
                          userController.currentUser.id == order.requestedByUser
                              ? userController.currentUser.username ?? '-'
                              : '-',
                        ),
                        _buildStatusRow('Status', order.status ?? '-'),
                        const SizedBox(height: 20),
                        
                        // Products Section
                        const Text(
                          'Products',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        if (order.products == null || order.products!.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No products',
                              style: TextStyle(color: Colors.grey),
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
                                    _buildInfoRow('Product', _safeString(product.product)),
                                    _buildInfoRow('Supplier', _safeString(product.supplier)),
                                    _buildInfoRow('Unit Price', unitPrice.toString()),
                                    _buildInfoRow('Quantity', quantity.toString()),
                                    _buildInfoRow('Total Amount', totalAmount.toStringAsFixed(2)),
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
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
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
    final supplierController = context.read<SupplierController>();
    final userController = context.read<UserController>();

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
    final suppliers = _getSuppliers(approvedOrders);

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
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Purchase Dashboard',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
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
                    hint: const Text('Select Supplier', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Suppliers', style: TextStyle(fontSize: 13)),
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
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                          _currentPage = 1;
                        });
                      }
                    },
                    child: Text(
                      _startDate != null 
                          ? DateFormat('yyyy-MM-dd').format(_startDate!)
                          : 'From Date',
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
                          ? DateFormat('yyyy-MM-dd').format(_endDate!)
                          : 'To Date',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Reset button
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {
                        _currentPage = 1;
                        _selectedSupplier = null;
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
                    child: const Icon(Icons.refresh, size: 18),
                  ),
                ),
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
                                            const Text('Title'),
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
                                            const Text('Product'),
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
                                            const Text('Quantity'),
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
                                            const Text('Unit Price'),
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
                                            const Text('Total Amount'),
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
                                            const Text('Date'),
                                            if (_sortBy == 'date')
                                              Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataColumn(label: const Text('Requester')),
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
                                          DataCell(Text(userController.currentUser.id == order.requestedByUser
                                              ? userController.currentUser.username ?? '-'
                                              : '-')),
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
                                                order.status ?? '-',
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
                                        DataCell(Text(totalAmount.toStringAsFixed(2))),
                                        DataCell(Text(order.startDate != null
                                            ? DateFormat('yyyy-MM-dd').format(order.startDate!)
                                            : '-')),
                                        DataCell(Text(userController.currentUser.id == order.requestedByUser
                                            ? userController.currentUser.username ?? '-'
                                            : '-')),
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
                                              order.status ?? '-',
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
