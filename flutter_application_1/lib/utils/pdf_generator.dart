// ignore_for_file: unused_local_variable
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/l10n/app_localizations.dart';
import '../models/purchase_order.dart';
import '../network/supplier_network.dart';
import '../network/purchase_request_network.dart';
import '../network/user_network.dart';
import '../models/purchase_request.dart';

class PdfGenerator {
  
  static Future<Uint8List> generatePurchaseOrderPdf(
    PurchaseOrder order, {
    AppLocalizations? l10n,
    String? requesterUsername,
    String? approverUsername,
    DateTime? prApprovalDate,
    String? creatorUsername,
    DateTime? creatorDate,
    String? accountantUsername,
    DateTime? accountantApprovalDate,
    Map<int, String>? userIdToUsername,
  }) async {
    String? serviceAchatUsername;
    try {
      print('[PDF DEBUG] order.approvedBy: [33m${order.approvedBy}[0m');
      print('[PDF DEBUG] userIdToUsername: [36m${userIdToUsername}[0m');
      if (order.approvedBy != null && userIdToUsername != null) {
        final id = order.approvedBy is int
            ? order.approvedBy as int
            : int.tryParse(order.approvedBy.toString());
        print('[PDF DEBUG] Service Achat lookup id: [35m$id[0m');
        if (id != null) {
          serviceAchatUsername = userIdToUsername[id];
          print('[PDF DEBUG] Service Achat username from map: [32m$serviceAchatUsername[0m');
        }
      }
      // fallback to showing the ID as string if username not found
      serviceAchatUsername ??= order.approvedBy?.toString();
      print('[PDF DEBUG] Final serviceAchatUsername: [31m$serviceAchatUsername[0m');
    } catch (e) {
      print('[PDF DEBUG] Exception in serviceAchatUsername lookup: $e');
      serviceAchatUsername = null;
    }
    // If username not resolved from map or id, attempt to fetch user details from API
    try {
      if ((serviceAchatUsername == null || serviceAchatUsername.trim().isEmpty) && order.approvedBy != null) {
        final _id = order.approvedBy is int ? order.approvedBy as int : int.tryParse(order.approvedBy.toString());
        print('[PDF DEBUG] Post-check: approvedBy raw value="${order.approvedBy}", parsed id="$_id"');
        if (_id != null) {
          try {
            print('[PDF DEBUG] Attempting API fetch for approvedBy id: $_id');
            final fetchedUser = await UserNetwork().viewUser(_id);
            print('[PDF DEBUG] API fetch returned user: ${fetchedUser != null ? (fetchedUser.username ?? fetchedUser.id?.toString()) : 'null'}');
            if (fetchedUser != null) {
              final fullName = ((fetchedUser.firstName ?? '') + ' ' + (fetchedUser.lastName ?? '')).trim();
              if (fullName.isNotEmpty && (fetchedUser.username ?? '').isNotEmpty) {
                serviceAchatUsername = '$fullName (${fetchedUser.username})';
              } else if ((fetchedUser.username ?? '').isNotEmpty) {
                serviceAchatUsername = fetchedUser.username;
              } else {
                serviceAchatUsername = fetchedUser.id?.toString();
              }
              print('[PDF DEBUG] Service Achat username fetched from API (post-check): $serviceAchatUsername');
            }
          } catch (e) {
            print('[PDF DEBUG] Error fetching Service Achat user (post-check): $e');
          }
        }
      }
    } catch (e) {
      // ignore
    }

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

    // Try to fetch supplier details dynamically (address & code) when supplier id is available in products
    String supplierName = '-';
    String supplierAddress = '';
    String supplierCode = '';
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
              supplierCode = (supData['code_fournisseur'] ?? supData['code'] ?? supData['codeFournisseur'])?.toString() ?? supplierCode;
            }
          }
        } else {
          // If product is not typed, try to read 'supplier' key generically
          try {
            final sup = (p as Map)['supplier'];
            if (sup is Map) {
              supplierName = sup['name']?.toString() ?? supplierName;
              supplierAddress = sup['address']?.toString() ?? '';
              supplierCode = (sup['code_fournisseur'] ?? sup['code'] ?? sup['codeFournisseur'])?.toString() ?? supplierCode;
            }
          } catch (_) {}
        }
      }
    } catch (_) {
      // ignore supplier fetch errors
    }

    // Fallback: if we couldn't resolve address/code from supplierId or inline map, try matching by supplier name
    try {
      if (supplierAddress.isEmpty || supplierCode.isEmpty) {
        if (order.products != null && order.products!.isNotEmpty) {
          final p = order.products![0];
          String candidateName = '';
          if (p is Products) {
            candidateName = p.supplier ?? '';
          } else if (p is Map) {
            candidateName = (p['supplier'] is Map) ? (p['supplier']['name']?.toString() ?? '') : (p['supplier']?.toString() ?? '');
          }
          if (candidateName.trim().isNotEmpty) {
            try {
              final allSuppliers = await SupplierNetwork().fetchSuppliers();
              for (final s in allSuppliers) {
                try {
                  final name = s is Map ? (s['name']?.toString() ?? '') : s.toString();
                  final lname = name.toLowerCase();
                  final lcandidate = candidateName.toLowerCase();
                  if (lname == lcandidate || lname.contains(lcandidate) || lcandidate.contains(lname)) {
                    supplierAddress = (s['address'] ?? supplierAddress)?.toString() ?? supplierAddress;
                    supplierCode = (s['code_fournisseur'] ?? s['code'] ?? s['codeFournisseur'] ?? supplierCode)?.toString() ?? supplierCode;
                    print('[PDF DEBUG] Fallback matched supplier: name=$name, address=$supplierAddress, code=$supplierCode');
                    break;
                  }
                } catch (_) {}
              }
            } catch (e) {
              print('[PDF DEBUG] Error during fallback supplier list fetch: $e');
            }
          }
        }
      }
    } catch (e) {
      print('[PDF DEBUG] Exception in supplier fallback lookup: $e');
    }

    // Effective values: prefer values passed by the caller. Only attempt to fetch the originating Purchase Request
    // when both `requesterUsername` and `approverUsername` are NOT provided (to avoid overwriting caller-provided names).
    String? prRequesterUsername;
    String? prApproverUsername;
    DateTime? fetchedPrApprovalDate;
    // If the PO is linked to a Purchase Request, always try to fetch it and prefer its requester/approver
    // so the generated PO PDF matches the PR PDF.
    try {
      print('[PDF DEBUG] order.purchaseRequestId: [33m${order.purchaseRequestId}[0m');
      if (order.purchaseRequestId != null) {
        final prId = order.purchaseRequestId!;
        print('[PDF DEBUG] Attempting to fetch PR with id: [36m$prId[0m');
        try {
          final resp = await PurchaseRequestNetwork().fetchPurchaseRequestById(prId);
          print('[PDF DEBUG] PR fetch response: statusCode=${resp.statusCode}');
          print('[PDF DEBUG] PR fetch data: ${resp.data}');
          if (resp.statusCode == 200 && resp.data != null) {
            final pr = PurchaseRequest.fromJson(resp.data);
            print('[PDF DEBUG] PR parsed: requestedByUsername="${pr.requestedByUsername}" approvedByUsername="${pr.approvedByUsername}" requestedByName="${pr.requestedByName}" approvedByName="${pr.approvedByName}"');
            // Prefer explicit username fields from PR when available
            if (pr.requestedByUsername != null && pr.requestedByUsername!.isNotEmpty) {
              prRequesterUsername = pr.requestedByUsername;
            } else if (pr.requestedByName != null && pr.requestedByName!.isNotEmpty) {
              prRequesterUsername = pr.requestedByName;
            }

            if (pr.approvedByUsername != null && pr.approvedByUsername!.isNotEmpty) {
              prApproverUsername = pr.approvedByUsername;
            } else if (pr.approvedByName != null && pr.approvedByName!.isNotEmpty) {
              prApproverUsername = pr.approvedByName;
            
            }
            

            fetchedPrApprovalDate = pr.updatedAt;
            print('Fetched PR #$prId: requester=$prRequesterUsername, approver=$prApproverUsername');
          }
        } catch (_) {
          // ignore fetch errors
        }
      } else {
        print('[PDF DEBUG] No purchaseRequestId, skipping PR fetch.');
      }
    } catch (_) {}

    final effectiveRequesterUsername = prRequesterUsername ?? requesterUsername;
    final effectiveApproverUsername = prApproverUsername ?? approverUsername;
    final effectivePrApprovalDate = prApprovalDate ?? fetchedPrApprovalDate;

    final totalAmount = (order.products ?? []).fold<double>(0.0, (sum, p) => sum + ((p.unitPrice ?? 0.0) * (p.quantity ?? 0)));

    // Precompute product rows (including supplier code) by fetching supplier info when needed
    final List<List<String>> productRows = [];
    final productsList = order.products ?? <dynamic>[];
    final Map<int, String> supplierCodeCache = {};
    for (final p in productsList) {
      String code = '';
      String nosRef = '';
      String designation = '-';
      String unitStr = '';
      int qty = 0;
      double unitPrice = 0.0;

      if (p is Products) {
        nosRef = p.family?.toString() ?? '';
        designation = p.product?.toString() ?? '-';
        qty = p.quantity ?? 0;
        unitPrice = p.unitPrice ?? 0.0;
        unitStr = '';

        if (p.supplierId != null) {
          final sid = p.supplierId!;
          if (supplierCodeCache.containsKey(sid)) {
            code = supplierCodeCache[sid]!;
          } else {
            try {
              final supData = await SupplierNetwork().fetchSupplierById(sid);
              if (supData != null) {
                final c = (supData['code_fournisseur'] ?? supData['code'] ?? supData['codeFournisseur'])?.toString() ?? '';
                if (c.isNotEmpty) {
                  supplierCodeCache[sid] = c;
                  code = c;
                }
              }
            } catch (_) {}
          }
        }
      } else if (p is Map) {
        nosRef = (p['family'] ?? '').toString();
        designation = (p['product'] ?? '-').toString();
        qty = (p['quantity'] ?? 0) is int ? (p['quantity'] as int) : int.tryParse((p['quantity'] ?? '0').toString()) ?? 0;
        unitPrice = double.tryParse((p['unit_price'] ?? p['price'] ?? 0).toString()) ?? 0.0;
        unitStr = '';

        try {
          if (p['supplier'] is Map) {
            final sup = p['supplier'] as Map;
            code = (sup['code_fournisseur'] ?? sup['code'] ?? sup['codeFournisseur'] ?? '')?.toString() ?? '';
            if (code.isEmpty && (sup['id'] != null)) {
              final sid = sup['id'] is int ? sup['id'] as int : int.tryParse(sup['id'].toString());
              if (sid != null) {
                if (supplierCodeCache.containsKey(sid)) {
                  code = supplierCodeCache[sid]!;
                } else {
                  try {
                    final supData = await SupplierNetwork().fetchSupplierById(sid);
                    if (supData != null) {
                      final c = (supData['code_fournisseur'] ?? supData['code'] ?? supData['codeFournisseur'])?.toString() ?? '';
                      if (c.isNotEmpty) {
                        supplierCodeCache[sid] = c;
                        code = c;
                      }
                    }
                  } catch (_) {}
                }
              }
            }
          } else if (p['supplier_id'] != null) {
            final sid = p['supplier_id'] is int ? p['supplier_id'] as int : int.tryParse(p['supplier_id'].toString());
            if (sid != null) {
              if (supplierCodeCache.containsKey(sid)) {
                code = supplierCodeCache[sid]!;
              } else {
                try {
                  final supData = await SupplierNetwork().fetchSupplierById(sid);
                  if (supData != null) {
                    final c = (supData['code_fournisseur'] ?? supData['code'] ?? supData['codeFournisseur'])?.toString() ?? '';
                    if (c.isNotEmpty) {
                      supplierCodeCache[sid] = c;
                      code = c;
                    }
                  }
                } catch (_) {}
              }
            }
          }
        } catch (_) {}
      } else {
        try {
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

      if (code.isNotEmpty) print('[PDF DEBUG] Product supplier code for product "${designation}": $code');
      productRows.add([
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
    final _target = 20;
    while (productRows.length < _target) productRows.add(['', '', '', '', '', '', '']);

    print('[PDF DEBUG] (TABLE) serviceAchatUsername used: $serviceAchatUsername');
    print('[PDF DEBUG] PO.requesterUsername: '
        '"${requesterUsername}" PO.approverUsername: "${approverUsername}"');
    print('[PDF DEBUG] PR prRequesterUsername: "${prRequesterUsername}" prApproverUsername: "${prApproverUsername}"');
    print('[PDF DEBUG] effectiveRequesterUsername: "${effectiveRequesterUsername}" effectiveApproverUsername: "${effectiveApproverUsername}"');

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
                          pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text(supplierCode.isNotEmpty ? supplierCode : '-', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
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
          // Build product rows (up to 20) and fetch supplier code per supplierId when available
          // This precomputes rows asynchronously to allow supplier API lookups.
          pw.Table.fromTextArray(
            headers: ['Code Fourniss', 'Nos.Réf', 'Désignation', 'Unité', 'Quantité', 'Prix', 'Total'],
            data: productRows,
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
                  // Emetteur: prefer PR requester username when available
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(displayUser(name: null, username: effectiveRequesterUsername, fallbackId: null), style: pw.TextStyle(fontSize: 9))),
                  // Resp. Technique: prefer PR approver username when available
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(displayUser(name: null, username: effectiveApproverUsername, fallbackId: null), style: pw.TextStyle(fontSize: 9))),
                  // Directeur Production -> intentionally left blank per request
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('-', style: pw.TextStyle(fontSize: 9))),
                  // Administration -> user who created the PO (supervisor) — only show username when available
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(displayUser(name: null, username: creatorUsername, fallbackId: null) , style: pw.TextStyle(fontSize: 9))),
                  // Service Achat -> always show username for approved_by_user
                  pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.Text(
                      displayUser(
                        name: null,
                        username: serviceAchatUsername,
                        fallbackId: order.approvedBy != null ? order.approvedBy.toString() : '-',
                      ),
                      style: pw.TextStyle(fontSize: 9),
                      
                    ),
                  ),
                ],
              ),

              // Date row
              pw.TableRow(
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(6), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
                  // Emetteur date (PO creation date)
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(formatDate(order.createdAt), style: pw.TextStyle(fontSize: 9))),
                  // PR approval date (Resp. Technique)
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(effectivePrApprovalDate != null ? formatDate(effectivePrApprovalDate) : '-', style: pw.TextStyle(fontSize: 9))),
                  // Directeur Production date intentionally left blank per request
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text('-', style: pw.TextStyle(fontSize: 9))),
                  // Administration date (PO creation date or provided creatorDate)
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(creatorDate != null ? formatDate(creatorDate) : formatDate(order.createdAt), style: pw.TextStyle(fontSize: 9))),
                  // Service Achat approval date
                  pw.Padding(padding: pw.EdgeInsets.all(10), child: pw.Text(accountantApprovalDate != null ? formatDate(accountantApprovalDate) : '-', style: pw.TextStyle(fontSize: 9))),
                ],
              ),
            ],
          ),

        ],
      ),
    );
print('[PDF DEBUG] (TABLE) serviceAchatUsername used: $serviceAchatUsername');
    return pdf.save();
    
  }

}
