import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
// import 'package:flutter_application_1/screens/Purchase%20purchaseRequest/refuse_purchase_screen.dart';
import 'package:intl/intl.dart';

class PurchaseRequestView extends StatefulWidget {
  final PurchaseRequest purchaseRequest;
  const PurchaseRequestView({
    super.key,
    required this.purchaseRequest,
    // required Null Function(dynamic newpurchaseRequest) onSave,
  });

  @override
  State<PurchaseRequestView> createState() => _PurchaseRequestViewState();
}

class _PurchaseRequestViewState extends State<PurchaseRequestView> {
  // String requestor = 'jasser';
  // String product = 'Souris';
  // String quantity = '7000';
  // String product2 = '';   // Nouveau champ
  // String quantity2 = '';  // Nouveau champ
  // String dueDate = '15-05-2025';
  // String submittedDate = '01-01-2025';
  // String note = '';
  // String status = "";
  // String priority = "";

  @override
  void initState() {
    super.initState();
    // requestor = widget.purchaseRequest.requestedBy?.toString() ?? '';
    // product = widget.purchaseRequest.products![0].product ?? '';
    // quantity = widget.purchaseRequest.products![0].quantity.toString() ?? '';
    // // Ajout pour un deuxième produit/quantité si présent
    // product2 = (widget.purchaseRequest['products']?.length ?? 0) > 1
    //     ? (widget.purchaseRequest['products']?[1]?['product']?.toString() ?? '')
    //     : '';
    // quantity2 = (widget.purchaseRequest['products']?.length ?? 0) > 1
    //     ? (widget.purchaseRequest['products']?[1]?['quantity']?.toString() ?? '')
    //     : '';
    // dueDate = widget.purchaseRequest['dueDate'] != null
    //     ? DateFormat('dd-MM-yyyy').format(widget.purchaseRequest['dueDate'])
    //     : '';
    // submittedDate = widget.purchaseRequest['dateSubmitted'] != null
    //     ? DateFormat('dd-MM-yyyy').format(widget.purchaseRequest['dateSubmitted'])
    //     : '';
    // note = widget.purchaseRequest['note']?.toString() ?? '';
    // status = widget.purchaseRequest['status']?.toString() ?? '';
    // priority = widget.purchaseRequest['priority']?.toString() ?? '';
  }

  void _editRequest() {
    showDialog(
      context: context,
      builder: (context) {
        // final TextEditingController productCtrl = TextEditingController(text: product);
        // final TextEditingController quantityCtrl = TextEditingController(text: quantity);
        return AlertDialog(
          title: const Text('Modifier la demande'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField( decoration: const InputDecoration(labelText: 'Produit')),
              TextField( decoration: const InputDecoration(labelText: 'Quantité'), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  // product = productCtrl.text;
                  // quantity = quantityCtrl.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Demande modifiée")),
                );
              },
              child: const Text('Enregistrer'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _deleteRequest() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFF7F9FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 340,
            minWidth: 260,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delete Purchase",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to delete ${widget.purchaseRequest.id ?? 'this purchase'}?",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                        // Ajoute ici la logique de suppression si besoin
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Purchase deleted")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Delete', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//   void _showDeleteDialog(String userName) {
//   showDialog(
//     context: context,
//     barrierColor: Colors.black.withOpacity(0.2),
//     builder: (context) => Dialog(
//       backgroundColor: const Color(0xF7F3F7FF),
//       shape: RoundedRectangleBpurchaseRequest(bpurchaseRequestRadius: BpurchaseRequestRadius.circular(24)),
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(
//           maxWidth: 340,
//           minWidth: 260,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Delete User",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 "Are you sure you want to delete $userName?",
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 28),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, false),
//                     child: const Text(
//                       'Cancel',
//                       style: TextStyle(color: Colors.deepPurple, fontSize: 16),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context, true),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
//                       shape: RoundedRectangleBpurchaseRequest(
//                         bpurchaseRequestRadius: BpurchaseRequestRadius.circular(24),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: const Text('Delete', style: TextStyle(fontSize: 16)),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }



  @override
  Widget build(BuildContext context) {
    // bool showActionButtons = status != "Approved"; // Ajout pour cacher les boutons après validation

    return Scaffold(
      body: Row(
        children: [
          // AppSidebar supprimé ici
          // const VerticalDivider(width: 1), // Supprimé aussi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre avec bouton retour
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.blue),
                            tooltip: 'Retour',
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Purchase Request',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Tooltip(
                            message: 'Modifier',
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: _editRequest,
                            ),
                          ),
                          Tooltip(
                            message: 'Supprimer',
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.blue),
                              onPressed: _deleteRequest,
                            ),
                          ),
                          const SizedBox(width: 10),
                        
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      // Première ligne : Requestor, Submitted Date, Due date
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildReadOnlyField('Requestor', widget.purchaseRequest.requestedBy.toString()),
                          const SizedBox(width: 20),
                          buildReadOnlyField('Starting Date', widget.purchaseRequest.startDate.toString()),
                          const SizedBox(width: 20),
                          buildReadOnlyField('Due date', widget.purchaseRequest.endDate.toString()),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Ensuite les produits et quantités
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (Products product in widget.purchaseRequest.products ?? [])
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildReadOnlyField('Product', product.product.toString()),
                              const SizedBox(width: 12),
                              buildReadOnlyField('Quantity', product.quantity.toString()),
                            ],
                          ),
                          // if (product2.isNotEmpty || quantity2.isNotEmpty)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 12.0),
                          //     child: Row(
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         buildReadOnlyField('Product', product2),
                          //         const SizedBox(width: 12),
                          //         buildReadOnlyField('Quantity', quantity2),
                          //       ],
                          //     ),
                          //   ),
                          // Priority sous les produits
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: buildReadOnlyField('Priority', 'High'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Note seule sur une ligne
                  const Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    readOnly: true,
                    maxLines: 5,
                    controller: TextEditingController(text: widget.purchaseRequest.description.toString()),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Ligne : Status à gauche, boutons à droite
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Status à gauche
                      SizedBox(
                        width: 280,
                        child: buildReadOnlyField('Status', widget.purchaseRequest.status.toString()),
                      ),
                      const Spacer(),
                      // if (showActionButtons)
                      //   Row(
                      //     children: [
                      //       ElevatedButton.icon(
                      //         onPressed: () {
                      //           setState(() {
                      //             status = "Approved";
                      //           });
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             SnackBar(
                      //               content: Row(
                      //                 children: const [
                      //                   Icon(Icons.check_circle, color: Colors.green, size: 28),
                      //                   SizedBox(width: 16),
                      //                   Expanded(
                      //                     child: Text(
                      //                       "Demande accepted",
                      //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //               backgroundColor: const Color.fromARGB(255, 32, 4, 243),
                      //               behavior: SnackBarBehavior.floating,
                      //               elevation: 8,
                      //               margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      //               shape: RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.circular(12),
                      //               ),
                      //               duration: const Duration(seconds: 2),
                      //             ),
                      //           );
                      //         },
                      //         icon: const Icon(Icons.check),
                      //         label: const Text('Accept'),
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: Colors.blue,
                      //           foregroundColor: Colors.white,
                      //           padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //         ),
                      //       ),
                      //       const SizedBox(width: 24),
                      //       OutlinedButton(
                      //         onPressed: () {
                      //           // showDialog(
                      //           //   context: context,
                      //           //   builder: (context) => RefusePurchaseDialog(),
                      //           // );
                      //         },
                      //         style: OutlinedButton.styleFrom(
                      //           padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      //         ),
                      //         child: Row(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: const [
                      //             Icon(Icons.close),
                      //             SizedBox(width: 8),
                      //             Text('Refuse'),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  const SizedBox(height: 30),
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReadOnlyField(String label, String value) {
    Color? badgeColor;
    Color? textColor = Colors.black;

    // Ajout du badge coloré pour Status
    if (label == 'Status') {
      if (value.toLowerCase() == 'pending') {
        badgeColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
      } else if (value.toLowerCase() == 'approved') {
        badgeColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
      }
    }

    // Ajout du badge coloré pour Priority
    if (label == 'Priority') {
      if (value.toLowerCase() == 'high') {
        badgeColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
      }
    }

    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          if (label == 'Status' || label == 'Priority')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: badgeColor ?? const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          else
            TextField(
              readOnly: true,
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
        ],
      ),
    );
  }

  
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key, required String selected, required Null Function(dynamic item) onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      color: const Color(0xFFEDEDED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _sidebarItem(Icons.home, 'Home'),
          _sidebarItem(Icons.dashboard, 'Dashboard'),
          _sidebarItem(Icons.people, 'Users', selected: true),
          _sidebarItem(Icons.lock, 'Password'),
          _sidebarItem(Icons.add, 'Request purchaseRequest'),
          _sidebarItem(Icons.shopping_cart, 'Purchase purchaseRequest'),
          _sidebarItem(Icons.security, 'Roles and access'),
          _sidebarItem(Icons.help, 'Support centre'),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, {bool selected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: selected
          ? BoxDecoration(
              color: const Color(0xFFD6C9F4),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        onTap: () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
      ),
    );
  }
}

