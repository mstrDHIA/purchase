import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_application_1/controllers/supplier_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/reset_notifier.dart';

import 'package:flutter_application_1/models/supplier.dart';
import 'package:flutter_application_1/widgets/standard_header.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

// Phone number formatter helper used to format national numbers according to country dial code
class PhoneNumberFormatter extends TextInputFormatter {
  final List<int> groups;
  PhoneNumberFormatter(this.groups);

  static List<String> supportedDialCodes() => ['+216', '+1', '+33', '+44'];

  factory PhoneNumberFormatter.fromCountryCode(String dialCode) {
    switch (dialCode) {
      case '+216':
        return PhoneNumberFormatter([2, 3, 3]); // e.g. 12 345 678
      case '+1':
        return PhoneNumberFormatter([3, 3, 4]); // 123 456 7890
      case '+33':
        return PhoneNumberFormatter([1, 2, 2, 2]); // 1 23 45 67
      case '+44':
        return PhoneNumberFormatter([2, 4, 4]);
      default:
        return PhoneNumberFormatter([3, 3, 4]);
    }
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));

    final buffer = StringBuffer();
    int idx = 0;
    for (final g in groups) {
      if (idx + g >= digits.length) {
        buffer.write(digits.substring(idx));
        break;
      }
      buffer.write(digits.substring(idx, idx + g));
      buffer.write(' ');
      idx += g;
    }
    final formatted = buffer.toString().trim();
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }

  // Format a national digit string for display given a dial code
  static String formatNational(String digits, String dialCode) {
    final formatter = PhoneNumberFormatter.fromCountryCode(dialCode);
    final value = formatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: digits));
    return value.text;
  }
}

String formatPhoneForDisplay(String? fullPhone) {
  if (fullPhone == null || fullPhone.isEmpty) return '';
  for (final code in PhoneNumberFormatter.supportedDialCodes()) {
    if (fullPhone.startsWith(code)) {
      final national = fullPhone.substring(code.length).replaceAll(RegExp(r'\D'), '');
      final formatted = PhoneNumberFormatter.formatNational(national, code);
      return '$code $formatted';
    }
  }
  // fallback: group digits in blocks of 3
  final digits = fullPhone.replaceAll(RegExp(r'\D'), '');
  return PhoneNumberFormatter([3, 3, 4]).formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: digits)).text;
}

// Note: this screen now uses the shared `Supplier` model from lib/models/supplier.dart
// which contains fields like `contactEmail`, `phoneNumber`, `matricule`, `cin`, `codeFournisseur`, etc.
// }

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

  // Reset notifier
  ResetNotifier? _resetNotifier;

  @override
  void initState() {
    super.initState();
    // Register reset listener after first frame so Provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetNotifier = Provider.of<ResetNotifier>(context, listen: false);
      _resetNotifier?.addListener(_onResetTriggered);
    });
  }

  @override
  void dispose() {
    _resetNotifier?.removeListener(_onResetTriggered);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onResetTriggered() {
    final target = _resetNotifier?.lastTarget;
    if (target == 'Supplier') {
      _resetPage();
      _resetNotifier?.clear();
    }
  }

  void _resetPage() {
    setState(() {
      _searchCtrl.clear();
      _sortIndex = null;
      _sortAsc = true;
      _currentPage = 1;
    });
    // re-fetch suppliers to ensure fresh data
    try {
      final controller = context.read<SupplierController>();
      controller.fetchSuppliers();
    } catch (_) {}
  }

  String _safeString(String? value) => value ?? '';

  // Safely extract supplier code from different possible representations
  String _getSupplierCode(dynamic s) {
    if (s == null) return '';
    try {
      if (s is Supplier) return s.codeFournisseur ?? '';
      if (s is Map<String, dynamic>) return (s['code_fournisseur'] ?? s['code'] ?? s['codeFournisseur'])?.toString() ?? '';
      // Fallback to dynamic access guarded by try/catch
      final dyn = s as dynamic;
      final val = dyn.codeFournisseur;
      return val?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  void _sortByColumn(int columnIndex, bool asc) {
    final controller = context.read<SupplierController>();
    switch (columnIndex) {
      case 0:
        controller.suppliers.sort((a, b) => asc ? (a.id ?? 0).compareTo(b.id ?? 0) : (b.id ?? 0).compareTo(a.id ?? 0));
        break;
      case 1:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.contactEmail).toLowerCase().compareTo(_safeString(b.contactEmail).toLowerCase())
            : _safeString(b.contactEmail).toLowerCase().compareTo(_safeString(a.contactEmail).toLowerCase()));
        break;
      case 2:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.name).toLowerCase().compareTo(_safeString(b.name).toLowerCase())
            : _safeString(b.name).toLowerCase().compareTo(_safeString(a.name).toLowerCase()));
        break;
      case 3:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.phoneNumber?.toString()).toLowerCase().compareTo(_safeString(b.phoneNumber?.toString()).toLowerCase())
            : _safeString(b.phoneNumber?.toString()).toLowerCase().compareTo(_safeString(a.phoneNumber?.toString()).toLowerCase()));
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
      case 6:
        controller.suppliers.sort((a, b) => asc
            ? _getSupplierCode(a).toLowerCase().compareTo(_getSupplierCode(b).toLowerCase())
            : _getSupplierCode(b).toLowerCase().compareTo(_getSupplierCode(a).toLowerCase()));
        break;
      case 7:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.groupName).toLowerCase().compareTo(_safeString(b.groupName).toLowerCase())
            : _safeString(b.groupName).toLowerCase().compareTo(_safeString(a.groupName).toLowerCase()));
        break;
      case 8:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.contactName).toLowerCase().compareTo(_safeString(b.contactName).toLowerCase())
            : _safeString(b.contactName).toLowerCase().compareTo(_safeString(a.contactName).toLowerCase()));
        break;
      case 9:
        controller.suppliers.sort((a, b) => asc
            ? _safeString(a.address).toLowerCase().compareTo(_safeString(b.address).toLowerCase())
            : _safeString(b.address).toLowerCase().compareTo(_safeString(a.address).toLowerCase()));
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
        await controller.deleteSupplier(supplier.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting supplier: $e', style: const TextStyle(color: Colors.red))),
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
    final codeCtrl = TextEditingController();
    final groupNameCtrl = TextEditingController();
    final contactNameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    String _selectedCountryCode = '+216'; // default country code
    final controller = context.read<SupplierController>();
    Map<String, String?> fieldErrors = {};

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
                      decoration: InputDecoration(labelText: 'Name', errorText: fieldErrors['name']),
                      validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: InputDecoration(labelText: 'Contact Email', errorText: fieldErrors['contact_email']),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    // Phone number with country code picker
                    Row(
                      children: [
                        CountryCodePicker(
                          onChanged: (country) {
                            setDialogState(() {
                              _selectedCountryCode = country.dialCode ?? '+216';
                            });
                          },
                          initialSelection: 'TN',
                          favorite: const ['US', 'TN', 'FR'],
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          textStyle: const TextStyle(fontSize: 14),
                          dialogSize: const Size(300, 400),
                          searchDecoration: InputDecoration(
                            hintText: 'Search country',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          boxDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: phoneCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'Enter phone number (min 6 digits)',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, PhoneNumberFormatter.fromCountryCode(_selectedCountryCode)],
                            validator: (v) {
                              final digits = v == null ? '' : v.replaceAll(RegExp(r'\D'), '');
                              if (digits.isEmpty) return 'Phone is required';
                              if (digits.length < 6) return 'Phone must be at least 6 digits';
                              if (!RegExp(r'^[0-9]+$').hasMatch(digits)) return 'Phone must contain only digits';
                              return null;
                            },
                            enabled: !isSubmitting,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: matriculeCtrl,
                      decoration: const InputDecoration(labelText: 'Matricule'),
                      validator: (v) {
                        if ((v == null || v.isEmpty) && (cinCtrl.text.isEmpty)) {
                          return 'Either Matricule or CIN is required';
                        }
                        return null;
                      },
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: cinCtrl,
                      decoration: const InputDecoration(labelText: 'CIN'),
                      validator: (v) {
                        if ((v == null || v.isEmpty) && (matriculeCtrl.text.isEmpty)) {
                          return 'Either Matricule or CIN is required';
                        }
                        return null;
                      },
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressCtrl,
                      decoration: InputDecoration(labelText: 'Address', errorText: fieldErrors['address']),
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: codeCtrl,
                      decoration: InputDecoration(labelText: 'Code fournisseur', errorText: fieldErrors['code_fournisseur']),
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: groupNameCtrl,
                      decoration: const InputDecoration(labelText: 'Group Name'),
                      enabled: !isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: contactNameCtrl,
                      decoration: const InputDecoration(labelText: 'Contact Name'),
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
                        // Prevent adding a supplier with an existing name (case-insensitive)
                        final newName = nameCtrl.text.trim();
                        if (controller.suppliers.any((s) => (s.name ?? '').toLowerCase() == newName.toLowerCase())) {
                          setDialogState(() {
                            fieldErrors = {...fieldErrors, 'name': 'Supplier already exists'};
                          });
                          return;
                        }

                        setDialogState(() {
                          isSubmitting = true;
                          fieldErrors = {};
                        });
                        try {
                          final fullPhoneNumber = _selectedCountryCode + phoneCtrl.text;
                          await controller.createSupplier(
                            name: nameCtrl.text,
                            contactEmail: emailCtrl.text,
                            phoneNumber: fullPhoneNumber,
                            address: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
                            codeFournisseur: codeCtrl.text.isNotEmpty ? codeCtrl.text : null,
                            groupName: groupNameCtrl.text.isNotEmpty ? groupNameCtrl.text : null,
                            contactName: contactNameCtrl.text.isNotEmpty ? contactNameCtrl.text : null,
                            matricule: matriculeCtrl.text.isNotEmpty ? matriculeCtrl.text : null,
                            cin: cinCtrl.text.isNotEmpty ? cinCtrl.text : null,
                            approvalStatus: 'pending',
                          );

                          if (mounted) {
                            setDialogState(() { isSubmitting = false; });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Supplier created successfully!')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            // Parse server validation errors if present
                            final msg = e.toString();
                            const prefix = 'Server validation error:';
                            if (msg.contains(prefix)) {
                              final body = msg.split(prefix).last.trim();
                              final parts = body.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty);
                              final Map<String, String?> newErrors = {};
                              for (final part in parts) {
                                final idx = part.indexOf(':');
                                if (idx > 0) {
                                  final key = part.substring(0, idx).trim();
                                  final val = part.substring(idx + 1).trim();
                                  newErrors[key] = val;
                                }
                              }
                              setDialogState(() {
                                fieldErrors = newErrors;
                                isSubmitting = false;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                              setDialogState(() => isSubmitting = false);
                            }
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
    final emailCtrl = TextEditingController(text: supplier?.contactEmail ?? '');
    // Determine country code from existing phone before creating controller
    String _initialPhone = supplier?.phoneNumber?.toString() ?? '';
    String _selectedCountryCode = '+216'; // default
    for (final c in PhoneNumberFormatter.supportedDialCodes()) {
      if (_initialPhone.startsWith(c)) {
        _selectedCountryCode = c;
        break;
      }
    }
    final national = _initialPhone.replaceFirst(_selectedCountryCode, '').replaceAll(RegExp(r'\D'), '');
    final phoneCtrl = TextEditingController(text: PhoneNumberFormatter.formatNational(national, _selectedCountryCode));
    final matriculeCtrl = TextEditingController(text: supplier?.matricule ?? '');
    final cinCtrl = TextEditingController(text: supplier?.cin ?? '');

    final groupNameCtrl = TextEditingController(text: supplier?.groupName ?? '');
    final contactNameCtrl = TextEditingController(text: supplier?.contactName ?? '');
    final addressCtrl = TextEditingController(text: supplier?.address ?? '');
    bool isSubmitting = false;

    final controller = context.read<SupplierController>();
    // Try to retrieve the detailed model for additional fields like codeFournisseur
    final matches = controller.suppliers.where((s) => (s as dynamic).id == supplier?.id).toList();
    final modelMatch = matches.isNotEmpty ? matches.first : null;
    final codeInitial = _getSupplierCode(modelMatch);
    final codeCtrl = TextEditingController(text: codeInitial);

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
                  Row(
                    children: [
                      CountryCodePicker(
                        onChanged: (country) {
                          setDialogState(() {
                            _selectedCountryCode = country.dialCode ?? '+216';
                          });
                        },
                        initialSelection: 'TN',
                        favorite: const ['US', 'TN', 'FR'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        textStyle: const TextStyle(fontSize: 14),
                        dialogSize: const Size(300, 400),
                        searchDecoration: InputDecoration(
                          hintText: 'Search country',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        boxDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Min 6 digits',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, PhoneNumberFormatter.fromCountryCode(_selectedCountryCode)],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address')),
                  const SizedBox(height: 12),
                  TextField(controller: matriculeCtrl, decoration: const InputDecoration(labelText: 'Matricule')),
                  const SizedBox(height: 12),
                  TextField(controller: cinCtrl, decoration: const InputDecoration(labelText: 'CIN')),
                  const SizedBox(height: 12),
                  TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code fournisseur')),
                  const SizedBox(height: 12),
                  TextField(controller: groupNameCtrl, decoration: const InputDecoration(labelText: 'Group Name')),
                  const SizedBox(height: 12),
                  TextField(controller: contactNameCtrl, decoration: const InputDecoration(labelText: 'Contact Name')),
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
                      if (matriculeCtrl.text.isEmpty && cinCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Either Matricule or CIN is required')),
                        );
                        return;
                      }

                      // Prevent renaming to an existing supplier name (case-insensitive), excluding current supplier
                      final newName = nameCtrl.text.trim();
                      if (supplier != null && controller.suppliers.any((s) => s.id != supplier.id && (s.name ?? '').toLowerCase() == newName.toLowerCase())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Supplier with this name already exists')),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);
                      try {
                        if (supplier != null && index != null) {
                          final fullPhoneNumber = _selectedCountryCode + phoneCtrl.text;
                          await controller.editSupplier(
                            id: supplier.id!,
                            name: nameCtrl.text,
                            contactEmail: emailCtrl.text,
                            phoneNumber: fullPhoneNumber,
                                address: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
                                codeFournisseur: codeCtrl.text.isNotEmpty ? codeCtrl.text : null,
                                groupName: groupNameCtrl.text.isNotEmpty ? groupNameCtrl.text : null,
                                contactName: contactNameCtrl.text.isNotEmpty ? contactNameCtrl.text : null,
                                matricule: matriculeCtrl.text.isNotEmpty ? matriculeCtrl.text : null,
                                cin: cinCtrl.text.isNotEmpty ? cinCtrl.text : null,
                                approvalStatus: 'pending',
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
    final userController = context.read<UserController>();
    final isAccountant = userController.currentUser.role_id == 6;
    bool isSubmitting = false;
    
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Supplier Details'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.mail, 'Email', _safeString(supplier.contactEmail)),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.person, 'Name', _safeString(supplier.name)),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.phone, 'Phone', formatPhoneForDisplay(supplier.phoneNumber?.toString())),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),                _buildDetailRow(Icons.location_on, 'Address', _safeString(supplier.address)),
                  const SizedBox(height: 16),                _buildDetailRow(Icons.badge, 'Matricule', _safeString(supplier.matricule)),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.credit_card, 'CIN', _safeString(supplier.cin)),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.groups, 'Group Name', _safeString(supplier.groupName)),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.person_outline, 'Contact Name', _safeString(supplier.contactName)),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.check_circle, 'Approval Status', (_safeString(supplier.approvalStatus).isNotEmpty ? _safeString(supplier.approvalStatus).toUpperCase() : 'N/A')),
                  const SizedBox(height: 16),
                  // Try to find the full model to show additional fields like Code Fournisseur
                  Builder(
                    builder: (context) {
                      final matches = context.read<SupplierController>().suppliers.where((s) => (s as dynamic).id == supplier.id).toList();
                      final model = matches.isNotEmpty ? matches.first : null;
                      final code = _getSupplierCode(model);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (code.isNotEmpty) ...[
                            _buildDetailRow(Icons.tag, 'Code fournisseur', code),
                            const SizedBox(height: 16),
                          ],
                          _buildDetailRow(Icons.tag, 'ID', supplier.id.toString()),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (isAccountant)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Back', style: TextStyle(color: Colors.white)),
                  ),
                  if (supplier.approvalStatus == 'pending')
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: isSubmitting ? null : () async {
                            setDialogState(() => isSubmitting = true);
                            try {
                              await _updateSupplierStatus(supplier, 'rejected');
                              if (mounted) Navigator.of(context).pop();
                            } finally {
                              if (mounted) setDialogState(() => isSubmitting = false);
                            }
                          },
                          child: isSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                              : const Text('Reject', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: isSubmitting ? null : () async {
                            setDialogState(() => isSubmitting = true);
                            try {
                              await _updateSupplierStatus(supplier, 'approved');
                              if (mounted) Navigator.of(context).pop();
                            } finally {
                              if (mounted) setDialogState(() => isSubmitting = false);
                            }
                          },
                          child: isSubmitting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                              : const Text('Approve', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSupplierStatus(Supplier supplier, String newStatus) async {
    final controller = context.read<SupplierController>();
    try {
      await controller.editSupplier(
        id: supplier.id!,
        name: supplier.name ?? '',
        contactEmail: supplier.contactEmail ?? '',
        phoneNumber: supplier.phoneNumber?.toString(),
        address: supplier.address,
        codeFournisseur: supplier.codeFournisseur,
        groupName: supplier.groupName,
        contactName: supplier.contactName,
        matricule: supplier.matricule,
        cin: supplier.cin,
        approvalStatus: newStatus,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Supplier status updated to ${newStatus.toUpperCase()}')),
        );
        // Refresh suppliers list to update the UI
        await controller.fetchSuppliers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating supplier: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
      final email = _safeString(s.contactEmail).toLowerCase();
      final phone = _safeString(s.phoneNumber?.toString()).toLowerCase();
      final matricule = _safeString(s.matricule).toLowerCase();
      final cin = _safeString(s.cin).toLowerCase();
      final groupName = _safeString(s.groupName).toLowerCase();
      final contactName = _safeString(s.contactName).toLowerCase();
      final matchesSearch = name.contains(filter) || email.contains(filter) || phone.contains(filter) || matricule.contains(filter) || cin.contains(filter) || groupName.contains(filter) || contactName.contains(filter);
      return matchesSearch;
    }).toList();

    final totalPages = (filtered.isEmpty) ? 1 : (filtered.length / _rowsPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > filtered.length ? filtered.length : (startIndex + _rowsPerPage);
    final paginatedFiltered = filtered.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: StandardHeader(title: AppLocalizations.of(context)!.supplier + ' Registration'),
      body: Column(
        children: [
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
                                      label: const Text('Matricule fiscale', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(4, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('CIN', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(5, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Code fournisseur', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(6, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Group Name', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(7, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Contact Name', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(8, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Address', style: TextStyle(fontWeight: FontWeight.w600)),
                                      onSort: (i, asc) => _sortByColumn(9, asc),
                                    ),
                                    DataColumn(
                                      label: const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                    const DataColumn(label: Text('')),
                                  ],

                                  rows: paginatedFiltered.map((supplier) {
                                    final index = suppliers.indexOf(supplier);
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(supplier.id.toString())),
                                        DataCell(Text(_safeString(supplier.contactEmail))),
                                        DataCell(Text(_safeString(supplier.name))),
                                        DataCell(Text(formatPhoneForDisplay(supplier.phoneNumber?.toString()))),
                                        DataCell(Text(_safeString(supplier.matricule))),
                                        DataCell(Text(_safeString(supplier.cin))),
                                        DataCell(Text(_getSupplierCode(supplier))),
                                        DataCell(Text(_safeString(supplier.groupName))),
                                        DataCell(Text(_safeString(supplier.contactName))),
                                        DataCell(Text(_safeString(supplier.address))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: supplier.approvalStatus == 'approved' ? Colors.green[50] :
                                                     supplier.approvalStatus == 'rejected' ? Colors.red[50] :
                                                     Colors.orange[50],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _safeString(supplier.approvalStatus).toLowerCase(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: supplier.approvalStatus == 'approved' ? Colors.green[700] :
                                                       supplier.approvalStatus == 'rejected' ? Colors.red[700] :
                                                       Colors.orange[700],
                                              ),
                                            ),
                                          ),
                                        ),
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