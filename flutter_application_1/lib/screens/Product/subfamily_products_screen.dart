import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/product_controller.dart';
import 'package:flutter_application_1/models/category.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SubfamilyProductsPage extends StatefulWidget {
  final Map<String, dynamic> family;
  final Map<String, dynamic> subfamily;

  const SubfamilyProductsPage({Key? key, required this.family, required this.subfamily}) : super(key: key);

  @override
  State<SubfamilyProductsPage> createState() => _SubfamilyProductsPageState();
}

class _SubfamilyProductsPageState extends State<SubfamilyProductsPage> {
  late ProductController productController;
  late Future<List<Map<String, dynamic>>> _productsFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    productController = Provider.of<ProductController>(context, listen: false);
    _productsFuture = _fetchProducts();
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final response = await productController.getCategories(widget.subfamily['id']);
    if (response is List<dynamic>) {
      return response.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        return Map<String, dynamic>.from(e as Map);
      }).toList();
    }
    return [];
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = _fetchProducts();
    });
  }

  Future<void> _openAddProductDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addProduct),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.product),
                validator: (value) => value == null || value.trim().isEmpty ? AppLocalizations.of(context)!.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    setState(() => _isSaving = true);
                    try {
                      final parentId = int.tryParse(widget.subfamily['id']?.toString() ?? '');
                      final newProduct = Category(
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        creationDate: DateTime.now(),
                        parentCategory: parentId,
                      );
                      await productController.createCategories(newProduct);
                      if (mounted) {
                        Navigator.of(context).pop(true);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.failedToLoadFamilies(e.toString()))),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isSaving = false);
                      }
                    }
                  },
            child: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(AppLocalizations.of(context)!.saveBtn),
          ),
        ],
      ),
    );

    if (result == true) {
      await _refreshProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.requestSavedAddAnother)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyName = widget.family['name'] ?? '';
    final subfamilyName = widget.subfamily['name'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('$familyName › $subfamilyName'),
        backgroundColor: const Color(0xFF7B61FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)?.products ?? 'Products', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${AppLocalizations.of(context)?.subfamilyLabel ?? 'Subfamily'}: $subfamilyName', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _openAddProductDialog,
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.addProduct),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B61FF)),
                ),
                TextButton.icon(
                  onPressed: _refreshProducts,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context)!.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final products = snapshot.data ?? [];
                  if (products.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }
                  return ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(product['name'] ?? ''),
                          subtitle: Text(product['description'] ?? ''),
                          trailing: Text('#${product['id'] ?? ''}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
