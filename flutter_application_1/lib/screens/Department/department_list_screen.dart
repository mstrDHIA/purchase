import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/department_controller.dart';
// import 'add_department_screen.dart';

/// Department item model used by the screen.
class DepartmentItem {
  final int? id;
  final String name;
  final String? description;

  DepartmentItem({this.id, required this.name, this.description});
}

/// A simple, reusable department selection screen.
///
/// Usage:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => DepartmentListScreen(
///     departments: myList,
///     initialId: currentDeptId,
///     onSelect: (dept) { /* save selection */ },
///   ),
/// ));
class DepartmentListScreen extends StatefulWidget {
  final List<DepartmentItem>? departments;
  final int? initialId;
  final void Function(DepartmentItem) onSelect;
  final String title;

  const DepartmentListScreen({
    super.key,
    this.departments,
    this.initialId,
    required this.onSelect,
    this.title = 'Select Department',
  });

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen>
    with SingleTickerProviderStateMixin {
  late List<DepartmentItem> _all;
  late List<DepartmentItem> _filtered;
  String _query = '';
  int? _selectedId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _all = widget.departments ?? _mockDepartments();
    _filtered = List.from(_all);
    _selectedId = widget.initialId;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    // Fetch from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<DepartmentController>();
      ctrl.fetchDepartments().then((_) {
        setState(() {
          if (widget.departments == null && ctrl.departments.isNotEmpty) {
            _all = ctrl.departments
                .map((d) => DepartmentItem(id: d.id, name: d.name, description: d.description))
                .toList();
            _filtered = List.from(_all.where((e) => e.name.toLowerCase().contains(_query.toLowerCase())).toList());
          }
        });
      }).catchError((_) {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- CRUD helpers ---
  Future<void> _showViewDialog(DepartmentItem d) async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Department', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    IconButton(
                      tooltip: 'Copy name',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: d.name));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name copied')));
                      },
                      icon: const Icon(Icons.copy, size: 20),
                    ),
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showEditDialog(d);
                      },
                      icon: const Icon(Icons.edit, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const SizedBox(height: 8),
                // Description section (always visible, shows placeholder if none)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: d.description != null && d.description!.isNotEmpty
                                ? SelectableText(d.description!)
                                : Text('(No description)', style: TextStyle(color: Colors.grey.shade600)),
                          ),
                          if (d.description != null && d.description!.isNotEmpty)
                            IconButton(
                              tooltip: 'Copy description',
                              onPressed: () {
                                final text = d.description ?? '';
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Description copied')));
                              },
                              icon: const Icon(Icons.copy, size: 18),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(DepartmentItem d) async {
    final nameController = TextEditingController(text: d.name);
    final descriptionController = TextEditingController(text: d.description ?? '');
    final isNew = d.id == null;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        bool isSaving = false;

        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(isNew ? 'Add Department' : 'Edit Department', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                          if (isSaving) const SizedBox(width: 8),
                          if (isSaving) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        maxLength: 100,
                        decoration: const InputDecoration(labelText: 'Department name', prefixIcon: Icon(Icons.business)),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Description (optional)', prefixIcon: Icon(Icons.description)),
                        maxLines: 3,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) return;
                                    setState(() => isSaving = true);
                                    final newName = nameController.text.trim();
                                    final newDescription = descriptionController.text.trim();
                                    final deptCtrl = context.read<DepartmentController>();
                                    try {
                                      if (isNew) {
                                        final created = await deptCtrl.createDepartment(name: newName, description: newDescription);
                                        setState(() {
                                          _all.insert(0, DepartmentItem(id: created.id, name: created.name, description: created.description));
                                          _filtered = _all.where((e) => e.name.toLowerCase().contains(_query.toLowerCase())).toList();
                                        });
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Department added')));
                                      } else {
                                        final updated = await deptCtrl.updateDepartment(id: d.id!, name: newName, description: newDescription);
                                        setState(() {
                                          final idx = _all.indexWhere((e) => e.id == d.id);
                                          if (idx != -1) _all[idx] = DepartmentItem(id: updated.id, name: updated.name, description: updated.description);
                                          _filtered = _all.where((e) => e.name.toLowerCase().contains(_query.toLowerCase())).toList();
                                        });
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Department updated')));
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                    } finally {
                                      if (mounted) setState(() => isSaving = false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
                            child: isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isNew ? 'Add' : 'Save'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _confirmDelete(DepartmentItem d) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text('Are you sure you want to delete "${d.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      final deptCtrl = context.read<DepartmentController>();
      deptCtrl.deleteDepartment(d.id!).then((_) {
        setState(() {
          _all.removeWhere((e) => e.id == d.id);
          _filtered.removeWhere((e) => e.id == d.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${d.name}"')));
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      });
    }
  }

  List<DepartmentItem> _mockDepartments() {
    // Fallback sample departments in case caller doesn't provide list
    return [
      DepartmentItem(id: 1, name: 'Purchasing'),
      DepartmentItem(id: 2, name: 'Accounting'),
      DepartmentItem(id: 3, name: 'Logistics'),
      DepartmentItem(id: 4, name: 'IT'),
      DepartmentItem(id: 5, name: 'HR'),
    ];
  }

  void _onSearchChanged(String q) {
    setState(() {
      _query = q;
      _filtered = _all
          .where((d) => d.name.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
    HapticFeedback.lightImpact();
  }

  Widget _buildListTile(DepartmentItem d, int index) {
    final selected = d.id != null && d.id == _selectedId;
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: selected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? Colors.deepPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: selected
                ? LinearGradient(
                    colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : Colors.white,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: selected
                      ? [Colors.deepPurple.shade400, Colors.deepPurple.shade700]
                      : [Colors.grey.shade300, Colors.grey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  d.name.isNotEmpty ? d.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            title: Text(
              d.name,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 16,
                color: selected ? Colors.deepPurple.shade700 : Colors.black87,
              ),
            ),
            subtitle: d.description != null && d.description!.isNotEmpty
                ? Text(
                    d.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  )
                : null,
            trailing: selected
                ? Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepPurple,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                : null,
            onTap: () {
              // open view dialog on tap
              HapticFeedback.mediumImpact();
              _showViewDialog(d);
            },
          ),
        ),
      ),
    );
  }

  // Future<void> _openAddDepartmentDialog() async {
  //   final result = await showDialog<Map<String, dynamic>>(
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: ConstrainedBox(
  //         constraints: const BoxConstraints(maxWidth: 700, maxHeight: 640),
  //         child: AddDepartmentPage(
  //           departments: _all,
  //           onCreated: (newDept) {
  //             // onCreated inside AddDepartmentPage will be called, but we still
  //             // return the result from Navigator.pop so we handle it below.
  //           },
  //         ),
  //       ),
  //     ),
  //   );

  //   if (result != null) {
  //     setState(() {
  //       final nextId = (_all.map((e) => e.id ?? 0).fold<int>(0, (p, c) => c > p ? c : p)) + 1;
  //       final created = DepartmentItem(id: nextId, name: result['name']?.toString() ?? '');
  //       _all.insert(0, created);
  //       _filtered = _all.where((e) => e.name.toLowerCase().contains(_query.toLowerCase())).toList();
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Department added')));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => _showEditDialog(DepartmentItem(id: null, name: '')),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add department', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showEditDialog(DepartmentItem(id: null, name: '')),
      //   child: const Icon(Icons.add),
      // ),
      // appBar: AppBar(
      //   title: Text(
      //     widget.title,
      //     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      //   ),
      //   backgroundColor: Colors.deepPurple,
      //   elevation: 2,
      //   centerTitle: true,
      //   actions: [
      //     TextButton.icon(
      //       onPressed: _openAddDepartmentDialog,
      //       icon: const Icon(Icons.add, color: Colors.white),
      //       label: const Text('Add department', style: TextStyle(color: Colors.white)),
      //       style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search departments...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: Colors.deepPurple.shade300),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    ),
                  ),
                ),
              ),
            ),
            if (_query.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '${_filtered.length} result${_filtered.length != 1 ? 's' : ''} found',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            Expanded(
              child: Builder(builder: (context) {
                final deptCtrl = context.watch<DepartmentController>();
                Widget child;
                if (deptCtrl.isLoading && _all.isEmpty) {
                  child = const Center(child: CircularProgressIndicator());
                } else if (_filtered.isEmpty) {
                  child = FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            _query.isEmpty ? 'No departments available' : 'No departments found',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                          if (_query.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Try a different search term',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                } else {
                  child = ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final d = _filtered[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            Expanded(child: _buildListTile(d, index)),
                            const SizedBox(width: 8),
                            // Action buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye_outlined),
                                  tooltip: 'View',
                                  onPressed: () => _showViewDialog(d),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit',
                                  onPressed: () => _showEditDialog(d),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  tooltip: 'Delete',
                                  onPressed: () => _confirmDelete(d),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return child;
              }),
            ),
            if (_selectedId != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Selected: ${_all.firstWhere((e) => e.id == _selectedId).name}',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            // Padding(
            //   padding: const EdgeInsets.all(16),
            //   child: Row(
            //     children: [
            //       // Expanded(
            //       //   child: OutlinedButton(
            //       //     style: OutlinedButton.styleFrom(
            //       //       padding: const EdgeInsets.symmetric(vertical: 14),
            //       //       side: BorderSide(color: Colors.grey.shade400),
            //       //       shape: RoundedRectangleBorder(
            //       //         borderRadius: BorderRadius.circular(10),
            //       //       ),
            //       //     ),
            //       //     onPressed: () => Navigator.of(context).pop(),
            //       //     child: const Text(
            //       //       'Cancel',
            //       //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            //       //     ),
            //       //   ),
            //       // ),
            //       // const SizedBox(width: 12),
            //       // Expanded(
            //       //   child: ElevatedButton(
            //       //     onPressed: _selectedId == null
            //       //         ? null
            //       //         : () {
            //       //             HapticFeedback.heavyImpact();
            //       //             final sel = _all.firstWhere((e) => e.id == _selectedId, orElse: () => _filtered.isNotEmpty ? _filtered.first : _all.first);
            //       //             widget.onSelect(sel);
            //       //             Navigator.of(context).pop(sel);
            //       //           },
            //       //     style: ElevatedButton.styleFrom(
            //       //       backgroundColor: Colors.deepPurple,
            //       //       padding: const EdgeInsets.symmetric(vertical: 14),
            //       //       shape: RoundedRectangleBorder(
            //       //         borderRadius: BorderRadius.circular(10),
            //       //       ),
            //       //       disabledBackgroundColor: Colors.grey.shade300,
            //       //     ),
            //       //     child: const Text(
            //       //       'Confirm',
            //       //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            //       //     ),
            //       //   ),
            //       // ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
