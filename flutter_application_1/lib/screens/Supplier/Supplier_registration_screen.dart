import 'package:flutter/material.dart';

class Supplier {
  final String email;
  final String name;
  final String category;
  final String status;

  Supplier(this.email, this.name, this.category, this.status);
}

class SupplierRegistrationPage extends StatefulWidget {
  const SupplierRegistrationPage({Key? key}) : super(key: key);

  @override
  State<SupplierRegistrationPage> createState() => _SupplierRegistrationPageState();
}

class _SupplierRegistrationPageState extends State<SupplierRegistrationPage> {
  final List<Supplier> suppliers = List.generate(
    5,
    (index) => Supplier(
      'deanna.curtis@example.com',
      'Jenny Wilson',
      'Jenny Wilson',
      index == 1 ? 'Inactive' : 'Active',
    ),
  );

  String searchText = '';
  String? selectedCategory;
  String? selectedStatus;

  int _currentPage = 1;
  final int _suppliersPerPage = 10;

  List<Supplier> get filteredSuppliers {
    return suppliers.where((supplier) {
      final matchesSearch = searchText.isEmpty ||
          supplier.email.toLowerCase().contains(searchText.toLowerCase()) ||
          supplier.name.toLowerCase().contains(searchText.toLowerCase());
      final matchesCategory = selectedCategory == null || supplier.category == selectedCategory;
      final matchesStatus = selectedStatus == null || supplier.status == selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Récupère toutes les catégories uniques
    final categories = suppliers.map((s) => s.category).toSet().toList();

    final int totalPages = (filteredSuppliers.length / _suppliersPerPage).ceil();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: const Color(0xFFF4F4F6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _sidebarItem(Icons.home, 'Home'),
                _sidebarItem(Icons.dashboard, 'Dashboard'),
                _sidebarItem(Icons.people, 'Users'),
                _sidebarItem(Icons.lock, 'Password'),
                _sidebarItem(Icons.add, 'Request Order'),
                _sidebarItem(Icons.shopping_cart, 'Purchase Order'),
                _sidebarItem(Icons.security, 'Roles and access'),
                _sidebarItem(Icons.help, 'Support centre'),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 0),
                  child: Row(
                    children: [
                      const Text(
                        "Supplier Registration",
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.account_circle, size: 36),
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                        tooltip: 'Profile',
                      ),
                    ],
                  ),
                ),
                // Search bar and filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search user name, email ...',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Category filter
                      DropdownButton<String>(
                        value: selectedCategory,
                        hint: const Text('Category'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...categories.map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      // Status filter
                      DropdownButton<String>(
                        value: selectedStatus,
                        hint: const Text('Status'),
                        items: const [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem(
                            value: 'Active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'Inactive',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value;
                          });
                        },
                      ),
                      const SizedBox(width: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9D8DF1),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _openAddSupplier,
                        child: const Text('+ Add New Supplier', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9D8DF1),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {},
                        child: const Text('Search', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                // Table
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 200,
                        dataRowHeight: 76,
                        dividerThickness: 0, 
                        columns: const [
                          DataColumn(label: Text('EMAIL', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('NAME', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('')),
                        ],
                        rows: _paginatedSuppliers.map((supplier) {
                          return DataRow(
                            cells: [
                              DataCell(Text(supplier.email)),
                              DataCell(Text(supplier.name)),
                              DataCell(Text(supplier.category)),
                              DataCell(_statusBadge(supplier.status)),
                              DataCell(Row(
                                children: [
                                  _iconAction(Icons.remove_red_eye, Colors.blue.shade100, onTap: () {
                                    Navigator.pushNamed(context, '/view_supplier');
                                  }),
                                  const SizedBox(width: 8),
                                  _iconAction(Icons.edit, Colors.blue.shade100, onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/edit_supplier',
                                      arguments: {
                                        'email': supplier.email,
                                        'name': supplier.name,
                                        'category': supplier.category,
                                        'status': supplier.status,
                                      },
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  // Delete icon: rendre fonctionnel ici
                                  _iconAction(Icons.delete, Colors.blue.shade100, onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Supplier'),
                                        content: const Text('Are you sure you want to delete this supplier?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      setState(() {
                                        suppliers.remove(supplier);
                                      });
                                    }
                                  }),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                // Pagination
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  child: Row(
                    children: [
                      // Previous page
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        onPressed: _currentPage > 1
                            ? () => setState(() => _currentPage--)
                            : null,
                      ),
                      // Page numbers
                      ...List.generate(4, (index) {
                        final pageNum = index + 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _currentPage = pageNum),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: _currentPage == pageNum ? Colors.blue : Colors.grey.shade200,
                              child: Text(
                                "$pageNum",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _currentPage == pageNum ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      // Ellipsis and last page
                      if (totalPages > 4) ...[
                        const Text(' ... ', style: TextStyle(fontSize: 14)),
                        GestureDetector(
                          onTap: () => setState(() => _currentPage = totalPages),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: _currentPage == totalPages ? Colors.blue : Colors.grey.shade200,
                            child: Text(
                              '$totalPages',
                              style: TextStyle(
                                fontSize: 12,
                                color: _currentPage == totalPages ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                      // Next page
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
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
        ],
      ),
    );
  }

  Future<void> _openAddSupplier() async {
    final newSupplier = await Navigator.pushNamed(context, '/add_supplier');
    if (newSupplier != null && newSupplier is Map<String, dynamic>) {
      setState(() {
        suppliers.add(
          Supplier(
            newSupplier['email'] ?? '',
            newSupplier['name'] ?? '',
            newSupplier['category'] ?? '',
            newSupplier['status'] ?? 'Active',
          ),
        );
      });
    }
  }

  List<Supplier> get _paginatedSuppliers {
    final start = (_currentPage - 1) * _suppliersPerPage;
    final end = (_currentPage * _suppliersPerPage).clamp(0, filteredSuppliers.length);
    return filteredSuppliers.sublist(
      start,
      end,
    );
  }

  Widget _sidebarItem(IconData icon, String label) {
    // Map label to route
    final routes = {
      'Home': '/home',
      'Dashboard': '/dashboard',
      'Users': '/users',
      'Password': '/password',
      'Request Order': '/requestor_order',
      'Purchase Order': '/purchase_order',
      'Roles and access': '/permission',
      'Support centre': '/support',
    };
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      selected: false,
      selectedTileColor: const Color(0xFFD6D6F4),
      onTap: () {
        final route = routes[label];
        if (route != null && ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      dense: true,
    );
  }

  Widget _statusBadge(String status) {
    final isActive = status == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade200 : Colors.red.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green.shade900 : Colors.red.shade900,
        ),
      ),
    );
  }

  Widget _iconAction(IconData icon, Color bgColor, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.black87),
        onPressed: onTap ?? () {},
        tooltip: icon == Icons.remove_red_eye
            ? 'View'
            : icon == Icons.edit
                ? 'Edit'
                : 'Delete',
      ),
    );
  }
}