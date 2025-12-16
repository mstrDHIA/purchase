// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class PurchaseOrderDataSource extends DataTableSource {
//   final List<Map<String, dynamic>> _data;
//   final DateFormat _dateFormat;
//   final Function(Map<String, dynamic>) onView;
//   final Function(Map<String, dynamic>) onEdit;
//   final Function(Map<String, dynamic>) onDelete;
//   final Function(Map<String, dynamic>) onArchive;

//   PurchaseOrderDataSource(
//     this._data,
//     this._dateFormat, {
//     required this.onView,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onArchive,
//   });

//   @override
//   DataRow? getRow(int index) {
//     if (index >= _data.length) return null;
//     final item = _data[index];
//     String formatDateCell(dynamic value) {
//       if (value == null) return '-';
//       DateTime? dt;
//       if (value is DateTime) {
//         dt = value;
//       } else if (value is String) {
//         try {
//           dt = DateTime.parse(value);
//         } catch (_) {
//           return value;
//         }
//       }
//       return dt != null ? _dateFormat.format(dt) : '-';
//     }
//     return DataRow(
//       cells: [
//         DataCell(Text(item['id'] ?? '-')),
//         DataCell(Text(item['actionCreatedBy'] ?? '-')),
//         DataCell(Text(formatDateCell(item['dateSubmitted']))),
//         DataCell(Text(formatDateCell(item['dueDate']))),
//         DataCell(_buildPriorityChip(item['priority'] ?? '-')),
//         DataCell(_buildStatusChip(item['statuss'] ?? '-')),
//         DataCell(Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.remove_red_eye_outlined),
//               onPressed: () => onView(item),
//               tooltip: 'View',
//             ),
//             IconButton(
//               icon: const Icon(Icons.edit_outlined),
//               onPressed: () => onEdit(item),
//               tooltip: 'Edit',
//             ),
//             IconButton(
//               icon: const Icon(Icons.archive_outlined),
//               onPressed: () => onArchive(item),
//               tooltip: 'Archive',
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete_outline),
//               onPressed: () => onDelete(item),
//               tooltip: 'Delete',
//             ),
//           ],
//         )),
//       ],
//     );
//   }

//   Widget _buildPriorityChip(String priority) {
//     final v = priority.toLowerCase();
//     Color bgColor;
//     if (v == 'low') {
//       bgColor = const Color(0xFF64B5F6); // blue
//     } else if (v == 'medium') {
//       bgColor = const Color(0xFFFFB74D); // orange
//     } else if (v == 'high') {
//       bgColor = const Color(0xFFE57373); // red
//     } else {
//       bgColor = Colors.grey;
//     }
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: 80,
//         constraints: const BoxConstraints(minWidth: 36),
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(6),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           v,
//           textAlign: TextAlign.center,
//           style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusChip(String status) {
//     final v = status.toLowerCase();
//     Color bgColor;
//     if (v == 'approved') {
//       bgColor = const Color(0xFF4CAF50); // green
//     } else if (v == 'pending') {
//       bgColor = const Color(0xFFFFB74D); // orange
//     } else if (v == 'rejected') {
//       bgColor = const Color(0xFFEF5350); // red
//     } else {
//       bgColor = Colors.grey;
//     }
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Container(
//         width: 80,
//         constraints: const BoxConstraints(minWidth: 0),
//         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(6),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           v,
//           textAlign: TextAlign.center,
//           style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
//         ),
//       ),
//     );
//   }

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get rowCount => _data.length;

//   @override
//   int get selectedRowCount => 0;
// }