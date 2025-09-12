import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
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

  // Liste dynamique de produits (chacun avec ses contrôleurs)
  late List<Map<String, TextEditingController>> productControllers;

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

    // Initialisation des contrôleurs pour chaque produit
    final products = pr.products ?? [];
    productControllers = products
        .map<Map<String, TextEditingController>>((prod) {
          String name = '';
          String quantity = '';
          try {
            if (prod is Map) {
              name = prod['name'] ?? prod['productName'] ?? prod['designation'] ?? prod['product']?.toString() ?? prod.toString();
              quantity = prod['quantity']?.toString() ?? '';
            } else {
              // For ProductLine or other objects
              if (prod.product != null && prod.product is Map) {
                name = prod.product['name'] ?? prod.product['productName'] ?? prod.product['designation'] ?? prod.product.toString();
              } else if (prod.product != null && prod.product is String) {
                name = prod.product;
              } else {
                name = prod.name ?? prod.productName ?? prod.designation ?? prod.product?.name ?? prod.product?.productName ?? prod.product?.designation ?? prod.product?.toString() ?? prod.toString();
              }
              quantity = prod.quantity?.toString() ?? '';
            }
          } catch (e) {
            name = prod.toString();
          }
          return {
            'name': TextEditingController(text: name),
            'quantity': TextEditingController(text: quantity),
          };
        })
        .toList();
  }

  @override
  void dispose() {
    requestorController.dispose();
    submittedDateController.dispose();
    dueDateController.dispose();
    noteController.dispose();
    for (var prod in productControllers) {
      prod['name']?.dispose();
      prod['quantity']?.dispose();
    }
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
    productControllers = products
        .map<Map<String, TextEditingController>>((prod) {
          String name = '';
          String quantity = '';
          try {
            if (prod is Map) {
              name = prod['name'] ?? prod['productName'] ?? prod['designation'] ?? prod['product']?.toString() ?? prod.toString();
              quantity = prod['quantity']?.toString() ?? '';
            } else {
              // For ProductLine or other objects
              if (prod.product != null && prod.product is Map) {
                name = prod.product['name'] ?? prod.product['productName'] ?? prod.product['designation'] ?? prod.product.toString();
              } else if (prod.product != null && prod.product is String) {
                name = prod.product;
              } else {
                name = prod.name ?? prod.productName ?? prod.designation ?? prod.product?.name ?? prod.product?.productName ?? prod.product?.designation ?? prod.product?.toString() ?? prod.toString();
              }
              quantity = prod.quantity?.toString() ?? '';
            }
          } catch (e) {
            name = prod.toString();
          }
          return {
            'name': TextEditingController(text: name),
            'quantity': TextEditingController(text: quantity),
          };
        })
        .toList();
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
      productControllers.add({
        'name': TextEditingController(),
        'quantity': TextEditingController(),
      });
    });
  }

  void _removeProduct(int index) {
    setState(() {
      productControllers[index]['name']?.dispose();
      productControllers[index]['quantity']?.dispose();
      productControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Purchase Request'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Requestor
            TextField(
              controller: requestorController,
              decoration: const InputDecoration(
                labelText: 'Requestor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Submitted Date
            TextField(
              controller: submittedDateController,
              decoration: const InputDecoration(
                labelText: 'Submitted Date',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Due Date
            TextField(
              controller: dueDateController,
              decoration: const InputDecoration(
                labelText: 'Due Date',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Produits dynamiques
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Produits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un produit'),
                ),
              ],
            ),
            ...productControllers.asMap().entries.map((entry) {
              final idx = entry.key;
              final prod = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    // Nom du produit
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: prod['name'],
                        decoration: const InputDecoration(
                          labelText: 'Nom du produit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Quantité
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: prod['quantity'],
                        decoration: const InputDecoration(
                          labelText: 'Quantité',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeProduct(idx),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            // Status Dropdown
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ['Pending', 'Approved', 'Rejected']
                  .map((stat) => DropdownMenuItem(
                        value: stat,
                        child: Text(stat),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => status = val);
              },
            ),
            const SizedBox(height: 16),
            // Note
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        final products = productControllers
                            .map((prod) => {
                                  'product': prod['name']!.text,
                                  'quantity': int.tryParse(prod['quantity']!.text) ?? 0,
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
                        print('updateData envoyé: ' + updateData.toString());
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
    );
  }
}