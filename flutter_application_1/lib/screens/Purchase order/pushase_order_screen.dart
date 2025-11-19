import 'package:flutter_application_1/models/datasources/purchase_order_datasource.dart';
import 'package:flutter_application_1/screens/Purchase%20order/Edit_purchase_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/view_purchase_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter/material.dart';
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
  late UserController userController;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String? _priorityFilter;
  String? _statusFilter;
  bool _showArchived = false;
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedDueDate;
  // Search bar controller and value
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';


  @override
  void initState() {
    super.initState();
    userController = Provider.of<UserController>(context, listen: false);
    userController.getUsers();
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
      // Resolve requestedByUser which may be either an id (int) or a nested user Map
      String actionCreatedBy = '';
      final userField = order.requestedByUser;
      if (userField != null) {
        // If API returned a nested user object
        if (userField is Map) {
          // Try common keys
          final fname = (userField['first_name'] ?? userField['firstName'] ?? '')?.toString();
          final lname = (userField['last_name'] ?? userField['lastName'] ?? '')?.toString();
          final uname = (userField['username'] ?? userField['user'] ?? '')?.toString();
          if (fname != null && fname.isNotEmpty) {
            actionCreatedBy = '$fname${lname != null && lname.isNotEmpty ? ' $lname' : ''}'.trim();
          } else if (uname != null && uname.isNotEmpty) {
            actionCreatedBy = uname;
          } else if (userField['id'] != null) {
            actionCreatedBy = userField['id'].toString();
          }
        } else {
          // Treat as id (int or string). Try to find in loaded users.
          final userId = int.tryParse(userField.toString()) ?? (userField is int ? userField : null);
          if (userId != null) {
            final found = userController.users.firstWhere((u) => u.id == userId, orElse: () => User(id: userId, username: userId.toString()));
            if (found.firstName != null && (found.firstName ?? '').isNotEmpty) {
              actionCreatedBy = '${found.firstName} ${found.lastName ?? ''}'.trim();
            } else if (found.username != null && (found.username ?? '').isNotEmpty) {
              actionCreatedBy = found.username!;
            } else {
              actionCreatedBy = userId.toString();
            }
          } else {
            // fallback to string representation
            actionCreatedBy = userField.toString();
          }
        }
      }
      return {
        'id': order.id?.toString() ?? '',
        'actionCreatedBy': actionCreatedBy,
        'dateSubmitted': parseDate(order.startDate),
        'dueDate': parseDate(order.endDate),
        'priority': order.priority ?? '',
        'status': order.status ?? '',
        'original': order,
      };
    }).toList();
    // Search filter: only show orders that match the search text in any main field
    if (_searchText.isNotEmpty) {
      final searchLower = _searchText.toLowerCase();
      mapped = mapped.where((order) =>
        order['id'].toLowerCase().contains(searchLower) ||
        order['actionCreatedBy'].toLowerCase().contains(searchLower) ||
        order['priority'].toLowerCase().contains(searchLower) ||
        order['status'].toLowerCase().contains(searchLower)
      ).toList();
    }

    // Filter archived orders
    if (_showArchived) {
      // Show ONLY archived orders
      mapped = mapped.where((order) => (order['original'].isArchived ?? false)).toList();
    } else {
      // Show ONLY non-archived orders
      mapped = mapped.where((order) => !(order['original'].isArchived ?? false)).toList();
    }

    // Apply filters
    if (_priorityFilter != null) {
      mapped = mapped.where((order) => order['priority'].toLowerCase() == _priorityFilter!.toLowerCase()).toList();
    }
    if (_statusFilter != null) {
      mapped = mapped.where((order) => order['status'].toLowerCase() == _statusFilter!.toLowerCase()).toList();
    }
    if (_selectedSubmissionDate != null) {
      mapped = mapped.where((order) {
        final date = order['dateSubmitted'];
        return date is DateTime && date.year == _selectedSubmissionDate!.year && date.month == _selectedSubmissionDate!.month && date.day == _selectedSubmissionDate!.day;
      }).toList();
    }
    if (_selectedDueDate != null) {
      mapped = mapped.where((order) {
        final date = order['dueDate'];
        return date is DateTime && date.year == _selectedDueDate!.year && date.month == _selectedDueDate!.month && date.day == _selectedDueDate!.day;
      }).toList();
    }
    // Sorting logic
    if (_sortColumnIndex != null) {
      String sortKey = 'id';
      if (_sortColumnIndex == 0) {
        sortKey = 'id';
      } else if (_sortColumnIndex == 1) {
        sortKey = 'actionCreatedBy';
      } else if (_sortColumnIndex == 2) {
        sortKey = 'dateSubmitted';
      } else if (_sortColumnIndex == 3) {
        sortKey = 'dueDate';
      } else if (_sortColumnIndex == 4) {
        sortKey = 'priority';
      } else if (_sortColumnIndex == 5) {
        sortKey = 'status';
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
      _showArchived = false;
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
        final allOrders = controller.orders;
        final filteredOrders = _filteredAndSortedOrders(allOrders);
        final dataSource = PurchaseOrderDataSource(
          filteredOrders,
          _dateFormat,
          onView: viewPurchaseOrder,
          onEdit: editPurchaseOrder,
          onDelete: deletePurchaseOrder,
          onArchive: archivePurchaseOrder,
        );
        return Scaffold(
          appBar: AppBar(
            title: const Text('Purchase Orders'),
          ),
          body: 
          (MediaQuery.of(context).size.width<600)?
                          ListView.builder(itemBuilder:  (context,index){
                            final order = filteredOrders[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text('PO #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text('Created by: ${order['actionCreatedBy']}'),
                                    Text('Date submitted: ${_dateFormat.format(order['dateSubmitted'])}'),
                                    Text('Due date: ${_dateFormat.format(order['dueDate'])}'),
                                    Text('Priority: ${order['priority']}'),
                                    Text('Status: ${order['status']}'),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'view', child: Text('View')),
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                  ],
                                ),
                              ),
                            );
                          }
                          ,itemCount: filteredOrders.length,)
                          :
          Column(
            children: [
              _buildFiltersRow(),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: 
                          PaginatedDataTable(
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
                            columnSpacing: MediaQuery.of(context).size.width * 0.08,
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        alignment: WrapAlignment.start,
        children: [
          // Search bar
          SizedBox(
            width: 500,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF7F3FF),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.deepPurple, fontSize: 16),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          // Filter by Priority
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _priorityFilter == null ? 'Priority' : 'Priority: $_priorityFilter',
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
          // Filter by Status
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _statusFilter == null ? 'Status' : 'Status: $_statusFilter',
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
                  ? 'Submission Date'
                  : '${_dateFormat.format(_selectedSubmissionDate!)}',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
                  ? 'Due Date'
                  : '${_dateFormat.format(_selectedDueDate!)}',
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Show/Hide Archived
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: _showArchived ? const Color(0xFF6F4DBF) : const Color(0xFFF7F3FF),
              foregroundColor: _showArchived ? Colors.white : Colors.deepPurple,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
            icon: const Icon(Icons.archive),
            label: Text(
              _showArchived ? 'Hide Archived' : 'Show Archived',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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

  void archivePurchaseOrder(Map<String, dynamic> order) async {
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
                  'Archive Purchase Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to archive purchase order ${order['id']}?',
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
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Archive',
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
        await controller.archivePurchaseOrder(order['id']);
        await controller.fetchOrders();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase order ${order['id']} archived')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to archive purchase order: $e')),
        );
      }
    }
  }
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