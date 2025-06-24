import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Product/Addproduct.dart';
import 'package:flutter_application_1/screens/users/Users_List.dart';
import 'package:flutter_application_1/screens/Product/Addproduct.dart'; // Import de la page AddProductPage

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final List<Map<String, dynamic>> products = [
    {
      'image': 'assets/mouse.png',
      'name': 'mouse',
      'price': 113.99,
      'brand': 'Herman Miller',
      'category': 'Electronic',
      'supplier': 'Jenny Wilson',
    },
    {
      'image': 'assets/keyboard.jpeg',
      'name': 'Keyboard',
      'price': 11.99,
      'brand': 'Vitra',
      'category': 'Electronic',
      'supplier': 'Jenny Wilson',
    },
    // ... add more products as needed
  ];

  int _rowsPerPage = 5;
  int _page = 0;
  String _search = '';

  String? _selectedCategory;
  String? _selectedSupplier;

  final TextEditingController _nameFilterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((p) {
      final name = p['name'].toString().toLowerCase();
      final filter = _nameFilterController.text.toLowerCase();
      return filter.isEmpty || name.contains(filter);
    }).toList();

    return Scaffold(
      body: Row(
        children: [
          // Sidebar ici (inchangé)
          Container(
            width: 180,
            color: const Color(0xFFEEEEEE),
            child: ListView(
              children: [
                const SizedBox(height: 32),
                _sidebarItem(Icons.home, 'Home'),
                _sidebarItem(Icons.dashboard, 'Dashboard'),
                _sidebarItem(Icons.people, 'Users'),
                _sidebarItem(Icons.lock, 'Password'),
                _sidebarItem(Icons.assignment, 'Request Order'),
                _sidebarItem(Icons.shopping_cart, 'Purchase Order'),
                _sidebarItem(Icons.devices, 'Product', selected: true),
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
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Product',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.account_circle, size: 32),
                      tooltip: 'Profile',
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search and Add
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameFilterController,
                        decoration: InputDecoration(
                          hintText: 'Search by product name',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _nameFilterController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _nameFilterController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.filter_alt_outlined),
                      onPressed: () async {
                        final result = await showDialog<Map<String, String?>>(
                          context: context,
                          builder: (context) {
                            String? tempCategory = _selectedCategory;
                            String? tempSupplier = _selectedSupplier;
                            return AlertDialog(
                              title: const Text('Filter Products'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: tempCategory,
                                    decoration: const InputDecoration(labelText: 'Category'),
                                    items: [
                                      const DropdownMenuItem(value: null, child: Text('All')),
                                      ...products
                                          .map((p) => p['category'].toString())
                                          .toSet()
                                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                                    ],
                                    onChanged: (v) => tempCategory = v,
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: tempSupplier,
                                    decoration: const InputDecoration(labelText: 'Supplier'),
                                    items: [
                                      const DropdownMenuItem(value: null, child: Text('All')),
                                      ...products
                                          .map((p) => p['supplier'].toString())
                                          .toSet()
                                          .map((sup) => DropdownMenuItem(value: sup, child: Text(sup)))
                                    ],
                                    onChanged: (v) => tempSupplier = v,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop({
                                    'category': tempCategory,
                                    'supplier': tempSupplier,
                                  }),
                                  child: const Text('Apply'),
                                ),
                              ],
                            );
                          },
                        );
                        if (result != null) {
                          setState(() {
                            _selectedCategory = result['category'];
                            _selectedSupplier = result['supplier'];
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddProductPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      ),
                      child: const Text('+ Add New Product'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade100,
                        foregroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Table
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF7F4FA),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 1700), // optionnel, adapte si tu veux une largeur min
                        child: DataTable(
                          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.deepPurple.withOpacity(0.08);
                              }
                              return Colors.white;
                            },
                          ),
                          columns: const [
                            DataColumn(label: Text('')),
                            DataColumn(label: Text('Product Name')),
                            DataColumn(label: Text('Purchase Unit Price')),
                            DataColumn(label: Text('Brand')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Supplier')),
                            DataColumn(label: Text('')),
                          ],
                          rows: products.asMap().entries.map((entry) {
                            final index = entry.key;
                            final product = entry.value;
                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  return index.isEven ? Colors.white : Colors.grey.shade50;
                                },
                              ),
                              cells: [
                                DataCell(
                                  Image.asset(
                                    product['image'],
                                    width: 32,
                                    height: 32,
                                    errorBuilder: (c, o, s) => const Icon(Icons.image),
                                  ),
                                ),
                                DataCell(Text(product['name'])),
                                DataCell(Text('\$${product['price']}')),
                                DataCell(Text(product['brand'])),
                                DataCell(Text(product['category'])),
                                DataCell(Text(product['supplier'])),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                                      tooltip: 'View',
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.teal),
                                      tooltip: 'Edit',
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Delete',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Product'),
                                            content: const Text('Are you sure you want to delete this product?'),
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
                                        if (confirm == true) {
                                          setState(() {
                                            products.remove(product);
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Product deleted')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                // Pagination
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _page > 0
                          ? () => setState(() => _page--)
                          : null,
                    ),
                    ...List.generate(
                      (products.length / _rowsPerPage).ceil(),
                      (i) => TextButton(
                        onPressed: () => setState(() => _page = i),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontWeight: _page == i ? FontWeight.bold : FontWeight.normal,
                            color: _page == i ? Colors.deepPurple : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: (_page + 1) * _rowsPerPage < products.length
                          ? () => setState(() => _page++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, {bool selected = false}) {
    return Container(
      color: selected ? Colors.white : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: selected ? Colors.deepPurple : Colors.black54),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.deepPurple : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {},
      ),
    );
  }
}