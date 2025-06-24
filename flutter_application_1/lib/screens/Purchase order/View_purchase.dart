import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/users/Modify_user.dart';
import 'package:flutter_application_1/screens/Purchase%20order/Refuse_Purchase.dart';

class PurchaseOrderView extends StatefulWidget {
  const PurchaseOrderView({super.key});

  @override
  State<PurchaseOrderView> createState() => _PurchaseOrderViewState();
}

class _PurchaseOrderViewState extends State<PurchaseOrderView> {
  // Use TextEditingController to make fields editable
  late TextEditingController supplierNameController;
  late TextEditingController productController;
  late TextEditingController quantityController;
  late TextEditingController brandController;
  late TextEditingController unitPriceController;
  late TextEditingController totalPriceController;
  late TextEditingController totalOrderPriceController;
  late TextEditingController dueDateController;
  late TextEditingController noteController;
  late TextEditingController statusController;
  late TextEditingController priorityController;
  late TextEditingController requestorNoteController; // Added
  late TextEditingController submittedDateController; // Ajouté

  List<Map<String, TextEditingController>> products = [];

  bool isApproved = false; // Add this field to your _PurchaseOrderViewState class

  @override
  void initState() {
    super.initState();
    supplierNameController = TextEditingController(text: 'ABC Supplier');
    productController = TextEditingController(text: 'Mouse');
    quantityController = TextEditingController(text: '7000');
    brandController = TextEditingController(text: 'Dell');
    unitPriceController = TextEditingController(text: '\$12.33');
    totalPriceController = TextEditingController(text: '\$124.33');
    totalOrderPriceController = TextEditingController(text: '\$1245.33');
    dueDateController = TextEditingController(text: '15-05-2025');
    submittedDateController = TextEditingController(text: '19-06-2025'); // Ajouté
    noteController = TextEditingController();
    statusController = TextEditingController(text: 'Pending');
    priorityController = TextEditingController(text: 'High');
    requestorNoteController = TextEditingController();

    // Add the first product by default
    products.add({
      'product': productController,
      'quantity': quantityController,
      'brand': brandController,
      'unitPrice': unitPriceController,
      'totalPrice': totalPriceController,
    });

    // Ajout d'un deuxième produit par défaut (exemple)
    products.add({
      'product': TextEditingController(text: 'Keyboard'),
      'quantity': TextEditingController(text: '1500'),
      'brand': TextEditingController(text: 'Logitech'),
      'unitPrice': TextEditingController(text: '\$25.00'),
      'totalPrice': TextEditingController(text: '\$37500.00'),
    });
  }

  @override
  void dispose() {
    supplierNameController.dispose();
    for (var map in products) {
      map.values.forEach((c) => c.dispose());
    }
    totalOrderPriceController.dispose();
    dueDateController.dispose();
    submittedDateController.dispose(); // Ajouté
    noteController.dispose();
    statusController.dispose();
    priorityController.dispose();
    requestorNoteController.dispose();
    super.dispose();
  }

  void _editRequest() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController productCtrl = TextEditingController(text: productController.text);
        final TextEditingController quantityCtrl = TextEditingController(text: quantityController.text);
        return AlertDialog(
          title: const Text('Edit Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: productCtrl, decoration: const InputDecoration(labelText: 'Product')),
              TextField(controller: quantityCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  productController.text = productCtrl.text;
                  quantityController.text = quantityCtrl.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Request updated")),
                );
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteRequest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Request"),
        content: const Text("Are you sure you want to delete this request?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Request deleted")),
              );
              setState(() {
                supplierNameController.text = '';
                productController.text = '';
                quantityController.text = '';
                dueDateController.text = '';
                noteController.text = '';
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addProduct() {
    setState(() {
      final productCtrl = TextEditingController();
      final quantityCtrl = TextEditingController();
      final brandCtrl = TextEditingController();
      final unitPriceCtrl = TextEditingController();
      final totalPriceCtrl = TextEditingController();
      // Automatically calculate total price when quantity or price changes
      quantityCtrl.addListener(() {
        _updateProductTotal(productCtrl, quantityCtrl, unitPriceCtrl, totalPriceCtrl);
      });
      unitPriceCtrl.addListener(() {
        _updateProductTotal(productCtrl, quantityCtrl, unitPriceCtrl, totalPriceCtrl);
      });
      products.add({
        'product': productCtrl,
        'quantity': quantityCtrl,
        'brand': brandCtrl,
        'unitPrice': unitPriceCtrl,
        'totalPrice': totalPriceCtrl,
      });
    });
  }

  void _updateProductTotal(
    TextEditingController productCtrl,
    TextEditingController quantityCtrl,
    TextEditingController unitPriceCtrl,
    TextEditingController totalPriceCtrl,
  ) {
    final q = int.tryParse(quantityCtrl.text) ?? 0;
    final up = double.tryParse(unitPriceCtrl.text.replaceAll('\$', '').replaceAll(',', '.')) ?? 0.0;
    final total = q * up;
    totalPriceCtrl.text = total == 0 ? '' : '\$${total.toStringAsFixed(2)}';
    _updateOrderTotal();
  }

  void _updateOrderTotal() {
    double sum = 0;
    for (var map in products) {
      final t = double.tryParse(map['totalPrice']!.text.replaceAll('\$', '').replaceAll(',', '.')) ?? 0.0;
      sum += t;
    }
    totalOrderPriceController.text = '\$${sum.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('View Purchase'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier name, Submitted Date, Due date, Priority sur la même ligne
            Row(
              children: [
                _buildField('Supplier name', supplierNameController, width: 220, readOnly: false),
                const SizedBox(width: 20),
                _buildFieldWithIcon('Submitted Date', submittedDateController, Icons.calendar_today, width: 180),
                const SizedBox(width: 20),
                _buildFieldWithIcon('Due date', dueDateController, Icons.calendar_today_outlined, width: 180),
                const SizedBox(width: 20),
                _buildField('Priority', priorityController, width: 120, readOnly: true),
              ],
            ),
            const SizedBox(height: 20),
            // Show all product lines (including the first)
            ...products.asMap().entries.map((entry) {
              final i = entry.key;
              final map = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _buildField('Product', map['product']!, width: 140),
                    const SizedBox(width: 8),
                    _buildField('Quantity', map['quantity']!, width: 90, keyboardType: TextInputType.number, onChanged: (_) {
                      _updateProductTotal(map['product']!, map['quantity']!, map['unitPrice']!, map['totalPrice']!);
                    }),
                    const SizedBox(width: 8),
                    // BRAND: Editable
                    _buildField(
                      'Brand',
                      map['brand']!,
                      width: 110,
                      readOnly: false, // <-- Editable
                    ),
                    const SizedBox(width: 8),
                    // UNIT PRICE: Editable
                    _buildField(
                      'Unit Price',
                      map['unitPrice']!,
                      width: 100,
                      prefixText: '\$',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      readOnly: false, // <-- Editable
                      onChanged: (_) {
                        _updateProductTotal(map['product']!, map['quantity']!, map['unitPrice']!, map['totalPrice']!);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildField('Total Price', map['totalPrice']!, width: 110, readOnly: true),
                    if (products.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            products.removeAt(i);
                            _updateOrderTotal();
                          });
                        },
                      ),
                  ],
                ),
              );
            }),
            Row(
              children: [
                const Spacer(),
                _buildField('Total Price', totalOrderPriceController, width: 140, readOnly: true),
              ],
            ),
            const SizedBox(height: 24),
            // Note field (prend toute la largeur)
            const Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              enabled: true,
              controller: noteController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter note',
                filled: true,
                fillColor: const Color(0xFFF1F1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Requestor Note field
            const Text('Requestor Note', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              controller: requestorNoteController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Status sous la note, à gauche de la ligne des boutons
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status à gauche
                _buildField('Status', statusController, width: 160, readOnly: true),
                const Spacer(),
                if (!isApproved) // Show buttons only if not approved
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            statusController.text = "Approved";
                            isApproved = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      "Demande accepted",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF3B3BFF),
                              behavior: SnackBarBehavior.floating,
                              elevation: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B3BFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Accept'),
                      ),
                      const SizedBox(width: 32),
                      OutlinedButton(
                        onPressed: () {
                          showDialog(context: context, builder: (context) => RefusePurchaseDialog());
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFEDEDED),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Refuse'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    double width = 180,
    bool readOnly = true, // Default not editable
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    void Function(String)? onChanged,
  }) {
    // Ajout du badge coloré pour Status et Priority
    Color? badgeColor;
    Color? textColor = Colors.black;
    if (label == 'Status') {
      if (controller.text.toLowerCase() == 'pending') {
        badgeColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
      } else if (controller.text.toLowerCase() == 'approved') {
        badgeColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
      }
    }
    if (label == 'Priority') {
      if (controller.text.toLowerCase() == 'high') {
        badgeColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
      }
    }

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          if (label == 'Status' || label == 'Priority')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: badgeColor ?? const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                controller.text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          else
            TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixText: prefixText,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFieldWithIcon(
    String label,
    TextEditingController controller,
    IconData icon, {
    double width = 180,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: true, // Always not editable
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF1F1F1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Icon(icon, color: Colors.black54),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
