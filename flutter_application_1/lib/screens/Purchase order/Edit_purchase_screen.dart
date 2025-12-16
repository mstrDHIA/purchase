import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/product_controller.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/supplier_controller.dart';
import '../../l10n/app_localizations.dart';

class ProductLine {
  String? product;
  String? family;
  String? subFamily;
  // String? brand;
  int quantity;
  double unitPrice;

  ProductLine({
    this.product,
    this.family,
    this.subFamily,
    // this.brand,
    this.quantity = 1,
    this.unitPrice = 12.33,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'family': family,
      'subFamily': subFamily,
      // 'brand': brand,
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
  String? selectedSupplier;
  late List<String> suppliers = [];
  late SupplierController supplierController;
  // Product families/subfamilies fetched from ProductController
  late ProductController productController;
  Map<String, List<String>> dynamicProductFamilies = {};
  bool _loadingFamilies = false;
  String? _familiesError;

  bool _isSaving = false;
  String? supplierName;

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
      _requestedByUser = initial['requestedByUser'] is int
          ? initial['requestedByUser']
          : int.tryParse(initial['requestedByUser']?.toString() ?? '') ?? 1;
      _approvedBy = initial['approvedBy'] is int
          ? initial['approvedBy']
          : int.tryParse(initial['approvedBy']?.toString() ?? '') ?? 2;
  _updatedAt = initial['updatedAt'] is DateTime
      ? initial['updatedAt']
      : (initial['updatedAt'] != null ? DateTime.tryParse(initial['updatedAt'].toString()) : null);
  _updatedAt ??= DateTime.now();
      // Pré-remplir le champ Supplier Name si la valeur existe, sinon le chercher dans les produits
      supplierName = initial['supplier'] ?? initial['supplierName'] ?? initial['Supplier'];
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
      // initialize currency from initial if present (expects ISO code)
      if (initial['currency'] != null) {
        final code = initial['currency']?.toString();
        if (code != null && _codeToCurrency.containsKey(code)) {
          _currency = _codeToCurrency[code]!;
        }
      }
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
      // initialize supplier delivery date if provided
      if (initial['supplier_delivery_date'] != null) {
        try {
          DateTime sd;
          if (initial['supplier_delivery_date'] is DateTime) {
            sd = initial['supplier_delivery_date'];
          } else {
            sd = DateTime.parse(initial['supplier_delivery_date'].toString());
          }
          supplierDeliveryDateController.text = DateFormat('dd-MM-yyyy').format(sd);
        } catch (_) {
          supplierDeliveryDateController.text = '';
        }
      }
      noteController.text = initial['description'] ?? '';
      if (initial['products'] != null && initial['products'] is List) {
        productLines = (initial['products'] as List).map((p) {
          return ProductLine(
            product: p['product']?.toString(),
            family: p['family']?.toString(),
            subFamily: p['subFamily']?.toString() ?? p['sub_family']?.toString() ?? p['subcategory']?.toString(),
            // brand: p['brand']?.toString(),
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
  _requestedByUser = 1; // Default user ID
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
      setState(() {
        suppliers = supplierController.suppliers
            .map((s) => s.name ?? '')
            .toList();
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
                      tooltip: 'Cancel',
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Edit Purchase Order',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 32),
              // Supplier dropdown always visible
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Supplier'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: selectedSupplier ?? (suppliers.contains(supplierNameController.text) ? supplierNameController.text : null),
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
                          items: suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedSupplier = val;
                              if (val != 'Autre') {
                                supplierNameController.text = val ?? '';
                              } else {
                                supplierNameController.text = '';
                              }
                            });
                          },
                        ),
                        if (selectedSupplier == 'Autre') ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: supplierNameController,
                            readOnly: false,
                            decoration: InputDecoration(
                              labelText: 'Nom du fournisseur',
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Currency selector
                  SizedBox(
                    width: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Currency'),
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
                        const Text('Priority'),
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
                            decoration: const InputDecoration.collapsed(hintText: ''),
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
              const Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...productLines.asMap().entries.map((entry) {
                int index = entry.key;
                ProductLine product = entry.value;
                return _buildProductLine(product, index);
              }),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
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
                    child: TextFormField(
                      controller: supplierDeliveryDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.supplierDeliveryDate,
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
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: dueDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Due date',
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
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Note
              const Text('Note'),
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
              const SizedBox(height: 32),
              // Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                  child: Text(
                    'Total: ${_currencySymbols[_currency]}${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Save/Cancel buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
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
                          : const Text('Save', style: TextStyle(color: Colors.white)),
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
      ),
    );
  }

  Future<void> _saveOrder() async {
    supplierName = supplierNameController.text;
    if (supplierName == null ||
        supplierName!.isEmpty ||
        _priority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
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
      // Adapter la structure des produits pour le backend
      final List<Map<String, dynamic>> productsList = productLines.map((p) => {
        'product': p.product ?? '',
        'family': p.family ?? '',
        'subFamily': p.subFamily ?? '',
        'quantity': p.quantity,
        'unit_price': p.unitPrice,
        'supplier': supplierName,
      }).toList();
      // Construction du body attendu par le backend
      final jsonBody = {
        'id': _id,
        'requested_by_user': _requestedByUser ?? 1,
        'approved_by': _approvedBy ?? 2,
        // Forcer l'envoi des dates comme String au format 'yyyy-MM-dd'
        'start_date': DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
        'end_date': DateFormat('yyyy-MM-dd').format(parsedEndDate).toString(),
        'products': productsList,
        'title': 'Purchase Order',
        'description': noteController.text,
        'statuss': 'edited',
        'currency': _currencyCodes[_currency] ?? _currency,
        'created_at': DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
        'updated_at': DateFormat('yyyy-MM-dd').format(_updatedAt ?? DateTime.now()).toString(),
        'supplier_delivery_date': parsedSupplierDeliveryDate != null ? DateFormat('yyyy-MM-dd').format(parsedSupplierDeliveryDate) : null,
        'priority': _priority,
      };
      if (widget.initialOrder.isNotEmpty && widget.initialOrder['id'] != null) {
        // Mode édition : appel update, on envoie le JSON directement
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
        await Provider.of<PurchaseOrderController>(context, listen: false)
            .addOrder(jsonBody);
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
                    const Text('Subfamily'),
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
                    const Text('Quantity'),
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

  

  
}
