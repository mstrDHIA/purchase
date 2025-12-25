// ignore_for_file: unused_local_variable
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/l10n/app_localizations.dart';
import '../models/purchase_order.dart';

class PdfGenerator {
  static Future<Uint8List> generatePurchaseOrderPdf(PurchaseOrder order, {AppLocalizations? l10n}) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy');

    String formatDate(DateTime? dt) => dt != null ? dateFormat.format(dt) : '-';

    // Try to load a logo from assets/images/logo.png (optional)
    Uint8List? logoBytes;

    bool _looksLikeImage(Uint8List b) {
      if (b.lengthInBytes < 4) return false;
      // PNG signature
      if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return true;
      // JPEG signature
      if (b[0] == 0xFF && b[1] == 0xD8) return true;
      // GIF signature
      if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46) return true;
      return false;
    }

    try {
      final data = await rootBundle.load('assets/images/logo.png');
      final bytes = data.buffer.asUint8List();
      // Basic check: skip if it's not a recognized raster image (e.g., svg)
      if (_looksLikeImage(bytes)) {
        logoBytes = bytes;
      } else {
        // Not a supported image type for the PDF widget — ignore the logo
        logoBytes = null;
      }
    } catch (_) {
      // Asset not available or load failed — proceed without logo
      logoBytes = null;
    }

    final totalAmount = (order.products ?? []).fold<double>(0.0, (sum, p) => sum + ((p.unitPrice ?? 0.0) * (p.quantity ?? 0)));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // logo: attempt to safely create memory image — guard against invalid formats
              if (logoBytes != null)
                () {
                  try {
                    final img = pw.MemoryImage(logoBytes!);
                    return pw.Container(width: 80, height: 80, child: pw.Image(img));
                  } catch (_) {
                    // If creating the image fails (unknown format), skip the logo rather than throw
                    return pw.SizedBox.shrink();
                  }
                }()
              else
                pw.SizedBox.shrink(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(l10n?.purchaseOrderTitle ?? 'Purchase Order', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text(l10n != null ? l10n.idLabel((order.id ?? '-').toString()) : 'ID: ${order.id ?? '-'}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(l10n != null ? l10n.createdLabel(formatDate(order.createdAt)) : 'Created: ${formatDate(order.createdAt)}'),
                  pw.Text(l10n != null ? l10n.updatedLabel(formatDate(order.updatedAt)) : 'Updated: ${formatDate(order.updatedAt)}'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 12),

          // Basic info
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(l10n?.supplierLabel ?? 'Supplier', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(order.products != null && order.products!.isNotEmpty ? (order.products![0].supplier ?? '-') : '-'),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(l10n?.dueDate ?? 'Due Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(formatDate(order.endDate)),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(l10n?.supplierDeliveryDate ?? 'Supplier Delivery Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(formatDate(order.supplierDeliveryDate)),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 18),

          // Products table

         

          pw.Text('Products', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (order.products != null && order.products!.isNotEmpty)
            pw.Table.fromTextArray(
              headers: ['Product', 'Family', 'Subfamily', 'Qty', 'Unit Price', 'Total'],
              data: order.products!.map((p) {
                final unit = p.unitPrice?.toStringAsFixed(2) ?? '0.00';
                final qty = (p.quantity ?? 0).toString();
                final total = ((p.unitPrice ?? 0.0) * (p.quantity ?? 0)).toStringAsFixed(2);
                return [p.product ?? '-', p.family?.toString() ?? '-', p.subFamily?.toString() ?? '-', qty, unit, total];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
            )
          else
            pw.Text('-'),

          pw.SizedBox(height: 18),

          // Notes and status
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(l10n?.noteLabel ?? 'Note', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text(order.description ?? '-'),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(l10n?.statusLabel ?? 'Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text(order.status ?? '-'),
                    pw.SizedBox(height: 6),
                    pw.Text(l10n != null ? l10n.priorityLabel(order.priority ?? '-') : 'Priority: ${order.priority ?? '-'}'),
                  ],
                ),
              ),
            ],
          ),


          
          if ((order.refuseReason ?? '').isNotEmpty) pw.SizedBox(height: 12),
          if ((order.refuseReason ?? '').isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Refuse Reason', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text(order.refuseReason ?? '-'),
              ],
            ),


          pw.SizedBox(height: 12),
          //HEDHI MTA3 TOTAL
          pw.Divider(),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Total: ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 6),
              pw.Text(totalAmount.toStringAsFixed(2), style: pw.TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
