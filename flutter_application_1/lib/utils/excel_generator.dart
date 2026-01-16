import 'package:excel/excel.dart';
import 'package:flutter/widgets.dart' hide Border, BorderStyle;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/models/purchase_order.dart';
import 'package:flutter_application_1/network/supplier_network.dart';

class ExcelGenerator {
  static Future<List<int>?> generatePurchaseOrderExcel(
    PurchaseOrder order, {
    String? requesterUsername,
    String? approverUsername,
    DateTime? prApprovalDate,
    String? creatorUsername,
    DateTime? creatorDate,
    String? accountantUsername,
    DateTime? accountantApprovalDate,
    Map<int, String>? userIdToUsername,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Offset to start the whole structure at column B and row 2 (A1 -> B2)
    final int _colOffset = 1; // move everything one column to the right (A->B)
    final int _rowOffset = 1; // move everything one row down (1->2)
    CellIndex _ci(int col, int row) =>
      CellIndex.indexByColumnRow(columnIndex: col + _colOffset, rowIndex: row + _rowOffset);
    // shorthand to access a cell with offsets applied
    dynamic _sc(int col, int row) => sheet.cell(_ci(col, row));

    // Set reasonable column widths so long texts (addresses, désignation) don't get cut.
    // Width units depend on the package implementation; adjust if needed.
    // Set equal widths for the approval-related columns (A..F) so their boxes look identical.
    // Note: this affects the whole sheet; Désignation (col C) will be narrower as a result.
    final List<double> colWidths = [15, 15, 15, 15, 15, 15, 15];
    for (int i = 0; i < colWidths.length; i++) {
      try {
        sheet.setColWidth(i, colWidths[i]);
      } catch (_) {}
    }
    
    final dateFormat = DateFormat('dd.MM.yy');
    String formatDate(DateTime? dt) => dt != null ? dateFormat.format(dt) : '';

    // Currency symbol
    String currencySymbol = '\$';
    final currencyRaw = order.currency?.toString();
    if (currencyRaw != null && currencyRaw.isNotEmpty) {
      final code = currencyRaw.toUpperCase();
      final Map<String, String> codeToSymbol = {'USD': '\$', 'EUR': '€', 'TND': 'DT'};
      if (codeToSymbol.containsKey(code)) {
        currencySymbol = codeToSymbol[code]!;
      }
    }

    int row = 0;

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
                    break;
                  }
                } catch (_) {}
              }
            } catch (e) {
              // ignore
            }
          }
        }
      }
    } catch (_) {
      // ignore fallback errors
    }

    // ===== LOGO / COMPANY NAME: MARTEK s.a.r.l in RED =====
    // Merge the first row across the main columns so the company name is perfectly centered.
    try {
      sheet.merge(_ci(0, row), _ci(6, row));
    } catch (_) {}
    _setCellValueColored(sheet, 0, row, 'MARTEK s.a.r.l', fontSize: 14, bold: true, textColor: '#FF0000');
    // Put telephone and fax together on the right side
    row++;

    // Company details
    _setCellValue(sheet, 0, row, 'Production de chaussures de sécurités');
    // Put Fax on the line below Tel to match the capture
    _sc(6, row).value = 'Tel: 72 113 700\nFax: 72 473 32';
    row++;

    _setCellValue(sheet, 0, row, 'Zone industrielle, route de Tunis');
    row++;

    _setCellValue(sheet, 0, row, '7050 Menzel Bourguiba – TUNISIE');
    row++;

    row++; // Empty row

    // Re-add Code fournisseur and Adresse here
    _setCellWithValue(sheet, 0, row, 'Code fournisseur :', bold: true);
    _sc(1, row).value = supplierCode;
    _setCellWithValue(sheet, 3, row, 'Fournisseur :', bold: true);
    _sc(4, row).value = supplierName;
    row++;

    // Date | Adresse
    _setCellWithValue(sheet, 0, row, 'Date :', bold: true);
    _sc(1, row).value = formatDate(order.startDate);
    _sc(2, row).value = '';
    _setCellWithValue(sheet, 3, row, 'Adresse:', bold: true);
    _sc(4, row).value = supplierAddress;
    row++;

    // Demande achat
    _setCellWithValue(sheet, 0, row, 'Demande achat n° :', bold: true);
    _sc(1, row).value = order.id?.toString() ?? '';
    row++;

    row++; // Empty row

    // ===== BON DE COMMANDE TITLE =====
    // Keep original placement: centered at column 2 as before
    final String poNumber = order.id?.toString() ?? '';
    _setCellValue(sheet, 2, row, 'BON DE COMMANDE N° ${poNumber}', fontSize: 12, bold: true);
    row++;

    row++; // Empty row

    // ===== PRODUCTS TABLE =====
    final headers = ['Code fournisseur', 'Nos.Ri', 'Désignation', 'Unité', 'Quantité', 'Prix', 'Total'];
    
    // Header row with background
    for (int col = 0; col < headers.length; col++) {
      final cell = _sc(col, row);
      cell.value = headers[col];
      cell.cellStyle = _borderedCellStyle(bold: true, bgHex: '#D3D3D3');
    }
    row++;

    // ===== PRODUCTS DATA =====
    double totalAmount = 0.0;
    final products = order.products ?? [];
    

    for (var prod in products) {
      final unitPrice = prod.unitPrice ?? 0.0;
      final quantity = prod.quantity ?? 0;
      final totalPrice = unitPrice * quantity;
      totalAmount += totalPrice;

      _sc(0, row).value = supplierCode;
      _sc(1, row).value = prod.family ?? '';
      _sc(2, row).value = prod.product ?? '';
      _sc(3, row).value = prod.unit ?? '';
      _sc(4, row).value = quantity;
      _sc(5, row).value = unitPrice.toStringAsFixed(2);
      _sc(6, row).value = totalPrice.toStringAsFixed(2);
      // Apply thin black borders to each cell in this product row
      for (int c = 0; c < headers.length; c++) {
        final prodCell = _sc(c, row);
        prodCell.cellStyle = _borderedCellStyle();
      }
      row++;
    }

    // ===== TOTAL ROW (included in products table) =====
    _sc(5, row).value = 'Total $currencySymbol';
    final totalCell = _sc(6, row);
    totalCell.value = totalAmount.toStringAsFixed(2);
    // make total visually part of the table: apply bordered style to all columns of the total row
    for (int c = 0; c < headers.length; c++) {
      final tcell = _sc(c, row);
      tcell.cellStyle = _borderedCellStyle(bold: true);
    }
    row++;

    row++; // Empty row

    // ===== APPROVALS TABLE =====
    // Place approvals table directly after the products/total (original location)
    // keep one empty row then the approval headers/names/dates
    final approvalHeaders = ['Role', 'Emetteur', 'Resp. Technique', 'Directeur Production', 'Administration', 'Service Achat'];
    for (int col = 0; col < approvalHeaders.length; col++) {
      final cell = _sc(col, row);
      cell.value = approvalHeaders[col];
      cell.cellStyle = _borderedCellStyle(bold: true, bgHex: '#D3D3D3');
    }
    // Keep each approval header in its own column so all six columns have equal width.
    row++;

    // Names
    final names = ['Nom', requesterUsername ?? '', approverUsername ?? '', '', creatorUsername ?? '', ''];
    for (int col = 0; col < names.length; col++) {
      final ncell = _sc(col, row);
      ncell.value = names[col];
      ncell.cellStyle = _borderedCellStyle();
    }
    // keep each approval name in its own column (no merge) so column widths remain equal
    row++;

    // Dates
    final dates = ['Date', formatDate(order.createdAt), formatDate(prApprovalDate), '', formatDate(creatorDate ?? order.createdAt), formatDate(accountantApprovalDate)];
    for (int col = 0; col < dates.length; col++) {
      final dcell = _sc(col, row);
      dcell.value = dates[col];
      dcell.cellStyle = _borderedCellStyle();
    }
    // keep each approval date in its own column (no merge) so column widths remain equal
    row++;

    // Add empty rows for table appearance (adjust gap before destination)
    // Reduced from 5 to 3 to match the desired spacing in the capture
    row += 3;

    // ===== DESTINATION =====
    if ((order.description ?? '').isNotEmpty) {
      _setCellValue(sheet, 0, row, 'Note', bold: true);
      row++;
      _setCellValue(sheet, 0, row, order.description ?? '');
      row++;
    }

    // ===== DELIVERY / DESTINATION BLOCK (match capture) =====
    row++; // empty row
    _setCellWithValue(sheet, 0, row, 'Destination', bold: true);
    _setCellValueColored(sheet, 1, row, supplierAddress.isNotEmpty ? supplierAddress : 'Martek Menzel Bourguiba (Zone industrielle)', textColor: '#FF0000');
    row++;
    _setCellWithValue(sheet, 0, row, 'Lieu de livraison', bold: true);
    // If the order has a deliveryPlace field use it, otherwise use a placeholder from the capture
    try {
      final deliveryPlace = (order as dynamic).deliveryPlace ?? 'QUALITE MAGASIN TIGE';
      _sc(1, row).value = deliveryPlace;
    } catch (_) {
      _sc(1, row).value = 'QUALITE MAGASIN TIGE';
    }
    row++;
    _setCellWithValue(sheet, 0, row, 'Délais de livraison :', bold: true);
    row++;
    _setCellWithValue(sheet, 0, row, 'Condition de paiement :', bold: true);
    row++;

    // Instruction lines shown in the capture
    // add extra vertical gap between 'Condition de paiement' and the paragraph
    row += 2;
    try {
      final int instrStart = row;
      sheet.merge(_ci(0, instrStart), _ci(4, instrStart));
      _setCellValue(sheet, 0, instrStart, 'Nous vous prions de bien vouloir nous confirmé la date de livraison par mail ou par fax');
      row++;
      sheet.merge(_ci(0, row), _ci(4, row));
      _setCellValue(sheet, 0, row, 'Veuillez Indiquer le numéro de la commande sur votre facture');
      row++;
      sheet.merge(_ci(0, row), _ci(4, row));
      _setCellValue(sheet, 0, row, 'Veuillez respecter la destination indiquée sur le bon de commande');
      row++;
    } catch (_) {}

    // Place 'Service Achat' to the right as in the capture
    row += 2; // small vertical gap
    _setCellValue(sheet, 6, row, 'Service Achat', bold: true);
    row += 2;

    const SizedBox(width: 20);

    // Footer grey bar with company/legal/bank info (split across three segments)
    try {
      final int footerRow = row + 6; // push footer to bottom after destination block and spacing
      // Left segment (cols 0..2) - two lines
      sheet.merge(_ci(0, footerRow), _ci(2, footerRow));
      _sc(0, footerRow).cellStyle = CellStyle(backgroundColorHex: '#D3D3D3', fontSize: 9);
      _sc(0, footerRow).value = 'Capital Social : 19715600 dt';
      // second footer line for left segment
      sheet.merge(_ci(0, footerRow + 1), _ci(2, footerRow + 1));
      _sc(0, footerRow + 1).cellStyle = CellStyle(backgroundColorHex: '#D3D3D3', fontSize: 9);
      _sc(0, footerRow + 1).value = 'Matricule fiscal : 1328212/J';

      // Middle segment (cols 3..4) - two lines
      sheet.merge(_ci(3, footerRow), _ci(4, footerRow));
      _sc(3, footerRow).cellStyle = CellStyle(backgroundColorHex: '#D3D3D3', fontSize: 9);
      _sc(3, footerRow).value = 'Code en douane : 1328212/J';
      sheet.merge(_ci(3, footerRow + 1), _ci(4, footerRow + 1));
      _sc(3, footerRow + 1).cellStyle = CellStyle(backgroundColorHex: '#D3D3D3', fontSize: 9);
      _sc(3, footerRow + 1).value = 'Référence Bancaire : T.I.B Bizerte';

      // Right segment (cols 5..6) - two lines
      sheet.merge(_ci(5, footerRow), _ci(6, footerRow));
      _sc(5, footerRow).cellStyle = CellStyle(backgroundColorHex: '#D3D3D3', fontSize: 9);
      _sc(5, footerRow).value = 'Registre de Commerce : B04239562013';
      sheet.merge(_ci(5, footerRow + 1), _ci(6, footerRow + 1));
      _sc(5, footerRow + 1).cellStyle = CellStyle(backgroundColorHex: '#D3D3D3', fontSize: 9);
      _sc(5, footerRow + 1).value = 'Bénéficiaire de Loi: 93-120 du 27/12/1993';
    } catch (_) {}

    // Encode to bytes
    var bytes = excel.encode();
    
    // Note: Logo injection is disabled due to ZIP conflict issuesfix err
    // You can add the logo manually in Excel if needed
    
    return bytes;
  }

  // Helper to set cell value with formatting
  static void _setCellValue(Sheet sheet, int col, int row, String value, {bool bold = false, int fontSize = 11}) {
    // Helpers are aware of the global offset of +1 column and +1 row to start at B2
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col + 1, rowIndex: row + 1));
    cell.value = value;
    cell.cellStyle = CellStyle(bold: bold, fontSize: fontSize);
  }

  // Helper to set cell with value and text color formatting
  static void _setCellValueColored(Sheet sheet, int col, int row, String value, {bool bold = false, int fontSize = 11, String? textColor}) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col + 1, rowIndex: row + 1));
    cell.value = value;
    if (textColor != null) {
      cell.cellStyle = CellStyle(bold: bold, fontSize: fontSize, fontColorHex: textColor);
    } else {
      cell.cellStyle = CellStyle(bold: bold, fontSize: fontSize);
    }
  }

  // Helper to set cell with value and formatting
  static void _setCellWithValue(Sheet sheet, int col, int row, String value, {bool bold = false}) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col + 1, rowIndex: row + 1));
    cell.value = value;
    if (bold) {
      cell.cellStyle = CellStyle(bold: true);
    }
  }

  // Helper to create a CellStyle with thin black borders (useful for table cells)
  static CellStyle _borderedCellStyle({bool bold = false, String? bgHex}) {
    if (bgHex != null) {
      return CellStyle(
        bold: bold,
        backgroundColorHex: bgHex,
        leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: 'FF000000'),
        rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: 'FF000000'),
        topBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: 'FF000000'),
        bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: 'FF000000'),
      );
    }

    return CellStyle(
      bold: bold,
      leftBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: 'FF000000'),
      rightBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: 'FF000000'),
      topBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: 'FF000000'),
      bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: 'FF000000'),
    );
  }
}
