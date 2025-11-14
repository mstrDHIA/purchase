// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/screens/Product/Edit_product_screen.dart';
// import 'package:flutter_application_1/screens/Product/View_product_screen.dart';
// import 'package:flutter_application_1/screens/Product/add_product_screen.dart';
// import 'package:flutter_application_1/screens/Product/family_screen.dart';
// import 'package:flutter_application_1/widgets/sidebar.dart';

// // Import de la page AddProductPage

// class ProductPage extends StatefulWidget {
//   const ProductPage({super.key});

//   @override
//   State<ProductPage> createState() => _ProductPageState();
// }

// class _ProductPageState extends State<ProductPage> {
//   final List<Map<String, dynamic>> products = [
//     {
//       'image': 'assets/images/mouse.png',
//       'name': 'mouse',
//       'price': 113.99,
//       'brand': 'Herman Miller',
//       'category': 'Electronic',
//       'supplier': 'Jenny Wilson',
//     },
//     {
//       'image': 'assets/images/keyboard.jpeg',
//       'name': 'Keyboard',
//       'price': 11.99,
//       'brand': 'Vitra',
//       'category': 'Electronic',
//       'supplier': 'Jenny Wilson',
//     },
//     {
//       'image': 'assets/images/keyboard.jpeg',
//       'name': 'PC',
//       'price': 11.01,
//       'brand': 'ACER',
//       'category': 'Electronic',
//       'supplier': 'JASSER',
//     },
//   ];

//   final int _rowsPerPage = 5;
//   int _page = 0;
//   int _rowsShown = 5;
//   // final String _search = '';

//   String? _selectedCategory;
//   String? _selectedSupplier;
//   final TextEditingController _nameFilterController = TextEditingController();
//   int? _sortColumnIndex;
//   bool _sortAscending = true;
//   String _userName = 'John Doe'; 
//   String _userRole = 'Admin'; // À remplacer par le vrai rôle

//   void _sort<T>(Comparable<T> Function(Map<String, dynamic> p) getField, int columnIndex, bool ascending) {
//     products.sort((a, b) {
//       final aValue = getField(a);
//       final bValue = getField(b);
//       return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
//     });
//     setState(() {
//       _sortColumnIndex = columnIndex;
//       _sortAscending = ascending;
//     });
//   }

//   void _resetFilters() {
//     setState(() {
//       _selectedCategory = null;
//       _selectedSupplier = null;
//       _nameFilterController.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Filtrage local
//     final filtered = products.where((p) {
//       final name = p['name'].toString().toLowerCase();
//       final filter = _nameFilterController.text.toLowerCase();
//       final cat = _selectedCategory;
//       final sup = _selectedSupplier;
//       final matchName = filter.isEmpty || name.contains(filter);
//       final matchCat = cat == null || p['category'] == cat;
//       final matchSup = sup == null || p['supplier'] == sup;
//       return matchName && matchCat && matchSup;
//     }).toList();
//     final total = filtered.length;
//     final start = _page * _rowsShown;
//     final end = (start + _rowsShown > total) ? total : start + _rowsShown;
//     final pageItems = filtered.sublist(start, end);

//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header enrichi
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   tooltip: 'Back',
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Product',
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Search, Add, Reset
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _nameFilterController,
//                     decoration: InputDecoration(
//                       hintText: 'Search by product name',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: _nameFilterController.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear),
//                               onPressed: () {
//                                 _nameFilterController.clear();
//                                 setState(() {});
//                               },
//                             )
//                           : null,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onChanged: (value) => setState(() {}),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 IconButton(
//                   icon: const Icon(Icons.filter_alt_outlined),
//                   tooltip: 'Filtrer',
//                   onPressed: () async {
//                     final result = await showDialog<Map<String, String?>>(
//                       context: context,
//                       builder: (context) {
//                         String? tempCategory = _selectedCategory;
//                         String? tempSupplier = _selectedSupplier;
//                         return AlertDialog(
//                           title: const Text('Filter Products'),
//                           content: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               DropdownButtonFormField<String>(
//                                 value: tempCategory,
//                                 decoration: const InputDecoration(labelText: 'Category'),
//                                 items: [
//                                   const DropdownMenuItem(value: null, child: Text('All')),
//                                   ...products
//                                       .map((p) => p['category'].toString())
//                                       .toSet()
//                                       .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
//                                 ],
//                                 onChanged: (v) => tempCategory = v,
//                               ),
//                               const SizedBox(height: 16),
//                               DropdownButtonFormField<String>(
//                                 value: tempSupplier,
//                                 decoration: const InputDecoration(labelText: 'Supplier'),
//                                 items: [
//                                   const DropdownMenuItem(value: null, child: Text('All')),
//                                   ...products
//                                       .map((p) => p['supplier'].toString())
//                                       .toSet()
//                                       .map((sup) => DropdownMenuItem(value: sup, child: Text(sup)))
//                                 ],
//                                 onChanged: (v) => tempSupplier = v,
//                               ),
//                             ],
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(),
//                               child: const Text('Cancel'),
//                             ),
//                             ElevatedButton(
//                               onPressed: () => Navigator.of(context).pop({
//                                 'category': tempCategory,
//                                 'supplier': tempSupplier,
//                               }),
//                               child: const Text('Apply'),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                     if (result != null) {
//                       setState(() {
//                         _selectedCategory = result['category'];
//                         _selectedSupplier = result['supplier'];
//                       });
//                     }
//                   },
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton.icon(
//                   onPressed: _resetFilters,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Reset'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey.shade200,
//                     foregroundColor: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton.icon(
//                   onPressed: () async {
//                     await Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => const FamiliesPage()),
//                     );
//                     setState(() {});
//                   },
//                   icon: const Icon(Icons.category),
//                   label: const Text('Families'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.indigo,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: () async {
//                     final newProduct = await showDialog<Map<String, dynamic>>(
//                       context: context,
//                       builder: (context) => Dialog(
//                         child: SizedBox(
//                           width: 500,
//                           child: AddProductPage(),
//                         ),
//                       ),
//                     );
//                     if (newProduct != null) {
//                       setState(() {
//                         products.add(newProduct);
//                       });
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Row(
//                             children: [
//                               Icon(Icons.check_circle, color: Colors.white),
//                               SizedBox(width: 8),
//                               Text('Product added!'),
//                             ],
//                           ),
//                           backgroundColor: Colors.green,
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
//                   ),
//                   child: const Text('+ Add New Product'),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Table
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               color: const Color(0xFFF7F4FA),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(minWidth: 1100),
//                   child: DataTable(
//                     sortColumnIndex: _sortColumnIndex,
//                     sortAscending: _sortAscending,
//                     dataRowColor: WidgetStateProperty.resolveWith<Color?>(
//                       (Set<WidgetState> states) {
//                         if (states.contains(WidgetState.selected)) {
//                           return Colors.deepPurple.withOpacity(0.08);
//                         }
//                         return Colors.white;
//                       },
//                     ),
//                     columns: [
//                       const DataColumn(label: Text('')),
//                       DataColumn(
//                         label: const Text('Product Name'),
//                         onSort: (columnIndex, ascending) => _sort<String>((p) => p['name'].toString().toLowerCase(), columnIndex, ascending),
//                       ),
//                       DataColumn(
//                         label: const Text('Purchase Unit Price'),
//                         numeric: true,
//                         onSort: (columnIndex, ascending) => _sort<num>((p) => p['price'] as num, columnIndex, ascending),
//                       ),
//                       DataColumn(
//                         label: const Text('Brand'),
//                         onSort: (columnIndex, ascending) => _sort<String>((p) => p['brand'].toString().toLowerCase(), columnIndex, ascending),
//                       ),
//                       DataColumn(
//                         label: const Text('Category'),
//                         onSort: (columnIndex, ascending) => _sort<String>((p) => p['category'].toString().toLowerCase(), columnIndex, ascending),
//                       ),
//                       DataColumn(
//                         label: const Text('Supplier'),
//                         onSort: (columnIndex, ascending) => _sort<String>((p) => p['supplier'].toString().toLowerCase(), columnIndex, ascending),
//                       ),
//                       const DataColumn(label: Text('')),
//                     ],
//                     rows: pageItems.asMap().entries.map((entry) {
//                       final index = entry.key + start;
//                       final product = pageItems[entry.key];
//                       return DataRow(
//                         color: WidgetStateProperty.resolveWith<Color?>(
//                           (Set<WidgetState> states) {
//                             return index.isEven ? Colors.white : Colors.grey.shade50;
//                           },
//                         ),
//                         cells: [
//                           DataCell(
//                             MouseRegion(
//                               cursor: SystemMouseCursors.click,
//                               child: Image.asset(
//                                 product['image'],
//                                 width: 32,
//                                 height: 32,
//                                 errorBuilder: (c, o, s) => const Icon(Icons.image),
//                               ),
//                             ),
//                           ),
//                           DataCell(Text(product['name'])),
//                           DataCell(Text('\$${product['price']}')),
//                           DataCell(Text(product['brand'])),
//                           DataCell(Text(product['category'])),
//                           DataCell(Text(product['supplier'])),
//                           DataCell(Row(
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
//                                 tooltip: 'View',
//                                 onPressed: () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (context) => ViewProductPage(product: product),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.edit, color: Colors.teal),
//                                 tooltip: 'Edit',
//                                 onPressed: () {
//                                   Navigator.of(context).push(
//                                     MaterialPageRoute(
//                                       builder: (context) => EditProductPage(product: product),
//                                     ),
//                                   ).then((updatedProduct) {
//                                     if (updatedProduct != null) {
//                                       setState(() {
//                                         products[index] = updatedProduct;
//                                       });
//                                     }
//                                   });
//                                 },
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                                 tooltip: 'Delete',
//                                 onPressed: () async {
//                                   final confirm = await showDialog<bool>(
//                                     context: context,
//                                     builder: (context) => AlertDialog(
//                                       title: const Text('Delete Product'),
//                                       content: const Text('Are you sure you want to delete this product?'),
//                                       actions: [
//                                         TextButton(
//                                           onPressed: () => Navigator.of(context).pop(false),
//                                           child: const Text('Cancel'),
//                                         ),
//                                         ElevatedButton(
//                                           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                                           onPressed: () => Navigator.of(context).pop(true),
//                                           child: const Text('Delete'),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                   if (confirm == true) {
//                                     setState(() {
//                                       products.remove(product);
//                                     });
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text('Product deleted')),
//                                     );
//                                   }
//                                 },
//                               ),
//                               // PopupMenuButton<String>(
//                               //   icon: const Icon(Icons.more_vert),
//                               //   itemBuilder: (context) => [
//                               //     const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
//                               //   ],
//                               //   // onSelected: (value) async {
//                               //   //   if (value == 'duplicate') {
//                               //   //     setState(() {
//                               //   //       products.add({...product});
//                               //   //     });
//                               //   //     ScaffoldMessenger.of(context).showSnackBar(
//                               //   //       const SnackBar(content: Text('Product duplicated')),
//                               //   //     );
//                               //   //   }
//                               //   // },
//                               // ),
//                             ],
//                           )),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // Pagination améliorée
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Affichage ${start + 1}–$end sur $total'),
//                 Row(
//                   children: [
//                     DropdownButton<int>(
//                       value: _rowsShown,
//                       items: [5, 10, 20, 50]
//                           .map((v) => DropdownMenuItem(value: v, child: Text('$v par page')))
//                           .toList(),
//                       onChanged: (v) {
//                         if (v != null) setState(() => _rowsShown = v);
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.chevron_left),
//                       onPressed: _page > 0 ? () => setState(() => _page--) : null,
//                     ),
//                     ...List.generate(
//                       (total / _rowsShown).ceil(),
//                       (i) => TextButton(
//                         onPressed: () => setState(() => _page = i),
//                         child: Text(
//                           '${i + 1}',
//                           style: TextStyle(
//                             fontWeight: _page == i ? FontWeight.bold : FontWeight.normal,
//                             color: _page == i ? Colors.deepPurple : Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.chevron_right),
//                       onPressed: (_page + 1) * _rowsShown < total ? () => setState(() => _page++) : null,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _sidebarItem(IconData icon, String label, {bool selected = false}) {
//   //   return Container(
//   //     color: selected ? Colors.white : Colors.transparent,
//   //     child: ListTile(
//   //       leading: Icon(icon, color: selected ? Colors.deepPurple : Colors.black54),
//   //       title: Text(
//   //         label,
//   //         style: TextStyle(
//   //           color: selected ? Colors.deepPurple : Colors.black87,
//   //           fontWeight: selected ? FontWeight.bold : FontWeight.normal,
//   //         ),
//   //       ),
//   //       onTap: () {},
//   //     ),
//   //   );
//   // }
// }