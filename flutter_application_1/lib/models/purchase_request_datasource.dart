import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:flutter_application_1/screens/Purchase%20Request/purchase_request_view_screen.dart';
import 'package:intl/intl.dart';

class PurchaseRequestDataSource extends DataTableSource {
  final List<PurchaseRequest> _data;
  // ignore: unused_field
  final BuildContext _context;
  // final DateFormat _dateFormat;
  // final Function(Map<String, dynamic>) onView;
  // final Function(Map<String, dynamic>) onEdit;
  // final Function(Map<String, dynamic>) onDelete;

  PurchaseRequestDataSource(
    this._data,
    this._context,
    // this._dateFormat, 
    // {
    // required this.onView,
    // required this.onEdit,
    // required this.onDelete,
  // }
  );

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final item = _data[index];
    return DataRow(
      cells: [
        DataCell(Text(item.id.toString())),
        DataCell(Text(item.requestedBy.toString())),
        DataCell(Text(item.startDate.toString())),
        DataCell(Text(item.endDate.toString())),
        DataCell(Text("High")),
        DataCell(Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: item.status == 'Approved' ? Colors.green : item.status == 'Refused' ? Colors.red:Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Text(
                  item.status ?? 'Pending',
                  style: TextStyle(
                    color: Colors.white
                    // color: item.status == 'Approved' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          ),
        )),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined),
              onPressed: () {
                Navigator.push(
                  _context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseRequestView(
                      purchaseRequest: item, // Passe la ligne sélectionnée ici
                      // onSave: (_) {},
                    ),
                  ),
                );
              },
              tooltip: 'View',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // Navigator.push(
                //   _context,
                //   MaterialPageRoute(
                //     builder: (context) => RequestEditPage(
                //       request: item,
                //       onSave: (_) {},
                //     ),
                //   ),
                // );
              },
              tooltip: 'Edit',
            ),
            // IconButton(
            //   icon: const Icon(Icons.delete_outline),
            //   onPressed: () => onDelete(item), // Fixed typo here
            //   tooltip: 'Delete',
            // ),
          ],
        )),
      ],
    );
  }

  // Widget _buildPriorityChip(String priority) {
  //   Color color;
  //   const textColor = Colors.white;
  //   switch (priority) {
  //     case 'High':
  //       color = Colors.red[300]!;
  //       break;
  //     case 'Medium':
  //       color = Colors.orange[300]!;
  //       break;
  //     case 'Low':
  //       color = Colors.green[300]!;
  //       break;
  //     default:
  //       color = Colors.grey;
  //   }
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: color,
  //       borderRadius: BorderRadius.circular(4),
  //     ),
  //     child: Text(
  //       priority,
  //       style: const TextStyle(color: textColor, fontSize: 12),
  //     ),
  //   );
  // }

  // Widget _buildStatusChip(String status) {
  //   Color color;
  //   Color textColor = Colors.black;
  //   switch (status) {
  //     case 'Pending':
  //       color = Colors.orange[200]!;
  //       break;
  //     case 'Approved':
  //       color = Colors.green[200]!;
  //       break;
  //     case 'Rejected':
  //       color = Colors.red[200]!;
  //       break;
  //     default:
  //       color = Colors.grey[200]!;
  //   }
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: color,
  //       borderRadius: BorderRadius.circular(4),
  //     ),
  //     child: Text(
  //       status,
  //       style: TextStyle(color: textColor, fontSize: 12),
  //     ),
  //   );
  // }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
