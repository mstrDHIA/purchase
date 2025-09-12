import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Filter state
  String? _statusFilter;
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedDueDate;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _selectedSubmissionDate = null;
      _selectedDueDate = null;
  _priorityFilter = null;
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

  @override
  void initState() {
    purchaseRequestController = Provider.of<PurchaseRequestController>(context, listen: false);
    purchaseRequestController.fetchRequests(context);
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
        purchaseRequestController.fetchRequests(context);
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
    purchaseRequestController.fetchRequests(context);

  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Requests'),
        actions: [
          ElevatedButton.icon(
            onPressed: _openAddRequestForm,
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
                const SizedBox(height: 16),
                // --- Filter Bar ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
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
                      final filteredDataSource = PurchaseRequestDataSource(filteredRequests, context, 'filtered');
                      print('DataSource: $filteredRequests');
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: Container(
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
                              columnSpacing: 190,
                              horizontalMargin: 16,
                              columns: [
                                DataColumn(label: const Text('ID')),
                                DataColumn(label: const Text('Created by')),
                                DataColumn(label: const Text('Date submitted')),
                                DataColumn(label: const Text('Due date')),
                                DataColumn(label: const Text('Priority')),
                                DataColumn(label: const Text('Status')),
                                DataColumn(
                                  label: SizedBox(
                                    width: 120,
                                    child: const Center(child: Text('Actions')),
                                  ),
                                ),
                              ],
                              source: filteredDataSource,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

