import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:flutter_application_1/screens/Purchase order/purchase_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

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

  // Normalize status to match dropdown items
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
    productLines = (pr.products ?? []).map<ProductLine>((prod) {
      return ProductLine(
        product: prod.product,
        brand: prod.brand,
        quantity: prod.quantity,
        supplier: prod.supplier,
        unitPrice: prod.unitPrice,
      );
    }).toList();
  }

  @override
  void dispose() {
    requestorController.dispose();
    submittedDateController.dispose();
    dueDateController.dispose();
    noteController.dispose();
    // Rien à disposer pour productLines
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
    productLines = products.map<ProductLine>((prod) {
      return ProductLine(
        product: prod.product,
        brand: prod.brand,
        quantity: prod.quantity,
        supplier: prod.supplier,
        unitPrice: prod.unitPrice,
      );
    }).toList();
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
              // Product & Quantity rows dynamiques (refonte)
              ...productLines.asMap().entries.map((entry) {
                int idx = entry.key;
                ProductLine prod = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
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
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priority.toLowerCase(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
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
              const Text('Status'),
              const SizedBox(height: 4),
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