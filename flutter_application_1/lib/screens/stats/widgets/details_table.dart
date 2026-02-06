import 'package:flutter/widgets.dart';

// Deprecated: replaced by new stats implementation. Stub kept to avoid breaking imports.
class DetailsTable extends StatelessWidget {
  const DetailsTable({super.key, this.supplierSpend = const {}, this.supplierPoCount = const {}});

  final Map<String, double> supplierSpend;
  final Map<String, int> supplierPoCount;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
