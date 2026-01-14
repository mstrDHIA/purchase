// ignore_for_file: unused_field
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/network/purchase_request_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/product_controller.dart';
import '../../utils/purchase_request_pdf.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show MissingPluginException;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_application_1/utils/download_helper.dart';
import 'package:printing/printing.dart';
import 'package:flutter_application_1/screens/Purchase order/refuse_purchase_screen.dart';
import 'package:flutter_application_1/screens/Purchase order/pushase_order_screen.dart';
import 'package:flutter_application_1/screens/Purchase order/Edit_purchase_screen.dart';

class PurchaseRequestView extends StatefulWidget {
  final PurchaseRequest purchaseRequest;
  const PurchaseRequestView({
    super.key,
    required this.purchaseRequest,
  });

  @override
  State<PurchaseRequestView> createState() => _PurchaseRequestViewState();
}

class _PurchaseRequestViewState extends State<PurchaseRequestView> {

  bool _showActionButtons = true;
  bool _poCreated = false;
  String? _status;
  late UserController userController;
  late ProductController productController;
  Map<int, String> _categoryNamesById = {};
  Map<String, List<String>> _families = {};
  bool _loadingFamilies = false;
  String? _familiesError;
  PurchaseOrderController? purchaseOrderController;
  @override
  void initState() {
  super.initState();
  _status = widget.purchaseRequest.status?.toString() ?? '';
  userController= Provider.of<UserController>(context, listen: false);
  purchaseOrderController = Provider.of<PurchaseOrderController>(context, listen: false);
    productController = Provider.of<ProductController>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProductFamilies();
    });
  }

  Future<void> _fetchProductFamilies() async {
    setState(() {
      _loadingFamilies = true;
      _familiesError = null;
    });
    try {
      final categories = await productController.getCategories(null);
      if (categories is List) {
        final all = categories.cast<Map<String, dynamic>>();
        final Map<int, String> idToName = {};
        for (final c in all) {
          final id = c['id'];
          final name = c['name']?.toString() ?? '';
          if (id != null) idToName[id as int] = name;
        }

        final parents = all.where((cat) => cat['parent_category'] == null).toList();
        final Map<String, List<String>> fams = {};
        for (final family in parents) {
          final familyId = family['id'];
          final familyName = family['name'] as String? ?? '';
          final subs = all
              .where((cat) => cat['parent_category'] == familyId)
              .map((c) => c['name'] as String)
              .toList();
          fams[familyName] = subs.isNotEmpty ? subs : [familyName];
        }

        setState(() {
          _categoryNamesById = idToName;
          _families = fams;
        });
      }
    } catch (e) {
      setState(() {
        _familiesError = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loadingFamilies = false);
    }
  }

  String _resolveCategoryName(dynamic value) {
    if (value == null) return '';
    if (value is int) return _categoryNamesById[value] ?? value.toString();
    if (value is String) {
      // if it's numeric string, try parse
      final parsed = int.tryParse(value);
      if (parsed != null) return _categoryNamesById[parsed] ?? value;
      return value;
    }
    if (value is Map) {
      return value['name']?.toString() ?? value.toString();
    }
    return value.toString();
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
    final products = widget.purchaseRequest.products ?? [];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      tooltip: 'Back',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Purchase Request',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'ID: ${widget.purchaseRequest.id?.toString() ?? '-'}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // PDF export icon (top-right) — small square with border and shadow
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Visibility(
                        visible: userController.currentUser.role!.id == 4 || userController.currentUser.role!.id == 1,
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              // Prefer explicit usernames from the users cache when available
                              String? requesterUsername;
                              String? approverUsername;
                              try {
                                final requesterUser = userController.users.firstWhere((u) => u.id == widget.purchaseRequest.requestedBy);
                                // Only use the explicit username when present; do NOT fall back to the ID
                                requesterUsername = requesterUser.username;
                              } catch (_) {
                                // Don't substitute another user — leave null so PDF shows '-'
                                requesterUsername = null;
                              }
                              try {
                                final approverUser = userController.users.firstWhere((u) => u.id == widget.purchaseRequest.approvedBy);
                                approverUsername = approverUser.username;
                              } catch (_) {
                                approverUsername = null;
                              }

                              final bytes = await PurchaseRequestPdf.generatePurchaseRequestPdf(
                                widget.purchaseRequest,
                                l10n: AppLocalizations.of(context),
                                requesterUsername: requesterUsername,
                                approverUsername: approverUsername,
                              );
                              final filename = 'purchase_request_${widget.purchaseRequest.id ?? 'request'}.pdf';
                              if (kIsWeb) {
                                try {
                                  await saveAsFile(bytes, filename);
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded $filename')));
                                } on UnsupportedError catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download not supported in this web context: $e'), backgroundColor: Colors.red));
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e'), backgroundColor: Colors.red));
                                }
                              } else {
                                try {
                                  await Printing.sharePdf(bytes: bytes, filename: filename);
                                } on MissingPluginException catch (_) {
                                  // Fallback: save file locally and offer to open it
                                  try {
                                    final dir = await getTemporaryDirectory();
                                    final path = '${dir.path}/$filename';
                                    final file = File(path);
                                    await file.writeAsBytes(bytes);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Saved to $path'),
                                          action: SnackBarAction(label: 'Open', onPressed: () => OpenFile.open(path)),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving file: $e'), backgroundColor: Colors.red));
                                  }
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share PDF: $e'), backgroundColor: Colors.red));
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF: ' + e.toString())));
                              }
                            }
                          },

                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
                            ),
                            child: const Icon(Icons.picture_as_pdf, size: 20, color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (_loadingFamilies) const LinearProgressIndicator(minHeight: 3),
              if (_familiesError != null) ...[
                const SizedBox(height: 8),
                Text('Failed to load product families: $_familiesError', style: const TextStyle(color: Colors.red)),
              ],
              // Products section
              const Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (products.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final dynamic prod = products[index];
                    // Normalize product fields whether prod is a ProductLine or a Map
                    String familyText = '-';
                    String subfamilyText = '-';
                    String productText = '-';
                    String quantityText = '';
                    try {
                      if (prod is Map) {
                        familyText = _resolveCategoryName(prod['family'] ?? prod['family_name'] ?? prod['category']);
                        subfamilyText = _resolveCategoryName(prod['subFamily'] ?? prod['sub_family'] ?? prod['subcategory']);
                        productText = _resolveCategoryName(prod['product']);
                        quantityText = (prod['quantity'] ?? '')?.toString() ?? '';
                      } else {
                        // assume ProductLine or similar object with properties
                        familyText = _resolveCategoryName(prod.family);
                        subfamilyText = _resolveCategoryName(prod.subFamily);
                        productText = _resolveCategoryName(prod.product);
                        quantityText = prod.quantity?.toString() ?? '';
                      }
                    } catch (_) {
                      // fallback to safe defaults
                      familyText = '';
                      subfamilyText = '';
                      productText = prod?.toString() ?? '';
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 0),
                      elevation: 2,
                      color: Colors.white.withOpacity(0.98),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(text: familyText),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Family',
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.black87),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.deepPurple),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(text: subfamilyText),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Subfamily',
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.black87),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.deepPurple),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: TextEditingController(text: productText),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Product',
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.black87),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.deepPurple),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: TextEditingController(text: quantityText),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Quantity',
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.black87),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.deepPurple),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              // Due date & Priority row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Due Date'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: TextEditingController(text: formatDate(widget.purchaseRequest.endDate)),
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Priority'),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (widget.purchaseRequest.priority?.toLowerCase() == 'high')
                                ? Colors.red.shade100
                                : (widget.purchaseRequest.priority?.toLowerCase() == 'medium')
                                    ? Colors.orange.shade100
                                    : (widget.purchaseRequest.priority?.toLowerCase() == 'low')
                                        ? Colors.green.shade100
                                        : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (widget.purchaseRequest.priority ?? '').toLowerCase(),
                            style: TextStyle(
                              color: (widget.purchaseRequest.priority?.toLowerCase() == 'high')
                                  ? Colors.red
                                  : (widget.purchaseRequest.priority?.toLowerCase() == 'medium')
                                      ? Colors.orange
                                      : (widget.purchaseRequest.priority?.toLowerCase() == 'low')
                                          ? Colors.green
                                          : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Description
              const Text('Description'),
              const SizedBox(height: 4),
              TextField(
                readOnly: true,
                maxLines: 5,
                controller: TextEditingController(text: widget.purchaseRequest.description.toString()),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black87),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              // Status & Action buttons
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        width: double.infinity,
        height: 50,
        child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          
                          const Text('Status'),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (_status?.toLowerCase() == 'pending')
                                  ? Colors.orange.shade100
                                  : (_status?.toLowerCase() == 'approved')
                                      ? Colors.green.shade100
                                      : (_status?.toLowerCase() == 'rejected')
                                          ? Colors.red.shade100
                                          : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (_status == null || _status!.isEmpty)
                                  ? ''
                                  : (_status!.toLowerCase() == 'pending')
                                      ? AppLocalizations.of(context)!.pending
                                      : (_status!.toLowerCase() == 'approved')
                                          ? AppLocalizations.of(context)!.approved
                                          : (_status!.toLowerCase() == 'rejected')
                                              ? AppLocalizations.of(context)!.rejected
                                              : (_status!.toLowerCase() == 'transformed')
                                                  ? AppLocalizations.of(context)!.transformed
                                                  : (_status!.toLowerCase() == 'edited')
                                                      ? AppLocalizations.of(context)!.edited
                                                      : _status![0].toUpperCase() + _status!.substring(1),
                              style: TextStyle(
                                color: (_status?.toLowerCase() == 'pending')
                                    ? Colors.orange.shade800
                                    : (_status?.toLowerCase() == 'approved')
                                        ? Colors.green.shade800
                                        : (_status?.toLowerCase() == 'rejected')
                                            ? Colors.red.shade800
                                            : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Spacer(),
                    if((userController.currentUser.role!.id==4||userController.currentUser.role!.id==1)&&(_status=='approved') && !_poCreated)
                    ElevatedButton(onPressed: () async {
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
                                  final id = widget.purchaseRequest.id;
                                  if (id == null) throw Exception('ID missing');
                                  final payload = {
                                    'status': 'transformed',
                                  };
                                  await PurchaseRequestNetwork().updatePurchaseRequest(id, payload, method: 'PATCH');
                                  // Update local model so the view reflects transformed status but do not change approvedBy
                                  widget.purchaseRequest.status = 'transformed';

                                  // Hide the Create PO button immediately to prevent duplicate clicks
                                  setState(() {
                                    _poCreated = true;
                                  });

                                  // Build initial PO data to prefill the editor (do NOT set 'id' here — leave null so editor treats it as new)
                                  Map<String, dynamic> purchaseOrderData = {
                                    'title': widget.purchaseRequest.title,
                                    'description': widget.purchaseRequest.description,
                                    'requested_by_user': widget.purchaseRequest.approvedBy,
                                    // Ensure both legacy and canonical status keys are set to 'edited' so the created PO appears as edited
                                    'status': 'edited',
                                    'statuss': 'edited',
                                    'created_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                    'updated_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                    'purchase_request_id': widget.purchaseRequest.id,
                                    'purchase_request': widget.purchaseRequest.id,
                                    'products': widget.purchaseRequest.products?.map((p) => p.toJson()).toList(),
                                    'priority': widget.purchaseRequest.priority,
                                    'start_date': widget.purchaseRequest.startDate != null ? DateFormat('yyyy-MM-dd').format(widget.purchaseRequest.startDate!) : null,
                                    'end_date': widget.purchaseRequest.endDate != null ? DateFormat('yyyy-MM-dd').format(widget.purchaseRequest.endDate!) : null,
                                  };

                                  // Open the EditPurchaseOrder editor in a dialog so user can review/edit before saving
                                  await showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (ctx) => Dialog(
                                      child: SizedBox(
                                        width: 900,
                                        child: EditPurchaseOrder(
                                          initialOrder: purchaseOrderData,
                                          onSave: (newOrder) async {
                                            try {
                                              await purchaseOrderController!.addOrder(newOrder);
                                              if (mounted) {
                                                setState(() {
                                                  _showActionButtons = false;
                                                  _poCreated = true;
                                                  _status = 'transformed';
                                                });
                                                Navigator.of(ctx).pop(); // close editor dialog
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Purchase Order created successfully!'), backgroundColor: Colors.green),
                                                );
                                                // Navigate to Purchase Orders page and reuse the existing controller so the new PO is visible immediately
                                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => PurchaseOrderPage(controller: purchaseOrderController)));
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Failed to create Purchase Order: $e'), backgroundColor: Colors.red),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Just close the dialog and maybe pop the view
                                  if (mounted) {}
                                  Navigator.pop(context, true);
                                }
                    }, child: Text('Create PO'),style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF635BFF),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(120, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),),
                    if (_showActionButtons && !isApproved && !isRejected && widget.purchaseRequest.status!='transformed' && (userController.currentUser.role!.id == 1 || userController.currentUser.role!.id == 3 || userController.currentUser.role!.id == 4))
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
                                await PurchaseRequestNetwork().updatePurchaseRequest(id, payload, method: 'PATCH');
                                setState(() {
                                  _showActionButtons = false;
                                });
                                // Show dialog to ask if a purchase order should be created
                                // final shouldCreate = await showDialog<bool>(
                                //   context: context,
                                //   builder: (context) => AlertDialog(
                                //     title: const Text('Create Purchase Order?'),
                                //     content: const Text('Do you want to create a new purchase order from this purchase request?'),
                                //     actions: [
                                //       TextButton(
                                //         onPressed: () => Navigator.of(context).pop(false),
                                //         child: const Text('No'),
                                //       ),
                                //       ElevatedButton(
                                //         onPressed: () => Navigator.of(context).pop(true),
                                //         child: const Text('Yes'),
                                //       ),
                                //     ],
                                //   ),
                                // );
                                // if (shouldCreate == true) {
                                //   widget.purchaseRequest.approvedBy=responseData['approved_by'];
                                //   Map<String,dynamic> purchaseOrderData = {
                                //     'id':widget.purchaseRequest.id,
                                //     'title': widget.purchaseRequest.title,
                                //     'description': widget.purchaseRequest.description,
                                //     'requested_by_user': widget.purchaseRequest.approvedBy,
                                //     'status': 'pending',
                                //     'created_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                //     'updated_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                //     // Include both the backend-friendly id field and the explicit
                                //     // 'purchase_request' field expected by some endpoints.
                                //     'purchase_request_id': widget.purchaseRequest.id,
                                //     'purchase_request': widget.purchaseRequest.id,
                                //     'products': widget.purchaseRequest.products?.map((p) => p.toJson()).toList(),
                                //     'priority': widget.purchaseRequest.priority,
                                //     'start_date': DateFormat('yyyy-MM-dd').format(widget.purchaseRequest.startDate!),
                                //     'end_date': DateFormat('yyyy-MM-dd').format(widget.purchaseRequest.endDate!),
                                //   };
                                //   await purchaseOrderController!.addOrder(purchaseOrderData);
        
                                //   if (mounted) {
                                //     SnackBar snackBar=SnackBar(content: Text('Purchase Order created successfully!'),backgroundColor: Colors.green,);
                                //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                //   }
                                // } else {
                                //   // Just close the dialog and maybe pop the view
                                //   if (mounted)
                                   Navigator.pop(context, true);
                                // }
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
                            child: Text(AppLocalizations.of(context)?.approve ?? 'Approve'),
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

                                // Coordinator (role id 3) sees a choice dialog before entering the refuse reason
                                if (userController.currentUser.role!.id == 3) {
                                  final choice = await showDialog<String>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(AppLocalizations.of(context)!.reject),
                                      content: Text('Reject type:'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop('modify'),
                                          child: const Text('Reject for modification'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop('total'),
                                          child: const Text('Reject completely'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (choice == null) return;

                                  // Show reason dialog
                                  final result = await showDialog<Map<String, dynamic>>(
                                    context: context,
                                    builder: (context) => const RefusePurchaseDialog(),
                                  );

                                  if (result == null) return;

                                  final payload = {
                                    'status': choice == 'total' ? 'rejected' : 'edited',
                                    'approved_by': userController.currentUser.id,
                                    if (result['reason_id'] != null) 'rejected_reason': result['reason_id'],
                                    'refuse_reason': result['reason_text'] ?? result['comment'] ?? '',
                                  };

                                  await PurchaseRequestNetwork().updatePurchaseRequest(id, payload, method: 'PATCH');

                                  setState(() {
                                    _showActionButtons = false;
                                    _status = payload['status'];
                                  });

                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) Navigator.pop(context, true);
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(choice == 'total' ? AppLocalizations.of(context)!.purchaseOrderRejected : '${AppLocalizations.of(context)!.rejected} (for modification)'), backgroundColor: choice == 'total' ? Colors.red : Colors.orange),
                                  );

                                  return;
                                }

                                // Default behavior for other roles: immediate reject (backwards compatible)
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
                            child: Text(AppLocalizations.of(context)?.reject ?? 'Reject'),
                          ),
                        ],
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
      final lv = value.toLowerCase();
      if (lv == 'pending') {
        badgeColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
      } else if (lv == 'approved') {
        badgeColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
      } else if (lv == 'rejected') {
        badgeColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
      } else if (lv == 'transformed') {
        badgeColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
      } else if (lv == 'edited') {
        badgeColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
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

    // Localized display value for Status
    String displayValue = value;
    if (label == 'Status') {
      final lv = value.toLowerCase();
      displayValue = lv == 'pending'
          ? AppLocalizations.of(context)!.pending
          : lv == 'approved'
              ? AppLocalizations.of(context)!.approved
              : lv == 'rejected'
                  ? AppLocalizations.of(context)!.rejected
                  : lv == 'transformed'
                      ? AppLocalizations.of(context)!.transformed
                      : lv == 'edited'
                          ? AppLocalizations.of(context)!.edited
                          : value[0].toUpperCase() + value.substring(1);
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
                displayValue,
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

