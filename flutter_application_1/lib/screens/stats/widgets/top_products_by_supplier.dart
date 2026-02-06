import 'package:flutter/widgets.dart';

// Deprecated: replaced by new stats implementation. Stub kept to avoid breaking imports.
class TopProductsBySupplier extends StatelessWidget {
  const TopProductsBySupplier({super.key, this.supplierProductCounts = const {}, this.selectedSupplier = 'All', this.topN = 5});

  final Map<String, Map<String, int>> supplierProductCounts;
  final String selectedSupplier;
  final int topN;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
