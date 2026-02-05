import 'package:flutter/material.dart';

class DetailsTable extends StatelessWidget {
  final Map<String, double> supplierSpend;
  final Map<String, int> supplierPoCount;

  const DetailsTable({super.key, required this.supplierSpend, required this.supplierPoCount});

  @override
  Widget build(BuildContext context) {
    final entries = supplierSpend.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Supplier')),
              DataColumn(label: Text('PO Count')),
              DataColumn(label: Text('Spend')),
            ],
            rows: entries.map((e) => DataRow(cells: [
              DataCell(Text(e.key)),
              DataCell(Text('${supplierPoCount[e.key] ?? 0}')),
              DataCell(Text('\$${e.value.toStringAsFixed(2)}')),
            ])).toList(),
          ),
        ),
      ),
    );
  }
}
