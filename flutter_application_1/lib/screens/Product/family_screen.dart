import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'subfamily_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../network/product_network.dart';
import '../../controllers/product_controller.dart';
import '../../models/category.dart';

class FamiliesPage extends StatefulWidget {
  const FamiliesPage({Key? key}) : super(key: key);

  @override
  State<FamiliesPage> createState() => _FamiliesPageState();
}

class _FamiliesPageState extends State<FamiliesPage> {
  List<Map<String, dynamic>> families = [];
  late ProductController productController;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    // Set your API base URL here
    final network = ProductNetwork();
    productController = Provider.of<ProductController>(context, listen: false);
    // fetchFamilies();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchFamilies();
  }

  Future<void> fetchFamilies() async {
    setState(() {
      _loading = true;
    });
    try {
      print('aaaa');
      final data = await productController.getCategoriesWithoutQuery();
      print(data);
      print('bbbb');
      // data is expected to be a List of categories; build families and compute subfamilies by scanning children
      final all = (data as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
      families = all
          .where((f) => f['parent_category'] == null)
          .map<Map<String, dynamic>>((f) {
        final subs = all.where((c) => c['parent_category'] == f['id']).map((c) => c as Map<String, dynamic>).toList();
        return {
          'id': f['id'],
          'name': f['name'],
          'description': f['description'] ?? '',
          'creationDate': f['created_at'] != null ? DateTime.tryParse(f['created_at']) : null,
          'subfamilies': subs,
        };
      }).toList();
      print('dddd');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load families: $e')),
      );
      print('Error fetching families: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  final TextEditingController _searchCtrl = TextEditingController();
  int? _sortIndex;
  bool _sortAsc = true;
  int? _minSubfamilies;
  int? _maxSubfamilies;
  // Pagination
  int _currentPage = 1;
  final int _rowsPerPage = 10;


  void _sortByName(bool asc) {
    families.sort((a, b) => asc
        ? a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase())
        : b['name'].toString().toLowerCase().compareTo(a['name'].toString().toLowerCase()));
    setState(() {
      // 'Family' is the second column in the DataTable (index 1)
      _sortIndex = 1;
      _sortAsc = asc;
    });
  }

  void _sortById(bool asc) {
    families.sort((a, b) {
      final aId = a['id']?.toString() ?? '';
      final bId = b['id']?.toString() ?? '';
      final aNum = int.tryParse(aId);
      final bNum = int.tryParse(bId);
      int cmp;
      if (aNum != null && bNum != null) {
        cmp = aNum.compareTo(bNum);
      } else {
        cmp = aId.compareTo(bId);
      }
      return asc ? cmp : -cmp;
    });
    setState(() {
      // ID is the first column (index 0)
      _sortIndex = 0;
      _sortAsc = asc;
    });
  }

  Future<void> _showEditDialog({Map<String, dynamic>? family, int? index}) async {
    final _formKey = GlobalKey<FormState>();
    print('Opening edit dialog for family: ${family != null ? family['name'] : 'New Family'}');
    final nameCtrl = TextEditingController(text: family != null ? family['name'] : '');
    final descCtrl = TextEditingController(text: family != null ? family['description'] : '');
    DateTime? selectedDate;
    if (family != null && family['creationDate'] is DateTime) {
      selectedDate = family['creationDate'] as DateTime;
    } else if (family != null && family['creationDate'] is String) {
      selectedDate = DateTime.tryParse(family['creationDate']);
    }

    await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        var _isSaving = false;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          // square / sharp corners
          shape: const RoundedRectangleBorder(),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(family == null ? 'Add Family' : 'Edit Family', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        autofocus: true,
                        decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.edit_note)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(selectedDate != null ? selectedDate!.toIso8601String().substring(0, 10) : 'No creation date'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? now,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(now.year + 5),
                              );
                              if (picked != null) setState(() => selectedDate = picked);
                            },
                            child: const Text('Pick date'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (!(_formKey.currentState?.validate() ?? false)) return;
                              setState(() => _isSaving = true);
                              final updatedFamily = Category(
                                id: family != null ? family['id'].toString() : '',
                                name: nameCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                                creationDate: selectedDate ?? DateTime.now(),
                              );
                              try {
                                if (family != null && index != null) {
                                  await productController.editCategory(updatedFamily);
                                  setState(() {
                                    families[index] = {
                                      'id': updatedFamily.id,
                                      'name': updatedFamily.name,
                                      'description': updatedFamily.description,
                                      'creationDate': updatedFamily.creationDate,
                                      'subfamilies': family['subfamilies'],
                                    };
                                  });
                                } else {
                                  await productController.createCategories(updatedFamily);
                                  await fetchFamilies();
                                }
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                                    content: Text(family != null ? 'Family updated successfully!' : 'Family created successfully!')));
                              } catch (e) {
                                ScaffoldMessenger.of(this.context)
                                    .showSnackBar(SnackBar(content: Text('Failed to ${family != null ? 'update' : 'create'} family: $e')));
                              } finally {
                                try {
                                  setState(() => _isSaving = false);
                                } catch (_) {}
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: _isSaving
                          ? Row(mainAxisSize: MainAxisSize.min, children: const [
                              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                              SizedBox(width: 10),
                              Text('Saving...'),
                            ])
                          : Text(family != null ? 'Save' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _confirmDelete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family'),
        content: Text('Delete "${families[index]['name']}" and all its subfamilies?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
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
        print('Deleting family with ID: ${families[index]['id']}');
        // await productController.deleteCategory(families[index]['id'].toString());
        setState(() => families.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Family deleted successfully')));
      } catch (e) {
        print('Error occurred while deleting family: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete family: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = _searchCtrl.text.toLowerCase();
    final filtered = families.where((f) {
      final name = f['name']?.toString().toLowerCase() ?? '';
      if (!name.contains(filter)) return false;
      final count = (f['subfamilies'] is List) ? (f['subfamilies'] as List).length : 0;
      if (_minSubfamilies != null && count < _minSubfamilies!) return false;
      if (_maxSubfamilies != null && count > _maxSubfamilies!) return false;
      return true;
    }).toList();

    // Pagination calculation
    final totalPages = (filtered.isEmpty) ? 1 : (filtered.length / _rowsPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage) > filtered.length ? filtered.length : (startIndex + _rowsPerPage);
    final displayed = filtered.sublist(startIndex, endIndex);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                // ...existing code...
                const Expanded(
                  child: Center(
                    child: Text('Product Families', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 48),
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
                            hintText: AppLocalizations.of(context)!.search,
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
                    _minSubfamilies = null;
                    _maxSubfamilies = null;
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                  child: const Row(children: [Icon(Icons.refresh), SizedBox(width: 6), Text('Reset')]),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Family'),
                  onPressed: () => _showEditDialog(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF7F4FA),
              padding: const EdgeInsets.all(24),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: DataTable(
                        sortColumnIndex: _sortIndex,
                        sortAscending: _sortAsc,
                        columns: [
                          DataColumn(
                            label: const Text('ID'),
                            onSort: (i, asc) => _sortById(asc),
                          ),
                          DataColumn(
                            label: const Text('Family'),
                            onSort: (i, asc) => _sortByName(asc),
                          ),
                          const DataColumn(label: Text('Description')),
                          const DataColumn(label: Text('Created')),
                          const DataColumn(label: Text('Subfamilies')),
                          const DataColumn(label: Text('')),
                        ],
                        rows: displayed.asMap().entries.map((entry) {
                          final fam = entry.value;
                          // if(fam['parent_category']!=null)
                          return DataRow(cells: [
                            DataCell(Text(fam['id']?.toString() ?? '')),
                            DataCell(Text(fam['name'] ?? '')),
                            DataCell(Text(fam['description'] ?? '')),
                            DataCell(Text(fam['creationDate'] is DateTime
                                ? (fam['creationDate'] as DateTime).toIso8601String().substring(0, 10)
                                : fam['creationDate']?.toString() ?? '')),
                            DataCell(Text((fam['subfamilies'] is List)
                                ? (fam['subfamilies'] as List).length.toString()
                                : '0')),
                            DataCell(Row(children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                tooltip: 'View Subfamilies',
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SubfamiliesPage(family: fam, onUpdate: (updated) {
                                  setState(() {});
                                })) ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.teal),
                                tooltip: 'Edit Family',
                                onPressed: () => _showEditDialog(family: fam, index: families.indexOf(fam)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete Family',
                                onPressed: () => _confirmDelete(families.indexOf(fam)),
                              ),
                            ]))
                          ]);
                        }).toList(),                          )),
                          // Pagination controls
                          if (filtered.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: _currentPage > 1
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),
                                  Text('Page $_currentPage of $totalPages'),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: _currentPage < totalPages
                                        ? () => setState(() => _currentPage++)
                                        : null,
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
