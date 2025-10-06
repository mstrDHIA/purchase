import 'package:flutter_application_1/screens/Purchase%20order/Edit_purchase_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/view_purchase_screen.dart';
import 'package:flutter_application_1/models/purchase_order.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Purchase%20order/purchase_form_screen.dart';
// import 'package:flutter_application_1/screens/Purchase%20order/view_purchase_screen.dart';
import 'package:intl/intl.dart';

class PurchaseOrderPage extends StatelessWidget {
  const PurchaseOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PurchaseOrderController(),
      child: const _PurchaseOrderPageBody(),
    );
  }
}

class _PurchaseOrderPageBody extends StatefulWidget {
  const _PurchaseOrderPageBody();

  @override
  State<_PurchaseOrderPageBody> createState() => _PurchaseOrderPageBodyState();
}

class _PurchaseOrderPageBodyState extends State<_PurchaseOrderPageBody> {
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String? _priorityFilter;
  String? _statusFilter;
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseOrderController>(context, listen: false).fetchOrders();
    });
  }

  List<Map<String, dynamic>> _filteredAndSortedOrders(List orders) {
  List<Map<String, dynamic>> mapped = orders
    .map((order) {
      DateTime parseDate(dynamic value) {
        if (value is DateTime) return value;
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (_) {
            return DateTime.now();
          }
        }
        return DateTime.now();
      }
      return {
        'id': order.id?.toString() ?? '',
        'actionCreatedBy': order.requestedByUser?.toString() ?? '',
        'dateSubmitted': parseDate(order.startDate),
        'dueDate': parseDate(order.endDate),
        'priority': order.priority ?? '',
        'status': order.status ?? '',
        'original': order,
      };
    })
    .toList();

  // Filtering
  if (_priorityFilter != null) {
    mapped = mapped.where((order) => order['priority'].toString().toLowerCase() == _priorityFilter!.toLowerCase()).toList();
  }
  if (_statusFilter != null) {
    mapped = mapped.where((order) => order['status'].toString().toLowerCase() == _statusFilter!.toLowerCase()).toList();
  }
  if (_selectedSubmissionDate != null) {
    mapped = mapped.where((order) =>
        order['dateSubmitted'].year == _selectedSubmissionDate!.year &&
        order['dateSubmitted'].month == _selectedSubmissionDate!.month &&
        order['dateSubmitted'].day == _selectedSubmissionDate!.day).toList();
  }
  if (_selectedDueDate != null) {
    mapped = mapped.where((order) =>
        order['dueDate'].year == _selectedDueDate!.year &&
        order['dueDate'].month == _selectedDueDate!.month &&
        order['dueDate'].day == _selectedDueDate!.day).toList();
  }

  // Sorting
  if (_sortColumnIndex != null) {
    String sortKey = '';
    switch (_sortColumnIndex) {
      case 0:
        sortKey = 'id';
        break;
      case 1:
        sortKey = 'actionCreatedBy';
        break;
      case 2:
        sortKey = 'dateSubmitted';
        break;
      case 3:
        sortKey = 'dueDate';
        break;
      case 4:
        sortKey = 'priority';
        break;
      case 5:
        sortKey = 'status';
        break;
    }

    mapped.sort((a, b) {
      dynamic aValue = a[sortKey];
      dynamic bValue = b[sortKey];
      if (aValue is String && bValue is String) {
        return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      }
      return 0;
    });
  }

  return mapped;
}

  void _sort<T>(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isSubmissionDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isSubmissionDate) {
          _selectedSubmissionDate = picked;
        } else {
          _selectedDueDate = picked;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _priorityFilter = null;
      _statusFilter = null;
      _selectedSubmissionDate = null;
      _selectedDueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseOrderController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error != null) {
          return Center(child: Text('Error: ${controller.error}'));
        }
        final dataSource = _PurchaseOrderDataSource(
          _filteredAndSortedOrders(controller.orders),
          _dateFormat,
          onView: viewPurchaseOrder,
          onEdit: editPurchaseOrder,
          onDelete: deletePurchaseOrder,
        );
        return Scaffold(
          appBar: AppBar(
            title: const Text('Purchase Orders'),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  final controller = Provider.of<PurchaseOrderController>(context, listen: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                        value: controller,
                        child: PurchaseOrderForm(
                          initialOrder: const <String, dynamic>{},
                          onSave: (newOrder) {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add PO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              _buildFiltersRow(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: PaginatedDataTable(
                      header: const Text('Purchase Orders Table'),
                      rowsPerPage: _rowsPerPage,
                      onRowsPerPageChanged: (r) {
                        if (r != null) {
                          setState(() {
                            _rowsPerPage = r;
                          });
                        }
                      },
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      columnSpacing: 180, 
                      horizontalMargin: 16, 
                      columns: [
                        DataColumn(
                            label: const Text('ID'),
                            onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                        DataColumn(
                            label: const Text('Created by'),
                            onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                        DataColumn(
                            label: const Text('Date submitted'),
                            onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                        DataColumn(
                            label: const Text('Due date'),
                            onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                        DataColumn(
                            label: const Text('Priority'),
                            onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                        DataColumn(
                            label: const Text('Status'),
                            onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                        const DataColumn(label: Text('Actions')),
                      ],
                      source: dataSource,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ...existing code for filters...
          PopupMenuButton<String?>(
            onSelected: (value) {
              setState(() {
                _priorityFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'high', child: Text('high')),
              const PopupMenuItem(value: 'medium', child: Text('medium')),
              const PopupMenuItem(value: 'low', child: Text('low')),
              if (_priorityFilter != null)
                const PopupMenuItem(value: null, child: Text('Clear Priority')),
            ],
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF7F3FF),
                foregroundColor: Colors.deepPurple,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                elevation: 0,
              ),
              onPressed: null,
              child: Row(
                children: [
                  Text(
                    _priorityFilter == null ? 'Filter by Priority' : 'Priority: $_priorityFilter',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String?>(
            onSelected: (value) {
              setState(() {
                _statusFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Pending', child: Text('Pending')),
              const PopupMenuItem(value: 'Approved', child: Text('Approved')),
              const PopupMenuItem(value: 'Rejected', child: Text('Rejected')),
              if (_statusFilter != null)
                const PopupMenuItem(value: null, child: Text('Clear Status')),
            ],
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF7F3FF),
                foregroundColor: Colors.deepPurple,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                elevation: 0,
              ),
              onPressed: null,
              child: Row(
                children: [
                  Text(
                    _statusFilter == null ? 'Filter by Status' : 'Status: $_statusFilter',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF7F3FF),
              foregroundColor: Colors.deepPurple,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () => _selectDate(context, true),
            child: Text(
              _selectedSubmissionDate == null
                  ? 'Filter by Submission Date'
                  : 'Submission: ${_dateFormat.format(_selectedSubmissionDate!)}',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF7F3FF),
              foregroundColor: Colors.deepPurple,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () => _selectDate(context, false),
            child: Text(
              _selectedDueDate == null
                  ? 'Filter by Due Date'
                  : 'Due: ${_dateFormat.format(_selectedDueDate!)}',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Clear Filters',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: implement viewPurchaseOrder, editPurchaseOrder, deletePurchaseOrder if needed
  Future<void> viewPurchaseOrder(Map<String, dynamic> order) async {
    // Utilise l'objet PurchaseOrder réel pour l'affichage
    final purchaseOrder = order['original'];
    final userController = Provider.of<UserController>(context, listen: false);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseOrderView.withProviders(order: purchaseOrder, userController: userController),
      ),
    );
    // Toujours rafraîchir la liste après retour de la page détail
    Provider.of<PurchaseOrderController>(context, listen: false).fetchOrders();
  }

  void editPurchaseOrder(Map<String, dynamic> order) async {
    // Navigation vers la page d'édition dédiée
    final controller = Provider.of<PurchaseOrderController>(context, listen: false);
    // On passe l'objet complet (order['original']) à la page d'édition
    final purchaseOrder = order['original'];
    // On convertit l'objet en Map pour initialOrder
    final initialOrder = purchaseOrder.toJson();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: controller,
          child: EditPurchaseOrder(
            initialOrder: initialOrder,
            onSave: (newOrder) {
              Navigator.pop(context, newOrder);
            },
          ),
        ),
      ),
    );
  }

  void deletePurchaseOrder(Map<String, dynamic> order) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        backgroundColor: const Color(0xFFF7F2FA),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Delete Purchase Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete ${order['id']}?',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF6F4DBF),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed == true) {
      final controller = Provider.of<PurchaseOrderController>(context, listen: false);
      try {
        await controller.deleteOrder(order['id'].toString());
        await controller.fetchOrders();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase order ${order['id']} deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete purchase order: $e')),
        );
      }
    }
  }
}

class _PurchaseOrderDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;
  final DateFormat _dateFormat;
  final Function(Map<String, dynamic>) onView;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  _PurchaseOrderDataSource(
    this._data,
    this._dateFormat, {
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final item = _data[index];
    String formatDateCell(dynamic value) {
      if (value == null) return '-';
      DateTime? dt;
      if (value is DateTime) {
        dt = value;
      } else if (value is String) {
        try {
          dt = DateTime.parse(value);
        } catch (_) {
          return value;
        }
      }
      return dt != null ? _dateFormat.format(dt) : '-';
    }
    return DataRow(
      cells: [
        DataCell(Text(item['id'] ?? '-')),
        DataCell(Text(item['actionCreatedBy'] ?? '-')),
        DataCell(Text(formatDateCell(item['dateSubmitted']))),
        DataCell(Text(formatDateCell(item['dueDate']))),
        DataCell(_buildPriorityChip(item['priority'] ?? '-')),
        DataCell(_buildStatusChip(item['status'] ?? '-')),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined),
              onPressed: () => onView(item),
              tooltip: 'View',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => onEdit(item),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => onDelete(item),
              tooltip: 'Delete',
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildPriorityChip(String priority) {
    final v = priority.toLowerCase();
    Color bgColor;
    if (v == 'low') {
      bgColor = const Color(0xFF64B5F6); // blue
    } else if (v == 'medium') {
      bgColor = const Color(0xFFFFB74D); // orange
    } else if (v == 'high') {
      bgColor = const Color(0xFFE57373); // red
    } else {
      bgColor = Colors.grey;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        constraints: const BoxConstraints(minWidth: 36),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          v,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final v = status.toLowerCase();
    Color bgColor;
    if (v == 'approved') {
      bgColor = const Color(0xFF4CAF50); // green
    } else if (v == 'pending') {
      bgColor = const Color(0xFFFFB74D); // orange
    } else if (v == 'rejected') {
      bgColor = const Color(0xFFEF5350); // red
    } else {
      bgColor = Colors.grey;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        constraints: const BoxConstraints(minWidth: 0),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          v,
          textAlign: TextAlign.center,
          
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}

// Example for ViewPurchasePage
class ViewPurchasePage extends StatelessWidget {
  final Map<String, dynamic> order;
  const ViewPurchasePage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    String formatDateCell(dynamic value) {
      if (value == null) return '-';
      DateTime? dt;
      if (value is DateTime) {
        dt = value;
      } else if (value is String) {
        try {
          dt = DateTime.parse(value);
        } catch (_) {
          return value;
        }
      }
      return dt != null ? dateFormat.format(dt) : '-';
    }
    return Scaffold(
      appBar: AppBar(title: Text('View Purchase Order ${order['id']}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${order['id']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Created by: ${order['actionCreatedBy']}'),
            Text('Date submitted: ${formatDateCell(order['dateSubmitted'])}'),
            Text('Due date: ${formatDateCell(order['dueDate'])}'),
            Text('Priority: ${order['priority']}'),
            Text('Status: ${order['status']}'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
