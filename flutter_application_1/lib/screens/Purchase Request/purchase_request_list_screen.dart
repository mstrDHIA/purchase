import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/controllers/product_controller.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/screens/Purchase%20Request/requestor_form_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order_screen.dart' as purchase_order;
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/datasources/purchase_request_datasource.dart';

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
  final List<String> _statusOptions = [
    'pending',
    'approved',
    'rejected',
  ];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex = 0;
  bool _sortAscending = false; // default: ID column descending
  final bool _isLoading = false;
  final int _page = 0;
  final int _totalRows = 0;
  int _rowsPerPageLocal = PaginatedDataTable.defaultRowsPerPage;
  String? _statusFilter;
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedDueDate;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  bool _showArchived = false;

  // Families (N2) and Subfamilies (N3) filters
  Map<String, List<String>> dynamicProductFamilies = {};
  bool _loadingFamilies = false;
  String? _familiesError;
  String? _familyFilter;
  String? _subFamilyFilter;

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _selectedSubmissionDate = null;
      _selectedDueDate = null;
      _priorityFilter = null;
      _searchText = '';
      _searchController.clear();
      _showArchived = false;
      _familyFilter = null;
      _subFamilyFilter = null;
    });
  }

  // Fetch product categories and build a families -> subfamilies map
  Future<void> _fetchProductFamilies() async {
    setState(() {
      _loadingFamilies = true;
      _familiesError = null;
    });
    try {
      final productController = Provider.of<ProductController>(context, listen: false);
      final categories = await productController.getCategories(null);
      if (categories is List<dynamic>) {
        final families = <String, List<String>>{};
        final allCategories = categories.cast<Map<String, dynamic>>();
        final parentCategories = allCategories.where((cat) => cat['parent_category'] == null).toList();
        for (final family in parentCategories) {
          final familyId = family['id'];
          final familyName = family['name'] as String;
          final subfamilies = allCategories
              .where((cat) => cat['parent_category'] == familyId)
              .map((cat) => cat['name'] as String)
              .toList();
          families[familyName] = subfamilies.isNotEmpty ? subfamilies : [familyName];
        }
        setState(() => dynamicProductFamilies = families);
      }
    } catch (e) {
      setState(() => _familiesError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingFamilies = false);
    }
  }

  bool _canShowFamilyFilters() {
    final user = Provider.of<UserController>(context, listen: false).currentUser;
    // Allowed user IDs provided by admin (user.id only mode)
    const allowedUserIds = {1, 4, 7};
    final uid = user.id;
    if (uid == null) return false;
    return allowedUserIds.contains(uid);
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

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large search bar on the left
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchText = value),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF7F3FF),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Filters on the right
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PopupMenuButton<String>(
                onSelected: (value) { setState(() { _priorityFilter = value.isEmpty ? null : value; }); },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: '', child: Text('All')),
                  ..._priorityOptions.map((p) => PopupMenuItem(value: p, child: Text(p[0].toUpperCase() + p.substring(1)))),
                ],
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7F3FF),
                    foregroundColor: Colors.deepPurple,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _priorityFilter == null ? 'Filter by Priority' : 'Priority: ${_priorityFilter![0].toUpperCase() + _priorityFilter!.substring(1)}',
                        style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                    ],
                  ),
                ),
              ),

              if (_canShowFamilyFilters()) ...[
              // Family (N2) filter
              PopupMenuButton<String?>(
                onSelected: (value) {
                  setState(() {
                    _familyFilter = (value == null || value.isEmpty) ? null : value;
                    _subFamilyFilter = null; // reset subfilter when family changes
                  });
                },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String?>>[];
                  items.add(const PopupMenuItem<String?>(value: '', child: Text('All Families')));
                  if (_loadingFamilies) {
                    items.add(const PopupMenuItem<String?>(value: null, child: Text('Loading...')));
                  } else {
                    for (final f in dynamicProductFamilies.keys) {
                      items.add(PopupMenuItem<String?>(value: f, child: Text(f)));
                    }
                  }
                  return items;
                },
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7F3FF),
                    foregroundColor: Colors.deepPurple,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _familyFilter == null ? 'Filter by Family' : 'Family: ${_familyFilter!}',
                        style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                    ],
                  ),
                ),
              ),

              // Subfamily (N3) filter — depends on selected family
              PopupMenuButton<String?>(
                onSelected: (value) { setState(() { _subFamilyFilter = (value == null || value.isEmpty) ? null : value; }); },
                itemBuilder: (context) {
                  final items = <PopupMenuEntry<String?>>[];
                  items.add(const PopupMenuItem<String?>(value: '', child: Text('All Subfamilies')));
                  if (_familyFilter == null) {
                    items.add(const PopupMenuItem<String?>(value: null, child: Text('Select a family first')));
                  } else {
                    final subs = dynamicProductFamilies[_familyFilter] ?? [];
                    for (final s in subs) items.add(PopupMenuItem<String?>(value: s, child: Text(s)));
                  }
                  return items;
                },
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7F3FF),
                    foregroundColor: Colors.deepPurple,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _subFamilyFilter == null ? 'Filter by Subfamily' : 'Sub: ${_subFamilyFilter!}',
                        style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                    ],
                  ),
                ),
              ),
              ],
              if(Provider.of<UserController>(context, listen: false).currentUser.role!.id!=4)
              PopupMenuButton<String>(
                onSelected: (value) { setState(() { _statusFilter = value.isEmpty ? null : value; }); },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: '', child: Text('All')),
                  ..._statusOptions.map((s) => PopupMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))),
                ],
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7F3FF),
                    foregroundColor: Colors.deepPurple,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _statusFilter == null ? 'Filter by Status' : 'Status: ${_statusFilter![0].toUpperCase() + _statusFilter!.substring(1)}',
                        style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                    ],
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => _selectDate(context, true),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7F3FF),
                  foregroundColor: Colors.deepPurple,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: Text(_selectedSubmissionDate == null ? 'Filter by Submission Date' : 'Submission: ${_dateFormat.format(_selectedSubmissionDate!)}'),
              ),
              OutlinedButton(
                onPressed: () => _selectDate(context, false),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7F3FF),
                  foregroundColor: Colors.deepPurple,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: Text(_selectedDueDate == null ? ' Delivery due date' : 'Due: ${_dateFormat.format(_selectedDueDate!)}'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _showArchived ? const Color(0xFF6F4DBF) : const Color(0xFFF7F3FF),
                  foregroundColor: _showArchived ? Colors.white : Colors.deepPurple,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: () {
                  setState(() {
                    _showArchived = !_showArchived;
                  });
                },
                icon: const Icon(Icons.archive),
                label: Text(
                  _showArchived ? 'Hide Archived' : 'Show Archived',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  late UserController userController;
  @override
  void initState() {
    userController= Provider.of<UserController>(context, listen: false);
    // ensure users are loaded so we can display names instead of ids
    userController.getUsers();
    purchaseRequestController = Provider.of<PurchaseRequestController>(context, listen: false);
    // initial paginated fetch
    purchaseRequestController.fetchRequests(context, userController.currentUser, page: 1, pageSizeParam: _rowsPerPageLocal);

    // fetch product families for filters (N2 and N3)
    _fetchProductFamilies();

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
    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseRequestorForm(
          onSave: (order) {
            Navigator.pop(context, order);
          }, initialOrder: {},
        ),
      ),
    );
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
                // Use the consolidated filters row builder (search on left, filters on right)
                _buildFiltersRow(),
                const SizedBox(height: 8),
                // --- End Filter Bar ---
                Expanded(
                  child: Consumer<PurchaseRequestController>(
                    builder: (context, purchaseRequestController, child) {
                      final allRequests = purchaseRequestController.requests;
                      var filteredRequests = allRequests;
                      // Filter archived requests
                      if (_showArchived) {
                        // Show ONLY archived requests
                        filteredRequests = filteredRequests.where((req) => (req.isArchived ?? false)).toList();
                      } else {
                        // Show ONLY non-archived requests
                        filteredRequests = filteredRequests.where((req) => !(req.isArchived ?? false)).toList();
                      }
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

                      // Apply family/subfamily filters (N2/N3) — match if any product line in the request has the family/subfamily
                      if (_familyFilter != null) {
                        filteredRequests = filteredRequests.where((req) => (req.products?.any((p) => (p.family?.toString() == _familyFilter)) ?? false)).toList();
                      }
                      if (_subFamilyFilter != null) {
                        filteredRequests = filteredRequests.where((req) => (req.products?.any((p) => (p.subFamily?.toString() == _subFamilyFilter)) ?? false)).toList();
                      }

                      final filteredDataSource = PurchaseRequestDataSource(filteredRequests, context, 'filtered');
                      // pagination data available in controller if needed
                      // Sort filteredRequests if a sort column is selected
                      if (_sortColumnIndex != null) {
                        Function(dynamic req) getField;
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
                      final pageDataSource = filteredDataSource;
                      // data source prepared for current page
                      return Column(
                        children: [
                          // Batch actions row
                          AnimatedBuilder(
                            animation: pageDataSource,
                            builder: (context, child) {
                              final curSelected = pageDataSource.getSelectedIds();
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Text('${curSelected.length} selected'),
                                    const SizedBox(width: 16),
                                    // Archive / Unarchive depending on current view
                                    ElevatedButton.icon(
                                      onPressed: curSelected.isEmpty ? null : () async {
                                        final isUnarchive = _showArchived == true;
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(isUnarchive ? 'Unarchive selected' : 'Archive selected'),
                                            content: Text(isUnarchive
                                                ? 'Are you sure you want to unarchive ${curSelected.length} requests?'
                                                : 'Are you sure you want to archive ${curSelected.length} requests?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                              ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(isUnarchive ? 'Unarchive' : 'Archive')),
                                            ],
                                          ),
                                        );
                                        if (confirmed != true) return;
                                        final controller = Provider.of<PurchaseRequestController>(context, listen: false);
                                        final userCtrl = Provider.of<UserController>(context, listen: false);
                                        try {
                                          for (final id in curSelected) {
                                            if (isUnarchive) {
                                              await controller.unarchivePurchaseRequest(id);
                                            } else {
                                              await controller.archivePurchaseRequest(id);
                                            }
                                          }
                                          await controller.fetchRequests(context, userCtrl.currentUser);
                                          pageDataSource.clearSelection();
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUnarchive ? 'Unarchived ${curSelected.length} requests' : 'Archived ${curSelected.length} requests')));
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                                        }
                                      },
                                      icon: Icon(_showArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                                      label: Text(_showArchived ? 'Unarchive Selected' : 'Archive Selected'),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: curSelected.isEmpty ? null : () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete selected',style: TextStyle(color: Color.fromARGB(255, 240, 239, 241)),),
                                            content: Text('Are you sure you want to delete ${curSelected.length} requests? This cannot be undone.'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                              ElevatedButton(onPressed: () => Navigator.of(context).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
                                            ],
                                          ),
                                        );
                                        if (confirmed != true) return;
                                        final controller = Provider.of<PurchaseRequestController>(context, listen: false);
                                        final userCtrl = Provider.of<UserController>(context, listen: false);
                                        try {
                                          for (final id in curSelected) {
                                            await controller.deleteRequest(id, context);
                                          }
                                          await controller.fetchRequests(context, userCtrl.currentUser);
                                          pageDataSource.clearSelection();
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted ${curSelected.length} requests')));
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
                                        }
                                      },
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Delete Selected'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: PaginatedDataTable(
                                    
                                    header: Text(AppLocalizations.of(context)!.purchaseRequestsTable),
                                    rowsPerPage: _rowsPerPageLocal,
                                    availableRowsPerPage: const [5, 10, 20, 50, 100],
                                    onRowsPerPageChanged: (r) {
                                      if (r != null) {
                                        setState(() {
                                          _rowsPerPageLocal = r;
                                          _rowsPerPage = r;
                                          // refetch with new page size and reset to first page
                                          purchaseRequestController.fetchRequests(context, userController.currentUser, page: 1, pageSizeParam: _rowsPerPageLocal);
                                        });
                                      }
                                    },
                                    sortColumnIndex: _sortColumnIndex,
                                    sortAscending: _sortAscending,
                                    // columnSpacing: 190,
                                    columnSpacing: MediaQuery.of(context).size.width * 0.05,
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
                                        label: const Text(' Delivery due date'),
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
                                          width: 100,
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
                          // Pagination controls removed (per request)
                          const SizedBox(height: 8),
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

