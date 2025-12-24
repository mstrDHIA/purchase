// ignore_for_file: dead_code, unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/product_controller.dart';
import 'package:flutter_application_1/models/category.dart';
import 'package:provider/provider.dart';

class SubfamiliesPage extends StatefulWidget {
  final Map<String, dynamic> family;
  final void Function(Map<String, dynamic>)? onUpdate;

  const SubfamiliesPage({Key? key, required this.family, this.onUpdate}) : super(key: key);

  @override
  State<SubfamiliesPage> createState() => _SubfamiliesPageState();
}

class _SubfamiliesPageState extends State<SubfamiliesPage> {
  List<Map<String, dynamic>> get subfamilies {
    final raw = widget.family['subfamilies'] as List<dynamic>? ?? [];
    return raw.map<Map<String, dynamic>>((e) {
      if (e is Map<String, dynamic>) return e;
      // handle cases where maps are JS maps or plain Map<dynamic, dynamic>
      return Map<String, dynamic>.from(e as Map);
    }).toList();
  }
  late ProductController productController;
  late Future _subfamiliesFuture;
  int _currentPage = 1;
  final int _rowsPerPage = 10;

  @override
  void initState() {
    productController = Provider.of<ProductController>(context, listen: false);
    _subfamiliesFuture = productController.getCategories(widget.family['id']);
    super.initState();
  }

  Future<void> _addOrEdit({Map<String, dynamic>? sub, int? index}) async {
    final nameCtrl = TextEditingController(text: sub != null ? sub['name'] : '');
    final descCtrl = TextEditingController(text: sub != null ? sub['description'] : '');


    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        var _isSaving = false;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEF6),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 6))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub == null ? 'Add Subfamily' : 'Edit Subfamily', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF2B2B2B))),
                  const SizedBox(height: 12),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.label))),
                  const SizedBox(height: 8),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          elevation: 2,
                        ),
                        onPressed: _isSaving
                            ? null
                            : () async {
                                setState(() => _isSaving = true);
                                try {
                                  Category updatedFamily = Category(
                                    parentCategory: widget.family['id'],
                                    name: nameCtrl.text,
                                    description: descCtrl.text,
                                    creationDate: DateTime.now(),
                                  );
                                  // add a timeout to avoid indefinite UI blocking
                                  await productController.createCategories(updatedFamily).timeout(const Duration(seconds: 15));
                                  // Return the created subfamily data so the caller can update the UI immediately
                                  if (mounted) Navigator.of(context).pop({
                                    'name': nameCtrl.text,
                                    'description': descCtrl.text,
                                    'parent_category': widget.family['id'],
                                  });
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subfamily created successfully!')));
                                } catch (e) {
                                  setState(() => _isSaving = false);
                                  if (e is Exception) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create subfamily: $e')));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create subfamily')));
                                  }
                                }
                              },
                        child: _isSaving
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );

    if (res != null) {
      setState(() {
        final list = widget.family['subfamilies'] as List;
        if (sub != null && index != null) {
          list[index] = {
            'name': res['name'],
            'description': res['description'],
            'parent_category': res['parent_category'], // Correct key for parent category
          };
        } else {
          list.add({
            'name': res['name'],
            'description': res['description'],
            'parent_category': res['parent_category'], // Correct key for parent category
          });
        }
        // Refresh the future so the FutureBuilder reloads data from the backend
        _subfamiliesFuture = productController.getCategories(widget.family['id']);
      });
      widget.onUpdate?.call(widget.family);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> subfamily) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subfamily'),
        content: Text('Delete "${subfamily['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      try {
        final subfamilyId = subfamily['id']?.toString();
        if (subfamilyId != null) {
          await productController.deleteCategory(subfamilyId);
          // Refresh the list after deletion
          setState(() {
            _subfamiliesFuture = productController.getCategories(widget.family['id']);
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subfamily deleted successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Subfamily ID not found')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete subfamily: $e')));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text('Subfamilies — ${widget.family['name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                const Spacer(),
                ElevatedButton.icon(onPressed: () => _addOrEdit(), icon: const Icon(Icons.add), label: const Text('Add Subfamily')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF7F4FA),
              padding: const EdgeInsets.all(24),
              child: FutureBuilder(
                future: _subfamiliesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData  ) {
                    return const Center(
                      child: Text('No subfamilies available'),
                    );
                  }
                    
                  final raw = snapshot.data! as List<dynamic>;
                  final list = raw.map<Map<String, dynamic>>((e) {
                    if (e is Map<String, dynamic>) return e;
                    return Map<String, dynamic>.from(e as Map);
                  }).toList();
                  // debug
                  // ignore: avoid_print
                  print('Subfamilies data: $list');

                  // Pagination calculations
                  final totalPagesCalc = (list.length / _rowsPerPage).ceil();
                  final totalPages = totalPagesCalc == 0 ? 1 : totalPagesCalc;
                  if (_currentPage > totalPages) {
                    _currentPage = totalPages;
                  }
                  final startIndex = (_currentPage - 1) * _rowsPerPage;
                  final displayed = list.skip(startIndex).take(_rowsPerPage).toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: double.infinity, child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Subfamily')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('')),
                          ],
                          rows: displayed.asMap().entries.map((entry) {
                            final localIndex = entry.key;
                            final s = entry.value;
                            final originalIndex = startIndex + localIndex;
                            return DataRow(cells: [
                              DataCell(Text(s['name'] ?? '')),
                              DataCell(Text(s['description'] ?? '')),
                              DataCell(Row(children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.blue),
                                  onPressed: () => showDialog<void>(
                                    context: context,
                                    builder: (context) => Dialog(
                                      insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 24),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 520),
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF6EEF6),
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 6))],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(s['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF2B2B2B))),
                                              const SizedBox(height: 16),
                                              Row(children: [
                                                const Icon(Icons.label, color: Colors.deepPurple),
                                                const SizedBox(width: 12),
                                                Expanded(child: Text(s['description'] ?? '-', style: const TextStyle(fontSize: 14))),
                                              ]),
                                              const SizedBox(height: 12),
                                              Row(children: [
                                                const Icon(Icons.confirmation_number, color: Colors.deepPurple),
                                                const SizedBox(width: 12),
                                                Text('ID: ${s['id']?.toString() ?? '-'}', style: const TextStyle(fontSize: 14)),
                                              ]),
                                              const SizedBox(height: 18),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF7C3AED),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                    elevation: 2,
                                                  ),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('Back', style: TextStyle(color: Colors.white)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(icon: const Icon(Icons.edit, color: Colors.teal), onPressed: () => _addOrEdit(sub: s, index: originalIndex)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(s)),
                              ]))
                            ]);
                          }).toList(),
                        )),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Page $_currentPage of $totalPages'),
                            const SizedBox(width: 12),
                            IconButton(
                              tooltip: 'Previous',
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _currentPage > 1
                                  ? () => setState(() {
                                        _currentPage -= 1;
                                      })
                                  : null,
                            ),
                            IconButton(
                              tooltip: 'Next',
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _currentPage < totalPages
                                  ? () => setState(() {
                                        _currentPage += 1;
                                      })
                                  : null,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
