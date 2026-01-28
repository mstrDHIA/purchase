// ignore_for_file: unused_field, unused_local_variable, unused_import
import 'package:flutter_application_1/models/datasources/purchase_order_datasource.dart';
import 'package:flutter_application_1/screens/Purchase%20order/Edit_purchase_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/view_purchase_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/product_controller.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

class PurchaseOrderPage extends StatelessWidget {
  final PurchaseOrderController? controller;

  const PurchaseOrderPage({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      // Reuse an existing controller instance (useful when navigating after creating an order)
      return ChangeNotifierProvider.value(
        value: controller!,
        child: const _PurchaseOrderPageBody(),
      );
    }

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
  Future<void>? _usersFuture;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex = 0; // default to ID column
  bool _sortAscending = false; // default descending order
  String? _priorityFilter;
  String? _statusFilter;
  bool _showArchived = false;
  DateTime? _selectedSubmissionDate;
  DateTime? _selectedDueDate;
  // Families (N2) and Subfamilies (N3) filters
  Map<String, List<String>> dynamicProductFamilies = {};
  bool _loadingFamilies = false;
  String? _familyFilter;
  String? _subFamilyFilter;
  // Search bar controller and value
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';


  @override
  void initState() {
    super.initState();
    userController = Provider.of<UserController>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = Provider.of<PurchaseOrderController>(context, listen: false);
      
      // Wait for orders to be fetched
      await controller.fetchOrders();
      _fetchProductFamilies();
      
      // Now auto-archive after orders are loaded
      if (mounted) {
        await _autoArchiveOldOrders();
      }
    });
  }

  // Auto-archive purchase orders older than 2 weeks
  Future<void> _autoArchiveOldOrders() async {
    try {
      final controller = Provider.of<PurchaseOrderController>(context, listen: false);
      final now = DateTime.now();
      final twoWeeksAgo = now.subtract(const Duration(days: 14));
      
      print('🔄 Starting auto-archive check for POs (checking before: ${twoWeeksAgo.toLocal()})');
      print('📊 Total POs to check: ${controller.orders.length}');

      int archivedCount = 0;
      int unarchivedCount = 0;
      
      for (var order in controller.orders) {
        // First: unarchive any archived items with status that shouldn't be archived
        if (order.isArchived ?? false) {
          final status = (order.status ?? '').toString().toLowerCase();
          if (status != 'rejected' && status != 'approved') {
            print('🔓 Unarchiving PO ${order.id} with status "$status"');
            try {
              await controller.unarchivePurchaseOrder(order.id);
              unarchivedCount++;
              print('✓ Unarchived PO ${order.id}');
            } catch (e) {
              print('❌ Failed to unarchive PO ${order.id}: $e');
            }
            continue;
          }
        }
        
        // Skip already archived orders
        if (order.isArchived ?? false) {
          print('⏭️ Skipping already archived PO ${order.id}');
          continue;
        }
        
        // Only auto-archive if status is rejected or approved
        final status = (order.status ?? '').toString().toLowerCase();
        if (status != 'rejected' && status != 'approved') {
          print('⏳ PO ${order.id} status is "$status" (not rejected/approved), skipped');
          continue;
        }
        
        // Check if order's updatedAt is older than 2 weeks
        final lastUpdate = order.updatedAt ?? order.createdAt;
        if (lastUpdate != null && lastUpdate.isBefore(twoWeeksAgo)) {
          print('📋 PO ${order.id} last updated: ${lastUpdate.toLocal()} - archiving...');
          try {
            await controller.archivePurchaseOrder(order.id);
            archivedCount++;
            print('✓ Auto-archived PO ${order.id}');
          } catch (e) {
            print('❌ Failed to auto-archive PO ${order.id}: $e');
          }
        } else {
          print('⏳ PO ${order.id} is recent (${lastUpdate?.toLocal()}), skipped');
        }
      }
      
      // Refresh list after archiving/unarchiving
      if ((archivedCount > 0 || unarchivedCount > 0) && mounted) {
        await controller.fetchOrders();
        print('✓ Auto-archived $archivedCount, Unarchived $unarchivedCount - refreshing list');
      } else {
        print('ℹ️ No changes needed (archived: $archivedCount, unarchived: $unarchivedCount)');
      }
    } catch (e) {
      print('❌ Error in _autoArchiveOldOrders: $e');
    }
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
        // setState(() {
          
        // });
      }
      final rawStatus = (order.status ?? '').toString();
      final statusLower = rawStatus.toLowerCase();
      final displayStatus = (statusLower == 'edited') ? 'pending' : rawStatus;
      return {
        // keep id as numeric to allow proper numeric sorting (not string lexicographic)
        'id': order.id ?? 0,
        'actionCreatedBy': actionCreatedBy,
        'dateSubmitted': parseDate(order.startDate),
        'dueDate': parseDate(order.endDate),
        'priority': order.priority ?? '',
        'statuss': rawStatus,
        'displayStatus': displayStatus,
        'original': order,
      };
    }).toList();
    // Search filter: only show orders that match the search text in any main field
    if (_searchText.isNotEmpty) {
      final searchLower = _searchText.toLowerCase();
      mapped = mapped.where((order) =>
        order['id'].toString().toLowerCase().contains(searchLower) ||
        (order['actionCreatedBy'] ?? '').toString().toLowerCase().contains(searchLower) ||
        (order['priority'] ?? '').toString().toLowerCase().contains(searchLower) ||
        (order['statuss'] ?? '').toString().toLowerCase().contains(searchLower) ||
        (order['displayStatus'] ?? '').toString().toLowerCase().contains(searchLower)
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
      mapped = mapped.where((order) => ((order['displayStatus'] ?? order['statuss'])?.toString() ?? '').toLowerCase() == _statusFilter!.toLowerCase()).toList();
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

    // Apply family/subfamily filters (N2/N3) — match if any product line in the order has the family/subfamily
    if (_familyFilter != null) {
      mapped = mapped.where((order) => (order['original'].products?.any((p) => (p.family?.toString() == _familyFilter)) ?? false)).toList();
    }
    if (_subFamilyFilter != null) {
      mapped = mapped.where((order) => (order['original'].products?.any((p) => (p.subFamily?.toString() == _subFamilyFilter)) ?? false)).toList();
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
        sortKey = 'statuss';
      }
      mapped.sort((a, b) {
        dynamic aValue = a[sortKey];
        dynamic bValue = b[sortKey];
        if (aValue is num && bValue is num) {
          return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else if (aValue is String && bValue is String) {
          return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          return _sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        }
        return 0;
      });
    }

    // If current user is role 6 (accountant), restrict visible orders to key statuses (including edited which will be shown as pending)
    if (Provider.of<UserController>(context, listen: false).currentUser.role?.id == 6) {
      mapped = mapped.where((order) {
        final s = (order['statuss'] ?? '').toString().toLowerCase();
        return s == 'approved' || s == 'rejected' || s == 'edited' || s == 'pending' || s == 'rework';
      }).toList();
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

  // Fetch product categories and build a families -> subfamilies map
  Future<void> _fetchProductFamilies() async {
    setState(() {
      _loadingFamilies = true;
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
      // ignore errors for now
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

  void _clearFilters() {
    setState(() {
      _priorityFilter = null;
      _statusFilter = null;
      _showArchived = false;
      _selectedSubmissionDate = null;
      _selectedDueDate = null;
      _familyFilter = null;
      _subFamilyFilter = null;
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
          return Center(child: Text('${AppLocalizations.of(context)!.error}: ${controller.error}'));
        }
        final allOrders = controller.orders;
        final filteredOrders = _filteredAndSortedOrders(allOrders);
        final dataSource = _PurchaseOrderDataSource(
          filteredOrders,
          _dateFormat,
          context: context,
          onView: viewPurchaseOrder,
          onEdit: editPurchaseOrder,
          onDelete: deletePurchaseOrder,
          onArchive: archivePurchaseOrder,
          onUnarchive: unarchivePurchaseOrder,
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.purchaseOrders),
          ),
          body: 
          (MediaQuery.of(context).size.width<600)?
                          ListView.builder(itemBuilder:  (context,index){
                            final order = filteredOrders[index];
                            final currentRoleIdLocal = Provider.of<UserController>(context, listen: false).currentUser.role?.id;
                            final isSupervisorN3Local = currentRoleIdLocal == 6;
                            final isRoleN4Local = currentRoleIdLocal == 4;
                            final itemStatusLocal = (order['statuss'] ?? '').toString().toLowerCase();
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text('${AppLocalizations.of(context)!.purchaseOrder} #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text('${AppLocalizations.of(context)!.createdBy}: ${order['actionCreatedBy']}'),
                                    Text('${AppLocalizations.of(context)!.dateSubmitted}: ${_dateFormat.format(order['dateSubmitted'])}'),
                                    Text('${AppLocalizations.of(context)!.dueDate}: ${_dateFormat.format(order['dueDate'])}'),
                                    Text(AppLocalizations.of(context)!.priorityLabel(order['priority'] ?? '-')),
                                    Text('${AppLocalizations.of(context)!.statusLabel}: ${(() {
                                      final s = (order['statuss'] ?? '').toString();
                                      final lv = s.toLowerCase();
                                      return lv == 'pending'
                                          ? AppLocalizations.of(context)!.pending
                                          : lv == 'approved'
                                              ? AppLocalizations.of(context)!.approved
                                              : lv == 'rejected'
                                                  ? AppLocalizations.of(context)!.rejected
                                                  : (lv == 'transformed' || lv == 'converted')
                                                      ? AppLocalizations.of(context)!.transformed
                                                      : lv == 'edited'
                                                          ? AppLocalizations.of(context)!.edited
                                                          : s[0].toUpperCase() + s.substring(1);
                                    })()}'),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(value: 'view', child: Text(AppLocalizations.of(context)!.view)),
                                    if (!isRoleN4Local) PopupMenuItem(value: 'edit', enabled: !(isSupervisorN3Local && itemStatusLocal == 'approved') && itemStatusLocal != 'pending' && itemStatusLocal != 'edited', child: Text(AppLocalizations.of(context)!.edit)),
                                    PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context)!.delete)),
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
              // Batch actions shown when any row is selected
              AnimatedBuilder(
                animation: dataSource,
                builder: (context, _) {
                  if (dataSource.selectedRowCount == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final bool? confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                backgroundColor: const Color(0xFFF7F2FA),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 360),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _showArchived ? AppLocalizations.of(context)!.unarchivePurchaseOrders : AppLocalizations.of(context)!.archivePurchaseOrders,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          AppLocalizations.of(context)!.confirmArchivePurchaseOrders(_showArchived ? AppLocalizations.of(context)!.unarchive : AppLocalizations.of(context)!.archive, dataSource.selectedRowCount),
                                          style: const TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Color(0xFF6F4DBF), fontWeight: FontWeight.w500, fontSize: 14)),
                                            ),
                                            const SizedBox(width: 16),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _showArchived ? Colors.green : Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              child: Text(_showArchived ? AppLocalizations.of(context)!.unarchive : AppLocalizations.of(context)!.archive, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                              final ids = dataSource.getSelectedIds();
                              for (final id in ids) {
                                try {
                                  if (_showArchived) {
                                    await controller.unarchivePurchaseOrder(id);
                                  } else {
                                    await controller.archivePurchaseOrder(id);
                                  }
                                } catch (e) {
                                  // ignore individual errors; continue
                                }
                              }
                              await controller.fetchOrders();
                              dataSource.clearSelection();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_showArchived ? AppLocalizations.of(context)!.unarchivedPurchaseOrders(ids.length) : AppLocalizations.of(context)!.archivedPurchaseOrders(ids.length))));
                            }
                          },
                          icon: Icon(_showArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                          label: Text(_showArchived ? AppLocalizations.of(context)!.unarchiveSelected : AppLocalizations.of(context)!.archiveSelected),
                          style: ElevatedButton.styleFrom(backgroundColor: _showArchived ? Colors.green : Colors.blue, foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final bool? confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                backgroundColor: const Color(0xFFF7F2FA),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 360),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(AppLocalizations.of(context)!.deletePurchaseOrders, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                        const SizedBox(height: 12),
                                        Text(AppLocalizations.of(context)!.confirmDeletePurchaseOrders(dataSource.selectedRowCount), style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Color(0xFF6F4DBF), fontWeight: FontWeight.w500, fontSize: 14))),
                                            const SizedBox(width: 16),
                                            ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
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
                              final ids = dataSource.getSelectedIds();
                              for (final id in ids) {
                                try {
                                  await controller.deleteOrder(id);
                                } catch (e) {
                                  // ignore individual errors
                                }
                              }
                              await controller.fetchOrders();
                              dataSource.clearSelection();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.deletedPurchaseOrders(ids.length))));
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: Text(AppLocalizations.of(context)!.deleteSelected),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.selectedCount(dataSource.selectedRowCount), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                },
              ),
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
                            header: Text(AppLocalizations.of(context)!.purchaseOrdersTable),
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
                                  label: Text(AppLocalizations.of(context)!.idShort),
                                  onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                              DataColumn(
                                  label: Text(AppLocalizations.of(context)!.createdBy),
                                  onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                              DataColumn(
                                  label: Text(AppLocalizations.of(context)!.dateSubmitted),
                                  onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                              DataColumn(
                                  label: Text(AppLocalizations.of(context)!.dueDate),
                                  onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                              DataColumn(
                                  label: Text(AppLocalizations.of(context)!.priorityShort),
                                  onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                              DataColumn(
                                  label: Text(AppLocalizations.of(context)!.statusLabel),
                                  onSort: (columnIndex, ascending) => _sort(columnIndex, ascending)),
                              DataColumn(label: Text(AppLocalizations.of(context)!.actions)),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large search bar on the left (Expanded)
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _searchController,
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
                style: const TextStyle(color: Colors.deepPurple, fontSize: 16),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Filters on the right
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Filter by Priority
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _priorityFilter = value.isEmpty ? null : value;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: '', child: Text(AppLocalizations.of(context)!.all)),
                  PopupMenuItem(value: 'high', child: Text(AppLocalizations.of(context)!.high)),
                  PopupMenuItem(value: 'medium', child: Text(AppLocalizations.of(context)!.medium)),
                  PopupMenuItem(value: 'low', child: Text(AppLocalizations.of(context)!.low)),
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
                        _priorityFilter == null ? AppLocalizations.of(context)!.filterByPriority : AppLocalizations.of(context)!.priorityLabel(_priorityFilter![0].toUpperCase() + _priorityFilter!.substring(1)),
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
                        _familyFilter == null ? AppLocalizations.of(context)!.filterByFamily : '${AppLocalizations.of(context)!.familyLabel}: ${_familyFilter!}',
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
                        _subFamilyFilter == null ? AppLocalizations.of(context)!.filterBySubfamily : '${AppLocalizations.of(context)!.subfamilyLabel}: ${_subFamilyFilter!}',
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
              ],
              // Filter by Status
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _statusFilter = value.isEmpty ? null : value;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: '', child: Text(AppLocalizations.of(context)!.all)),
                  PopupMenuItem(value: 'pending', child: Text(AppLocalizations.of(context)!.pending)),
                  PopupMenuItem(value: 'approved', child: Text(AppLocalizations.of(context)!.approved)),
                  PopupMenuItem(value: 'rejected', child: Text(AppLocalizations.of(context)!.rejected)),
                  PopupMenuItem(value: 'rework', child: Text('Rework')),
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
                        _statusFilter == null
                            ? AppLocalizations.of(context)!.filterStatus
                            : '${AppLocalizations.of(context)!.status}: '
                                '${_statusFilter == 'pending' ? AppLocalizations.of(context)!.pending : _statusFilter == 'approved' ? AppLocalizations.of(context)!.approved : _statusFilter == 'rejected' ? AppLocalizations.of(context)!.rejected : _statusFilter == 'transformed' ? AppLocalizations.of(context)!.transformed : _statusFilter == 'edited' ? AppLocalizations.of(context)!.edited : _statusFilter![0].toUpperCase() + _statusFilter!.substring(1)}',
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
                      ? AppLocalizations.of(context)!.filterBySubmissionDate
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
                      ? AppLocalizations.of(context)!.filterByDueDate
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
                  _showArchived ? AppLocalizations.of(context)!.hideArchived : AppLocalizations.of(context)!.showArchived,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Clear Filters
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  AppLocalizations.of(context)!.clearFilters,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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
                Text(
                  AppLocalizations.of(context)!.deletePurchaseOrder,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.confirmDeletePurchaseOrders(1),
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: const TextStyle(
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
                      child: Text(
                        AppLocalizations.of(context)!.delete,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.purchaseOrderDeleted(order['id']))) ,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToDeletePurchaseOrder(e.toString()))),
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
                Text(
                  AppLocalizations.of(context)!.archivePurchaseOrders,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.confirmArchivePurchaseOrders(AppLocalizations.of(context)!.archive, 1),
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: const TextStyle(
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
                      child: Text(
                        AppLocalizations.of(context)!.archive,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
        if (mounted) {
          setState(() {});
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.archivedPurchaseOrder(order['id']))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToArchivePurchaseOrder(e.toString()))),
        );
      }
    }
  }

  void unarchivePurchaseOrder(Map<String, dynamic> order) async {
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
                Text(
                  AppLocalizations.of(context)!.unarchivePurchaseOrders,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.confirmArchivePurchaseOrders(AppLocalizations.of(context)!.unarchive, 1),
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: const TextStyle(
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
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.unarchive,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
        await controller.unarchivePurchaseOrder(order['id']);
        await controller.fetchOrders();
        if (mounted) {
          setState(() {});
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.unarchivedPurchaseOrder(order['id']))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToArchivePurchaseOrder(e.toString()))),
        );
      }
    }
  }
}

class _PurchaseOrderDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;
  BuildContext? context;
  final DateFormat _dateFormat;
  final Function(Map<String, dynamic>) onView;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onArchive;
  final Function(Map<String, dynamic>) onUnarchive;

  _PurchaseOrderDataSource(
    this._data,
    this._dateFormat, {
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
    required this.onUnarchive,
    required this.context,
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
      selected: _selectedIds.contains(item['id']),
      onSelectChanged: (selected) {
        if (selected == null) return;
        if (selected) {
          _selectedIds.add(item['id']);
        } else {
          _selectedIds.remove(item['id']);
        }
        notifyListeners();
      },
      cells: [
        DataCell(Text(item['id']?.toString() ?? '-')),
        DataCell(Text(item['actionCreatedBy'] ?? '-')),
        DataCell(Text(formatDateCell(item['dateSubmitted']))),
        DataCell(Text(formatDateCell(item['dueDate']))),
        DataCell(_buildPriorityChip(item['priority'] ?? '-')),
        DataCell(_buildStatusChip(item['displayStatus'] ?? item['statuss'] ?? '-')),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined),
              onPressed: () => onView(item),
              tooltip: AppLocalizations.of(context!)!.view,
            ),
            Builder(
              builder: (ctx) {
                final currentRoleId = Provider.of<UserController>(context!, listen: false).currentUser.role?.id;
                final isRoleN4 = currentRoleId == 6;
                final isSupervisorN3 = currentRoleId == 4;
                final itemStatus = (item['statuss'] ?? '').toString().toLowerCase();
                if (isRoleN4) {
                  // N4 users should not see the Edit action at all
                  return const SizedBox.shrink();
                }
                // Cannot edit if status is pending or edited (edited displays as pending for role 6)
                if (itemStatus == 'pending' || itemStatus == 'edited') {
                  return Opacity(
                    opacity: 0.4,
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: null,
                      tooltip: AppLocalizations.of(context!)!.edit,
                    ),
                  );
                }
                // Role 4 users cannot edit rejected orders (show disabled icon)
                if (isSupervisorN3 && itemStatus == 'rejected') {
                  return Opacity(
                    opacity: 0.4,
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: null,
                      tooltip: AppLocalizations.of(context!)!.edit,
                    ),
                  );
                }
                // N3 users cannot edit approved orders (show disabled icon)
                if (isSupervisorN3 && itemStatus == 'approved') {
                  return Opacity(
                    opacity: 0.4,
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: null,
                      tooltip: AppLocalizations.of(context!)!.edit,
                    ),
                  );
                }
                // Otherwise show enabled edit
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => onEdit(item),
                  tooltip: AppLocalizations.of(context!)!.edit,
                );
              },
            ),
            Builder(
              builder: (context) {
                final original = item['original'];
                final bool isArchived = (original?.isArchived ?? false);
                if (isArchived) {
                  return IconButton(
                    icon: const Icon(Icons.restore_outlined),
                    onPressed: () => onUnarchive(item),
                    tooltip: AppLocalizations.of(this.context!)!.unarchive,
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: () => onArchive(item),
                  tooltip: AppLocalizations.of(this.context!)!.archive,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => onDelete(item),
              tooltip: AppLocalizations.of(this.context!)!.delete,
            ),
          ],
        )),
      ],
    );
  }

  final Set<dynamic> _selectedIds = <dynamic>{};

  List<dynamic> getSelectedIds() => _selectedIds.toList(growable: false);

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
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
    final label = (v == 'low') ? AppLocalizations.of(this.context!)!.low : (v == 'medium') ? AppLocalizations.of(this.context!)!.medium : (v == 'high') ? AppLocalizations.of(this.context!)!.high : v;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 80,
        constraints: const BoxConstraints(minWidth: 36),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final v = status.toLowerCase();
    // status value: $v
    Color bgColor;
    if (v == 'approved') {
      bgColor = const Color(0xFF4CAF50); // green
    } else if (v == 'pending') {
      bgColor = const Color(0xFFFFB74D); // orange
    } else if (v == 'rejected') {
      bgColor = const Color(0xFFEF5350); // red
    } else if (v == 'transformed' || v == 'converted') {
      bgColor = const Color(0xFF42A5F5); // blue
    }
    else if (v == 'rework' || v == 'for modification' || v.contains('for')) {
      bgColor = const Color.fromARGB(255, 1, 213, 241); // sky blue
    }
     else {
      bgColor = Colors.grey;
    }
    final label = (v == 'approved') ? AppLocalizations.of(this.context!)!.approved : (v == 'pending') ? AppLocalizations.of(this.context!)!.pending : (v == 'rejected') ? AppLocalizations.of(this.context!)!.rejected : (v == 'transformed' || v == 'converted') ? AppLocalizations.of(this.context!)!.transformed : (v == 'for modification' || v == 'rework' || v.contains('for')) ? 'Rework' : v;
    // Capitalize first letter
    final displayLabel = label.isNotEmpty 
        ? label[0].toUpperCase() + label.substring(1) 
        : label;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: 80,
        constraints: const BoxConstraints(minWidth: 0),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          displayLabel,
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
  int get selectedRowCount => _selectedIds.length;
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.viewPurchaseOrder(order['id']))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.idLabel(order['id']?.toString() ?? '-'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),
            Text('${AppLocalizations.of(context)!.createdBy}: ${order['actionCreatedBy']}'),
            Text('${AppLocalizations.of(context)!.dateSubmitted}: ${formatDateCell(order['dateSubmitted'])}'),
            Text('${AppLocalizations.of(context)!.dueDate}: ${formatDateCell(order['dueDate'])}'),
            Text(AppLocalizations.of(context)!.priorityLabel(order['priority'] ?? '-')),
            Text('${AppLocalizations.of(context)!.statusLabel}: ${(() {
                  final s = (order['statuss'] ?? '').toString();
                  final lv = s.toLowerCase();
                  return lv == 'pending'
                      ? AppLocalizations.of(context)!.pending
                      : lv == 'approved'
                          ? AppLocalizations.of(context)!.approved
                          : lv == 'rejected'
                              ? AppLocalizations.of(context)!.rejected
                              : (lv == 'transformed' || lv == 'converted')
                                  ? AppLocalizations.of(context)!.transformed
                                  : lv == 'edited'
                                      ? AppLocalizations.of(context)!.edited
                                      : s[0].toUpperCase() + s.substring(1);
                })()}'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(AppLocalizations.of(context)!.back),
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