import 'package:flutter/material.dart';

class TopSuppliersList extends StatelessWidget {
  final Map<String, double> supplierSpend;
  const TopSuppliersList({super.key, required this.supplierSpend});

  @override
  Widget build(BuildContext context) {
    final sorted = supplierSpend.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Card(
      elevation: 1,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: sorted.length,
          itemBuilder: (context, idx) {
            final e = sorted[idx];
            return ListTile(
              dense: true,
              title: Text(e.key),
              trailing: Text('\$${e.value.toStringAsFixed(2)}'),
            );
          },
        ),
      ),
    );
  }
}
