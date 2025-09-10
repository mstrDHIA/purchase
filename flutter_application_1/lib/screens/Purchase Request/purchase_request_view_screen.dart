import 'package:flutter_application_1/network/purchase_request_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:flutter_application_1/screens/Purchase%20order/purchase_form_screen.dart';

class PurchaseRequestView extends StatefulWidget {
  final PurchaseRequest purchaseRequest;
  const PurchaseRequestView({
    super.key,
    required this.purchaseRequest, required Map<String, dynamic> order, required Null Function(dynamic newOrder) onSave,
    // required Null Function(dynamic newpurchaseRequest) onSave,
  });

  @override
  State<PurchaseRequestView> createState() => _PurchaseRequestViewState();
}

class _PurchaseRequestViewState extends State<PurchaseRequestView> {
  // Future<void> _showRefuseDialog() async {
  //   final reasonController = TextEditingController();
  //   final commentController = TextEditingController();
  //   bool submitting = false;
  //   String? errorText;
  //   await showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  //             titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
  //             contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //             title: Row(
  //               children: const [
  //                 Icon(Icons.error, color: Colors.red, size: 28),
  //                 SizedBox(width: 10),
  //                 Text('Purchase Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
  //               ],
  //             ),
  //             content: SizedBox(
  //               width: 350,
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const SizedBox(height: 8),
  //                   const Text('Please provide a reason for refusing this request:', style: TextStyle(fontSize: 15)),
  //                   const SizedBox(height: 16),
  //                   const Text('Reason (required)', style: TextStyle(fontWeight: FontWeight.w600)),
  //                   const SizedBox(height: 6),
  //                   TextField(
  //                     controller: reasonController,
  //                     minLines: 2,
  //                     maxLines: 3,
  //                     decoration: InputDecoration(
  //                       hintText: 'Example: The requested item exceeds the approved budget for this quarter.',
  //                       filled: true,
  //                       fillColor: const Color(0xFFF1F1F1),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                         borderSide: BorderSide.none,
  //                       ),
  //                       errorText: errorText,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 18),
  //                   const Text('Additional Comments (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
  //                   const SizedBox(height: 6),
  //                   TextField(
  //                     controller: commentController,
  //                     minLines: 2,
  //                     maxLines: 3,
  //                     decoration: InputDecoration(
  //                       hintText: 'Provide any further details or context, if necessary.',
  //                       filled: true,
  //                       fillColor: const Color(0xFFF1F1F1),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                         borderSide: BorderSide.none,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 18, top: 8),
  //             actions: [
  //               ElevatedButton(
  //                 onPressed: submitting
  //                     ? null
  //                     : () async {
  //                         setState(() { errorText = null; });
  //                         if (reasonController.text.trim().isEmpty) {
  //                           setState(() { errorText = 'Reason is required'; });
  //                           return;
  //                         }
  //                         setState(() { submitting = true; });
  //                         await _deletePurchaseFromServer();
  //                         if (mounted) Navigator.of(context).pop();
  //                       },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xFF635BFF),
  //                   foregroundColor: Colors.white,
  //                   minimumSize: const Size(120, 44),
  //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //                   elevation: 0,
  //                 ),
  //                 child: submitting
  //                     ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
  //                     : const Text('Submit'),
  //               ),
  //               TextButton(
  //                 onPressed: submitting ? null : () => Navigator.of(context).pop(),
  //                 child: const Text('Cancel'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Future<void> _deletePurchaseFromServer() async {
    try {
      final id = widget.purchaseRequest.id;
      if (id == null) throw Exception('ID manquant');
      await PurchaseRequestNetwork().deletePurchaseRequest(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Color.fromARGB(255, 245, 3, 3), content: Text('Purchase deleted!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: const Color.fromARGB(255, 245, 3, 3), content: Text('Error: $e')),
      );
    }
  }
  bool _showActionButtons = true;
  String? _status;

  @override
  void initState() {
  super.initState();
  _status = widget.purchaseRequest.status?.toString() ?? '';
  }

  void _editRequest() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: const InputDecoration(labelText: 'Product')),
              TextField(decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            ],
          ),
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
    String formatDate(dynamic date) {
      if (date == null) return '';
      if (date is String) {
        final parsed = DateTime.tryParse(date);
        if (parsed != null) {
          return '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
        }
        return date.length >= 10 ? date.substring(0, 10) : date;
      }
      if (date is DateTime) {
        return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      return date.toString();
    }

  final isApproved = (_status ?? '').toLowerCase() == 'approved';
  final isRejected = (_status ?? '').toLowerCase() == 'rejected';
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with back button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.blue),
                            tooltip: 'Back',
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
                    ],
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      // First row: Requestor, Submitted Date, Due date
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildReadOnlyField('Requestor', widget.purchaseRequest.requestedBy.toString()),
                          const SizedBox(width: 20),
                          buildReadOnlyField('Submission Date', formatDate(widget.purchaseRequest.startDate)),
                          const SizedBox(width: 20),
                          buildReadOnlyField('Due Date', formatDate(widget.purchaseRequest.endDate)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Then products and quantities
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (ProductLine product in widget.purchaseRequest.products ?? [])
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildReadOnlyField('Product', product.product.toString()),
                              const SizedBox(width: 12),
                              buildReadOnlyField('Quantity', product.quantity.toString()),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: buildReadOnlyField('Priority', widget.purchaseRequest.priority.toString()),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Note on a single line
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

                  // Ligne : Status à gauche, boutons à droite (comme la capture)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Status à gauche
                      SizedBox(
                        width: 280,
                        child: buildReadOnlyField('Status', _status ?? ''),
                      ),
                      const Spacer(),
                      if (_showActionButtons && !isApproved && !isRejected)
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  final id = widget.purchaseRequest.id;
                                  if (id == null) throw Exception('ID missing');
                                  final payload = {
                                    'status': 'approved',
                                  };
                                  await PurchaseRequestNetwork().updatePurchaseRequest(id, payload, method: 'PATCH');
                                  setState(() {
                                    _showActionButtons = false;
                                  });
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      Navigator.pop(context, true); // Indique à la liste de se rafraîchir
                                    }
                                  });
                                } catch (e) {
                                  String errorMsg = e.toString();
                                  if (e is DioError && e.response != null) {
                                    errorMsg = 'Erreur serveur: ' + e.response.toString();
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(backgroundColor: const Color.fromARGB(255, 245, 3, 3), content: Text(errorMsg)),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF635BFF),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(120, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Accept'),
                            ),
                            const SizedBox(width: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF5F5F5),
                                foregroundColor: Colors.black87,
                                minimumSize: const Size(120, 44),
                                side: const BorderSide(color: Color(0xFFE0E0E0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  final id = widget.purchaseRequest.id;
                                  if (id == null) throw Exception('ID missing');
                                  final payload = {
                                    'status': 'rejected',
                                  };
                                  await PurchaseRequestNetwork().updatePurchaseRequest(id, payload, method: 'PATCH');
                                  setState(() {
                                    _showActionButtons = false;
                                  });
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      Navigator.pop(context, true); // Indique à la liste de se rafraîchir
                                    }
                                  });
                                } catch (e) {
                                  String errorMsg = e.toString();
                                  if (e is DioError && e.response != null) {
                                    errorMsg = 'Erreur serveur: ' + e.response.toString();
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(backgroundColor: const Color.fromARGB(255, 245, 3, 3), content: Text(errorMsg)),
                                  );
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(backgroundColor: Color.fromARGB(255, 9, 37, 250), content: Text('rejected!')),
                                );
                              },
                              child: const Text('Refuse'),
                            ),
                          ],
                        ),
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
      else if (value.toLowerCase() == 'rejected') {
        badgeColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
      }
    }

    // Ajout du badge coloré pour Priority
    if (label == 'Priority') {
      if (value.toLowerCase() == 'high') {
        badgeColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
      }
      else if(value.toLowerCase() == 'medium'){
        badgeColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
      }
      else if(value.toLowerCase() == 'low'){
        badgeColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
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

