import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FiltersCard extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<String> supplierOptions;
  final String selectedSupplier;
  final VoidCallback onSelectStart;
  final VoidCallback onSelectEnd;
  final ValueChanged<String?> onSupplierChanged;
  final VoidCallback onApply;
  final VoidCallback onExport;

  const FiltersCard({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.supplierOptions,
    required this.selectedSupplier,
    required this.onSelectStart,
    required this.onSelectEnd,
    required this.onSupplierChanged,
    required this.onApply,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 700;
          return wide
              ? Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onSelectStart,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Start Date', filled: true),
                          child: Text(DateFormat('dd-MM-yyyy').format(startDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: onSelectEnd,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'End Date', filled: true),
                          child: Text(DateFormat('dd-MM-yyyy').format(endDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSupplier,
                        items: supplierOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: onSupplierChanged,
                        decoration: const InputDecoration(labelText: 'Supplier', filled: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(onPressed: onApply, icon: const Icon(Icons.refresh), label: const Text('Apply')),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(onPressed: onExport, icon: const Icon(Icons.download_outlined), label: const Text('Export')),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(
                        child: InkWell(
                          onTap: onSelectStart,
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Start Date', filled: true),
                            child: Text(DateFormat('dd-MM-yyyy').format(startDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: onSelectEnd,
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'End Date', filled: true),
                            child: Text(DateFormat('dd-MM-yyyy').format(endDate)),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedSupplier,
                      items: supplierOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: onSupplierChanged,
                      decoration: const InputDecoration(labelText: 'Supplier', filled: true),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: ElevatedButton.icon(onPressed: onApply, icon: const Icon(Icons.refresh), label: const Text('Apply'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(onPressed: onExport, icon: const Icon(Icons.download_outlined), label: const Text('Export'))),
                    ])
                  ],
                );
        }),
      ),
    );
  }
}
