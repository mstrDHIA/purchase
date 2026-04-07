import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/product_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class PurchaseRequestorForm extends StatefulWidget {
  const PurchaseRequestorForm({super.key, required this.onSave, required this.initialOrder});
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic> initialOrder;

  @override
  State<PurchaseRequestorForm> createState() => _PurchaseRequestorFormState();
}

class _PurchaseRequestorFormState extends State<PurchaseRequestorForm> {
  final TextEditingController productController = TextEditingController();
  String? selectedFamily;
  String? selectedSubFamily;
  String? selectedProduct;
  late Map<String, List<String>> dynamicProductFamilies = {};
  final Map<String, String> familyIds = {};
  final Map<String, String> subfamilyIds = {};
  List<String> productOptions = [];
  late ProductController productControllerProvider;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  late FocusNode noteFocusNode;
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
    productControllerProvider = Provider.of<ProductController>(context, listen: false);
    _fetchProductFamilies();

    // Charger l'ordre existant
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
      }

      if (selectedDueDate != null) {
        dueDateController.text = DateFormat('MMM dd, yyyy').format(selectedDueDate!);
      }
    }

    // Focus node for note field and initial caret position
    noteFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        noteController.selection = const TextSelection.collapsed(offset: 0);
      }
    });
  }

  Future<void> _fetchProductFamilies() async {
    try {
      final categories = await productControllerProvider.getCategories(null);
      if (categories is List<dynamic>) {
        final families = <String, List<String>>{};
        final allCategories = categories.cast<Map<String, dynamic>>();

        final parentCategories = allCategories.where((cat) => cat['parent_category'] == null).toList();
        for (final family in parentCategories) {
          final familyId = family['id']?.toString() ?? '';
          final familyName = family['name'] as String;
          familyIds[familyName] = familyId;

          final subfamilies = allCategories
              .where((cat) => cat['parent_category'] == family['id'])
              .map((cat) {
                final subName = cat['name'] as String;
                subfamilyIds[subName] = cat['id']?.toString() ?? '';
                return subName;
              })
              .toList();

          families[familyName] = subfamilies.isNotEmpty ? subfamilies : [familyName];
        }

        setState(() {
          dynamicProductFamilies = families;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToLoadFamilies(e.toString()))),
        );
      }
    }
  }

  Future<void> _loadProductsForSubfamily(String subfamilyId) async {
    try {
      final response = await productControllerProvider.getProducts(subcategoryId: int.tryParse(subfamilyId));
      final names = <String>[];
      for (final product in response) {
        final name = product.name;
        if (name.isNotEmpty) {
          names.add(name);
        }
      }
      setState(() {
        productOptions = names.toSet().toList()..sort();
        selectedProduct = null;
        productController.clear();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          productOptions = [];
          selectedProduct = null;
          productController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToLoadFamilies(e.toString()))),
        );
      }
    }
  }

  @override
  void dispose() {
    productController.dispose();
    quantityController.dispose();
    noteController.dispose();
    noteFocusNode.dispose();
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
        SnackBar(content: Text(AppLocalizations.of(context)!.userNotLoggedInError)),
      );
      return;
    }

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseAddAtLeastOneProduct)),
      );
      return;
    }

    for (final p in products) {
      if ((p['product'] == null || p['product'].toString().isEmpty) ||
          (p['quantity'] == null || p['quantity'].toString().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.eachProductMustHaveNameAndQuantity)),
        );
        return;
      }
    }

    if (selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidDueDate)),
      );
      return;
    }

    if (selectedPriority == null || selectedPriority!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fieldRequired)),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.requestSavedAddAnother)),
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
    final family = selectedFamily;
    final subFamily = selectedSubFamily;
    final product = productController.text.trim().isNotEmpty ? productController.text.trim() : selectedProduct?.trim();
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;

    if ((family == null || family.isEmpty) ||
        (subFamily == null || subFamily.isEmpty) ||
        quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une famille, une sous-famille et une quantité valide')),
      );
      return;
    }

    setState(() {
      products.add({
        'family': family,
        'subFamily': subFamily,
        'product': product != null && product.isNotEmpty ? product : subFamily,
        'quantity': quantity,
        'brand': null,
        'unit_price': 0.0,
      });

      productController.clear();
      selectedProduct = null;
      quantityController.clear();
      selectedFamily = null;
      selectedSubFamily = null;
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // LEFT CONTAINER — Produits
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedFamily,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.familyLabel,
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: dynamicProductFamilies.keys
                            .map((fam) => DropdownMenuItem(value: fam, child: Text(fam)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedFamily = val;
                            selectedSubFamily = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedSubFamily,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.subfamilyLabel,
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: selectedFamily == null
                            ? []
                            : dynamicProductFamilies[selectedFamily]!
                                .map((sub) => DropdownMenuItem(value: sub, child: Text(sub)))
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedSubFamily = val;
                            selectedProduct = null;
                            productController.clear();
                            productOptions = [];
                          });
                          if (val != null) {
                            final subfamilyId = subfamilyIds[val];
                            if (subfamilyId != null && subfamilyId.isNotEmpty) {
                              _loadProductsForSubfamily(subfamilyId);
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedProduct,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.product,
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: productOptions
                            .map((prod) => DropdownMenuItem(value: prod, child: Text(prod)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProduct = value;
                            if (value != null) {
                              productController.text = value;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: productController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.product,
                          helperText: 'Ou saisissez manuellement',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.quantity,
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _addProduct,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: Text(AppLocalizations.of(context)!.confirm, style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (products.isNotEmpty) ...[
                        Text(AppLocalizations.of(context)!.products + ':', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final item = products[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['product'] ?? item['subFamily'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${AppLocalizations.of(context)!.familyLabel}: ${item['family'] ?? ''} • ${AppLocalizations.of(context)!.subfamilyLabel}: ${item['subFamily'] ?? ''}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                          ),
                                          if ((item['product'] ?? '') != (item['subFamily'] ?? '')) ...[
                                            const SizedBox(height: 6),
                                            Text(item['product'] ?? '', style: const TextStyle(fontSize: 13)),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text('${AppLocalizations.of(context)!.quantity}: ${item['quantity'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(height: 6),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              products.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ] else
                        const Spacer(),
                    ],
                  ),
                ),
              ),

              // RIGHT CONTAINER — Notes, priorité, dates
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: dueDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.dueDate,
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        onTap: _pickDueDate,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.priority,
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ['high', 'medium', 'low']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedPriority = val),
                      ),

                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.noteLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),

                      Expanded(
                        child: TextField(
                          controller: noteController,
                          focusNode: noteFocusNode,
                          maxLines: 25,
                          // expands: true,
                          onTap: () {
                            // Force caret to the start whenever user taps the field
                            // if (mounted) {
                            //   // Request focus then set selection at beginning
                            //   noteFocusNode.requestFocus();
                            //   noteController.selection = const TextSelection.collapsed(offset: 0);
                            //   WidgetsBinding.instance.addPostFrameCallback((_) {
                            //     if (mounted) noteController.selection = const TextSelection.collapsed(offset: 0);
                            //   });
                            // }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () async {
                                final shouldCancel = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.cancel),
                                    content: Text(AppLocalizations.of(context)!.confirmCancelUnsavedChanges),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text(AppLocalizations.of(context)!.no),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text(AppLocalizations.of(context)!.yes),
                                      ),
                                    ],
                                  ),
                                );
                                if (shouldCancel == true) Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                foregroundColor: Colors.black54,
                                backgroundColor: const Color(0xFFF3F3F3),
                              ),
                              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(fontSize: 14)),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _save(addAnother: false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7B61FF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              child: Text(AppLocalizations.of(context)!.saveBtn, style: const TextStyle(fontSize: 14, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
