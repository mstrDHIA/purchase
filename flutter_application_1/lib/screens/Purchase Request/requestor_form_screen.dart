import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseRequestorForm extends StatefulWidget {
  const PurchaseRequestorForm({super.key, required this.onSave, required this.initialOrder});
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic> initialOrder;

  @override
  State<PurchaseRequestorForm> createState() => _PurchaseRequestorFormState();
}

class _PurchaseRequestorFormState extends State<PurchaseRequestorForm> {
  final TextEditingController productController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedPriority;
  DateTime? selectedDueDate;
  List<Map<String, dynamic>> products = [];
  late UserController userController;
  Null get order => null;

  @override
  void initState() {
    super.initState();
    userController = Provider.of<UserController>(context, listen: false);
    if (widget.initialOrder.isNotEmpty) {
      productController.text = widget.initialOrder['product'] ?? '';
      quantityController.text = widget.initialOrder['quantity']?.toString() ?? '';
      noteController.text = widget.initialOrder['note'] ?? '';
      selectedPriority = widget.initialOrder['priority'];
      var dueDateValue = widget.initialOrder['dueDate'];
      if (dueDateValue is String) {
        selectedDueDate = DateTime.tryParse(dueDateValue);
      } else if (dueDateValue is DateTime) {
        selectedDueDate = dueDateValue;
      } else {
        selectedDueDate = null;
      }
      if (selectedDueDate != null) {
        dueDateController.text = DateFormat('MMM dd, yyyy').format(selectedDueDate!);
      }
    }
  }

  @override
  void dispose() {
    productController.dispose();
    quantityController.dispose();
    noteController.dispose();
    dueDateController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDueDate = picked;
        dueDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _save({bool addAnother = false}) async {
    if (userController.currentUser.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: utilisateur non connecté ou id manquant')),
      );
      return;
    }
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product')),
      );
      return;
    }
    for (final p in products) {
      if ((p['product'] == null || p['product'].toString().isEmpty) ||
          (p['quantity'] == null || p['quantity'].toString().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Each product must have a name and a quantity')),
        );
        return;
      }
    }
    if (selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }
    if (selectedPriority == null || selectedPriority!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a priority')),
      );
      return;
    }
    final dateSubmitted = DateTime.now();
    if (!selectedDueDate!.isAfter(dateSubmitted)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Due date must be after submission date')),
      );
      return;
    }

    final Map<String, dynamic> order = {
      'title': titleController.text.isNotEmpty ? titleController.text : 'Demande d\'achat',
      'description': noteController.text.isNotEmpty ? noteController.text : (descriptionController.text.isNotEmpty ? descriptionController.text : 'Description par défaut'),
      'requested_by': userController.currentUser.id,
      'products': products,
      'priority': selectedPriority,
      'end_date': '${selectedDueDate!.year}-${selectedDueDate!.month}-${selectedDueDate!.day}',
      'start_date': '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
    };

    try {
      await Provider.of<PurchaseRequestController>(context, listen: false).addRequest(order);
      if (addAnother) {
        productController.clear();
        quantityController.clear();
        noteController.clear();
        dueDateController.clear();
        setState(() {
          selectedPriority = null;
          selectedDueDate = null;
          products.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request saved! You can now add another.')),
        );
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save request: $e')),
      );
    }
  }

  void _addProduct() {
    final product = productController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    if (product.isEmpty || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid product and quantity')),
      );
      return;
    }
    setState(() {
      products.add({
        'product': product,
        'quantity': quantity,
        'brand': null, // or provide a default/empty string if needed
        'unit_price': 0.0, // default value
      });
      productController.clear();
      quantityController.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Purchase Request Form',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product & Quantity row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: productController,
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green, size: 28),
                    onPressed: _addProduct, // Add product functionality
                  ),
                ],
              ),
              // Show the list of added products
              if (products.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return ListTile(
                      title: Text(item['product']),
                      subtitle: Text('Quantity: ${item['quantity']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            products.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),
              // Due date & Priority row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dueDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Due date',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: _pickDueDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: ['high', 'medium', 'low']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedPriority = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Note field
              const Text(
                'Note',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter text',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const Spacer(),
              // Buttons row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _save(addAnother: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B61FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _save(addAnother: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B61FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Save & add another', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final shouldCancel = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cancel Request'),
                            content: const Text('Are you sure you want to cancel? Unsaved changes will be lost.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false), // User chooses not to cancel
                                child: const Text('No'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true), // User confirms cancellation
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );
                        if (shouldCancel == true) {
                          Navigator.of(context).pop(); // Retourne à la page précédente proprement
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: Colors.black54,
                        backgroundColor: const Color(0xFFF3F3F3),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}