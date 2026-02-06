import 'package:flutter/material.dart';

// Deprecated summary card (replaced by new stats screen UI). Kept as a no-op
// to avoid breaking imports elsewhere.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, this.title = '', this.value = ''});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
