// ignore_for_file: unused_field, dead_code, unused_local_variable, unused_element
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
import 'package:flutter_application_1/models/user_model.dart';

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
    'converted',
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
                  PopupMenuItem(value: '', child: Text(AppLocalizations.of(context)!.all)),
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
                        _priorityFilter == null ? AppLocalizations.of(context)!.filterByPriority : AppLocalizations.of(context)!.priorityLabel(_priorityFilter![0].toUpperCase() + _priorityFilter!.substring(1)),
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
                  items.add(PopupMenuItem<String?>(value: '', child: Text(AppLocalizations.of(context)!.allFamilies)));
                  if (_loadingFamilies) {
                    items.add(PopupMenuItem<String?>(value: null, child: Text(AppLocalizations.of(context)!.loading)));
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
                        _familyFilter == null ? AppLocalizations.of(context)!.filterByFamily : 'Family: ${_familyFilter!}',
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
                  items.add(PopupMenuItem<String?>(value: '', child: Text(AppLocalizations.of(context)!.allSubfamilies)));
                  if (_familyFilter == null) {
                    items.add(PopupMenuItem<String?>(value: null, child: Text(AppLocalizations.of(context)!.selectFamilyFirst)));
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
                        _subFamilyFilter == null ? AppLocalizations.of(context)!.filterBySubfamily : 'Sub: ${_subFamilyFilter!}',
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
                  PopupMenuItem(value: '', child: Text(AppLocalizations.of(context)!.all)),
                  ..._statusOptions.map((s) => PopupMenuItem(
                        value: s,
                        child: Text(
                          s == 'pending' ? AppLocalizations.of(context)!.pending
                            : s == 'approved' ? AppLocalizations.of(context)!.approved
                            : s == 'rejected' ? AppLocalizations.of(context)!.rejected
                            : s == 'converted' ? AppLocalizations.of(context)!.transformed
                            : s[0].toUpperCase() + s.substring(1),
                        ),
                      )),
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
                  child: Builder(builder: (context) {
                    final statusLabel = _statusFilter == null ? AppLocalizations.of(context)!.filterStatus
                      : (_statusFilter == 'pending' ? AppLocalizations.of(context)!.pending
                        : _statusFilter == 'approved' ? AppLocalizations.of(context)!.approved
                          : _statusFilter == 'rejected' ? AppLocalizations.of(context)!.rejected
                            : _statusFilter == 'converted' ? AppLocalizations.of(context)!.transformed
                              : _statusFilter![0].toUpperCase() + _statusFilter!.substring(1));
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(statusLabel, style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                      ],
                    );
                  }),
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
                child: Text(_selectedSubmissionDate == null ? AppLocalizations.of(context)!.filterBySubmissionDate : 'Submission: ${_dateFormat.format(_selectedSubmissionDate!)}'),
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
                child: Text(_selectedDueDate == null ? AppLocalizations.of(context)!.dueDate : 'Due: ${_dateFormat.format(_selectedDueDate!)}'),
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
                  _showArchived ? AppLocalizations.of(context)!.hideArchived : AppLocalizations.of(context)!.showArchived,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: Text(AppLocalizations.of(context)!.clearFilters, style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500)),
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
    userController = Provider.of<UserController>(context, listen: false);
    // ensure users are loaded so we can display names instead of ids
    purchaseRequestController = Provider.of<PurchaseRequestController>(context, listen: false);

    // Fetch users first, then fetch requests so we can resolve ids to names immediately
    userController.getUsers().whenComplete(() {
      purchaseRequestController.fetchRequests(context, userController.currentUser, page: 1, pageSizeParam: _rowsPerPageLocal);
    });

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
      body: Consumer<PurchaseRequestController>(
        builder: (context, purchaseRequestController, child) {
          if (purchaseRequestController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Use the controller data after loading to avoid showing stale cached requests
          final allRequests = purchaseRequestController.requests;
          var filteredRequests = allRequests;
          // Filter archived requests
          if (_showArchived) {
            filteredRequests = filteredRequests.where((req) => (req.isArchived ?? false)).toList();
          } else {
            filteredRequests = filteredRequests.where((req) => !(req.isArchived ?? false)).toList();
          }
          if (_statusFilter != null) {
            final statusLower = _statusFilter!.toLowerCase().trim();
            final stem = statusLower.replaceAll(RegExp(r'(ed|e|ed_to_po|to_po)\$'), '').trim();
            filteredRequests = filteredRequests.where((req) {
              final s = (req.status?.toString().toLowerCase().trim() ?? '');
              if (s.isEmpty) return false;
              // direct or substring match
              if (s == statusLower || s.contains(statusLower) || statusLower.contains(s)) return true;
              // synonyms: converted <-> transformed
              if (statusLower == 'converted' && (s.contains('convert') || s.contains('transf'))) return true;
              if (statusLower == 'transformed' && (s.contains('convert') || s.contains('transf'))) return true;
              // stem/prefix match (catch small spelling/case differences, accents removed earlier)
              final minLen = 4;
              final sPrefix = s.length >= minLen ? s.substring(0, minLen) : s;
              final stemPrefix = stem.length >= minLen ? stem.substring(0, minLen) : stem;
              if (sPrefix == stemPrefix && stemPrefix.isNotEmpty) return true;
              return false;
            }).toList();
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

          // Manager department restriction: detect manager either by role id (3)
          // or by role name containing 'manager' (some deployments use different ids).
          // Only show requests whose requester is in the same department. If the
          // manager has no department assigned (depId == null), do not filter.
          final _currentUser = Provider.of<UserController>(context, listen: false).currentUser;
          // Detect manager using role id only
          final isManagerRole = _currentUser.role?.id == 3;
          if (isManagerRole) {
            final managerDepId = _currentUser.depId;
            if (managerDepId != null) {
              final usersList = Provider.of<UserController>(context, listen: false).users;
              filteredRequests = filteredRequests.where((req) {
                // Try to resolve requester by id first, then by display name / email / username
                User? matched;
                final uid = req.requestedBy;
                if (uid != null) {
                  try {
                    matched = usersList.firstWhere((u) => u.id == uid);
                  } catch (e) {
                    matched = null;
                  }
                }
                if (matched == null) {
                  final name = (req.requestedByName ?? '').toLowerCase();
                  if (name.isNotEmpty) {
                    try {
                      matched = usersList.firstWhere((u) => (u.email ?? '').toLowerCase() == name || (u.username ?? '').toLowerCase() == name || ('${u.firstName ?? ''} ${u.lastName ?? ''}').toLowerCase() == name);
                    } catch (e) {
                      matched = null;
                    }
                  }
                }

                return matched != null && matched.depId != null && matched.depId == managerDepId;
              }).toList();
            }
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

          return Column(
            children: [
              const SizedBox(height: 16),
              // --- Filter Bar + Search ---
              // Use the consolidated filters row builder (search on left, filters on right)
              _buildFiltersRow(),
              const SizedBox(height: 8),
              // --- End Filter Bar ---
              Expanded(
                child: Column(
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
                              Text(AppLocalizations.of(context)!.selectedCount(curSelected.length.toString())),
                              const SizedBox(width: 16),
                              // Archive / Unarchive depending on current view
                              ElevatedButton.icon(
                                onPressed: curSelected.isEmpty ? null : () async {
                                  final isUnarchive = _showArchived == true;
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(isUnarchive ? AppLocalizations.of(context)!.unarchiveSelected : AppLocalizations.of(context)!.archiveSelected),
                                      content: Text(isUnarchive
                                          ? AppLocalizations.of(context)!.unarchivedRequests(curSelected.length.toString())
                                          : AppLocalizations.of(context)!.archivedRequests(curSelected.length.toString())),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(AppLocalizations.of(context)!.cancel)),
                                        ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(isUnarchive ? AppLocalizations.of(context)!.unarchive : AppLocalizations.of(context)!.archive)),
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
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUnarchive ? AppLocalizations.of(context)!.unarchivedRequests(curSelected.length.toString()) : AppLocalizations.of(context)!.archivedRequests(curSelected.length.toString()))));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedWithError(e.toString()))));
                                  }
                                },
                                icon: Icon(_showArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                                label: Text(_showArchived ? AppLocalizations.of(context)!.unarchiveSelected : AppLocalizations.of(context)!.archiveSelected),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: curSelected.isEmpty ? null : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(AppLocalizations.of(context)!.deleteSelected,style: const TextStyle(color: Color.fromARGB(255, 240, 239, 241)),),
                                      content: Text(AppLocalizations.of(context)!.confirmDeleteSelectedRequests(curSelected.length.toString())),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(AppLocalizations.of(context)!.cancel)),
                                        ElevatedButton(onPressed: () => Navigator.of(context).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text(AppLocalizations.of(context)!.delete)),
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
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.deletedRequests(curSelected.length.toString()))));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToDeleteRequests(e.toString()))));
                                  }
                                },
                                icon: const Icon(Icons.delete_outline),
                                label: Text(AppLocalizations.of(context)!.deleteSelected),
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
                                  label: Text(AppLocalizations.of(context)!.id),
                                  onSort: (columnIndex, ascending) {
                                    _sort<num>((req) => req.id ?? 0, columnIndex, ascending);
                                  },
                                ),
                                DataColumn(
                                  label: Text(
                                    userController.currentUser.role!.id != 2
                                        ? AppLocalizations.of(context)!.createdBy
                                        : AppLocalizations.of(context)!.validatedBy,
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    _sort<String>((req) => req.requestedBy?.toString() ?? '', columnIndex, ascending);
                                  },
                                ),
                                DataColumn(
                                  label: Text(AppLocalizations.of(context)!.dateSubmitted),
                                  onSort: (columnIndex, ascending) {
                                    _sort<String>((req) => req.startDate?.toString() ?? '', columnIndex, ascending);
                                  },
                                ),
                                DataColumn(
                                  label: Text(AppLocalizations.of(context)!.dueDate),
                                  onSort: (columnIndex, ascending) {
                                    _sort<String>((req) => req.endDate?.toString() ?? '', columnIndex, ascending);
                                  },
                                ),
                                DataColumn(
                                  label: Text(AppLocalizations.of(context)!.priority),
                                  onSort: (columnIndex, ascending) {
                                    _sort<String>((req) => req.priority?.toString() ?? '', columnIndex, ascending);
                                  },
                                ),
                                DataColumn(
                                  label: Text(AppLocalizations.of(context)!.status),
                                  onSort: (columnIndex, ascending) {
                                    _sort<String>((req) => req.status?.toString() ?? '', columnIndex, ascending);
                                  },
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 100,
                                    child: Center(child: Text(AppLocalizations.of(context)!.actions)),
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
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

