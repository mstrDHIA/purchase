import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:flutter_application_1/screens/Purchase%20Request/requestor_form_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20Request/purchase_request_view_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order_screen.dart' as purchase_order;
import 'package:flutter_application_1/network/purchase_request_network.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseRequestPage extends StatefulWidget {
  const PurchaseRequestPage({super.key});

  @override
  State<PurchaseRequestPage> createState() => _PurchaseRequestPageState();
}

class _PurchaseRequestPageState extends State<PurchaseRequestPage> {
  late PurchaseRequestController purchaseRequestController;
  final List<Map<String, dynamic>> _PurchaseRequests = [];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  bool _isLoading = false;

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
    );
  }

  void editPurchaseRequest(Map<String, dynamic> order) async {
    print('Edit button clicked for order: ${order['id']}'); // Debug log
    final updatedOrder = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseRequestView(
          purchaseRequest: PurchaseRequest.fromJson(order),
          onSave: (newOrder) {
            Navigator.pop(context, newOrder);
          }, order: {},
        ),
      ),
    );

    if (updatedOrder != null) {
      // Refresh the list from backend to reflect the latest data
      await purchaseRequestController.fetchRequests(context);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase order ${updatedOrder['id']} updated')),
      );
    }
  }

  // void deletePurchaseRequest(Map<String, dynamic> order) async {
  //   final bool? confirmed = await showDialog<bool>(
  //     context: context,
  //     barrierColor: Colors.black.withOpacity(0.2),
  //     builder: (context) => Dialog(
  //       backgroundColor: const Color(0xF7F3F7FF),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       child: ConstrainedBox(
  //         constraints: const BoxConstraints(
  //           maxWidth: 340, // Taille max du dialog (plus petit)
  //           minWidth: 260,
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 'Delete Purchase',
  //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
  //               ),
  //               const SizedBox(height: 16),
  //               Text(
  //                 'Are you sure you want to delete ${order['id']}?.',
  //                 style: const TextStyle(fontSize: 16),
  //               ),
  //               const SizedBox(height: 28),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   TextButton(
  //                     onPressed: () => Navigator.pop(context, false),
  //                     child: const Text(
  //                       'Cancel',
  //                       style: TextStyle(color: Colors.deepPurple, fontSize: 16),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   ElevatedButton(
  //                     onPressed: () => Navigator.pop(context, true),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.red,
  //                       foregroundColor: Colors.white,
  //                       padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(24),
  //                       ),
  //                       elevation: 0,
  //                     ),
  //                     child: const Text('Delete', style: TextStyle(fontSize: 16)),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );

  //   if (confirmed == true) {
  //     setState(() {
  //       _PurchaseRequests.removeWhere((o) => o['id'] == order['id']);
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Purchase request ${order['id']} deleted')),
  //     );
  //   }
  // }

  // Future<void> _submitPurchaseRequest(Map<String, dynamic> requestData) async {
  //   try {
  //     final response = await PurchaseRequestNetwork().createPurchaseRequest(requestData);

  //     print('Response from API: $response'); // Vérifie les données reçues

  //     if (response.containsKey('id')) {
  //       setState(() {
  //         _PurchaseRequests.add(response); // Ajout local après succès
  //         print('_PurchaseRequests after addition: $_PurchaseRequests'); // Vérifie les données ajoutées
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Purchase request ajoutée avec succès')),
  //       );
  //     } else {
  //       throw Exception('Réponse invalide de l\'API');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Erreur lors de l\'ajout de la demande : $e')),
  //     );
  //   }
  // }

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
    
    // if (newRequest != null) {
      //  await Provider.of<PurchaseRequestController>(context, listen: false).addRequest(newRequest);
      // await _submitPurchaseRequest(newRequest); 
    // }
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
                Expanded(
                  child: Consumer<PurchaseRequestController>(
                    builder: (context, purchaseRequestController, child) {
                      print('DataSource: ${purchaseRequestController.dataSource.requests}'); // Log data source requests
                      return SingleChildScrollView(
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
                            columnSpacing: 200, // Reduced spacing
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
                                  width: 120, // Fixed width for actions
                                  child: const Center(child: Text('Actions')),
                                ),
                              ),
                            ],
                            source: purchaseRequestController.dataSource,
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

class PurchaseRequestDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _requests;
  final BuildContext context;
  int _selectedCount = 0;

  PurchaseRequestDataSource(this._requests, this.context);

  @override
  DataRow? getRow(int index) {
    if (index >= _requests.length) return null;
    final order = _requests[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(order['id'].toString())),
        DataCell(Text(order['createdBy'] ?? '')),
        DataCell(
          Text(
            order['dateSubmitted'] != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                    DateTime.tryParse(order['dateSubmitted'].toString().split('.').first) ?? DateTime.now())
                : ''
          ),
        ),
        DataCell(
          Text(
            order['dueDate'] != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                    DateTime.tryParse(order['dueDate'].toString().split('.').first) ?? DateTime.now())
                : ''
          ),
        ),
        DataCell(Text(order['priority'] ?? '')),
        DataCell(Text(order['status'] ?? '')),
        DataCell(SizedBox(
          width: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_red_eye),
                tooltip: 'View',
                onPressed: () => viewPurchaseRequest(order),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () => editPurchaseRequest(order),
              ),
             
            ],
          ),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _requests.length;

  @override
  int get selectedRowCount => _selectedCount;

  void viewPurchaseRequest(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => purchase_order.ViewPurchasePage(order: order),
      ),
    );
  }

  void editPurchaseRequest(Map<String, dynamic> order) async {
    print('Edit button clicked for order: ${order['id']}'); // Debug log
    final updatedOrder = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseRequestView(
          purchaseRequest: PurchaseRequest.fromJson(order),
          onSave: (newOrder) {
            Navigator.pop(context, newOrder);
          }, order: {},
        ),
      ),
    );

    if (updatedOrder != null) {
      // Update the order in the data source
      final index = _requests.indexWhere((o) => o['id'] == updatedOrder['id']);
      if (index != -1) {
        _requests[index] = updatedOrder;
      }
    }
  }
}
