import 'package:flutter/material.dart';

class TopProductsBySupplier extends StatelessWidget {
  final Map<String, Map<String, int>> supplierProductCounts;
  final String selectedSupplier; // 'All' means show all suppliers collapsed
  final int topN;

  const TopProductsBySupplier({super.key, required this.supplierProductCounts, required this.selectedSupplier, this.topN = 5});

  List<MapEntry<String, int>> _topFor(Map<String, int> m) {
    final list = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return list.take(topN).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (supplierProductCounts.isEmpty) {
      return Card(elevation: 1, child: Container(height: 160, padding: const EdgeInsets.all(12), child: const Center(child: Text('No product data'))));
    }

    if (selectedSupplier != 'All' && supplierProductCounts.containsKey(selectedSupplier)) {
      final top = _topFor(supplierProductCounts[selectedSupplier]!);
      return Card(
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Top products — $selectedSupplier', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...top.map((e) => ListTile(dense: true, title: Text(e.key), trailing: Text('${e.value}'))),
            ],
          ),
        ),
      );
    }

    // Show an ExpansionTile per supplier with top products
    final suppliers = supplierProductCounts.keys.toList()..sort();
    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: suppliers.map((s) {
            final top = _topFor(supplierProductCounts[s]!);
            return ExpansionTile(
              title: Text(s),
              children: top.map((e) => ListTile(dense: true, title: Text(e.key), trailing: Text('${e.value}'))).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
