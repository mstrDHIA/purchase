import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:flutter_application_1/screens/Purchase order/purchase_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/controllers/product_controller.dart';

class RequestEditPage extends StatefulWidget {
  final PurchaseRequest purchaseRequest;
  const RequestEditPage({super.key, required this.purchaseRequest, required Null Function(dynamic _) onSave, required Map order, required Map<String, dynamic> request});
  @override
  State<RequestEditPage> createState() => _RequestEditPageState();

}

class _RequestEditPageState extends State<RequestEditPage> {
  bool _isLoading = false;
  late TextEditingController requestorController;
  late TextEditingController submittedDateController;
  late TextEditingController dueDateController;
  late TextEditingController noteController;

  String priority = 'High';
  String status = 'Pending';

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Liste dynamique de produits (ProductLine)
  late List<ProductLine> productLines;
  // Families/subfamilies map used for dropdowns
  late ProductController productController;
  Map<String, List<String>> dynamicProductFamilies = {};
  bool _loadingFamilies = false;
  String? _familiesError;
  
  String _normalizeStatus(dynamic value) {
    if (value == null) return 'Pending';
    final s = value.toString().toLowerCase();
    if (s == 'pending') return 'Pending';
    if (s == 'approved') return 'Approved';
    if (s == 'rejected') return 'Rejected';
    return 'Pending';
  }

  @override
  void initState() {
    super.initState();
    final pr = widget.purchaseRequest;
    requestorController = TextEditingController(text: pr.requestedBy?.toString() ?? '');
    submittedDateController = TextEditingController(
        text: pr.startDate != null ? _dateFormat.format(pr.startDate!) : '');
    dueDateController = TextEditingController(
        text: pr.endDate != null ? _dateFormat.format(pr.endDate!) : '');
    noteController = TextEditingController(text: pr.description ?? '');
    priority = pr.priority?.toString() ?? 'High';
    status = _normalizeStatus(pr.status);

    // Initialisation de la liste des produits comme ProductLine
    productLines = (pr.products ?? []).map<ProductLine>((dynamic prod) {
      // support both Map representations and ProductLine-like objects
      String? productVal;
      String? familyVal;
      String? subVal;
      int qty = 1;
      double unitPrice = 0.0;
      if (prod is Map) {
        productVal = prod['product']?.toString();
        familyVal = prod['family']?.toString() ?? prod['family_name']?.toString();
        subVal = prod['subFamily']?.toString() ?? prod['sub_family']?.toString() ?? prod['subcategory']?.toString();
        qty = prod['quantity'] is int ? prod['quantity'] : int.tryParse(prod['quantity']?.toString() ?? '') ?? 1;
        unitPrice = prod['unit_price'] is double ? prod['unit_price'] : double.tryParse(prod['unit_price']?.toString() ?? '') ?? 0.0;
      } else {
        productVal = prod.product;
        familyVal = prod.family?.toString();
        subVal = prod.subFamily?.toString();
        qty = prod.quantity ?? 1;
        unitPrice = prod.unitPrice ?? 0.0;
      }

      return ProductLine(
        product: productVal,
        family: familyVal,
        subFamily: subVal,
        // brand: prod.brand,
        quantity: qty,
        supplier: prod is Map ? (prod['supplier']?.toString()) : prod.supplier,
        unitPrice: unitPrice,
      );
    }).toList();
    // initialize product controller and fetch families
    productController = Provider.of<ProductController>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProductFamilies());
  }

  @override
  void dispose() {
    requestorController.dispose();
    submittedDateController.dispose();
    dueDateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RequestEditPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pr = widget.purchaseRequest;
    requestorController.text = pr.requestedBy?.toString() ?? '';
    submittedDateController.text = pr.startDate != null ? _dateFormat.format(pr.startDate!) : '';
    dueDateController.text = pr.endDate != null ? _dateFormat.format(pr.endDate!) : '';
    noteController.text = pr.description ?? '';
    priority = pr.priority?.toString() ?? 'High';
    status = _normalizeStatus(pr.status);
    final products = pr.products ?? [];
    productLines = products.map<ProductLine>((dynamic prod) {
      String? productVal;
      String? familyVal;
      String? subVal;
      int qty = 1;
      double unitPrice = 0.0;
      if (prod is Map) {
        productVal = prod['product']?.toString();
        familyVal = prod['family']?.toString() ?? prod['family_name']?.toString();
        subVal = prod['subFamily']?.toString() ?? prod['sub_family']?.toString() ?? prod['subcategory']?.toString();
        qty = prod['quantity'] is int ? prod['quantity'] : int.tryParse(prod['quantity']?.toString() ?? '') ?? 1;
        unitPrice = prod['unit_price'] is double ? prod['unit_price'] : double.tryParse(prod['unit_price']?.toString() ?? '') ?? 0.0;
      } else {
        productVal = prod.product;
        familyVal = prod.family?.toString();
        subVal = prod.subFamily?.toString();
        qty = prod.quantity ?? 1;
        unitPrice = prod.unitPrice ?? 0.0;
      }
      return ProductLine(
        product: productVal,
        family: familyVal,
        subFamily: subVal,
        // brand: prod.brand,
        quantity: qty,
        supplier: prod is Map ? (prod['supplier']?.toString()) : prod.supplier,
        unitPrice: unitPrice,
      );
    }).toList();
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

  Color? _priorityColor(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return Colors.red.shade100;
      case 'medium':
        return Colors.orange.shade100;
      case 'low':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color? _priorityTextColor(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return Colors.red.shade800;
      case 'medium':
        return Colors.orange.shade800;
      case 'low':
        return Colors.green.shade800;
      default:
        return Colors.black;
    }
  }

  void _addProduct() {
    setState(() {
      productLines.add(ProductLine(product: '', quantity: 1));
    });
  }

  void _removeProduct(int index) {
    setState(() {
      productLines.removeAt(index);
    });
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
                      'Edit Purchase Request',
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
              // Loading families state
              if (_loadingFamilies) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
              ],
              if (_familiesError != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text('Failed loading product families: $_familiesError', style: const TextStyle(color: Colors.red)),
                ),
              ],

              // Product & Quantity rows dynamiques (refonte)
              ...productLines.asMap().entries.map((entry) {
                int idx = entry.key;
                ProductLine prod = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                DropdownButtonFormField<String>(
                                  value: prod.family,
                                  items: dynamicProductFamilies.keys.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                                  onChanged: (val) => setState(() {
                                    prod.family = val;
                                    prod.subFamily = null;
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
                                DropdownButtonFormField<String>(
                                  value: prod.subFamily,
                                  items: (dynamicProductFamilies[prod.family] ?? []).map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (val) => setState(() => prod.subFamily = val),
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
                                Text('Product ${productLines.length > 1 ? idx + 1 : ''}'),
                                const SizedBox(height: 4),
                                TextFormField(
                                  initialValue: prod.product,
                                  onChanged: (val) => setState(() => prod.product = val),
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
                                  initialValue: prod.quantity.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => setState(() => prod.quantity = int.tryParse(val) ?? 1),
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
                              onPressed: () => _removeProduct(idx),
                              tooltip: 'Remove product',
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              // Bouton pour ajouter un produit
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  onPressed: _addProduct,
                ),
              ),
              const SizedBox(height: 24),
              // Due Date & Priority row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Due Date'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: dueDateController,
                          readOnly: false,
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
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Priority'),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priorityColor(priority),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            // match saved priority case-insensitively and default to 'High'
                            value: ['High', 'Medium', 'Low']
                                .firstWhere((p) => p.toLowerCase() == priority.toLowerCase(), orElse: () => 'High'),
                            items: ['High', 'Medium', 'Low']
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                        // display the label in UPPERCASE (e.g. 'HIGH')
                                        p.toUpperCase(),
                                        style: TextStyle(
                                          color: _priorityTextColor(p),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => priority = val ?? 'High'),
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
              // Note (full width)
              const Text('Note'),
              const SizedBox(height: 4),
              TextField(
                controller: noteController,
                maxLines: 4,
                readOnly: false,
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
              const SizedBox(height: 24),
              // Status badge
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Status'),
                  SizedBox(width: 8),
                  Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status.toLowerCase() == 'approved'
                      ? Colors.green.shade100
                      : status.toLowerCase() == 'pending'
                          ? Colors.orange.shade100
                          : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toLowerCase(),
                  style: TextStyle(
                    color: status.toLowerCase() == 'approved'
                        ? Colors.green
                        : status.toLowerCase() == 'pending'
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
                ],
              ),
              // const SizedBox(height: 4),
              
              const SizedBox(height: 32),
              // Save button (unchanged)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
              final products = productLines
                .map((prod) => {
                      'product': prod.product,
                      'quantity': prod.quantity,
                      'family': prod.family,
                      'subFamily': prod.subFamily,
                    })
                .toList();
                          final updateData = {
                            'start_date': submittedDateController.text,
                            'end_date': dueDateController.text,
                            'requested_by': int.tryParse(requestorController.text) ?? 1,
                            'description': noteController.text,
                            'title': 'Demande d\'achat',
                            'status': status.toLowerCase(),
                            'products': products,
                          };
                          try {
                            final controller = Provider.of<PurchaseRequestController>(context, listen: false);
                            await controller.updateRequest(widget.purchaseRequest.id!, updateData, context);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(backgroundColor: Colors.blue, 
                              content: Text('Purchase request updated successfully!')
                              ),
                            );
                            Navigator.pop(context, updateData);
                          } on DioException catch (e) {
                            if (!mounted) return;
                            String errorMsg = 'Failed to update';
                            if (e.response != null && e.response?.data != null) {
                              errorMsg = e.response?.data.toString() ?? errorMsg;
                              print('Erreur serveur (body): ${e.response?.data}');
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMsg)),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to update: ${e.toString()}')),
                            );
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}