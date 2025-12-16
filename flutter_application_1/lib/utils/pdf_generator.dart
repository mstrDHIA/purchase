import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/purchase_order.dart';

class PdfGenerator {
  static Future<Uint8List> generatePurchaseOrderPdf(PurchaseOrder order) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy');

    String formatDate(DateTime? dt) => dt != null ? dateFormat.format(dt) : '-';

    // Try to load a logo from assets/images/logo.png (optional)
    Uint8List? logoBytes;
    try {
      final data = await rootBundle.load('assets/images/logo.png');
      logoBytes = data.buffer.asUint8List();
    } catch (_) {
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
              if (logoBytes != null)
                pw.Container(width: 80, height: 80, child: pw.Image(pw.MemoryImage(logoBytes)))
              else
                pw.SizedBox.shrink(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Purchase Order', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text('ID: ${order.id ?? '-'}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Created: ${formatDate(order.createdAt)}'),
                  pw.Text('Updated: ${formatDate(order.updatedAt)}'),
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
                    pw.Text('Supplier', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                    pw.Text('Due Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                    pw.Text('Supplier Delivery Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(formatDate(order.supplierDeliveryDate)),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 18),

          // Products table

          //HEDHI MTA3 PRODUCTS

          // pw.Text('Products', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          // pw.SizedBox(height: 8),
          // if (order.products != null && order.products!.isNotEmpty)
          //   pw.Table.fromTextArray(
          //     headers: ['Product', 'Family', 'Subfamily', 'Qty', 'Unit Price', 'Total'],
          //     data: order.products!.map((p) {
          //       final unit = p.unitPrice?.toStringAsFixed(2) ?? '0.00';
          //       final qty = (p.quantity ?? 0).toString();
          //       final total = ((p.unitPrice ?? 0.0) * (p.quantity ?? 0)).toStringAsFixed(2);
          //       return [p.product ?? '-', p.family?.toString() ?? '-', p.subFamily?.toString() ?? '-', qty, unit, total];
          //     }).toList(),
          //     headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          //     cellAlignment: pw.Alignment.centerLeft,
          //     cellStyle: const pw.TextStyle(fontSize: 10),
          //   )
          // else
          //   pw.Text('-'),

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
                    pw.Text('Note', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                    pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text(order.status ?? '-'),
                    pw.SizedBox(height: 6),
                    pw.Text('Priority: ${order.priority ?? '-'}'),
                  ],
                ),
              ),
            ],
          ),


          //HEDHI MTA3 REFUSE REASON
          // if ((order.refuseReason ?? '').isNotEmpty) pw.SizedBox(height: 12),
          // if ((order.refuseReason ?? '').isNotEmpty)
          //   pw.Column(
          //     crossAxisAlignment: pw.CrossAxisAlignment.start,
          //     children: [
          //       pw.Text('Refuse Reason', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //       pw.SizedBox(height: 6),
          //       pw.Text(order.refuseReason ?? '-'),
          //     ],
          //   ),


          pw.SizedBox(height: 12),
          //HEDHI MTA3 TOTAL
          // pw.Divider(),
          // pw.SizedBox(height: 6),
          // pw.Row(
          //   mainAxisAlignment: pw.MainAxisAlignment.end,
          //   children: [
          //     pw.Text('Total: ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          //     pw.SizedBox(width: 6),
          //     pw.Text(totalAmount.toStringAsFixed(2), style: pw.TextStyle(fontSize: 12)),
          //   ],
          // ),
        ],
      ),
    );

    return pdf.save();
  }
}
