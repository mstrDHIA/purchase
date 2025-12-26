// ignore_for_file: unused_local_variable
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/l10n/app_localizations.dart';
import '../models/purchase_order.dart';
import '../network/supplier_network.dart';


class PdfGenerator {
  static Future<Uint8List> generatePurchaseOrderPdf(PurchaseOrder order, {AppLocalizations? l10n, String? requesterUsername, String? approverUsername}) async {
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
      // Try multiple candidate images from assets/images/ and pick the first valid raster image
      final candidates = [
        'assets/images/logo.png',
        'assets/images/Company.jpg',
        'assets/images/Capture.PNG',
        'assets/images/j.png',
        'assets/images/keyboard.jpeg',
        'assets/images/mouse.png',
      ];
      for (final path in candidates) {
        try {
          final data = await rootBundle.load(path);
          final bytes = data.buffer.asUint8List();
          if (_looksLikeImage(bytes)) {
            logoBytes = bytes;
            break;
          }
        } catch (_) {
          // ignore and try next path
          continue;
        }
      }
    } catch (_) {
      logoBytes = null;
    }

    // Try to fetch supplier details dynamically (address) when supplier id is available in products
    String supplierName = '-';
    String supplierAddress = '';
    try {
      if (order.products != null && order.products!.isNotEmpty) {
        final p = order.products![0];
        if (p is Products) {
          supplierName = p.supplier ?? supplierName;
          if (p.supplierId != null) {
            final supData = await SupplierNetwork().fetchSupplierById(p.supplierId!);
            if (supData != null) {
              supplierAddress = supData['address']?.toString() ?? '';
              supplierName = supData['name']?.toString() ?? supplierName;
            }
          }
        } else {
          // If product is not typed, try to read 'supplier' key generically
          try {
            final sup = (p as Map)['supplier'];
            if (sup is Map) {
              supplierName = sup['name']?.toString() ?? supplierName;
              supplierAddress = sup['address']?.toString() ?? '';
            }
          } catch (_) {}
        }
      }
    } catch (_) {
      // ignore supplier fetch errors
    }

    final totalAmount = (order.products ?? []).fold<double>(0.0, (sum, p) => sum + ((p.unitPrice ?? 0.0) * (p.quantity ?? 0)));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          // New template header: logo + company text (left), supplier/date box (center), supplier contact (right)
          pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
            padding: pw.EdgeInsets.all(4),
            child: pw.Column(
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Left: logo above company lines (compact)
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (logoBytes != null)
                            pw.Container(width: 110, height: 48, child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain))
                          else
                            pw.Container(width: 110, height: 48),
                          pw.SizedBox(height: 4),
                          pw.Text('MARTEK s.a.r.l', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Production de chaussures de sécurité', style: pw.TextStyle(fontSize: 7)),
                          pw.Text('Zone industrielle, route de Tunis', style: pw.TextStyle(fontSize: 7)),
                          pw.Text('7050 Menzel Bourguiba', style: pw.TextStyle(fontSize: 7)),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    // Right: contact (Tel/Fax) compact and aligned right
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Tel : 72 113 700', style: pw.TextStyle(fontSize: 8)),
                          pw.SizedBox(height: 2),
                          pw.Text('Fax : 72 473 32', style: pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                  ],
                ),


              ],
            ),
          ),

          // Red separator and supplier blocks under header
          pw.SizedBox(height: 6),
          pw.Container(height: 3, color: PdfColors.red),
          pw.SizedBox(height: 30),

          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Left boxed block (matching sample shape)
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: pw.EdgeInsets.all(1),
                  child: pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
                    padding: pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    child: pw.Table(
                      columnWidths: {0: pw.FlexColumnWidth(1.3), 1: pw.FlexColumnWidth(1)},
                      children: [
                        pw.TableRow(children: [
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('Code fournisseur :', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('Date :', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text(formatDate(order.supplierDeliveryDate), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('Demande achat n° :', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text((order.purchaseRequestId ?? order.id)?.toString() ?? '-', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),

              pw.SizedBox(width: 8),

              // Right boxed block (matching sample shape)
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: pw.EdgeInsets.all(2),
                  child: pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
                    padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    child: pw.Table(
                      columnWidths: {0: pw.FlexColumnWidth(0.7), 1: pw.FlexColumnWidth(1)},
                      children: [
                        pw.TableRow(children: [
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('Fournisseur :', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text(supplierName, textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('Adresse :', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: supplierAddress.isNotEmpty ? supplierAddress.split('\n').map((l) => pw.Text(l, style: pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right)).toList() : [pw.Text('-', style: pw.TextStyle(fontSize: 9))])),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 6),
          // Title placed under supplier blocks
          pw.Align(alignment: pw.Alignment.center, child: pw.Text('BON DE COMMANDE N° ${order.id ?? '-'}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 6),

          // pw.SizedBox(height: 12),
          // pw.Divider(),
          // pw.SizedBox(height: 12),

          pw.SizedBox(height: 18),

          // Products table in the requested layout
          pw.SizedBox(height: 6),
          pw.Text('DETAIL DES ARTICLES', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 8),
          // Build fixed-size table (20 rows) to match the template
          pw.Table.fromTextArray(
            headers: ['Code Fourniss', 'Nos.Réf', 'Désignation', 'Unité', 'Quantité', 'Prix', 'Total'],
            data: () {
              final rows = <List<String>>[];
              final products = order.products ?? <dynamic>[];
              for (final p in products) {
                String code = '';
                String nosRef = '';
                String designation = '-';
                String unitStr = '';
                int qty = 0;
                double unitPrice = 0.0;

                if (p is Products) {
                  code = '';
                  nosRef = p.family?.toString() ?? '';
                  designation = p.product?.toString() ?? '-';
                  qty = p.quantity ?? 0;
                  unitPrice = p.unitPrice ?? 0.0;
                  unitStr = '';
                } else if (p is Map) {
                  code = '';
                  nosRef = (p['family'] ?? '').toString();
                  designation = (p['product'] ?? '-').toString();
                  qty = (p['quantity'] ?? 0) is int ? (p['quantity'] as int) : int.tryParse((p['quantity'] ?? '0').toString()) ?? 0;
                  unitPrice = double.tryParse((p['unit_price'] ?? p['price'] ?? 0).toString()) ?? 0.0;
                  unitStr = '';
                } else {
                  try {
                    code = '';
                    nosRef = p.family?.toString() ?? '';
                    designation = p.product?.toString() ?? '-';
                    qty = p.quantity ?? 0;
                    unitPrice = p.unitPrice ?? 0.0;
                    unitStr = '';
                  } catch (_) {}
                }

                final unitPriceStr = unitPrice.toStringAsFixed(2);
                final qtyStr = qty.toString();
                final total = (unitPrice * qty).toStringAsFixed(2);

                rows.add([
                  code,
                  nosRef,
                  designation,
                  unitStr,
                  qtyStr,
                  unitPriceStr,
                  total,
                ]);
              }
              // Fill to 20 rows with empty lines for a form-like appearance
              final target = 20;
              while (rows.length < target) rows.add(['', '', '', '', '', '', '']);
              return rows;
            }(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 9),
            columnWidths: {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(1.0),
              2: pw.FlexColumnWidth(3.0),
              3: pw.FlexColumnWidth(0.8),
              4: pw.FlexColumnWidth(0.8),
              5: pw.FlexColumnWidth(1.0),
              6: pw.FlexColumnWidth(1.0),
            },
            cellPadding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            border: pw.TableBorder.symmetric(inside: pw.BorderSide(color: PdfColors.black, width: 0.5), outside: pw.BorderSide(color: PdfColors.black, width: 1)),
          ),

          pw.SizedBox(height: 12),
          // Boxed TOTAL aligned right
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
                padding: pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: pw.Row(
                  children: [
                    pw.Text('Total ${order.currency ?? 'EUR'}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 12),
                    pw.Text(totalAmount.toStringAsFixed(2), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),

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


          pw.SizedBox(height: 20),

          // Sign-off / approval table (left label column) — same as Purchase Request
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Emetteur', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                  pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Resp. Technique', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                  pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Directeur Production', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                  pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Administration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                  pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Service Achat', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                ],
              ),

              // Nom row
              pw.TableRow(
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Nom', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(requesterUsername ?? (order.requestedByUser?.toString() ?? '-'), style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text((order.status?.toLowerCase() == 'approved') ? (approverUsername ?? (order.approvedBy?.toString() ?? '-')) : '-', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                ],
              ),

              // Date row
              pw.TableRow(
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(formatDate(order.createdAt), style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text((order.status?.toLowerCase() == 'approved') ? formatDate(order.updatedAt) : '', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                ],
              ),
            ],
          ),

        ],
      ),
    );

    return pdf.save();
  }

}
