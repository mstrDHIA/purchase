import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_order.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'dart:convert'; // <-- Import jsonEncode

class ProductLine {

  String? product;
  String? brand;
  int quantity;
  String? supplier;
  double unitPrice;

  ProductLine({
  // this.productId,
    this.product,
    this.brand,
    this.supplier,
    this.quantity = 1,
    this.unitPrice = 12.33,
  });

  Map<String, dynamic> toJson() {
    return {
      // 'product_id': productId, // Removed
      'product': product,
      'brand': brand,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}

class PurchaseOrderForm extends StatefulWidget {
  final Map<String, dynamic> initialOrder;
  final void Function(dynamic newOrder) onSave;

  const PurchaseOrderForm({
    super.key,
    required this.onSave,
    required this.initialOrder,
  });

  @override
  State<PurchaseOrderForm> createState() => _PurchaseOrderFormState();
}

class _PurchaseOrderFormState extends State<PurchaseOrderForm> {
  String? _priority;
  // String? _status; // Removed
  int? _id;
  int? _requestedByUser; // Now int
  int? _approvedBy;      // Now int
  DateTime? _updatedAt;
  List<ProductLine> productLines = [ProductLine()];
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController supplierNameController = TextEditingController();

  bool _isSaving = false;
  String? supplierName;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialOrder;
    if (initial.isNotEmpty) {
      _priority = initial['priority']?.toString();
      _id = initial['id'] is int ? initial['id'] : int.tryParse(initial['id']?.toString() ?? '');
      _requestedByUser = initial['requestedByUser'] is int
          ? initial['requestedByUser']
          : int.tryParse(initial['requestedByUser']?.toString() ?? '') ?? 1;
      _approvedBy = initial['approvedBy'] is int
          ? initial['approvedBy']
          : int.tryParse(initial['approvedBy']?.toString() ?? '') ?? 2;
      _updatedAt = initial['updatedAt'] is DateTime
          ? initial['updatedAt']
          : (initial['updatedAt'] != null ? DateTime.tryParse(initial['updatedAt'].toString()) : null);
      if (_updatedAt == null) {
        _updatedAt = DateTime.now();
      }
      // Pré-remplir le champ Supplier Name si la valeur existe, sinon le chercher dans les produits
      supplierName = initial['supplierName'] ?? initial['supplier'] ?? initial['Supplier'];
      if ((supplierName == null || (supplierName?.isEmpty ?? true)) && initial['products'] != null && initial['products'] is List) {
        for (final p in (initial['products'] as List)) {
          final s = p['supplier']?.toString() ?? p['Supplier']?.toString();
          if (s != null && s.isNotEmpty) {
            supplierName = s;
            break;
          }
        }
      }
      supplierNameController.text = supplierName ?? '';
      

      if (initial['endDate'] != null) {
        try {
          DateTime endDate;
          if (initial['endDate'] is DateTime) {
            endDate = initial['endDate'];
          } else {
            endDate = DateTime.parse(initial['endDate'].toString());
          }
          dueDateController.text = DateFormat('dd-MM-yyyy').format(endDate);
        } catch (_) {
          dueDateController.text = '';
        }
      } else {
        dueDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      }

      noteController.text = initial['description'] ?? '';

      if (initial['products'] != null && initial['products'] is List) {
        productLines = (initial['products'] as List).map((p) {
          return ProductLine(
            // productId: p['product_id'] is int ? p['product_id'] : int.tryParse(p['product_id']?.toString() ?? ''), // Removed
            product: p['product']?.toString(),
            brand: p['brand']?.toString(),
            quantity: (p['quantity'] is int)
                ? p['quantity']
                : int.tryParse(p['quantity'].toString()) ?? 1,
            unitPrice: (p['unit_price'] is double)
                ? p['unit_price']
                : (p['unit_price'] is int)
                    ? (p['unit_price'] as int).toDouble()
                    : double.tryParse(p['unit_price']?.toString() ?? '') ?? 0.0,
          );
        }).toList();
      }
    } else {
      dueDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      supplierNameController.text = supplierName ?? '';
      // Find last id from provider
      final contextController = Provider.of<PurchaseOrderController>(context, listen: false);
      int maxId = 0;
      for (var order in contextController.orders) {
        if (order.id != null) {
          int? id = int.tryParse(order.id.toString());
          if (id != null && id > maxId) maxId = id;
        }
      }
  _id = maxId + 1;
  _priority = null;
  // _status = null; // Removed
  _requestedByUser = 1; // Default user ID
  _approvedBy = 2;      // Default approver ID
  _updatedAt = DateTime.now();
    }
  }

  double get totalPrice => productLines.fold(
        0,
        (sum, p) => sum + (p.unitPrice * p.quantity.toDouble()),
      );

  @override
  void dispose() {
    noteController.dispose();
    dueDateController.dispose();
    supplierNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'high', child: Text('high')),
                      DropdownMenuItem(value: 'medium', child: Text('medium')),
                      DropdownMenuItem(value: 'low', child: Text('low')),
                    ],
                    onChanged: (val) => setState(() => _priority = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Supplier Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: supplierNameController,
              decoration: const InputDecoration(
                labelText: 'Supplier name',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => supplierName = val),
            ),
            const SizedBox(height: 24),

            const Text('Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...productLines.asMap().entries.map((entry) {
              int index = entry.key;
              ProductLine product = entry.value;
              return _buildProductLine(product, index);
            }).toList(),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C7AE6),
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    setState(() => productLines.add(ProductLine())),
              ),
            ),

            const SizedBox(height: 32),

            const Text('Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextFormField(
              controller: dueDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Due date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    dueDateController.text =
                        DateFormat('dd-MM-yyyy').format(pickedDate);
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Note',
                filled: true,
                fillColor: Color(0xFFF0F0F0),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C7AE6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save',
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOrder() async {
    supplierName = supplierNameController.text;
    if (supplierName == null ||
        supplierName!.isEmpty ||
        productLines.any((p) => p.brand == null || p.brand!.isEmpty) ||
        _priority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    // Correction du parsing de la date de fin
    DateTime? parsedEndDate;
    try {
      parsedEndDate = DateFormat('dd-MM-yyyy').parseStrict(dueDateController.text);
    } catch (_) {
      try {
        parsedEndDate = DateFormat('yyyy-MM-dd').parseStrict(dueDateController.text);
      } catch (e) {
        parsedEndDate = null;
      }
    }
    if (parsedEndDate == null || parsedEndDate.year < 2000 || parsedEndDate.year > 2100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid due date.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Adapter la structure des produits pour le backend
      final List<Map<String, dynamic>> productsList = productLines.map((p) => {
        'product': p.product ?? '',
        'brand': p.brand ?? '',
        'quantity': p.quantity,
        'unit_price': p.unitPrice,
        'price': (p.unitPrice * p.quantity),
        'supplier': supplierName,
      }).toList();

      // Construction du body attendu par le backend
      final jsonBody = {
        'id': _id,
        'requested_by_user': _requestedByUser ?? 1,
        'approved_by': _approvedBy ?? 2,
        'start_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'end_date': DateFormat('yyyy-MM-dd').format(parsedEndDate),
        'products': productsList,
        'title': 'Purchase Order',
        'description': noteController.text,
        'status': 'pending', // Always set to pending
        'created_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'updated_at': DateFormat('yyyy-MM-dd').format(_updatedAt ?? DateTime.now()),
        'priority': _priority,
      };

      print('PurchaseOrder JSON body sent to backend:');
      print(jsonEncode(jsonBody)); // <-- Use jsonEncode here

      if (widget.initialOrder.isNotEmpty) {
        widget.onSave(jsonBody);
        if (mounted) Navigator.of(context).pop(jsonBody);
      } else {
        // Ici il faudrait adapter addOrder pour accepter le jsonBody si besoin
        await Provider.of<PurchaseOrderController>(context, listen: false)
            .addOrder(jsonBody); // <-- à adapter côté controller si besoin
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase order saved!')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildProductLine(ProductLine product, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              // Product ID field removed
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: product.product,
                  decoration: const InputDecoration(
                    labelText: 'Product',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => product.product = val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: product.quantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() {
                    final parsed = int.tryParse(val);
                    if (parsed != null && parsed > 0) {
                      product.quantity = parsed;
                    }
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: product.brand,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => product.brand = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: product.unitPrice.toStringAsFixed(2),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Unit Price',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() {
                    final parsed = double.tryParse(val);
                    if (parsed != null && parsed >= 0) {
                      product.unitPrice = parsed;
                    }
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    '\$${(product.unitPrice * product.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                tooltip: 'Remove product line',
                onPressed: () {
                  if (productLines.length > 1) {
                    setState(() {
                      productLines.removeAt(index);
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return const Drawer(
      child: Center(child: Text("Menu here")),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Purchase Order'),
      backgroundColor: const Color(0xFF8C7AE6),
    );
  }
}
