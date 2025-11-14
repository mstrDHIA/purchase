// // main.dart
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class AddProductPage extends StatefulWidget {
//   const AddProductPage({super.key});

//   @override
//   State<AddProductPage> createState() => _AddProductPageState();
// }

// class _AddProductPageState extends State<AddProductPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameCtrl = TextEditingController();
//   final TextEditingController _categoryCtrl = TextEditingController();
//   final TextEditingController _descCtrl = TextEditingController();
//   final TextEditingController _unitPriceCtrl = TextEditingController();
//   final TextEditingController _quantityCtrl = TextEditingController();
//   final TextEditingController _supplierCtrl = TextEditingController();
//   final TextEditingController _brandCtrl = TextEditingController();

//   // XFile? _photo;
//   Uint8List? _photoBytes;

//   Future<void> _pickPhoto() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       final bytes = await picked.readAsBytes();
//       setState(() {
//         // _photo = picked;
//         _photoBytes = bytes;
//       });
//     }
//   }

//   void _save({bool addAnother = false}) {
//     if (_formKey.currentState?.validate() != true) return;

//     final newProduct = {
//       'image': 'assets/mouse.png', // Default image if none is provided
//       'name': _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '-',
//       'price': double.tryParse(_unitPriceCtrl.text) ?? 0.0,
//       'brand': _brandCtrl.text.isNotEmpty ? _brandCtrl.text : '-',
//       'category': _categoryCtrl.text.isNotEmpty ? _categoryCtrl.text : '-',
//       'supplier': _supplierCtrl.text.isNotEmpty ? _supplierCtrl.text : '-',
//       'description': _descCtrl.text,
//       'quantity': int.tryParse(_quantityCtrl.text) ?? 0,
//       'photoBytes': _photoBytes,
//     };

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white),
//             SizedBox(width: 8),
//             Text('Product saved successfully!'),
//           ],
//         ),
//         backgroundColor: Colors.green,
//       ),
//     );

//     if (addAnother) {
//       _formKey.currentState?.reset();
//       setState(() {
//         _photoBytes = null;
//       });
//       // Pass the new product back to the previous screen
//       Navigator.of(context).pop(newProduct);
//     } else {
//       Navigator.of(context).pop(newProduct);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Container(
//           //   width: 200,
//           //   color: const Color(0xFF1E1E2C),
//           //   child: Column(
//           //     crossAxisAlignment: CrossAxisAlignment.start,
//           //     children: [
//           //       const SizedBox(height: 32),
//           //       const Padding(
//           //         padding: EdgeInsets.symmetric(horizontal: 16.0),
//           //         child: Text('MENU', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
//           //       ),
//           //       const SizedBox(height: 16),
//           //       _sidebarItem(Icons.home, 'Home'),
//           //       _sidebarItem(Icons.dashboard, 'Dashboard'),
//           //       _sidebarItem(Icons.people, 'Users'),
//           //       _sidebarItem(Icons.lock, 'Password'),
//           //       _sidebarItem(Icons.assignment, 'Request Order'),
//           //       _sidebarItem(Icons.shopping_cart, 'Purchase Order'),
//           //       _sidebarItem(Icons.security, 'Roles and access'),
//           //       _sidebarItem(Icons.help, 'Support center'),
//           //     ],
//           //   ),
//           // ),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.only(top: 40),

            
//               color: const Color(0xFFF4F4F6), 
//               child: Center(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.arrow_back),
//                             tooltip: 'Back',
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                           const SizedBox(width: 8),
//                           const Text(
//                             'Add New Product',
//                             style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//                           // ),
//                           // const Spacer(),
//                           // IconButton(
//                           //   icon: const Icon(Icons.account_circle, size: 32),
//                           //   tooltip: 'Profile',
//                           //   onPressed: () {},
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 32),
//                       Form(
//                         key: _formKey,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text("General Information", style: Theme.of(context).textTheme.titleLarge),
//                                   const SizedBox(height: 12),
//                                   _label('Product Name'),
//                                   TextFormField(
//                                     controller: _nameCtrl,
//                                     keyboardType: TextInputType.text,
//                                     decoration: _inputDecoration('Wireless Mouse MX500', icon: Icons.label),
//                                     validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                                   ),
//                                   const SizedBox(height: 18),
//                                   _label('Category'),
//                                   TextFormField(
//                                     controller: _categoryCtrl,
//                                     keyboardType: TextInputType.text,
//                                     decoration: _inputDecoration('Electronics, Office Supplies', icon: Icons.category),
//                                     validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                                   ),
//                                   const SizedBox(height: 18),
//                                   _label('Description'),
//                                   TextFormField(
//                                     controller: _descCtrl,
//                                     keyboardType: TextInputType.text,
//                                     decoration: _inputDecoration('Brief product overview', icon: Icons.description),
//                                     maxLines: 2,
//                                   ),
//                                   const SizedBox(height: 18),
//                                   _label('Photo'),
//                                   GestureDetector(
//                                     onTap: _pickPhoto,
//                                     child: Container(
//                                       width: 120,
//                                       height: 120,
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey[200],
//                                         borderRadius: BorderRadius.circular(8),
//                                         border: Border.all(color: Colors.grey.shade300),
//                                       ),
//                                       child: _photoBytes != null
//                                           ? Stack(
//                                               children: [
//                                                 ClipRRect(
//                                                   borderRadius: BorderRadius.circular(8),
//                                                   child: Image.memory(_photoBytes!, fit: BoxFit.cover, width: 120, height: 120),
//                                                 ),
//                                                 Positioned.fill(
//                                                   child: Container(
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.black26,
//                                                       borderRadius: BorderRadius.circular(8),
//                                                     ),
//                                                     child: const Icon(Icons.edit, color: Colors.white),
//                                                   ),
//                                                 ),
//                                               ],
//                                             )
//                                           : const Center(
//                                               child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
//                                             ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 32),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text("Additional Details", style: Theme.of(context).textTheme.titleLarge),
//                                   const SizedBox(height: 12),
//                                   _label('Unit Price'),
//                                   TextFormField(
//                                     controller: _unitPriceCtrl,
//                                     decoration: _inputDecoration('Ex: 59.99', icon: Icons.attach_money),
//                                     keyboardType: TextInputType.number,
//                                     validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                                   ),
//                                   const SizedBox(height: 18),
//                                   _label('Available Quantity'),
//                                   TextFormField(
//                                     controller: _quantityCtrl,
//                                     decoration: _inputDecoration('', icon: Icons.inventory),
//                                     keyboardType: TextInputType.number,
//                                     validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                                   ),
//                                   const SizedBox(height: 18),
//                                   _label('Supplier'),
//                                   TextFormField(
//                                     controller: _supplierCtrl,
//                                     decoration: _inputDecoration('', icon: Icons.store),
//                                     validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                                   ),
//                                   const SizedBox(height: 18),
//                                   _label('Brand'),
//                                   TextFormField(
//                                     controller: _brandCtrl,
//                                     decoration: _inputDecoration('', icon: Icons.branding_watermark),
//                                     validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 32),
//                       Row(
//                         children: [
//                           ElevatedButton(
//                             onPressed: () => _save(addAnother: false),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.deepPurple,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                             ),
//                             child: const Text('Save'),
//                           ),
//                           const SizedBox(width: 16),
//                           ElevatedButton(
//                             onPressed: () => _save(addAnother: true),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.deepPurple.shade100,
//                               foregroundColor: Colors.deepPurple,
//                               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                             ),
//                             child: const Text('Save & add another'),
//                           ),
//                           const SizedBox(width: 16),
//                           OutlinedButton(
//                             onPressed: () => Navigator.pop(context),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                             ),
//                             child: const Text('Cancel'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _label(String text) => Padding(
//         padding: const EdgeInsets.only(bottom: 4),
//         child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
//       );

//   InputDecoration _inputDecoration(String hint, {IconData? icon}) => InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: const Color(0xFFEDEDED),
//         border: InputBorder.none,
//         prefixIcon: icon != null ? Icon(icon) : null,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       );

//   Widget _sidebarItem(IconData icon, String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.white70),
//         title: Text(
//           label,
//           style: const TextStyle(color: Colors.white),
//         ),
//         onTap: () {},
//       ),
//     );
//   }
// }