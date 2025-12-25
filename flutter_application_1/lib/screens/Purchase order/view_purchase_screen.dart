import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_order.dart';
import 'package:flutter_application_1/utils/download_helper.dart';
import 'package:flutter_application_1/utils/pdf_generator.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/screens/Purchase order/refuse_purchase_screen.dart';
import '../../l10n/app_localizations.dart';

class PurchaseOrderView extends StatefulWidget {
  final PurchaseOrder order;
  const PurchaseOrderView({super.key, required this.order});

  static Widget withProviders({Key? key, required PurchaseOrder order, UserController? userController}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PurchaseOrderController()),
        if (userController != null)
          ChangeNotifierProvider.value(value: userController)
        else
          ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: PurchaseOrderView(key: key, order: order),
    );
  }

  @override
  State<PurchaseOrderView> createState() => _PurchaseOrderViewState();
}

class _PurchaseOrderViewState extends State<PurchaseOrderView> {
  late PurchaseOrder _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  // Shows a polished dialog allowing the coordinator to choose how to reject
  Future<String?> _showRejectTypeDialog() async {
    String? _selected;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Row(children: [const Icon(Icons.error_outline, color: Colors.red), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.reject)]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: 'total',
                  groupValue: _selected,
                  title: const Text('Reject completely'),
                  subtitle: const Text('Close the request and record a refusal reason.'),
                  secondary: const Icon(Icons.block, color: Colors.red),
                  onChanged: (v) => setState(() => _selected = v),
                ),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  value: 'modify',
                  groupValue: _selected,
                  title: const Text('Reject for modification'),
                  subtitle: const Text('Return the request to the requester to edit and resubmit.'),
                  secondary: const Icon(Icons.edit, color: Colors.orange),
                  onChanged: (v) => setState(() => _selected = v),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
              ElevatedButton(
                onPressed: _selected == null ? null : () => Navigator.of(context).pop(_selected),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF635BFF)),
                child: const Text('Continue'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    // final submittedDate = _order.startDate != null ? dateFormat.format(_order.startDate!) : '-';
    final dueDate = _order.endDate != null ? dateFormat.format(_order.endDate!) : '-';
    final supplierDeliveryDate = _order.supplierDeliveryDate != null ? dateFormat.format(_order.supplierDeliveryDate!) : '-';
    final status = _order.status ?? '-';
    final priority = _order.priority ?? '-';
    final note = _order.description ?? '';
    final products = _order.products ?? [];
    final userController = Provider.of<UserController>(context, listen: false);
    final purchaseOrderController = Provider.of<PurchaseOrderController>(context, listen: false);
    // compute total and currency symbol
    final double totalAmount = (products).fold<double>(0.0, (sum, p) => sum + ((p.unitPrice ?? 0.0) * (p.quantity ?? 0)));
    String currencySymbol = '\$';
    final currencyRaw = _order.currency?.toString();
    if (currencyRaw != null && currencyRaw.isNotEmpty) {
      final code = currencyRaw.toUpperCase();
      final Map<String, String> codeToSymbol = {'USD': '\$', 'EUR': '€', 'TND': 'DT'};
      if (codeToSymbol.containsKey(code)) {
        currencySymbol = codeToSymbol[code]!;
      } else if (currencyRaw.toLowerCase().contains('dinar')) {
        currencySymbol = 'DT';
      } else if (currencyRaw.toLowerCase().contains('dollar')) {
        currencySymbol = '\$';
      } else if (currencyRaw.toLowerCase().contains('euro')) {
        currencySymbol = '€';
      } else {
        // fallback: show code itself if it's short
        currencySymbol = currencyRaw.length <= 4 ? currencyRaw : '\$';
      }
    }


    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with back button and centered title
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: AppLocalizations.of(context)!.back,
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.purchaseOrderTitle,
                          style: const TextStyle(
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
                            AppLocalizations.of(context)!.idLabel(_order.id?.toString() ?? '-'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // button to export pdf
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Export PDF',
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.black87),
                      onPressed: () async {
                        // Show actions: Share or Save
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.share),
                                    title: const Text('Share / Download'),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      try {
                                        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Generating PDF...')));
                                        final bytes = await PdfGenerator.generatePurchaseOrderPdf(_order);
                                        try {
                                          await Printing.sharePdf(bytes: bytes, filename: 'purchase_order_${_order.id ?? 'po'}.pdf');
                                        } catch (_) {
                                          // Printing not available — fall back depending on platform
                                          try {
                                            await _saveOrDownload(bytes, 'purchase_order_${_order.id ?? 'po'}.pdf');
                                          } catch (e) {
                                            if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Error sharing/downloading: $e'), backgroundColor: Colors.red));
                                          }
                                        }
                                      } catch (e) {
                                        if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.save_alt),
                                    title: const Text('Save locally'),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      try {
                                        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Generating PDF...')));
                                        final bytes = await PdfGenerator.generatePurchaseOrderPdf(_order);
                                        if (kIsWeb) {
                                          // On web, trigger a direct download
                                          await _saveOrDownload(bytes, 'purchase_order_${_order.id ?? 'po'}.pdf', preferAppDocs: true);
                                          return;
                                        }
                                        final dir = await getApplicationDocumentsDirectory();
                                        final file = File('${dir.path}/purchase_order_${_order.id ?? 'po'}.pdf');
                                        await file.writeAsBytes(bytes);
                                        if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(
                                          SnackBar(
                                            content: Text('Saved to ${file.path}'),
                                            action: SnackBarAction(
                                              label: 'Open',
                                              onPressed: () async {
                                                try {
                                                  await OpenFile.open(file.path);
                                                } catch (e) {
                                                  if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Error opening file: $e'), backgroundColor: Colors.red));
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Error saving PDF: $e'), backgroundColor: Colors.red));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 24),
              if ((_order.refuseReason ?? '').isNotEmpty) ...[
                Text(AppLocalizations.of(context)!.refuseReasonLabel),
                const SizedBox(height: 4),
                TextField(
                  controller: TextEditingController(text: _order.refuseReason ?? ''),
                  readOnly: true,
                  maxLines: 3,
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
              ],
              // Priority row (supplier header removed)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.priority),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: priority.toLowerCase() == 'high'
                                ? Colors.red.shade100
                                : priority.toLowerCase() == 'medium'
                                    ? Colors.orange.shade100
                                    : priority.toLowerCase() == 'low'
                                        ? Colors.green.shade100
                                        : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priority.toLowerCase(),
                            style: TextStyle(
                              color: priority.toLowerCase() == 'high'
                                  ? Colors.red
                                  : priority.toLowerCase() == 'medium'
                                      ? Colors.orange
                                      : priority.toLowerCase() == 'low'
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
              // Dates: Due Date and Supplier Delivery Date side by side
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.dueDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),),
                        const SizedBox(height: 4),
                        TextField(
                          controller: TextEditingController(text: dueDate),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.supplierDeliveryDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),),
                        const SizedBox(height: 4),
                        TextField(
                          controller: TextEditingController(text: supplierDeliveryDate),
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
                ],
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              // Products section
              Text(AppLocalizations.of(context)!.products, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 8),
              if (products.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final prod = products[index];
                    final unitPrice = prod.unitPrice ?? 0.0;
                    final quantity = prod.quantity ?? 0;
                    final totalPrice = unitPrice * quantity;
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
                                    controller: TextEditingController(text: prod.family?.toString() ?? '-'),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.familyLabel,
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
                                    controller: TextEditingController(text: prod.subFamily?.toString() ?? '-'),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.subfamilyLabel,
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
                            // Supplier shown per product (read-only)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(text: prod.supplier ?? '-'),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.supplierLabel,
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
                                    controller: TextEditingController(text: prod.product ?? '-'),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.product,
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
                                    controller: TextEditingController(text: quantity.toString()),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.quantity,
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
                                    controller: TextEditingController(text: unitPrice.toStringAsFixed(2)),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.unitPrice,
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
                                    controller: TextEditingController(text: totalPrice.toStringAsFixed(2)),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!.totalPrice,
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
              // Note
              Text(AppLocalizations.of(context)!.noteLabel),
              const SizedBox(height: 4),
              TextField(
                controller: TextEditingController(text: note),
                readOnly: true,
                maxLines: 4,
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
              // Status, total, and action buttons moved to the fixed bottom bar
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SafeArea(
          top: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.totalLabel('${currencySymbol}${totalAmount.toStringAsFixed(2)}'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.statusLabel + ':', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status.toLowerCase() == 'approved'
                          ? Colors.green.shade100
                          : status.toLowerCase() == 'pending'
                              ? Colors.orange.shade100
                              : status.toLowerCase() == 'edited'
                                  ? Colors.pink.shade100
                                  : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      status.isNotEmpty ? (status[0].toUpperCase() + status.substring(1)) : '-',
                      style: TextStyle(
                        color: status.toLowerCase() == 'approved'
                            ? Colors.green.shade700
                            : status.toLowerCase() == 'pending'
                                ? Colors.orange.shade800
                                : status.toLowerCase() == 'edited'
                                    ? Colors.red.shade700
                                    : Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (widget.order.status!.toLowerCase()=='edited' && (userController.currentUser.role?.id == 1 || userController.currentUser.role?.id == 6)) ...[
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final updatedOrderJson = {
                            'id': _order.id,
                            'requested_by_user': _order.requestedByUser,
                            'approved_by': userController.currentUser.id,
                            'statuss': 'approved',
                            'start_date': _order.startDate != null ? DateFormat('yyyy-MM-dd').format(_order.startDate!) : null,
                            'end_date': _order.endDate != null ? DateFormat('yyyy-MM-dd').format(_order.endDate!) : null,
                            'priority': _order.priority,
                            'description': _order.description,
                            'products': (_order.products ?? []).map((p) => p.toJson()).toList(),
                            'title': _order.title ?? '',
                            'created_at': _order.createdAt != null ? DateFormat('yyyy-MM-dd').format(_order.createdAt!) : null,
                            'updated_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          };
                          await purchaseOrderController.updateOrder(updatedOrderJson);
                          await purchaseOrderController.fetchOrders();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.purchaseOrderApproved), backgroundColor: Colors.green),
                            );
                            setState(() {
                              _order = PurchaseOrder(
                                id: _order.id,
                                requestedByUser: _order.requestedByUser,
                                approvedBy: userController.currentUser.id,
                                status: 'Approved',
                                startDate: _order.startDate,
                                endDate: _order.endDate,
                                priority: _order.priority,
                                description: _order.description,
                                products: _order.products,
                                title: _order.title,
                                createdAt: _order.createdAt,
                                updatedAt: DateTime.now(),
                              );
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.failedWithError(e.toString())), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF635BFF),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text(AppLocalizations.of(context)!.approve),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final id = _order.id;
                          if (id == null) throw Exception('ID missing');

                          // Coordinator (role id 6): ask for reject type first
                          if (userController.currentUser.role!.id == 6) {
                            final choice = await _showRejectTypeDialog();
                            if (choice == null) return;

                            // Show reason dialog
                            final result = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => const RefusePurchaseDialog(),
                            );
                            if (result == null) return;

                            final updatedOrderJson = {
                              'id': _order.id,
                              'requested_by_user': _order.requestedByUser,
                              'approved_by': userController.currentUser.id,
                              'statuss': choice == 'total' ? 'rejected' : 'edited',
                              if (choice == 'modify') 'for_modification': true,
                              'start_date': _order.startDate != null ? DateFormat('yyyy-MM-dd').format(_order.startDate!) : null,
                              'end_date': _order.endDate != null ? DateFormat('yyyy-MM-dd').format(_order.endDate!) : null,
                              'priority': _order.priority,
                              'description': _order.description,
                              if (result['reason_id'] != null) 'rejected_reason': result['reason_id'],
                              'refuse_reason': result['reason_text'] ?? result['comment'] ?? '',
                              'products': (_order.products ?? []).map((p) => p.toJson()).toList(),
                              'title': _order.title ?? '',
                              'created_at': _order.createdAt != null ? DateFormat('yyyy-MM-dd').format(_order.createdAt!) : null,
                              'updated_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            };

                            await purchaseOrderController.updateOrder(updatedOrderJson);
                            await purchaseOrderController.fetchOrders();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(choice == 'total' ? AppLocalizations.of(context)!.purchaseOrderRejected : '${AppLocalizations.of(context)!.rejected} (for modification)'), backgroundColor: choice == 'total' ? Colors.red : Colors.orange),
                              );
                              setState(() {
                                _order = PurchaseOrder(
                                  id: _order.id,
                                  requestedByUser: _order.requestedByUser,
                                  approvedBy: userController.currentUser.id,
                                  status: choice == 'total' ? 'Rejected' : 'Edited',
                                  startDate: _order.startDate,
                                  endDate: _order.endDate,
                                  priority: _order.priority,
                                  description: _order.description,
                                  refuseReason: result['comment'] ?? result['reason_text'] ?? '',
                                  products: _order.products,
                                  title: _order.title,
                                  createdAt: _order.createdAt,
                                  updatedAt: DateTime.now(),
                                );
                                try {
                                  (_order as dynamic).rejectedReason = result['reason_id'];
                                } catch (_) {}
                              });
                            }

                            return;
                          }

                          // Default behavior for other roles: immediate reject as before
                          final result = await showDialog(
                            context: context,
                            builder: (context) => const RefusePurchaseDialog(),
                          );
                          if (result != null && result is Map) {
                            final updatedOrderJson = {
                              'id': _order.id,
                              'requested_by_user': _order.requestedByUser,
                              'approved_by': userController.currentUser.id,
                              'statuss': 'rejected',
                              'start_date': _order.startDate != null ? DateFormat('yyyy-MM-dd').format(_order.startDate!) : null,
                              'end_date': _order.endDate != null ? DateFormat('yyyy-MM-dd').format(_order.endDate!) : null,
                              'priority': _order.priority,
                              'description': _order.description,
                              // Use the selected reason id for the backend field 'rejected_reason'
                              'rejected_reason': result['reason_id'],
                              // Use the additional comment as 'refuse_reason'
                              'refuse_reason': result['comment'],
                              'products': (_order.products ?? []).map((p) => p.toJson()).toList(),
                              'title': _order.title ?? '',
                              'created_at': _order.createdAt != null ? DateFormat('yyyy-MM-dd').format(_order.createdAt!) : null,
                              'updated_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                            };
                            await purchaseOrderController.updateOrder(updatedOrderJson);
                            await purchaseOrderController.fetchOrders();
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.purchaseOrderRejected), backgroundColor: Colors.red),
                              );
                              setState(() {
                                _order = PurchaseOrder(
                                  id: _order.id,
                                  requestedByUser: _order.requestedByUser,
                                  approvedBy: userController.currentUser.id,
                                  status: 'Rejected',
                                  startDate: _order.startDate,
                                  endDate: _order.endDate,
                                  priority: _order.priority,
                                  description: _order.description,
                                  refuseReason: result['comment'],
                                  products: _order.products,
                                  title: _order.title,
                                  createdAt: _order.createdAt,
                                  updatedAt: DateTime.now(),
                                );
                                // Try to set a rejectedReason id on the local model if it exists
                                try {
                                  // Use dynamic assignment to avoid static analyzer errors if field doesn't exist
                                  (_order as dynamic).rejectedReason = result['reason_id'];
                                } catch (_) {}
                              });
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.failedWithError(e.toString())), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5),
                        foregroundColor: Colors.black87,
                        minimumSize: const Size(120, 44),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(AppLocalizations.of(context)!.reject),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveOrDownload(Uint8List bytes, String filename, {bool preferAppDocs = false}) async {
    try {
      if (kIsWeb) {
        try {
          await saveAsFile(bytes, filename);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded $filename')));
        } on UnsupportedError catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download not supported in this web context: $e'), backgroundColor: Colors.red));
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e'), backgroundColor: Colors.red));
        }
        return;
      }

      final dir = preferAppDocs ? await getApplicationDocumentsDirectory() : await getTemporaryDirectory();
      final path = '${dir.path}/$filename';
      final file = File(path);
      await file.writeAsBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Saved to $path'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              try {
                await OpenFile.open(path);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening file: $e'), backgroundColor: Colors.red));
              }
            },
          ),
        ),
      );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing/downloading: $e'), backgroundColor: Colors.red));
    }
  }
}
