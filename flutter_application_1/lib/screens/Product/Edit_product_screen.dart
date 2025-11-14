// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class EditProductPage extends StatefulWidget {
//   final Map<String, dynamic> product;
//   const EditProductPage({Key? key, required this.product}) : super(key: key);

//   @override
//   State<EditProductPage> createState() => _EditProductPageState();
// }

// class _EditProductPageState extends State<EditProductPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameCtrl;
//   late TextEditingController _categoryCtrl;
//   late TextEditingController _descCtrl;
//   late TextEditingController _unitPriceCtrl;
//   late TextEditingController _quantityCtrl;
//   late TextEditingController _supplierCtrl;
//   late TextEditingController _brandCtrl;
//   Uint8List? _photoBytes;
//   String? _imagePath;

//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.product['name'] ?? '');
//     _categoryCtrl = TextEditingController(text: widget.product['category'] ?? '');
//     _descCtrl = TextEditingController(text: widget.product['description'] ?? '');
//     _unitPriceCtrl = TextEditingController(text: widget.product['price']?.toString() ?? '');
//     _quantityCtrl = TextEditingController(text: widget.product['quantity']?.toString() ?? '');
//     _supplierCtrl = TextEditingController(text: widget.product['supplier'] ?? '');
//     _brandCtrl = TextEditingController(text: widget.product['brand'] ?? '');
//     _imagePath = widget.product['image'];
//     if (widget.product['photoBytes'] != null) {
//       _photoBytes = widget.product['photoBytes'];
//     }
//   }

//   Future<void> _pickPhoto() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       final bytes = await picked.readAsBytes();
//       setState(() {
//         _photoBytes = bytes;
//         _imagePath = null;
//       });
//     }
//   }

//   void _save() {
//     if (_formKey.currentState?.validate() != true) return;
//     final updatedProduct = {
//       ...widget.product,
//       'name': _nameCtrl.text,
//       'category': _categoryCtrl.text,
//       'description': _descCtrl.text,
//       'price': double.tryParse(_unitPriceCtrl.text) ?? 0.0,
//       'quantity': int.tryParse(_quantityCtrl.text) ?? 0,
//       'supplier': _supplierCtrl.text,
//       'brand': _brandCtrl.text,
//       'image': _imagePath,
//       'photoBytes': _photoBytes,
//     };
//     Navigator.of(context).pop(updatedProduct);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back, color: Colors.deepPurple, size: 28),
//                       tooltip: 'Back',
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                     const SizedBox(width: 8),
//                     const Text('Edit Product', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _label('Product Name'),
//                           TextFormField(
//                             controller: _nameCtrl,
//                             decoration: _inputDecoration('Product Name'),
//                             validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                           ),
//                           const SizedBox(height: 18),
//                           _label('Category'),
//                           TextFormField(
//                             controller: _categoryCtrl,
//                             decoration: _inputDecoration('Category'),
//                             validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                           ),
//                           const SizedBox(height: 18),
//                           _label('Description'),
//                           TextFormField(
//                             controller: _descCtrl,
//                             decoration: _inputDecoration('Description'),
//                             maxLines: 2,
//                           ),
//                           const SizedBox(height: 18),
//                           _label('Photo'),
//                           GestureDetector(
//                             onTap: _pickPhoto,
//                             child: Container(
//                               width: 120,
//                               height: 120,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(color: Colors.grey.shade300),
//                               ),
//                               child: _photoBytes != null
//                                   ? ClipRRect(
//                                       borderRadius: BorderRadius.circular(8),
//                                       child: Image.memory(_photoBytes!, fit: BoxFit.cover, width: 120, height: 120),
//                                     )
//                                   : (_imagePath != null && _imagePath!.isNotEmpty)
//                                       ? ClipRRect(
//                                           borderRadius: BorderRadius.circular(8),
//                                           child: Image.asset(_imagePath!, fit: BoxFit.cover, width: 120, height: 120),
//                                         )
//                                       : const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 32),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _label('Unit Price'),
//                           TextFormField(
//                             controller: _unitPriceCtrl,
//                             decoration: _inputDecoration('Unit Price'),
//                             keyboardType: TextInputType.number,
//                             validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                           ),
//                           const SizedBox(height: 18),
//                           _label('Available Quantity'),
//                           TextFormField(
//                             controller: _quantityCtrl,
//                             decoration: _inputDecoration('Available Quantity'),
//                             keyboardType: TextInputType.number,
//                           ),
//                           const SizedBox(height: 18),
//                           _label('Supplier'),
//                           TextFormField(
//                             controller: _supplierCtrl,
//                             decoration: _inputDecoration('Supplier'),
//                             validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                           ),
//                           const SizedBox(height: 18),
//                           _label('Brund'),
//                           TextFormField(
//                             controller: _brandCtrl,
//                             decoration: _inputDecoration('Brand'),
//                             validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _save,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.deepPurple.shade100,
//                         foregroundColor: Colors.deepPurple,
//                         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                       ),
//                       child: const Text('Save'),
//                     ),
//                     const SizedBox(width: 16),
//                     OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                       ),
//                       child: const Text('Cancel'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//     Widget _label(String text) {
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 4),
//         child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
//       );
//     }

//     InputDecoration _inputDecoration(String hint) {
//       return InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: const Color(0xFFEDEDED),
//         border: InputBorder.none,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       );
//     }

//   // Removed duplicate _label and _inputDecoration declarations
// }
