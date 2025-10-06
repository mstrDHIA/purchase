import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/screens/Purchase%20Request/requestor_form_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order_screen.dart' as purchase_order;
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/purchase_request_datasource.dart';

class PurchaseRequestPage extends StatefulWidget {
  const PurchaseRequestPage({super.key});

  @override
  State<PurchaseRequestPage> createState() => _PurchaseRequestPageState();
}

class _PurchaseRequestPageState extends State<PurchaseRequestPage> {
  void _sort<T>(Comparable<T> Function(dynamic req) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
  final List<String> _priorityOptions = [
    'high',
    'medium',
    'low',
  ];
  String? _priorityFilter;
  late PurchaseRequestController purchaseRequestController;
  // final List<Map<String, dynamic>> _PurchaseRequests = [];
  final List<String> _statusOptions = [
    'pending',
    'approved',
    'rejected',
  ];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isLoading = false;
  int _page = 0;
  int _totalRows = 0;
  int _rowsPerPageLocal = PaginatedDataTable.defaultRowsPerPage;

  // Filter state
  String? _statusFilter;
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedDueDate;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _selectedSubmissionDate = null;
      _selectedDueDate = null;
      _priorityFilter = null;
      _searchText = '';
      _searchController.clear();
    });
    // TODO: Apply filter logic to data source if needed
  }

  Future<void> _selectDate(BuildContext context, bool isSubmission) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isSubmission) {
          _selectedSubmissionDate = picked;
        } else {
          _selectedDueDate = picked;
        }
      });
      // TODO: Apply filter logic to data source if needed
    }
  }
  late UserController userController;
  @override
  void initState() {
    userController= Provider.of<UserController>(context, listen: false);
    purchaseRequestController = Provider.of<PurchaseRequestController>(context, listen: false);
    purchaseRequestController.fetchRequests(context,userController.currentUser);
    super.initState();
  }

  void viewPurchaseRequest(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => purchase_order.ViewPurchasePage(order: order),
      ),
    ).then((result) {
      if (result == true) {
        purchaseRequestController.fetchRequests(context,userController.currentUser);
      }
    });
  }


  Future<void> _openAddRequestForm() async {
    final newRequest = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseRequestorForm(
          onSave: (order) {
            Navigator.pop(context, order);
          }, initialOrder: {},
        ),
      ),
    );
    print(newRequest);
    purchaseRequestController.fetchRequests(context,userController.currentUser);

  }

  @override
  Widget build(BuildContext context) {
    
  return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.purchaseRequests),
        actions: [
          if(userController.currentUser.role!.id==2||userController.currentUser.role!.id==1)
          ElevatedButton.icon(
            onPressed: _openAddRequestForm,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(AppLocalizations.of(context)!.addPR),
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
                const SizedBox(height: 16),
                // --- Filter Bar + Search ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Search Bar
                      SizedBox(
                        width: 240,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.search,
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Color(0xFFF7F3FF),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter by Status
                      PopupMenuButton<String>(
                        onSelected: (String value) {
                          setState(() {
                            _statusFilter = value;
                          });
                        },
                        itemBuilder: (context) => [
                          ..._statusOptions.map((status) => PopupMenuItem(
                                value: status,
                                child: Text(status[0].toUpperCase() + status.substring(1)),
                              )),
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
                                _statusFilter == null ? 'Filter by Status' : 'Status: ${_statusFilter![0].toUpperCase() + _statusFilter!.substring(1)}',
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
                      // Filter by Priority
                      PopupMenuButton<String>(
                        onSelected: (String value) {
                          setState(() {
                            _priorityFilter = value;
                          });
                        },
                        itemBuilder: (context) => [
                          ..._priorityOptions.map((priority) => PopupMenuItem(
                                value: priority,
                                child: Text(priority[0].toUpperCase() + priority.substring(1)),
                              )),
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
                                _priorityFilter == null ? 'Filter by Priority' : 'Priority: ${_priorityFilter![0].toUpperCase() + _priorityFilter!.substring(1)}',
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
                ),
                const SizedBox(height: 8),
                // --- End Filter Bar ---
                Expanded(
                  child: Consumer<PurchaseRequestController>(
                    builder: (context, purchaseRequestController, child) {
                      final allRequests = purchaseRequestController.dataSource.requests;
                      var filteredRequests = allRequests;
                      if (_statusFilter != null) {
                        filteredRequests = filteredRequests.where((req) => req.status == _statusFilter).toList();
                      }
                      if (_priorityFilter != null) {
                        filteredRequests = filteredRequests.where((req) => req.priority == _priorityFilter).toList();
                      }
                      if (_selectedSubmissionDate != null) {
                        filteredRequests = filteredRequests.where((req) => req.startDate != null &&
                          req.startDate!.year == _selectedSubmissionDate!.year &&
                          req.startDate!.month == _selectedSubmissionDate!.month &&
                          req.startDate!.day == _selectedSubmissionDate!.day).toList();
                      }
                      if (_selectedDueDate != null) {
                        filteredRequests = filteredRequests.where((req) => req.endDate != null &&
                          req.endDate!.year == _selectedDueDate!.year &&
                          req.endDate!.month == _selectedDueDate!.month &&
                          req.endDate!.day == _selectedDueDate!.day).toList();
                      }
                      // Apply search filter
                      if (_searchText.isNotEmpty) {
                        final searchLower = _searchText.toLowerCase();
                        filteredRequests = filteredRequests.where((req) {
                          return (req.id?.toString().toLowerCase().contains(searchLower) ?? false)
                              || (req.requestedBy?.toString().toLowerCase().contains(searchLower) ?? false)
                              || (req.status?.toString().toLowerCase().contains(searchLower) ?? false)
                              || (req.priority?.toString().toLowerCase().contains(searchLower) ?? false)
                              || (req.startDate?.toString().toLowerCase().contains(searchLower) ?? false)
                              || (req.endDate?.toString().toLowerCase().contains(searchLower) ?? false);
                        }).toList();
                      }
                      final filteredDataSource = PurchaseRequestDataSource(filteredRequests, context, 'filtered');
                      int totalRows = filteredRequests.length;
                      // Corriger la page si besoin (ex: suppression d'éléments)
                      if (_page * _rowsPerPageLocal >= totalRows && _page > 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            _page = ((totalRows - 1) / _rowsPerPageLocal).floor();
                            if (_page < 0) _page = 0;
                          });
                        });
                      }
                      final int start = _page * _rowsPerPageLocal;
                      final int end = (_page + 1) * _rowsPerPageLocal > totalRows ? totalRows : (_page + 1) * _rowsPerPageLocal;
                      // Sort filteredRequests if a sort column is selected
                      if (_sortColumnIndex != null) {
                        var getField;
                        switch (_sortColumnIndex) {
                          case 0:
                            getField = (req) => req.id ?? 0;
                            break;
                          case 1:
                            getField = (req) => req.requestedBy?.toString() ?? '';
                            break;
                          case 2:
                            getField = (req) => req.startDate?.toString() ?? '';
                            break;
                          case 3:
                            getField = (req) => req.endDate?.toString() ?? '';
                            break;
                          case 4:
                            getField = (req) => req.priority?.toString() ?? '';
                            break;
                          case 5:
                            getField = (req) => req.status?.toString() ?? '';
                            break;
                          default:
                            getField = (req) => req.id ?? 0;
                        }
                        filteredRequests.sort((a, b) {
                          final aValue = getField(a);
                          final bValue = getField(b);
                          if (aValue is Comparable && bValue is Comparable) {
                            return _sortAscending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
                          }
                          return 0;
                        });
                      }
                      final pageRequests = filteredRequests.sublist(start < totalRows ? start : 0, end < totalRows ? end : totalRows);
                      final pageDataSource = PurchaseRequestDataSource(pageRequests, context, 'filtered');
                      print('DataSource: $pageRequests');
                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: Container(
                                  child: PaginatedDataTable(
                                    header: Text(AppLocalizations.of(context)!.purchaseRequestsTable),
                                    rowsPerPage: _rowsPerPageLocal,
                                    availableRowsPerPage: const [5, 10, 20, 50, 100],
                                    onRowsPerPageChanged: (r) {
                                      if (r != null) {
                                        setState(() {
                                          _rowsPerPageLocal = r;
                                          _rowsPerPage = r;
                                          _page = 0;
                                        });
                                      }
                                    },
                                    sortColumnIndex: _sortColumnIndex,
                                    sortAscending: _sortAscending,
                                    columnSpacing: 190,
                                    horizontalMargin: 16,
                                    columns: [
                                      DataColumn(
                                        label: const Text('ID'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<num>((req) => req.id ?? 0, columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: Text(
                                          userController.currentUser.role!.id != 2
                                              ? 'Created by'
                                              : 'Validated by',
                                        ),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((req) => req.requestedBy?.toString() ?? '', columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('Date submitted'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((req) => req.startDate?.toString() ?? '', columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('Due date'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((req) => req.endDate?.toString() ?? '', columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('Priority'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((req) => req.priority?.toString() ?? '', columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: const Text('Status'),
                                        onSort: (columnIndex, ascending) {
                                          _sort<String>((req) => req.status?.toString() ?? '', columnIndex, ascending);
                                        },
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 120,
                                          child: const Center(child: Text('Actions')),
                                        ),
                                      ),
                                    ],
                                    source: pageDataSource,
                                    showFirstLastButtons: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _page > 0
                                    ? () {
                                        setState(() {
                                          _page--;
                                        });
                                      }
                                    : null,
                                child: const Text('Previous'),
                              ),
                              const SizedBox(width: 8),
                              // Numérotation des pages
                              ...List.generate(
                                (totalRows / _rowsPerPageLocal).ceil(),
                                (index) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: index == _page ? Colors.deepPurple : Colors.grey[200],
                                      foregroundColor: index == _page ? Colors.white : Colors.deepPurple,
                                      minimumSize: const Size(36, 36),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _page = index;
                                      });
                                    },
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: (_page + 1) * _rowsPerPageLocal < totalRows
                                    ? () {
                                        setState(() {
                                          _page++;
                                        });
                                      }
                                    : null,
                                child: const Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

