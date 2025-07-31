import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestEditPage extends StatefulWidget {
  final Map<String, dynamic> request;
  const RequestEditPage({super.key, required this.request, required Null Function(dynamic _) onSave});

  @override
  State<RequestEditPage> createState() => _RequestEditPageState();
}

class _RequestEditPageState extends State<RequestEditPage> {
  late TextEditingController requestorController;
  late TextEditingController submittedDateController;
  late TextEditingController dueDateController;
  late TextEditingController noteController;

  String priority = 'High';
  String status = 'Pending';

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Liste dynamique de produits (chacun avec ses contrôleurs)
  late List<Map<String, TextEditingController>> productControllers;

  @override
  void initState() {
    super.initState();
    requestorController = TextEditingController(text: widget.request['requestor'] ?? '');
    submittedDateController = TextEditingController(
        text: widget.request['submittedDate'] != null && widget.request['submittedDate'] is DateTime
            ? _dateFormat.format(widget.request['submittedDate'])
            : (widget.request['submittedDate'] ?? ''));
    dueDateController = TextEditingController(
        text: widget.request['dueDate'] != null && widget.request['dueDate'] is DateTime
            ? _dateFormat.format(widget.request['dueDate'])
            : (widget.request['dueDate'] ?? ''));
    noteController = TextEditingController(text: widget.request['note'] ?? '');
    priority = widget.request['priority'] ?? 'High';
    status = widget.request['status'] ?? 'Pending';

    // Initialisation des contrôleurs pour chaque produit
    final products = (widget.request['products'] ?? []) as List;
    productControllers = products
        .map<Map<String, TextEditingController>>((prod) => {
              'name': TextEditingController(text: prod['name'] ?? ''),
              'quantity': TextEditingController(text: prod['quantity']?.toString() ?? ''),
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
                          labelText: 'Nom du produit', // <-- Ceci affiche "Nom du produit"
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
            // Priority Dropdown
            DropdownButtonFormField<String>(
              value: priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: ['High', 'Medium', 'Low']
                  .map((prio) => DropdownMenuItem(
                        value: prio,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priorityColor(prio)!,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            prio,
                            style: TextStyle(
                              color: _priorityTextColor(prio),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => priority = val);
              },
            ),
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
                onPressed: () {
                  final updatedRequest = {
                    'id': widget.request['id'],
                    'actionCreatedBy': widget.request['actionCreatedBy'],
                    'requestor': requestorController.text,
                    'dateSubmitted': submittedDateController.text.isNotEmpty
                        ? DateTime.tryParse(submittedDateController.text) ?? widget.request['dateSubmitted']
                        : widget.request['dateSubmitted'],
                    'dueDate': dueDateController.text.isNotEmpty
                        ? DateTime.tryParse(dueDateController.text) ?? widget.request['dueDate']
                        : widget.request['dueDate'],
                    'products': productControllers
                        .map((prod) => {
                              'name': prod['name']!.text,
                              'quantity': prod['quantity']!.text,
                            })
                        .toList(),
                    'priority': priority,
                    'status': status,
                    'note': noteController.text,
                  };
                  Navigator.pop(context, updatedRequest);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}