import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/supplier_controller.dart';

class Supplier {
  final int id;
  final String email;
  final String name;

  Supplier(this.id, this.email, this.name);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_email': email,
      'name': name,
    };
  }

  /// Factory constructor to create Supplier from API response
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      json['id'] as int? ?? 0,
      json['contact_email'] as String? ?? '',
      json['name'] as String? ?? '',
    );
  }
}

class SupplierRegistrationPage extends StatefulWidget {
  const SupplierRegistrationPage({super.key});

  @override
  State<SupplierRegistrationPage> createState() => _SupplierRegistrationPageState();
}

class _SupplierRegistrationPageState extends State<SupplierRegistrationPage> {
  String searchText = '';
  bool _initialLoadDone = false;

  final TextEditingController _searchCtrl = TextEditingController();
  int? _sortIndex;
  bool _sortAsc = true;

  @override
  void initState() {
    super.initState();
    // Fetch suppliers will be called in build() after widget is mounted
    // This avoids BuildContext issues during initialization
  }

  void _sortByColumn(int columnIndex, bool asc) {
    final controller = context.read<SupplierController>();
    switch (columnIndex) {
      case 0: // ID
        controller.suppliers.sort((a, b) => asc ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
        break;
      case 1: // Email
        controller.suppliers.sort((a, b) => asc
            ? a.email.toLowerCase().compareTo(b.email.toLowerCase())
            : b.email.toLowerCase().compareTo(a.email.toLowerCase()));
        break;
      case 2: // Name
        controller.suppliers.sort((a, b) => asc
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }
    setState(() {
      _sortIndex = columnIndex;
      _sortAsc = asc;
    });
  }

  Future<void> _showEditDialog({Supplier? supplier, int? index}) async {
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final emailCtrl = TextEditingController(text: supplier?.email ?? '');
    bool isSubmitting = false;
    final controller = context.read<SupplierController>();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(supplier == null ? 'Add Supplier' : 'Edit Supplier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      try {
                        if (supplier != null && index != null) {
                          // Update existing supplier via controller
                          await controller.editSupplier(
                            id: supplier.id,
                            name: nameCtrl.text,
                            contactEmail: emailCtrl.text,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Supplier updated successfully!')),
                            );
                          }
                        } else {
                          // Create new supplier via controller
                          await controller.createSupplier(
                            name: nameCtrl.text,
                            contactEmail: emailCtrl.text,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Supplier created successfully!')),
                            );
                          }
                        }
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                          setDialogState(() => isSubmitting = false);
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int index) async {
    final controller = context.read<SupplierController>();
    final supplier = controller.suppliers[index];
    
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Delete "${supplier.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        final supplierId = supplier.id;
        await controller.deleteSupplier(supplierId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting supplier: $e')),
          );
        }
      }
    }
  }

  Future<void> _openAddSupplierDialog() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    final controller = context.read<SupplierController>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Supplier'),
          contentPadding: const EdgeInsets.all(20),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Contact Email'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(labelText: 'Address'),
                      enabled: !isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() => isSubmitting = true);
                        try {
                          await controller.createSupplier(
                            name: nameCtrl.text,
                            contactEmail: emailCtrl.text,
                            phoneNumber: phoneCtrl.text.isNotEmpty ? phoneCtrl.text : null,
                            address: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
                          );
                          
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Supplier created successfully!')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                            setDialogState(() => isSubmitting = false);
                          }
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showViewSupplierDialog(Supplier supplier) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supplier Details'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.mail, color: Colors.purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(supplier.email, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Name', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(supplier.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.tag, color: Colors.purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ID', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(supplier.id.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupplierController>();
    
    // Fetch suppliers on first build if not already done
    if (!_initialLoadDone && controller.suppliers.isEmpty && !controller.isLoading) {
      _initialLoadDone = true;
      Future.microtask(() {
        controller.fetchSuppliers();
      });
    }
    
    final suppliers = controller.suppliers;
    final filter = _searchCtrl.text.toLowerCase();

    final filtered = suppliers.where((s) {
      final name = s.name.toLowerCase();
      final email = s.email.toLowerCase();
      final matchesSearch = name.contains(filter) || email.contains(filter);
      return matchesSearch;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: const Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Supplier Registration',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search supplier name, email ...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: const Color(0xFFF7F3FF),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    context.read<SupplierController>().fetchSuppliers();
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 6),
                      Text('Reset'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Supplier'),
                  onPressed: () async {
                    await _openAddSupplierDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF7F4FA),
              // left padding for ID column flush after sidebar
              padding: const EdgeInsets.only(left: 16, right: 0, top: 24, bottom: 24),
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => controller.fetchSuppliers(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: DataTable(
                            horizontalMargin: 16,
                            columnSpacing: 0,
                            sortColumnIndex: _sortIndex,
                            sortAscending: _sortAsc,
                            columns: [
                              DataColumn(
                                label: SizedBox(
                                  width: 80,
                                  child: Align(alignment: Alignment.centerLeft, child: const Text('ID', style: TextStyle(fontWeight: FontWeight.w600))),
                                ),
                                numeric: true,
                                onSort: (i, asc) => _sortByColumn(0, asc),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 360,
                                  child: Align(alignment: Alignment.centerLeft, child: const Text('Email', style: TextStyle(fontWeight: FontWeight.w600))),
                                ),
                                onSort: (i, asc) => _sortByColumn(1, asc),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 360,
                                  child: Align(alignment: Alignment.centerLeft, child: const Text('Name', style: TextStyle(fontWeight: FontWeight.w600))),
                                ),
                                onSort: (i, asc) => _sortByColumn(2, asc),
                              ),
                              DataColumn(
                                label: SizedBox(
                                  width: 120,
                                  child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
                                ),
                              ),
                            ],
                            rows: filtered.asMap().entries.map((entry) {
                              final supplier = entry.value;
                              final index = suppliers.indexOf(supplier);
                              return DataRow(
                                cells: [
                                  DataCell(SizedBox(width: 80, child: Align(alignment: Alignment.centerLeft, child: Text(supplier.id.toString())))),
                                  DataCell(SizedBox(width: 360, child: Align(alignment: Alignment.centerLeft, child: Text(supplier.email)))),
                                  DataCell(SizedBox(width: 360, child: Align(alignment: Alignment.centerLeft, child: Text(supplier.name)))),
                                  DataCell(
                                    SizedBox(
                                      width: 120,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, color: Colors.blue),
                                            tooltip: 'View',
                                            onPressed: () {
                                              _showViewSupplierDialog(supplier);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.teal),
                                            tooltip: 'Edit',
                                            onPressed: () => _showEditDialog(supplier: supplier, index: index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            tooltip: 'Delete',
                                            onPressed: () => _confirmDelete(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}