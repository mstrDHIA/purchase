// import 'package:flutter/material.dart';

// class ProductHolder extends StatefulWidget{
//   @override
//   State<ProductHolder> createState() => _ProductHolderState();
// }

// class _ProductHolderState extends State<ProductHolder> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         spreadRadius: 2,
//                         blurRadius: 5,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   width: MediaQuery.of(context).size.width * 0.4,
//                   child:  Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     child: DropdownButtonFormField<String>(
//                     value: selectedFamily,
//                     decoration: const InputDecoration(
//                       labelText: 'Famille',
//                       border: OutlineInputBorder(),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     items: dynamicProductFamilies.keys
//                         .map((fam) => DropdownMenuItem(value: fam, child: Text(fam)))
//                         .toList(),
//                     onChanged: (val) {
//                       setState(() {
//                         selectedFamily = val;
//                         selectedSubFamily = null;
//                       });
//                     },
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: DropdownButtonFormField<String>(
//                     value: selectedSubFamily,
//                     decoration: const InputDecoration(
//                       labelText: 'Sous-famille',
//                       border: OutlineInputBorder(),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     items: selectedFamily == null
//                         ? []
//                         : dynamicProductFamilies[selectedFamily]!
//                             .map((sub) => DropdownMenuItem(value: sub, child: Text(sub)))
//                             .toList(),
//                     onChanged: (val) {
//                       setState(() {
//                         selectedSubFamily = val;
//                       });
//                     },
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: TextField(
//                     controller: productController,
//                     decoration: const InputDecoration(
//                       labelText: 'Produit (optionnel)',
//                       border: OutlineInputBorder(),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: TextField(
//                     controller: quantityController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: 'Quantité',
//                       border: OutlineInputBorder(),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   ElevatedButton.icon(
//                                     onPressed: _addProduct,
//                                     icon: const Icon(Icons.check, color: Colors.white),
//                                     label: const Text('Confirm Product', style: TextStyle(color: Colors.white)),
//                                     style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     elevation: 0,
//                                     ),
//                                   ),
//                                 ]),
//                   ),);
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }