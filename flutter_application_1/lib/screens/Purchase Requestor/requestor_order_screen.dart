import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/user_model.dart';
// import 'package:flutter_application_1/screens/Purchase%20Requestor/Request_Edit_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20Requestor/requestor_form_screen.dart';
// import 'package:flutter_application_1/screens/Purchase%20Requestor/request_view_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order_screen.dart' as purchase_order;
// Make sure the above import points to the file where addPurchaseOrder is defined as a top-level function.
import 'package:intl/intl.dart';
import 'package:flutter_application_1/network/purchase_request_network.dart';
import 'package:provider/provider.dart';

class PurchaseRequestPage extends StatefulWidget {
  const PurchaseRequestPage({super.key});

  @override
  State<PurchaseRequestPage> createState() => _PurchaseRequestPageState();
}

class _PurchaseRequestDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;
  // ignore: unused_field
  final BuildContext _context;
  final DateFormat _dateFormat;
  final Function(Map<String, dynamic>) onView;
  // final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  _PurchaseRequestDataSource(
    this._data,
    this._context,
    this._dateFormat, {
    required this.onView,
    // required this.onEdit,
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
              onPressed: () {
                // Navigator.push(
                //   _context,
                //   MaterialPageRoute(
                //     builder: (context) => PurchaseRequestView(
                //       order: item, // Passe la ligne sélectionnée ici
                //       onSave: (_) {},
                //     ),
                //   ),
                // );
              },
              tooltip: 'View',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // Navigator.push(
                //   _context,
                //   MaterialPageRoute(
                //     builder: (context) => RequestEditPage(
                //       request: item,
                //       onSave: (_) {},
                //     ),
                //   ),
                // );
              },
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => onDelete(item), // Fixed typo here
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


class _PurchaseRequestPageState extends State<PurchaseRequestPage> {
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final List<Map<String, dynamic>> _PurchaseRequests = [];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String? _priorityFilter;
  String? _statusFilter;
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedDueDate;
  bool _isLoading = false;
  late UserController userController; 
  @override
  void initState() {
    userController= Provider.of<UserController>(context, listen: false);
    super.initState();
    _fetchRequestsFromApi();
  }

  Future<void> _fetchRequestsFromApi() async {
    setState(() { _isLoading = true; });
    try {
      final api = PurchaseRequestNetwork();
      final List<dynamic> data = (await api.fetchPurchaseRequests(userController.currentUser)) as List;
      setState(() {
        _PurchaseRequests.clear();
        _PurchaseRequests.addAll(data.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'].toString(),
            'actionCreatedBy': item['actionCreatedBy'] ?? '',
            'dateSubmitted': item['dateSubmitted'] != null ? DateTime.parse(item['dateSubmitted']) : DateTime.now(),
            'dueDate': item['dueDate'] != null ? DateTime.parse(item['dueDate']) : DateTime.now(),
            'priority': item['priority'] ?? '',
            'status': item['status'] ?? '',
          };
        }));
      });
    } catch (e) {
      print('Erreur lors du chargement des requests: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  List<Map<String, dynamic>> get _filteredAndSortedOrders {
    List<Map<String, dynamic>> orders = List.from(_PurchaseRequests);

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

  void viewPurchaseRequest(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewPurchasePage(order: order),
      ),
    );
  }

  // void editPurchaseRequest(Map<String, dynamic> order) async {
  //   final updatedOrder = await Navigator.push<Map<String, dynamic>>(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PurchaseRequestView(
  //         order: order,
  //         onSave: (newOrder) {
  //           Navigator.pop(context, newOrder);
  //         },
  //       ),
  //     ),
  //   );

  //   if (updatedOrder != null) {
  //     setState(() {
  //       final index = _PurchaseRequests.indexWhere((o) => o['id'] == updatedOrder['id']);
  //       if (index != -1) {
  //         _PurchaseRequests[index] = updatedOrder;
  //       }
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Purchase order ${updatedOrder['id']} updated')),
  //     );
  //   }
  // }

  void deletePurchaseRequest(Map<String, dynamic> order) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) => Dialog(
        backgroundColor: const Color(0xF7F3F7FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 340, // Taille max du dialog (plus petit)
            minWidth: 260,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delete Purchase',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to delete ${order['id']}?.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Delete', style: TextStyle(fontSize: 16)),
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
        _PurchaseRequests.removeWhere((o) => o['id'] == order['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase request ${order['id']} deleted')),
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

  // void _openAddRequestForm() async {
  //   final newOrder = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PurchaseRequestorForm(
  //         onSave: (_) {},
  //         initialOrder: const {
  //           'priority': 'High', // Définit "High" comme valeur par défaut
  //         },
  //       ),
  //     ),
  //   );
  //   if (newOrder != null) {
  //     setState(() {
  //       final id = 'PR${_PurchaseRequests.length + 1}';
  //       final order = {
  //         'id': id,
  //         'actionCreatedBy': newOrder['actionCreatedBy'] ?? 'Moi',
  //         'dateSubmitted': newOrder['dateSubmitted'] is String
  //             ? DateTime.parse(newOrder['dateSubmitted'])
  //             : (newOrder['dateSubmitted'] ?? DateTime.now()),
  //         'dueDate': newOrder['dueDate'] is String
  //             ? DateTime.parse(newOrder['dueDate'])
  //             : (newOrder['dueDate'] ?? DateTime.now().add(const Duration(days: 7))),
  //         'priority': newOrder['priority'] ?? 'High',
  //         'status': 'Pending',
  //         'requested_by': newOrder['requested_by'], // Use the value from the form, which should be the correct user ID
  //         ...newOrder,
  //       };
  //       _PurchaseRequests.add(order.cast<String, dynamic>());
  //       purchase_order.PurchaseOrderPage.addPurchaseOrder(order.cast<String, dynamic>());
  //     });
  //   }
  // }

  // void _addNewRequest(Map<String, dynamic> request) {
  //   setState(() {
  //     _PurchaseRequests.add(request); // Ajout local
  //     purchase_order.PurchaseOrderPage.addPurchaseOrder(request); // Ajout à la table des orders
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final dataSource = _PurchaseRequestDataSource(
      _filteredAndSortedOrders,
      context,
      _dateFormat,
      onView: viewPurchaseRequest,
      // onEdit: editPurchaseRequest,
      onDelete: deletePurchaseRequest,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Requests'),
        actions: [
          ElevatedButton.icon(
            onPressed: null,
            // _openAddRequestForm,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add PR'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFiltersRow(),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: PaginatedDataTable(
                        header: const Text('Purchase Requests Table'),
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
                        columnSpacing: 170,
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
        mainAxisAlignment: MainAxisAlignment.center, // <-- Ajouté pour centrer
        children: [
          // Filter by Priority
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              foregroundColor: Colors.deepPurple,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () {},
            child: Row(
              children: const [
                Text(
                  'Filter by Priority',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Filter by Status
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFF7F3FF),
              foregroundColor: Colors.deepPurple,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () {},
            child: Row(
              children: const [
                Text(
                  'Filter by Status',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
              ],
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
    // Conversion sécurisée des dates
    final dateSubmitted = order['dateSubmitted'] is String
        ? DateTime.parse(order['dateSubmitted'])
        : order['dateSubmitted'];
    final dueDate = order['dueDate'] is String
        ? DateTime.parse(order['dueDate'])
        : order['dueDate'];
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
            Text('Date submitted: ${dateFormat.format(dateSubmitted)}'),
            Text('Due date: ${dateFormat.format(dueDate)}'),
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

/// Add a purchase order to your storage or list.
/// This is a stub implementation. Replace with your actual logic.
void addPurchaseOrder(Map<String, dynamic> order) {
  // TODO: Implement the logic to add the purchase order.
  print('Purchase request $order');
}
