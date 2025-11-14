// import 'dart:typed_data';
// import 'package:flutter/material.dart';

// class ViewProductPage extends StatelessWidget {
// 	final Map<String, dynamic> product;
// 	const ViewProductPage({Key? key, required this.product}) : super(key: key);

// 	@override
// 	Widget build(BuildContext context) {
// 		return Scaffold(
// 			body: Padding(
// 				padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
// 				child: SingleChildScrollView(
// 					child: Column(
// 						crossAxisAlignment: CrossAxisAlignment.start,
// 						children: [
// 							Row(
// 								children: [
// 									IconButton(
// 										icon: const Icon(Icons.arrow_back, color: Colors.deepPurple, size: 28),
// 										tooltip: 'Back',
// 										onPressed: () => Navigator.of(context).pop(),
// 									),
// 									const SizedBox(width: 8),
// 									const Text('View Product', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
// 									const Spacer(),
// 									IconButton(
// 										icon: const Icon(Icons.account_circle, size: 32),
// 										tooltip: 'Profile',
// 										onPressed: () {},
// 									),
// 								],
// 							),
// 							const SizedBox(height: 32),
// 							Row(
// 								crossAxisAlignment: CrossAxisAlignment.start,
// 								children: [
// 									Expanded(
// 										child: Column(
// 											crossAxisAlignment: CrossAxisAlignment.start,
// 											children: [
// 												_label('Product Name'),
// 												_readonlyField(product['name'] ?? ''),
// 												const SizedBox(height: 18),
// 												_label('Category'),
// 												_readonlyField(product['category'] ?? ''),
// 												const SizedBox(height: 18),
// 												_label('Description'),
// 												_readonlyField(product['description'] ?? ''),
// 												const SizedBox(height: 18),
// 												_label('Photo'),
// 												_productImage(product),
// 											],
// 										),
// 									),
// 									const SizedBox(width: 32),
// 									Expanded(
// 										child: Column(
// 											crossAxisAlignment: CrossAxisAlignment.start,
// 											children: [
// 												_label('Unit Price'),
// 												_readonlyField(product['price']?.toString() ?? ''),
// 												const SizedBox(height: 18),
// 												_label('Available Quantity'),
// 												_readonlyField(product['quantity']?.toString() ?? ''),
// 												const SizedBox(height: 18),
// 												_label('Supplier'),
// 												_readonlyField(product['supplier'] ?? ''),
// 												const SizedBox(height: 18),
// 												_label('Brand'),
// 												_readonlyField(product['brand'] ?? ''),
// 											],
// 										),
// 									),
// 								],
// 							),
// 						],
// 					),
// 				),
// 			),
// 		);
// 	}

// 	Widget _label(String text) {
// 		return Padding(
// 			padding: const EdgeInsets.only(bottom: 4),
// 			child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
// 		);
// 	}
//   // external String toString();
//   // external int get hashCode;



// 	Widget _readonlyField(String value) {
// 		return Container(
// 			width: double.infinity,
// 			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// 			margin: const EdgeInsets.only(bottom: 4),
// 			decoration: BoxDecoration(
// 				color: const Color(0xFFEDEDED),
// 				borderRadius: BorderRadius.circular(8),
// 			),
// 			child: Text(value, style: const TextStyle(fontSize: 16)),
// 		);
// 	}

// 	Widget _productImage(Map<String, dynamic> product) {
// 		if (product['photoBytes'] != null && product['photoBytes'] is Uint8List) {
// 			return Padding(
// 				padding: const EdgeInsets.only(top: 8, bottom: 8),
// 				child: ClipRRect(
// 					borderRadius: BorderRadius.circular(8),
// 					child: Image.memory(product['photoBytes'], width: 120, height: 120, fit: BoxFit.cover),
// 				),
// 			);
// 		} else if (product['image'] != null && (product['image'] as String).isNotEmpty) {
// 			return Padding(
// 				padding: const EdgeInsets.only(top: 8, bottom: 8),
// 				child: ClipRRect(
// 					borderRadius: BorderRadius.circular(8),
// 					child: Image.asset(product['image'], width: 120, height: 120, fit: BoxFit.cover),
// 				),
// 			);
// 		} else {
// 			return const Padding(
// 				padding: EdgeInsets.only(top: 8, bottom: 8),
// 				child: Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
// 			);
// 		}
// 	}
// }
