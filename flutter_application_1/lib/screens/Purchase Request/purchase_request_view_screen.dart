import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/network/purchase_request_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

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

  bool _showActionButtons = true;
  String? _status;
  late UserController userController;
  PurchaseOrderController? purchaseOrderController;
  @override
  void initState() {
  super.initState();
  _status = widget.purchaseRequest.status?.toString() ?? '';
  userController= Provider.of<UserController>(context, listen: false);
  purchaseOrderController = Provider.of<PurchaseOrderController>(context, listen: false);
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with back button
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
                            tooltip: AppLocalizations.of(context)?.cancel ?? 'Back',
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Center(
                          child: Text(
                            AppLocalizations.of(context)?.purchaseRequests ?? 'Purchase Request',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Afficher tous les produits, quantités, et leurs familles
                    if ((widget.purchaseRequest.products ?? []).isNotEmpty)
                      ...widget.purchaseRequest.products!.map((prod) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: buildReadOnlyField('Product', prod.product.toString()),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: buildReadOnlyField('Quantity', prod.quantity.toString()),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: buildReadOnlyField('Family', prod.family?.toString() ?? '-'),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: buildReadOnlyField('Subfamily', prod.subFamily?.toString() ?? '-'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                    const SizedBox(height: 20),
                    // Ligne 2 : Due date | Priority
                    Row(
                      children: [
                        Expanded(
                          child: buildReadOnlyField('Due Date', formatDate(widget.purchaseRequest.endDate)),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: buildReadOnlyField('Priority', widget.purchaseRequest.priority.toString()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Note
                    const Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      readOnly: true,
                      maxLines: 5,
                      controller: TextEditingController(text: widget.purchaseRequest.description.toString()),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Ligne : Status à gauche, boutons à droite (inchangé)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          child: buildReadOnlyField('Status', _status ?? ''),
                        ),
                        const Spacer(),
                        if (_showActionButtons && !isApproved && !isRejected && (userController.currentUser.role!.id == 1 || userController.currentUser.role!.id == 3 || userController.currentUser.role!.id == 4))
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final id = widget.purchaseRequest.id;
                                    if (id == null) throw Exception('ID missing');
                                    final payload = {
                                      'status': 'approved',
                                      'approved_by': userController.currentUser.id,
                                    };
                                    Map<String,dynamic> responseData = await PurchaseRequestNetwork().updatePurchaseRequest(id, payload, method: 'PATCH');
                                    setState(() {
                                      _showActionButtons = false;
                                    });
                                    // Show dialog to ask if a purchase order should be created
                                    final shouldCreate = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Create Purchase Order?'),
                                        content: const Text('Do you want to create a new purchase order from this purchase request?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('No'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (shouldCreate == true) {
                                      widget.purchaseRequest.approvedBy=responseData['approved_by'];
                                      Map<String,dynamic> purchaseOrderData = {
                                        'id':widget.purchaseRequest.id,
                                        'title': widget.purchaseRequest.title,
                                        'description': widget.purchaseRequest.description,
                                        'requested_by_user': widget.purchaseRequest.approvedBy,
                                        'status': 'pending',
                                        'created_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                        'updated_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                        // Include both the backend-friendly id field and the explicit
                                        // 'purchase_request' field expected by some endpoints.
                                        'purchase_request_id': widget.purchaseRequest.id,
                                        'purchase_request': widget.purchaseRequest.id,
                                        'products': widget.purchaseRequest.products?.map((p) => p.toJson()).toList(),
                                        'priority': widget.purchaseRequest.priority,
                                        'start_date': DateFormat('yyyy-MM-dd').format(widget.purchaseRequest.startDate!),
                                        'end_date': DateFormat('yyyy-MM-dd').format(widget.purchaseRequest.endDate!),
                                      };
                                      await purchaseOrderController!.addOrder(purchaseOrderData);
        
                                      if (mounted) {
                                        SnackBar snackBar=SnackBar(content: Text('Purchase Order created successfully!'),backgroundColor: Colors.green,);
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      }
                                    } else {
                                      // Just close the dialog and maybe pop the view
                                      if (mounted) Navigator.pop(context, true);
                                    }
                                  } catch (e) {
                                    String errorMsg = e.toString();
                                    if (e is DioException && e.response != null) {
                                      errorMsg = 'Erreur serveur: ${e.response}';
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
                                child: Text(AppLocalizations.of(context)?.confirm ?? 'Accept'),
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
                                      'approved_by': userController.currentUser.id,
                                    };
                                    await PurchaseRequestNetwork().updatePurchaseRequest(id, payload, method: 'PATCH');
                                    setState(() {
                                      _showActionButtons = false;
                                    });
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (mounted) {
                                        Navigator.pop(context, true);
                                      }
                                    });
                                  } catch (e) {
                                    String errorMsg = e.toString();
                                    if (e is DioException && e.response != null) {
                                      errorMsg = 'Erreur serveur: ${e.response}';
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(backgroundColor: const Color.fromARGB(255, 245, 3, 3), content: Text(errorMsg)),
                                    );
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(backgroundColor: Color.fromARGB(255, 9, 37, 250), content: Text('rejected!')),
                                  );
                                },
                                child: Text(AppLocalizations.of(context)?.cancel ?? 'Refuse'),
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
      } else if (value.toLowerCase() == 'rejected') {
        badgeColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
      }
    }
    // Ajout du badge coloré pour Priority
    if (label == 'Priority') {
      if (value.toLowerCase() == 'high') {
        badgeColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
      } else if (value.toLowerCase() == 'medium') {
        badgeColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
      } else if (value.toLowerCase() == 'low') {
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
              style: const TextStyle(fontSize: 15, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

