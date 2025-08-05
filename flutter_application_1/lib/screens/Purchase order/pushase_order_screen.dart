import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Purchase%20order/purchase_form_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/view_purchase_screen.dart';
import 'package:intl/intl.dart';

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  static final List<Map<String, dynamic>> purchaseOrders = [];

  static void addPurchaseOrder(Map<String, dynamic> order) {
    purchaseOrders.add(order);
  }

  @override
  State<PurchaseOrderPage> createState() => PurchaseOrderPageState();
}

class _PurchaseOrderDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;
  final BuildContext _context;
  final DateFormat _dateFormat;
  final Function(Map<String, dynamic>) onView;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  _PurchaseOrderDataSource(
    this._data,
    this._context,
    this._dateFormat, {
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final item = _data[index];
    return DataRow(
      cells: [
        DataCell(Text(item['id']!)),
        DataCell(Text(item['actionCreatedBy']!)),
        DataCell(Text(_dateFormat.format(item['dateSubmitted']))),
        DataCell(Text(_dateFormat.format(item['dueDate']))),
        DataCell(_buildPriorityChip(item['priority']!)),
        DataCell(_buildStatusChip(item['status']!)),
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
    Color color;
    const textColor = Colors.white;
    switch (priority) {
      case 'High':
        color = Colors.red[300]!;
        break;
      case 'Medium':
        color = Colors.orange[300]!;
        break;
      case 'Low':
        color = Colors.green[300]!;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority,
        style: const TextStyle(color: textColor, fontSize: 12),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color textColor = Colors.black;
    switch (status) {
      case 'Pending':
        color = Colors.orange[200]!;
        break;
      case 'Approved':
        color = Colors.green[200]!;
        break;
      case 'Rejected':
        color = Colors.red[200]!;
        break;
      default:
        color = Colors.grey[200]!;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 12),
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

class PurchaseOrderPageState extends State<PurchaseOrderPage> {
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    // Initialiser la liste locale avec les données statiques
    _purchaseOrders = PurchaseOrderPage.purchaseOrders;
  }

  List<Map<String, dynamic>> _purchaseOrders = [];

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  String? _priorityFilter;
  String? _statusFilter;
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedDueDate;

  List<Map<String, dynamic>> get _filteredAndSortedOrders {
    List<Map<String, dynamic>> orders = List.from(_purchaseOrders);

    // Filtres
    if (_priorityFilter != null) {
      orders = orders.where((order) => order['priority'] == _priorityFilter).toList();
    }
    if (_statusFilter != null) {
      orders = orders.where((order) => order['status'] == _statusFilter).toList();
    }
    if (_selectedSubmissionDate != null) {
      orders = orders.where((order) =>
          order['dateSubmitted'].year == _selectedSubmissionDate!.year &&
          order['dateSubmitted'].month == _selectedSubmissionDate!.month &&
          order['dateSubmitted'].day == _selectedSubmissionDate!.day).toList();
    }
    if (_selectedDueDate != null) {
      orders = orders.where((order) =>
          order['dueDate'].year == _selectedDueDate!.year &&
          order['dueDate'].month == _selectedDueDate!.month &&
          order['dueDate'].day == _selectedDueDate!.day).toList();
    }

    // Tri
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

      orders.sort((a, b) {
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

    return orders;
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

  void viewPurchaseOrder(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseOrderView(), // <-- Remplace ici
      ),
    );
  }

  void editPurchaseOrder(Map<String, dynamic> order) async {
    final updatedOrder = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseOrderForm(
          initialOrder: order,
          onSave: (newOrder) {
            Navigator.pop(context, newOrder);
          },
        ),
      ),
    );

    if (updatedOrder != null) {
      setState(() {
        final index = _purchaseOrders.indexWhere((o) => o['id'] == updatedOrder['id']);
        if (index != -1) {
          _purchaseOrders[index] = updatedOrder;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase order ${updatedOrder['id']} updated')),
      );
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18), // <-- padding réduit
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 320, // <-- largeur max réduite
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Delete User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // <-- taille réduite
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete ${order['actionCreatedBy']}?',
                  style: const TextStyle(fontSize: 14), // <-- taille réduite
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
                          fontSize: 14, // <-- taille réduite
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), // <-- padding réduit
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), // <-- taille réduite
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
      setState(() {
        _purchaseOrders.removeWhere((o) => o['id'] == order['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase order ${order['id']} deleted')),
      );
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
    final dataSource = _PurchaseOrderDataSource(
      _filteredAndSortedOrders,
      context,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PurchaseOrderForm(
                    initialOrder: <String, dynamic>{},
                    onSave: (newOrder) {
                      setState(() {
                        _purchaseOrders.add(newOrder);
                      });
                      Navigator.pop(context);
                    },
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
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Filter by Priority
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _priorityFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'High', child: Text('High')),
              const PopupMenuItem(value: 'Medium', child: Text('Medium')),
              const PopupMenuItem(value: 'Low', child: Text('Low')),
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
              onPressed: null, // Désactive le onPressed ici
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
          // Filter by Status
          PopupMenuButton<String>(
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
          // Filter by Submission Date
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
          // Filter by Due Date
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
          // Clear Filters
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
}

// Example for ViewPurchasePage
class ViewPurchasePage extends StatelessWidget {
  final Map<String, dynamic> order;
  const ViewPurchasePage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
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
            Text('Date submitted: ${dateFormat.format(order['dateSubmitted'])}'),
            Text('Due date: ${dateFormat.format(order['dueDate'])}'),
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
