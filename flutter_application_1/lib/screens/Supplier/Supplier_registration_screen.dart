import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/supplier_controller.dart';

/// A small local Supplier model used by the screen. The project's real
/// Supplier model may differ; this mirrors the fields used in the UI.
class Supplier {
  final int id;
  final String? email;
  final String? name;
  final String? phone;
  final String? matricule;
  final String? cin;

  Supplier({
    required this.id,
    this.email,
    this.name,
    this.phone,
    this.matricule,
    this.cin,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'] as int? ?? 0,
        email: json['contact_email'] as String?,
        name: json['name'] as String?,
        phone: json['phone'] as String? ??
               json['phone_number'] as String? ??
               json['contact_phone'] as String?,
        matricule: json['matricule'] as String? ??
                   json['registration_number'] as String?,
        cin: json['cin'] as String? ??
             json['cin_number'] as String? ??
             json['identity_number'] as String?,
      );
}

class SupplierRegistrationPage extends StatefulWidget {
  const SupplierRegistrationPage({super.key});

  @override
  State<SupplierRegistrationPage> createState() => _SupplierRegistrationPageState();
}

class _SupplierRegistrationPageState extends State<SupplierRegistrationPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _initialLoadDone = false;
  int? _sortIndex;
  bool _sortAsc = true;

  int _currentPage = 1;
  final int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
  }

  String _safeString(String? value) => value ?? '';

  void _sortByColumn(int columnIndex, bool asc) {
    final controller = context.read<SupplierController>();
    switch (columnIndex) {
      case 0:
        controller.suppliers.sort((a, b) => asc ? a.id.compareTo(b.id) : b.id.compareTo(a.id));
        break;
      case 1:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.email).toLowerCase().compareTo(_safeString(b.email).toLowerCase())
            : _safeString(b.email).toLowerCase().compareTo(_safeString(a.email).toLowerCase()));
        break;
      case 2:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.name).toLowerCase().compareTo(_safeString(b.name).toLowerCase())
            : _safeString(b.name).toLowerCase().compareTo(_safeString(a.name).toLowerCase()));
        break;
      case 3:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.phone).toLowerCase().compareTo(_safeString(b.phone).toLowerCase())
            : _safeString(b.phone).toLowerCase().compareTo(_safeString(a.phone).toLowerCase()));
        break;
      case 4:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.matricule).toLowerCase().compareTo(_safeString(b.matricule).toLowerCase())
            : _safeString(b.matricule).toLowerCase().compareTo(_safeString(a.matricule).toLowerCase()));
        break;
      case 5:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.cin).toLowerCase().compareTo(_safeString(b.cin).toLowerCase())
            : _safeString(b.cin).toLowerCase().compareTo(_safeString(a.cin).toLowerCase()));
        break;
    }
    setState(() {
      _sortIndex = columnIndex;
      _sortAsc = asc;
    });
  }

  Future<void> _confirmDelete(int index) async {
    final controller = context.read<SupplierController>();
    final supplier = controller.suppliers[index];

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Delete "${_safeString(supplier.name)}" ?'),
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
        await controller.deleteSupplier(supplier.id);
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
    final matriculeCtrl = TextEditingController();
    final cinCtrl = TextEditingController();
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
                      controller: matriculeCtrl,
                      decoration: const InputDecoration(labelText: 'Matricule'),
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: cinCtrl,
                      decoration: const InputDecoration(labelText: 'CIN'),
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

  Future<void> _showEditDialog({Supplier? supplier, int? index}) async {
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final emailCtrl = TextEditingController(text: supplier?.email ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final matriculeCtrl = TextEditingController(text: supplier?.matricule ?? '');
    final cinCtrl = TextEditingController(text: supplier?.cin ?? '');
    bool isSubmitting = false;
    final controller = context.read<SupplierController>();

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(supplier == null ? 'Add Supplier' : 'Edit Supplier'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Contact Email')),
                  const SizedBox(height: 12),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                  const SizedBox(height: 12),
                  TextField(controller: matriculeCtrl, decoration: const InputDecoration(labelText: 'Matricule')),
                  const SizedBox(height: 12),
                  TextField(controller: cinCtrl, decoration: const InputDecoration(labelText: 'CIN')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      try {
                        if (supplier != null && index != null) {
                          await controller.editSupplier(
                            id: supplier.id,
                            name: nameCtrl.text,
                            contactEmail: emailCtrl.text,
                            phoneNumber: phoneCtrl.text,
                          );
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier updated')));
                        }
                        Navigator.of(context).pop();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          setDialogState(() => isSubmitting = false);
                        }
                      }
                    },
              child: const Text('Save'),
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
                _buildDetailRow(Icons.mail, 'Email', _safeString(supplier.email)),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.person, 'Name', _safeString(supplier.name)),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.phone, 'Phone', _safeString(supplier.phone)),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.badge, 'Matricule', _safeString(supplier.matricule)),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.credit_card, 'CIN', _safeString(supplier.cin)),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.tag, 'ID', supplier.id.toString()),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value.isNotEmpty ? value : '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SupplierController>();

    if (!_initialLoadDone && controller.suppliers.isEmpty && !controller.isLoading) {
      _initialLoadDone = true;
      Future.microtask(() {
        controller.fetchSuppliers();
      });
    }

    final suppliers = controller.suppliers;
    final filter = _searchCtrl.text.toLowerCase();

    final filtered = suppliers.where((s) {
      final name = _safeString(s.name).toLowerCase();
      final email = _safeString(s.email).toLowerCase();
      final phone = _safeString(s.phone).toLowerCase();
      final matricule = _safeString(s.matricule).toLowerCase();
      final cin = _safeString(s.cin).toLowerCase();
      final matchesSearch = name.contains(filter) || email.contains(filter) || phone.contains(filter) || matricule.contains(filter) || cin.contains(filter);
      return matchesSearch;
    }).toList();

    final totalPages = (filtered.isEmpty) ? 1 : (filtered.length / _rowsPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > filtered.length ? filtered.length : (startIndex + _rowsPerPage);
    final paginatedFiltered = filtered.sublist(startIndex, endIndex);

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
                            hintText: 'Search supplier name, email, phone, matricule, cin ...',
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
                                      setState(() {
                                        _currentPage = 1;
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {
                            _currentPage = 1;
                          }),
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
                    setState(() {
                      _currentPage = 1;
                    });
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
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: DataTable(
                                  horizontalMargin: 16,
                                  columnSpacing: 24,
                                  sortColumnIndex: _sortIndex,
                                  sortAscending: _sortAsc,
                                  columns: [
                                    DataColumn(
                                      label: const Text('ID', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(0, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(1, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(2, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Phone', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(3, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Matricule', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(4, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('CIN', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(5, asc),
                                    ),
                                    const DataColumn(label: Text('')),
                                  ],
                                  rows: paginatedFiltered.map((supplier) {
                                    final index = suppliers.indexOf(supplier);
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(supplier.id.toString())),
                                        DataCell(Text(_safeString(supplier.email))),
                                        DataCell(Text(_safeString(supplier.name))),
                                        DataCell(Text(_safeString(supplier.phone))),
                                        DataCell(Text(_safeString(supplier.matricule))),
                                        DataCell(Text(_safeString(supplier.cin))),
                                        DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, color: Colors.blue),
                                            tooltip: 'View',
                                            onPressed: () => _showViewSupplierDialog(supplier),
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
                                        ])),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left),
                                      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                                    ),
                                    Text('Page $_currentPage of $totalPages'),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right),
                                      onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}