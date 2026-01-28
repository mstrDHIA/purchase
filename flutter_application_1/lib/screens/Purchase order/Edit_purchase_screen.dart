import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/product_controller.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/controllers/supplier_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/network/purchase_request_network.dart';
import '../../l10n/app_localizations.dart';

class ProductLine {
  String? product;
  String? family;
  String? subFamily;
  // String? brand;
  String? supplier;
  int quantity;
  double unitPrice;

  ProductLine({
    this.product,
    this.family,
    this.subFamily,
    // this.brand,
    this.supplier,
    this.quantity = 1,
    this.unitPrice = 12.33,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'family': family,
      'subFamily': subFamily,
      // 'brand': brand,
      'supplier': supplier,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}

class EditPurchaseOrder extends StatefulWidget {
  final Map<String, dynamic> initialOrder;
  final void Function(dynamic newOrder) onSave;

  const EditPurchaseOrder({
    super.key,
    required this.onSave,
    required this.initialOrder,
  });
       
  @override
  State<EditPurchaseOrder> createState() => _EditPurchaseOrderState();
}

class _EditPurchaseOrderState extends State<EditPurchaseOrder> {
  String? _priority;
  int? _id;
  int? _requestedByUser; // Now int
  int? _approvedBy;      // Now int
  DateTime? _updatedAt;
  List<ProductLine> productLines = [ProductLine()];
  // Order-level Supplier Delivery date
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
  final Map<String, String> _codeToCurrency = {
    'USD': 'Dollar',
    'EUR': 'Euro',
    'TND': 'Dinar',
  };
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController supplierNameController = TextEditingController();
  late List<String> suppliers = [];
  late SupplierController supplierController;
  // Product families/subfamilies fetched from ProductController
  late ProductController productController;
  Map<String, List<String>> dynamicProductFamilies = {};
  bool _loadingFamilies = false;
  String? _familiesError;

  bool _isSaving = false;
  String? supplierName;
  String? _dateWarning; // For displaying date conflict warning

  @override
  void initState() {
    super.initState();
    supplierController = Provider.of<SupplierController>(context, listen: false);
    _fetchSuppliers();
    // initialize product controller and fetch families
    productController = Provider.of<ProductController>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProductFamilies());
    final initial = widget.initialOrder;
    if (initial.isNotEmpty) {
      // Correction : forcer la casse pour correspondre aux DropdownMenuItem
      final priorityRaw = initial['priority']?.toString();
      if (priorityRaw != null) {
        if (priorityRaw.toLowerCase() == 'high') {
          _priority = 'high';
        } else if (priorityRaw.toLowerCase() == 'medium') {
          _priority = 'medium';
        } else if (priorityRaw.toLowerCase() == 'low') {
          _priority = 'low';
        } else {
          _priority = null;
        }
      } else {
        _priority = null;
      }
      _id = initial['id'] is int ? initial['id'] : int.tryParse(initial['id']?.toString() ?? '');
      // Use int for user IDs, fallback to 1 if not present
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

      // initialize currency from initial if present (expects ISO code)
      if (initial['currency'] != null) {
        final code = initial['currency']?.toString();
        if (code != null && _codeToCurrency.containsKey(code)) {
          _currency = _codeToCurrency[code]!;
        }
      }
      // Prefer API-provided end date (check both camelCase and snake_case).
      final endDateRaw = initial['endDate'] ?? initial['end_date'];
      if (endDateRaw != null && endDateRaw.toString().isNotEmpty) {
        try {
          DateTime endDate;
          if (endDateRaw is DateTime) {
            endDate = endDateRaw;
          } else {
            // Try parsing ISO / yyyy-MM-dd first, then dd-MM-yyyy format
            endDate = DateTime.tryParse(endDateRaw.toString()) ?? DateFormat('dd-MM-yyyy').parseStrict(endDateRaw.toString());
          }
          dueDateController.text = DateFormat('dd-MM-yyyy').format(endDate);
        } catch (_) {
          // If parsing fails, leave the field empty (don't default to today)
          dueDateController.text = '';
        }
      } else {
        // Editing an existing order with no due date: leave it blank
        dueDateController.text = '';
      }
      // initialize supplier delivery date if provided
      final supplierDeliveryRaw = initial['supplier_delivery_date'] ?? initial['supplierDeliveryDate'];
      if (supplierDeliveryRaw != null) {
        try {
          DateTime sd;
          if (supplierDeliveryRaw is DateTime) {
            sd = supplierDeliveryRaw;
          } else {
            sd = DateTime.parse(supplierDeliveryRaw.toString());
          }
          supplierDeliveryDateController.text = DateFormat('dd-MM-yyyy').format(sd);
        } catch (_) {
          supplierDeliveryDateController.text = '';
        }
      }
      noteController.text = initial['description'] ?? '';
      if (initial['products'] != null && initial['products'] is List) {
        productLines = (initial['products'] as List).map((p) {
          final supplierField = p['supplier'] ?? p['Supplier'];
          final supplierNameFromProd = supplierField is Map ? (supplierField['name']?.toString() ?? supplierField['supplier']?.toString()) : (supplierField?.toString());
          return ProductLine(
            product: p['product']?.toString(),
            family: p['family']?.toString(),
            subFamily: p['subFamily']?.toString() ?? p['sub_family']?.toString() ?? p['subcategory']?.toString(),
            // brand: p['brand']?.toString(),
            supplier: supplierNameFromProd,
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
        // no-op: product brands are kept in productLines; supplier delivery date is order-level
      }
      } else {
        dueDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
        supplierNameController.text = '';
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
  // default priority to 'high' for new orders
  _priority = 'high';
  final userController = Provider.of<UserController>(context, listen: false);
  final int currentUserId = userController.currentUser.id ?? 1;
  _requestedByUser = currentUserId; // Default to current user ID
  _approvedBy = 2;      // Default approver ID
  _updatedAt = DateTime.now();
      // initialize order-level supplier delivery date to today's date by default
      supplierDeliveryDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }
  }

  @override
  void dispose() {
    supplierDeliveryDateController.dispose();
    noteController.dispose();
    dueDateController.dispose();
    supplierNameController.dispose();
    super.dispose();
  }

  double get totalPrice => productLines.fold(
        0,
        (sum, p) => sum + (p.unitPrice * p.quantity.toDouble()),
      );

  Future<void> _fetchSuppliers() async {
    try {
      await supplierController.fetchSuppliers();
      final approvedOnly = <String>[];
      for (var s in supplierController.suppliers) {
        final status = (s.approvalStatus ?? '').trim().toLowerCase();
        if (status == 'approved') {
          approvedOnly.add(s.name ?? '');
        }
      }
      setState(() {
        suppliers = approvedOnly;
        suppliers.add('Autre'); // Add "Other" option at the end
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch suppliers: $e')),
        );
      }
    }
  }

  Future<void> _fetchProductFamilies() async {
    setState(() {
      _loadingFamilies = true;
      _familiesError = null;
    });
    try {
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

        setState(() {
          dynamicProductFamilies = families;
          // if product lines have families but no subfamily selected, default to first subfamily
          for (final p in productLines) {
            if (p.family != null && (p.subFamily == null || p.subFamily!.isEmpty)) {
              final subs = dynamicProductFamilies[p.family] ?? [];
              if (subs.isNotEmpty) p.subFamily = subs.first;
            }
          }
        });
      }
    } catch (e) {
      setState(() {
        _familiesError = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loadingFamilies = false);
    }
  }

  void _checkDateConflict() {
    if (supplierDeliveryDateController.text.isEmpty || dueDateController.text.isEmpty) {
      setState(() => _dateWarning = null);
      return;
    }

    try {
      DateTime supplierDate = DateFormat('dd-MM-yyyy').parseStrict(supplierDeliveryDateController.text);
      DateTime dueDate = DateFormat('dd-MM-yyyy').parseStrict(dueDateController.text);

      if (supplierDate.isAfter(dueDate)) {
        setState(() => _dateWarning = 'Warning: Supplier delivery date is after due date');
      } else {
        setState(() => _dateWarning = null);
      }
    } catch (_) {
      setState(() => _dateWarning = null);
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with back button and centered title
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: AppLocalizations.of(context)!.cancel,
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.purchaseOrder,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (_id != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F2F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ID: ${_id}',
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 32),
              // Supplier dropdown always visible
              Row(
                children: [
                  // Currency selector
                  SizedBox(
                    width: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.currency),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _currency,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: _currencySymbols.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) => setState(() => _currency = val ?? 'Dollar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.priority),
                        const SizedBox(height: 4),
                        // Dropdown that shows labels in UPPERCASE, matches saved value case-insensitively,
                        // and stores the selected value in lowercase for saving
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _priority == 'high'
                                ? Colors.red.shade100
                                : _priority == 'medium'
                                    ? Colors.orange.shade100
                                    : _priority == 'low'
                                        ? Colors.green.shade100
                                        : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            // match saved priority case-insensitively and default to 'High'
                            value: ['High', 'Medium', 'Low']
                                .firstWhere((p) => p.toLowerCase() == (_priority ?? '').toLowerCase(), orElse: () => 'High'),
                            items: ['High', 'Medium', 'Low']
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                        // display the label in UPPERCASE (e.g. 'HIGH')
                                        p.toUpperCase(),
                                        style: TextStyle(
                                          color: _priority == p.toLowerCase()
                                              ? (_priority == 'high'
                                                  ? Colors.red
                                                  : _priority == 'medium'
                                                      ? Colors.orange
                                                      : Colors.green)
                                              : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _priority = val?.toLowerCase()),
                            decoration: InputDecoration.collapsed(hintText: ''),
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Products section (unchanged, but styled)
              Text(AppLocalizations.of(context)!.products, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),
              if (_familiesError != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(_familiesError!, style: const TextStyle(color: Colors.red)),
                ),
              ],
              ...productLines.asMap().entries.map((entry) {
                int index = entry.key;
                ProductLine product = entry.value;
                return _buildProductLine(product, index);
              }),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.addProduct),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => setState(() {
                    productLines.add(ProductLine());
                  }),
                ),
              ),
              const SizedBox(height: 24),
              // Supplier delivery date and due date displayed side-by-side (under Add Product)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.supplierDeliveryDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: supplierDeliveryDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime initialDate = DateTime.now();
                            try {
                              final parsed = DateTime.tryParse(supplierDeliveryDateController.text);
                              if (parsed != null) initialDate = parsed;
                            } catch (_) {}
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                supplierDeliveryDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                              });
                              _checkDateConflict();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.dueDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),),
                        const SizedBox(height: 4),
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
                                dueDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
                              });
                              _checkDateConflict();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Note
              Text(AppLocalizations.of(context)!.noteLabel),
              const SizedBox(height: 4),
              TextField(
                controller: noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black87),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              if (_dateWarning != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    border: Border.all(color: Colors.orange.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _dateWarning!,
                    style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Text(
                'Total: ${_currencySymbols[_currency]}${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(120, 44),
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 44),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
      );
  }

  Future<void> _saveOrder() async {
    if (_priority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a priority.')),
      );
      return;
    }

    // Require supplier on each product
    final missingSuppliers = productLines.any((p) => p.supplier == null || p.supplier!.isEmpty);
    if (missingSuppliers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set supplier for each product.')),
      );
      return;
    }

    // Require unit price on each product
    final missingPrices = productLines.any((p) => p.unitPrice <= 0);
    if (missingPrices) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a unit price for each product.')),
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
          const SnackBar(content: Text('Please enter a valid supplier delivery date.')),
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
        const SnackBar(content: Text('Please enter a valid due date.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Adapter la structure des produits pour le backend (supplier per product)
      final supplierControllerLocal = supplierController;

      final List<Map<String, dynamic>> productsList = productLines.map((p) {
        final prodSupplierName = p.supplier ?? '';
        final prodSupplierObj = (() {
          if (prodSupplierName.isEmpty) return null;
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
          'family': p.family ?? '',
          'subFamily': p.subFamily ?? '',
          'quantity': p.quantity,
          'unit_price': p.unitPrice,
          'supplier': prodSupplierObj,
        };
      }).toList();
      // Construction du body attendu par le backend
      // If this editor was opened from a Purchase Request, prefer to create the PO with 'edited' status
      final prId = widget.initialOrder['purchase_request_id'] ?? widget.initialOrder['purchase_request'];
      final defaultStatus = 'edited';
      var statusToUse = widget.initialOrder['statuss'] ?? widget.initialOrder['status'] ?? defaultStatus;
      
      // Check if we're in edit mode (has existing id)
      final isEditMode = _id != null && _id! > 0;
      
      // Si le statut était "for modification" et qu'on édite et sauvegarde, le mettre à "pending"
      final statusLower = statusToUse.toString().toLowerCase().trim();
      if (isEditMode && (statusLower == 'rework' || statusLower == 'for modification')) {
        statusToUse = 'pending';
      }

      final jsonBody = {
        'requested_by_user': _requestedByUser ?? 1,
        'approved_by': _approvedBy ?? 2,
        // Forcer l'envoi des dates comme String au format 'yyyy-MM-dd'
        'start_date': DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
        'end_date': DateFormat('yyyy-MM-dd').format(parsedEndDate).toString(),
        'products': productsList,
        'title': 'Purchase Order',
        'description': noteController.text,
        // Set both keys to maximize backend compatibility
        'statuss': statusToUse,
        'status': statusToUse,
        'currency': _currencyCodes[_currency] ?? _currency,
        'created_at': DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
        'updated_at': DateFormat('yyyy-MM-dd').format(_updatedAt ?? DateTime.now()).toString(),
        'supplier_delivery_date': parsedSupplierDeliveryDate != null ? DateFormat('yyyy-MM-dd').format(parsedSupplierDeliveryDate) : null,
        'priority': _priority,
      };
      if (widget.initialOrder.isNotEmpty && widget.initialOrder['id'] != null) {
        // Mode édition : include id then call update
        jsonBody['id'] = _id;
        await Provider.of<PurchaseOrderController>(context, listen: false)
            .updateOrder(jsonBody);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.green, content: Text('Purchase order updated!')),
          );
          Navigator.of(context).pop(jsonBody);
        }
      } else {
        // Mode création
        // Link the new PO to the originating purchase request (do NOT set the resource 'id' to the request id).
        // Instead include explicit relation fields the backend expects. Also ensure the status is pending when created from a request.
        if (prId != null) {
          // Some backends require an explicit 'id' on create tied to the purchase request.
          // Include it when creating from a Purchase Request to satisfy those APIs.
          jsonBody['id'] = prId;
          jsonBody['purchase_request'] = prId;
          jsonBody['purchase_request_id'] = prId;
          // When creating a PO from a Purchase Request, use 'edited' as requested
          jsonBody['statuss'] = 'edited';
          jsonBody['status'] = 'edited';
        }

        await Provider.of<PurchaseOrderController>(context, listen: false)
            .addOrder(jsonBody);
        if (mounted) {
          // Update PR status if we created from a PR (role 4 creates PO from PR)
          if (prId != null) {
            try {
              final userController = Provider.of<UserController>(context, listen: false);
              // Change PR status to 'transformed' after PO creation
              final updatePayload = {
                'status': 'transformed',
                'statuss': 'transformed', // Some backends expect both
              };
              final response = await PurchaseRequestNetwork().updatePurchaseRequest(
                prId as int,
                updatePayload,
                method: 'PATCH'
              );
              // Refresh the PR list immediately so it disappears from the datatable without page change
              await Provider.of<PurchaseRequestController>(context, listen: false)
                  .fetchRequests(context, userController.currentUser);
            } catch (e) {
              if (mounted) {
                // Silently ignore PR update errors
              }
            }
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase order saved!')),
          );
          Navigator.of(context).pop(true); // Return true to indicate PR list was updated
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
          // First row: Family | Subfamily
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Family'),
                    const SizedBox(height: 4),
                    _loadingFamilies
                        ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                        : (dynamicProductFamilies.isEmpty)
                            ? TextFormField(
                                initialValue: product.family,
                                decoration: const InputDecoration(
                                  hintText: 'Family',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (val) => setState(() => product.family = val),
                              )
                            : DropdownButtonFormField<String>(
                                // ensure current value is present in the items so it's displayed
                                value: (product.family != null && dynamicProductFamilies.keys.contains(product.family)) ? product.family : (product.family != null ? product.family : null),
                                items: () {
                                  final list = <String>[];
                                  list.addAll(dynamicProductFamilies.keys);
                                  if (product.family != null && product.family!.isNotEmpty && !list.contains(product.family)) {
                                    list.insert(0, product.family!);
                                  }
                                  return list.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList();
                                }(),
                                onChanged: (val) => setState(() {
                                  product.family = val;
                                  // default subFamily to first available when family changes
                                  final subs = dynamicProductFamilies[val] ?? [];
                                  product.subFamily = subs.isNotEmpty ? subs.first : null;
                                }),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.black87),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.deepPurple),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.subfamilyLabel),
                    const SizedBox(height: 4),
                    ((dynamicProductFamilies[product.family] ?? []).isNotEmpty)
                        ? DropdownButtonFormField<String>(
                            value: ((dynamicProductFamilies[product.family] ?? []).contains(product.subFamily)) ? product.subFamily : (product.subFamily != null && product.subFamily!.isNotEmpty ? product.subFamily : null),
                            items: () {
                              final list = <String>[];
                              list.addAll(dynamicProductFamilies[product.family] ?? []);
                              if (product.subFamily != null && product.subFamily!.isNotEmpty && !list.contains(product.subFamily)) {
                                list.insert(0, product.subFamily!);
                              }
                              return list.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList();
                            }(),
                            onChanged: (val) => setState(() => product.subFamily = val),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black87),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.deepPurple),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          )
                        : TextFormField(
                            initialValue: product.subFamily,
                            decoration: const InputDecoration(
                              hintText: 'Optional subfamily',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => setState(() => product.subFamily = val),
                          ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row: Product (wide) | Quantity (small)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product ${productLines.length > 1 ? index + 1 : ''}'),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: product.product,
                      onChanged: (val) => setState(() => product.product = val),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black87),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.quantity),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: product.quantity.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() => product.quantity = int.tryParse(val) ?? 1),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black87),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              if (productLines.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => setState(() => productLines.removeAt(index)),
                  tooltip: 'Remove product',
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
                    // If no suppliers fetched, show a text field; otherwise show styled dropdown
                    if (suppliers.isEmpty)
                      TextFormField(
                        initialValue: product.supplier,
                        onChanged: (v) => setState(() => product.supplier = v),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.supplierLabel,
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: suppliers.contains(product.supplier)
                            ? product.supplier
                            : (product.supplier != null && product.supplier!.isNotEmpty ? 'Autre' : null),
                        items: suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() {
                          if (val == 'Autre') {
                            product.supplier = '';
                          } else {
                            product.supplier = val;
                          }
                        }),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        dropdownColor: Colors.white,
                      ),
                    if (product.supplier != null && product.supplier!.isNotEmpty && !suppliers.contains(product.supplier))
                      const SizedBox(height: 8),
                    if (product.supplier != null && product.supplier!.isNotEmpty && !suppliers.contains(product.supplier))
                      TextFormField(
                        initialValue: product.supplier,
                        onChanged: (v) => setState(() => product.supplier = v),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.supplierLabel,
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.deepPurple),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                  ],
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
                  //  initialValue: product.unitPrice.toStringAsFixed(2),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    labelText: 'Unit Price (${_currencySymbols[_currency]})',
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
                tooltip: 'Remove line',
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
