import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/supplier_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';

class ProductLine {

  String? product;
  String? brand;
  String? family;
  String? subFamily;
  int quantity;
  String? supplier;
  double unitPrice;

  ProductLine({
    this.product,
    this.brand,
    this.family,
    this.subFamily,
    this.supplier,
    this.quantity = 1,
    this.unitPrice = 12.33,
  });

  Map<String, dynamic> toJson() {
    return {
      // 'product_id': productId, // Removed
      'product': product,
      'brand': brand,
      'family': family,
      'subFamily': subFamily,
      'supplier': supplier,
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
  int? _id;
  int? _requestedByUser; // Now int
  int? _approvedBy;      // Now int
  DateTime? _updatedAt;
  List<ProductLine> productLines = [ProductLine()];
  final TextEditingController supplierDeliveryDateController = TextEditingController();
  // Multi-currency support
  String _currency = 'Dollar';
  final Map<String, String> _currencySymbols = {
    'Dollar': '\$',
    'Euro': '€',
    'Dinar': 'DT',
  };
  final Map<String, String> _currencyCodes = {
    'Dollar': 'USD',
    'Euro': 'EUR',
    'Dinar': 'TND',
  };
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController supplierNameController = TextEditingController();

  bool _isSaving = false;
  String? supplierName;

  late SupplierController supplierController;
  late List<String> suppliers = [];

  @override
  void initState() {
    super.initState();
    supplierController = Provider.of<SupplierController>(context, listen: false);
    _fetchSuppliers();
    final initial = widget.initialOrder;
    if (initial.isNotEmpty) {
      _priority = initial['priority']?.toString();
      _id = initial['id'] is int ? initial['id'] : int.tryParse(initial['id']?.toString() ?? '');
      final userController = Provider.of<UserController>(context, listen: false);
      final int currentUserId = userController.currentUser.id ?? 1;
      _requestedByUser = initial['requestedByUser'] is int
          ? initial['requestedByUser']
          : int.tryParse(initial['requestedByUser']?.toString() ?? '') ?? currentUserId;
      _approvedBy = initial['approvedBy'] is int
          ? initial['approvedBy']
          : int.tryParse(initial['approvedBy']?.toString() ?? '') ?? 2;
      _updatedAt = initial['updatedAt'] is DateTime
          ? initial['updatedAt']
          : (initial['updatedAt'] != null ? DateTime.tryParse(initial['updatedAt'].toString()) : null);
      _updatedAt ??= DateTime.now();
      // Pré-remplir le champ Supplier Name si la valeur existe, sinon le chercher dans les produits
      supplierName = initial['supplierName'] ?? initial['supplier'] ?? initial['Supplier'];
      if ((supplierName == null || (supplierName?.isEmpty ?? true)) && initial['products'] != null && initial['products'] is List) {
        for (final p in (initial['products'] as List)) {
          final supplierField = p['supplier'] ?? p['Supplier'];
          final s = supplierField is Map ? (supplierField['name']?.toString() ?? supplierField['supplier']?.toString()) : (supplierField?.toString());
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
            product: p['product']?.toString(),
            brand: p['brand']?.toString(),
            quantity: (p['quantity'] is int)
                ? p['quantity']
                : int.tryParse(p['quantity'].toString()) ?? 1,
            unitPrice: (p['unit_price'] is double)
                ? p['unit_price']
                : (p['unit_price'] is int)
                    ? (p['unit_price'] as int).toDouble()
                    : double.tryParse(p['unit_price']?.toString() ?? '') ?? 0.0,            supplier: p['supplier'] is Map ? (p['supplier']['name']?.toString()) : (p['supplier']?.toString()),          );
        }).toList();
        // product brands kept on productLines; supplier delivery is order-level
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
  final userController = Provider.of<UserController>(context, listen: false);
  final int currentUserId = userController.currentUser.id ?? 1;
  _requestedByUser = currentUserId; // Default to current user ID
  _approvedBy = 2;      // Default approver ID
  _updatedAt = DateTime.now();
      supplierDeliveryDateController.text = '';
    }
  }

  Future<void> _fetchSuppliers() async {
    try {
      await supplierController.fetchSuppliers();
      setState(() {
        suppliers = supplierController.suppliers.map((s) => s.name ?? '').toList();
        suppliers.add('Autre');
      });
    } catch (_) {
      // ignore
    }
  }

  double get totalPrice => productLines.fold(
        0,
        (sum, p) => sum + (p.unitPrice * p.quantity.toDouble()),
      );

  @override
  void dispose() {
    supplierDeliveryDateController.dispose();
    noteController.dispose();
    dueDateController.dispose();
    supplierNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.priority,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'high', child: Text(loc.high)),
                      DropdownMenuItem(value: 'medium', child: Text(loc.medium)),
                      DropdownMenuItem(value: 'low', child: Text(loc.low)),
                    ],
                    onChanged: (val) => setState(() => _priority = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.supplierLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: supplierNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.supplierName,
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => supplierName = val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(loc.currency, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    items: _currencySymbols.keys
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _currency = val ?? 'Dollar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(AppLocalizations.of(context)!.products, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),
            Column(
              children: productLines.asMap().entries.map((entry) => _buildProductLine(entry.value, entry.key)).toList(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(loc.addProduct),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C7AE6),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => setState(() => productLines.add(ProductLine())),
              ),
            ),
const SizedBox(height: 24),
Row(
  children: [
    // 🔹 Supplier Delivery Date
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.supplierDeliveryDate,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: supplierDeliveryDateController,
            readOnly: true,
            decoration: const InputDecoration(
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
                  supplierDeliveryDateController.text =
                      DateFormat('dd-MM-yyyy').format(pickedDate);
                });
              }
            },
          ),
        ],
      ),
    ),

    const SizedBox(width: 12),

    // 🔹 Due Date
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.dueDate,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: dueDateController,
            readOnly: true,
            decoration: const InputDecoration(
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
        ],
      ),
    ),
  ],
),

            const SizedBox(height: 24),
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: loc.noteLabel,
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                border: const OutlineInputBorder(),
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
                loc.totalLabel('${_currencySymbols[_currency]}${totalPrice.toStringAsFixed(2)}'),
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
                        : Text(loc.saveBtn,
                            style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(loc.cancel),
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
        // productLines.any((p) => p.brand == null || p.brand!.isEmpty) ||
        _priority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllRequiredFields)),
      );
      return;
    }
    // parse supplier delivery date (optional but if provided must be valid)
    DateTime? parsedSupplierDeliveryDate;
    if ((supplierDeliveryDateController.text).isNotEmpty) {
      try {
        parsedSupplierDeliveryDate = DateFormat('dd-MM-yyyy').parseStrict(supplierDeliveryDateController.text);
      } catch (_) {
        try {
          parsedSupplierDeliveryDate = DateFormat('yyyy-MM-dd').parseStrict(supplierDeliveryDateController.text);
        } catch (e) {
          parsedSupplierDeliveryDate = null;
        }
      }
      if (parsedSupplierDeliveryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.invalidSupplierDeliveryDate)),
        );
        return;
      }
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
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidDueDate)),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      // Adapter la structure des produits pour le backend (supplier per product)
      final supplierControllerLocal = Provider.of<SupplierController>(context, listen: false);
      final supplierNameLocal = supplierName ?? supplierNameController.text;

      final List<Map<String, dynamic>> productsList = productLines.map((p) {
        final prodSupplierName = (p.supplier != null && p.supplier!.isNotEmpty) ? p.supplier : supplierNameLocal;
        final prodSupplierObj = (() {
          if (prodSupplierName == null || prodSupplierName.isEmpty) return null;
          try {
            final s = supplierControllerLocal.suppliers.firstWhere((sup) => sup.name == prodSupplierName);
            return {
              'id': s.id,
              'name': s.name,
              if (s.contactEmail != null) 'email': s.contactEmail,
            };
          } catch (_) {
            return {'name': prodSupplierName};
          }
        })();
        return {
          'product': p.product ?? '',
          // 'brand': p.brand ?? '',
          'quantity': p.quantity,
          'unit_price': p.unitPrice,
          'price': (p.unitPrice * p.quantity),
          'supplier': prodSupplierObj,
        };
      }).toList();
      // Construction du body attendu par le backend
      final jsonBody = {
        'id': _id,
        'requested_by_user': _requestedByUser ?? 1,
        'approved_by': _approvedBy ?? 2,
        'start_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'end_date': DateFormat('yyyy-MM-dd').format(parsedEndDate),
        'products': productsList,
        'title': AppLocalizations.of(context)!.purchaseOrder,
        'description': noteController.text,
        'statuss': 'pending', // Always set to pending
        'currency': _currencyCodes[_currency] ?? _currency,
        'created_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'updated_at': DateFormat('yyyy-MM-dd').format(_updatedAt ?? DateTime.now()),
        'priority': _priority,
      };
        if (parsedSupplierDeliveryDate != null) {
          jsonBody['supplier_delivery_date'] = DateFormat('yyyy-MM-dd').format(parsedSupplierDeliveryDate);
        }
      if (widget.initialOrder.isNotEmpty) {
        widget.onSave(jsonBody);
        if (mounted) Navigator.of(context).pop(jsonBody);
      } else {
        await Provider.of<PurchaseOrderController>(context, listen: false)
            .addOrder(jsonBody); // <-- à adapter côté controller si besoin
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.purchaseOrderSaved)),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.failedWithError(e.toString()))),
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
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.product,
                    border: const OutlineInputBorder(),
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
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.quantity,
                    border: const OutlineInputBorder(),
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
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: product.brand,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.brand,
                    border: const OutlineInputBorder(),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.supplierLabel),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: suppliers.contains(product.supplier) ? product.supplier : (product.supplier != null && product.supplier!.isNotEmpty ? 'Autre' : null),
                      items: suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() {
                        if (val == 'Autre') {
                          product.supplier = '';
                        } else {
                          product.supplier = val;
                        }
                      }),
                    ),
                    if (product.supplier != null && product.supplier!.isNotEmpty && !suppliers.contains(product.supplier))
                      TextFormField(
                        initialValue: product.supplier,
                        onChanged: (v) => setState(() => product.supplier = v),
                        decoration: InputDecoration(hintText: AppLocalizations.of(context)!.supplierLabel),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                //  initialValue: product.unitPrice.toStringAsFixed(2),
                  keyboardType:
                       TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    labelText: '${AppLocalizations.of(context)!.unitPrice} (${_currencySymbols[_currency]})',
                    border: const OutlineInputBorder(),
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
                    '${_currencySymbols[_currency]}${(product.unitPrice * product.quantity).toStringAsFixed(2)}',
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
                tooltip: AppLocalizations.of(context)!.removeProductLine,
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
}
