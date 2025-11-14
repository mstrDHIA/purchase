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
      families = data
          .where((f) => f['parent_category'] == null)
          .map<Map<String, dynamic>>((f) {
        print('cccc');
        print(f['parent_category']);
        return {
          'id': f['id'],
          'name': f['name'],
          'description': f['description'] ?? '',
          'creationDate': f['created_at'] != null ? DateTime.tryParse(f['created_at']) : null,
          'subfamilies': f['subfamilies'] ?? [],
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


  void _sortByName(bool asc) {
    families.sort((a, b) => asc
        ? a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase())
        : b['name'].toString().toLowerCase().compareTo(a['name'].toString().toLowerCase()));
    setState(() {
      _sortIndex = 0;
      _sortAsc = asc;
    });
  }

  Future<void> _showEditDialog({Map<String, dynamic>? family, int? index}) async {
    print('Opening edit dialog for family: ${family != null ? family['name'] : 'New Family'}');
    final nameCtrl = TextEditingController(text: family != null ? family['name'] : '');
    final descCtrl = TextEditingController(text: family != null ? family['description'] : '');
    final dateCtrl = TextEditingController(
      text: family != null && family['creationDate'] != null
          ? (family['creationDate'] as DateTime).toIso8601String().substring(0, 10)
          : DateTime.now().toIso8601String().substring(0, 10),
    );

    await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(family == null ? 'Add Family' : 'Edit Family'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 8),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Creation Date (YYYY-MM-DD)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () async {
                print('Save button clicked');
                final updatedFamily = Category(
                  id: family != null ? family['id'].toString() : '', // Convertir l'ID en chaîne de caractères
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  creationDate: DateTime.tryParse(dateCtrl.text) ?? DateTime.now(),
                );

                try {
                  if (family != null && index != null) {
                    print('Editing family with ID: ${updatedFamily.id}');
                    // await productController.editCategory(updatedFamily);
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
                    print('Creating new family');
                    // await productController.createCategories(updatedFamily);
                    setState(() {
                      families.add({
                        'id': updatedFamily.id,
                        'name': updatedFamily.name,
                        'description': updatedFamily.description,
                        'creationDate': updatedFamily.creationDate,
                        'subfamilies': [],
                      });
                    });
                  }
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(family != null ? 'Family updated successfully!' : 'Family created successfully!')),
                  );
                } catch (e) {
                  print('Error occurred: $e');
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to ${family != null ? 'update' : 'create'} family: $e')),
                  );
                }
              },
              child: const Text('Save')),
        ],
      ),
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
                      child: DataTable(
                        sortColumnIndex: _sortIndex,
                        sortAscending: _sortAsc,
                        columns: [
                          DataColumn(label: const Text('ID')),
                          DataColumn(
                            label: const Text('Family'),
                            onSort: (i, asc) => _sortByName(asc),
                          ),
                          const DataColumn(label: Text('Description')),
                          const DataColumn(label: Text('Created')),
                          const DataColumn(label: Text('Subfamilies')),
                          const DataColumn(label: Text('')),
                        ],
                        rows: filtered.asMap().entries.map((entry) {
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
