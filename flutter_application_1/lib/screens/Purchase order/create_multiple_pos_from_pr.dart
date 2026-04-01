import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/purchase_request.dart';
import '../../controllers/purchase_order_controller.dart';
import '../../controllers/supplier_controller.dart';
import 'pushase_order_screen.dart';

class POLine {
  String? title;
  String? description;
  String? product;
  String? family;
  String? subFamily;
  int quantity;
  String? supplier;
  double unitPrice;
  String currency;
  String status;

  POLine({
    this.title,
    this.description,
    this.product,
    this.family,
    this.subFamily,
    this.supplier,
    this.quantity = 1,
    this.unitPrice = 0.0,
    this.currency = 'USD',
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title ?? '',
      'description': description ?? '',
      'product': product ?? '',
      'family': family ?? '',
      'subFamily': subFamily ?? '',
      'supplier': supplier ?? '',
      'quantity': quantity,
      'unit_price': unitPrice,
      'currency': currency,
      'statuss': status,
    };
  }
}

class CreateMultiplePOsFromPR extends StatefulWidget {
  final PurchaseRequest purchaseRequest;

  const CreateMultiplePOsFromPR({
    super.key,
    required this.purchaseRequest,
  });

  @override
  State<CreateMultiplePOsFromPR> createState() => _CreateMultiplePOsFromPRState();
}

class _CreateMultiplePOsFromPRState extends State<CreateMultiplePOsFromPR> {
  List<POLine> poLines = [];
  List<dynamic> _createdPOs = [];  // Store created POs to display
  bool _isSaving = false;
  String? _error;
  String? _success;
  
  late SupplierController supplierController;
  late List<String> suppliers = [];
  
  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'TND': 'DT',
  };

  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    supplierController = Provider.of<SupplierController>(context, listen: false);
    supplierController.fetchSuppliers();
    _loadSuppliers();
    _initializeFromPR();
  }

  void _initializeFromPR() {
    // Pré-remplir avec les produits de la PR
    if (widget.purchaseRequest.products != null && widget.purchaseRequest.products!.isNotEmpty) {
      poLines = widget.purchaseRequest.products!.map((product) {
        return POLine(
          title: '${widget.purchaseRequest.title ?? 'PO'} - ${product.product ?? 'Item'}',
          description: widget.purchaseRequest.description ?? '',
          product: product.product ?? '',
          family: product.family ?? '',
          subFamily: product.subFamily ?? '',
          quantity: product.quantity,
          unitPrice: 0.0,
          currency: 'USD',
          status: 'pending',
        );
      }).toList();
    } else {
      poLines = [POLine()];
    }
  }

  void _loadSuppliers() {
    suppliers = supplierController.suppliers
        .map((s) => s.name ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    suppliers.add('Autre');
  }

  void _addPOLine() {
    setState(() {
      // Ajouter un POLine avec les données pré-remplies de la PR
      if (widget.purchaseRequest.products != null && widget.purchaseRequest.products!.isNotEmpty) {
        final firstProduct = widget.purchaseRequest.products!.first;
        poLines.add(POLine(
          title: '${widget.purchaseRequest.title ?? 'PO'} - ${firstProduct.product ?? 'Item'}',
          description: widget.purchaseRequest.description ?? '',
          product: firstProduct.product ?? '',
          family: firstProduct.family ?? '',
          subFamily: firstProduct.subFamily ?? '',
          quantity: firstProduct.quantity,
          unitPrice: 0.0,
          currency: 'Dollar',
          status: 'pending',
        ));
      } else {
        poLines.add(POLine());
      }
    });
  }

  void _removePOLine(int index) {
    if (poLines.length > 1) {
      setState(() {
        poLines.removeAt(index);
      });
    }
  }

  Future<void> _createMultiplePOs() async {
    // Validation
    if (poLines.isEmpty) {
      setState(() => _error = 'Add at least one PO');
      return;
    }

    for (var line in poLines) {
      if (line.title == null || line.title!.isEmpty) {
        setState(() => _error = 'All titles must be filled');
        return;
      }
      if (line.description == null || line.description!.isEmpty) {
        setState(() => _error = 'All descriptions must be filled');
        return;
      }
      if (line.supplier == null || line.supplier!.isEmpty) {
        setState(() => _error = 'All suppliers must be selected');
        return;
      }
      if (line.unitPrice <= 0) {
        setState(() => _error = 'All unit prices must be greater than 0');
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _error = null;
      _success = null;
    });

    try {
      final poController = Provider.of<PurchaseOrderController>(context, listen: false);
      
      final poListData = poLines.map((line) {
        return {
          'title': line.title,
          'description': line.description,
          'product': line.product,
          'family': line.family ?? '',
          'subfamily': line.subFamily ?? '',
          'supplier': line.supplier,
          'quantity': line.quantity,
          'unit_price': line.unitPrice,
          'currency': line.currency,
          'statuss': line.status,
          'requested_by_user': 1, // ID de l'utilisateur connecté
        };
      }).toList();

      final createdPOs = await poController.createMultiplePOs(
        widget.purchaseRequest.id!,
        poListData,
      );

      // Build success message with PO numbers
      final poNumbers = createdPOs.map((po) => po.poNumber ?? 'PO ${po.id}').join(', ');
      
      setState(() {
        _createdPOs = createdPOs;  // Store POs for display
        _success = 'Created $poNumbers successfully!';
        _isSaving = false;
      });

      // Refresh PO list and navigate to main PO screen after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        // Refresh the PO controller to fetch updated list
        await poController.fetchOrders(page: null, pageSize: null);
        
        // Navigate to PO list screen with the updated controller
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PurchaseOrderPage(controller: poController),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F4DBF),
        title: const Text('Create Purchase Orders from PR', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display PR Info
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Purchase Request Details', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6F4DBF))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('PR ID: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('${widget.purchaseRequest.id}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Title: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Expanded(child: Text(widget.purchaseRequest.title ?? 'N/A')),
                      ],
                    ),
                    if (widget.purchaseRequest.description != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text('Description: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(widget.purchaseRequest.description!),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status Messages
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_success != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_success!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 20),
                  
                  // Display created POs table
                  if (_createdPOs.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Created Purchase Orders', 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6F4DBF))),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('PO Number')),
                              DataColumn(label: Text('Title')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: _createdPOs.map((po) => DataRow(
                              cells: [
                                DataCell(Text(po.id?.toString() ?? '-')),
                                DataCell(Text(po.poNumber ?? '-')),
                                DataCell(Text(po.title ?? '-')),
                                DataCell(Text((po.description ?? '-').length > 30 
                                  ? '${(po.description ?? '').substring(0, 30)}...' 
                                  : po.description ?? '-')),
                                DataCell(Text(po.status?.toUpperCase() ?? '-')),
                              ],
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Returning to PO list in 2 seconds...', 
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final poController = Provider.of<PurchaseOrderController>(context, listen: false);
                            // Refresh PO list before navigating
                            await poController.fetchOrders(page: null, pageSize: null);
                            
                            if (mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => PurchaseOrderPage(controller: poController),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6F4DBF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Back to PO List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                ],
              ),
            const SizedBox(height: 16),

            // PO Lines - Only show if not yet created
            if (_createdPOs.isEmpty) ...[
              const Text('Purchase Orders', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6F4DBF))),
              const SizedBox(height: 16),

              Consumer<SupplierController>(
                builder: (context, supplierCtrl, child) {
                  suppliers = supplierCtrl.suppliers
                      .map((s) => s.name ?? '')
                      .where((name) => name.isNotEmpty)
                      .toList();
                  suppliers.add('Autre');
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: poLines.length,
                    itemBuilder: (context, index) => _buildPOLineCard(index, suppliers),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Add PO Line Button
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _addPOLine,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Another PO', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F4DBF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _createMultiplePOs,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F4DBF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Create All POs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPOLineCard(int index, List<String> supplierList) {
    final line = poLines[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PO ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (poLines.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removePOLine(index),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: TextEditingController(text: line.title ?? ''),
              onChanged: (val) => setState(() => line.title = val),
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: TextEditingController(text: line.description ?? ''),
              onChanged: (val) => setState(() => line.description = val),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            // Product (Read-only from PR)
            TextField(
              readOnly: true,
              controller: TextEditingController(text: line.product ?? ''),
              decoration: InputDecoration(
                labelText: 'Product (from PR)',
                border: const OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),

            // Family & SubFamily (Read-only from PR)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: line.family ?? ''),
                    decoration: InputDecoration(
                      labelText: 'Family (from PR)',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: line.subFamily ?? ''),
                    decoration: InputDecoration(
                      labelText: 'Sub Family (from PR)',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Supplier
            DropdownButtonFormField<String>(
              value: supplierList.contains(line.supplier) ? line.supplier : null,
              items: supplierList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => line.supplier = val),
              decoration: const InputDecoration(
                labelText: 'Supplier *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            // Status
            DropdownButtonFormField<String>(
              value: line.status,
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (val) => setState(() => line.status = val ?? 'pending'),
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            // Quantity (Read-only from PR) & Unit Price & Currency
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: line.quantity.toString()),
                    decoration: InputDecoration(
                      labelText: 'Qty (from PR)',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: line.currency,
                    items: _currencySymbols.keys
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => line.currency = val ?? 'USD'),
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) => setState(() => line.unitPrice = double.tryParse(val) ?? 0.0),
                    decoration: InputDecoration(
                      labelText: 'Unit Price *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixText: _currencySymbols[line.currency],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${_currencySymbols[line.currency]}${(line.unitPrice * line.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
