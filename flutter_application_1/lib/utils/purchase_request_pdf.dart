// Purchase Request PDF generator
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:flutter_application_1/l10n/app_localizations.dart';
import '../models/purchase_request.dart';

class PurchaseRequestPdf {
  static Future<Uint8List> generatePurchaseRequestPdf(PurchaseRequest req, {AppLocalizations? l10n, String? requesterUsername, String? approverUsername}) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy');
    String formatDate(DateTime? dt) => dt != null ? dateFormat.format(dt) : '-';

    // Helper to display users as "Full Name (username)" when available
    String displayUser({String? name, String? username, String? fallbackId}) {
      final n = (name ?? '').trim();
      final u = (username ?? '').trim();
      if (n.isNotEmpty && u.isNotEmpty) return '$n ($u)';
      if (u.isNotEmpty) return u;
      if (n.isNotEmpty) return n;
      return fallbackId ?? '-';
    }


    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          pw.Container(
            height: 84,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.black, width: 1))),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('MARTEK', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.SizedBox(height: 2),
                        pw.Text('7050 MENZEL BOURGUIBA', style: pw.TextStyle(fontSize: 9)),
                        pw.Text('M.F 1328212/J', style: pw.TextStyle(fontSize: 9)),
                        pw.Text('SMA', style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('MODULE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                        pw.SizedBox(height: 4),
                        pw.Text('DEMANDE D\'ACHAT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('N° ${req.id?.toString() ?? '-'}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColors.black, width: 1))),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('FOURNISSEUR :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        // pw.SizedBox(height: 4),
                        // pw.Text(req.products != null && req.products!.isNotEmpty ? (req.products![0].supplier ?? '-') : '-', style: pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 15),
                        pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('Date : ${formatDate(req.dueDate)}', style: pw.TextStyle(fontSize: 9))),
                        pw.SizedBox(height: 15),
                        pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('page : 1/1', style: pw.TextStyle(fontSize: 9))),
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          // pw.Divider(),
          pw.SizedBox(height: 12),

          // Basic info
          // pw.Row(
          //   children: [
          //     pw.Expanded(
          //       child: pw.Column(
          //         crossAxisAlignment: pw.CrossAxisAlignment.start,
          //         children: [
          //           pw.Text('Requested by', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //           pw.SizedBox(height: 4),
          //           pw.Text(req.requestedByName ?? (req.requestedBy?.toString() ?? '-')),
          //         ],
          //       ),
          //     ),
          //     pw.SizedBox(width: 12),
          //     pw.Expanded(
          //       child: pw.Column(
          //         crossAxisAlignment: pw.CrossAxisAlignment.start,
          //         children: [
          //           pw.Text('Start Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //           pw.SizedBox(height: 4),
          //           pw.Text(formatDate(req.startDate)),
          //         ],
          //       ),
          //     ),
          //     pw.SizedBox(width: 12),
          //     pw.Expanded(
          //       child: pw.Column(
          //         crossAxisAlignment: pw.CrossAxisAlignment.start,
          //         children: [
          //           pw.Text('End Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //           pw.SizedBox(height: 4),
          //           pw.Text(formatDate(req.endDate)),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),

          pw.SizedBox(height: 18),

          pw.Text('Products', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (req.products != null && req.products!.isNotEmpty)
            pw.Table.fromTextArray(
              headers: ['Product', 'Family', 'Subfamily', 'Qty'],
              data: req.products!.map((p) {
                final qty = p.quantity.toString();
                return [p.product ?? '-', p.family?.toString() ?? '-', p.subFamily?.toString() ?? '-', qty];
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
                    pw.Text(req.description ?? '-'),
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
                    pw.Text(req.status ?? '-'),
                    pw.SizedBox(height: 6),
                    pw.Text(l10n != null ? l10n.priorityLabel(req.priority ?? '-') : 'Priority: ${req.priority ?? '-'}'),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Total qty: ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 6),
              pw.Text((req.products ?? []).fold<int>(0, (sum, p) => sum + p.quantity).toString(), style: pw.TextStyle(fontSize: 12)),
            ],
          ),

          pw.SizedBox(height: 20),

          // Sign-off / approval table (left label column)
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            children: [
              // Header row: empty label cell + role titles
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
                  // Emetteur: use requesterUsername only when provided (no substitution); otherwise show '-'
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(displayUser(name: null, username: requesterUsername, fallbackId: null), style: pw.TextStyle(fontSize: 9))),
                  // Resp. Technique: use approverUsername only when provided (no substitution); otherwise show '-'
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(displayUser(name: null, username: approverUsername, fallbackId: null), style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                ],
              ),

              // Date row
              pw.TableRow(
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(formatDate(req.createdAt), style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(req.updatedAt != null ? formatDate(req.updatedAt) : '', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('', style: pw.TextStyle(fontSize: 9))),
                ],
              ),

              // Visé / Signature row (empty boxes for signatures)
              // pw.TableRow(
              //   children: [
              //     pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Visé', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
              //     pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Container(height: 36)),
              //     pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Container(height: 36)),
              //     pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Container(height: 36)),
              //     pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Container(height: 36)),
              //     pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Container(height: 36)),
              //   ],
              // ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
