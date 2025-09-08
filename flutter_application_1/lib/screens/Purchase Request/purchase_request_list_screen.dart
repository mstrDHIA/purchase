import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/screens/Purchase%20Request/requestor_form_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order_screen.dart' as purchase_order;
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
                Expanded(
                  child: Consumer<PurchaseRequestController>(
                    builder: (context, purchaseRequestController, child) {
                      print('DataSource: ${purchaseRequestController.dataSource.requests}'); // Log data source requests
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: Container(
                            // width: MediaQuery.of(context).size.width * 0.95,
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
                              columnSpacing: 190, // Reduced spacing
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

