import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SupplierBarChart extends StatefulWidget {
  final Map<String, double> supplierSpend;
  /// How many top suppliers to show (default 6)
  final int topN;
  /// Optional callback when a supplier bar is tapped
  final void Function(String)? onBarTap;

  const SupplierBarChart({super.key, required this.supplierSpend, this.topN = 6, this.onBarTap});

  @override
  State<SupplierBarChart> createState() => _SupplierBarChartState();
}

class _SupplierBarChartState extends State<SupplierBarChart> {
  int? _selectedIdx;

  String _formatYAxis(double value) {
    if (value >= 1000000) {
      final v = value / 1000000;
      return v % 1 == 0 ? '${v.toInt()}M' : '${v.toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      final v = value / 1000;
      return v % 1 == 0 ? '${v.toInt()}K' : '${v.toStringAsFixed(1)}K';
    }
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
  }

  String _formatCurrency(double v) {
    if (v >= 1000000) {
      return '\$${(v / 1000000).toStringAsFixed(1)}M';
    }
    if (v >= 1000) {
      return '\$${(v / 1000).toStringAsFixed(1)}K';
    }
    return '\$${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.supplierSpend.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) {
      return Card(elevation: 1, child: Container(height: 200, padding: const EdgeInsets.all(12), child: const Center(child: Text('No data'))));
    }

    final count = math.min(widget.topN, entries.length);
    final top = entries.take(count).toList();

    // Use orange for bars and make them a bit slimmer for a refined look
    final Color barColor = Colors.deepOrange;
    final Color barColorSelected = Colors.deepOrange.shade700;

    final groups = top.asMap().entries.map((entry) {
      final idx = entry.key;
      final e = entry.value;
      final isSelected = _selectedIdx == idx;
      return BarChartGroupData(
        x: idx,
        barRods: [
          BarChartRodData(
            toY: e.value,
            width: isSelected ? 20 : 14,
            borderRadius: BorderRadius.circular(4),
            color: isSelected ? barColorSelected : barColor,
          ),
        ],
        showingTooltipIndicators: [],
      );
    }).toList();

    final maxY = top.map((e) => e.value).fold(0.0, (p, c) => c > p ? c : p);

    // Make chart scrollable horizontally when needed
    double minWidthPerBar = 64;
    double chartWidth = (count * minWidthPerBar).toDouble();
    if (chartWidth < 240) chartWidth = 240;

    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title and info
            Row(
              children: [
                Text('Top suppliers', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 8),
                Text('(top $count)', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 18),
                  tooltip: 'Shows top suppliers by spend in the selected date range',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('About this chart'),
                        content: const Text('This chart shows the top suppliers by total spend for the selected date range. Tap a bar to filter by that supplier.'),
                        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Chart area: adapt height to available space to prevent overflow
            LayoutBuilder(
              builder: (context, constraints) {
                final double chartHeight = constraints.maxHeight.isFinite ? math.min(200, constraints.maxHeight) : 200.0;
                return Column(
                  children: [
                    SizedBox(
                      height: chartHeight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: chartWidth,
                          child: BarChart(
                            BarChartData(
                              maxY: (maxY * 1.15) > 1 ? (maxY * 1.15) : 1.0,
                              barGroups: groups,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  // disable built-in tooltip (caused aggressive overlays)
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
                                ),
                                touchCallback: (event, response) {
                                  if (event is FlTapUpEvent && response != null && response.spot != null) {
                                    final idx = response.spot!.touchedBarGroup.x.toInt();
                                    final label = top[idx].key;
                                    setState(() => _selectedIdx = idx);
                                    if (widget.onBarTap != null) widget.onBarTap!(label);
                                  }
                                },
                              ),
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= top.length) return const SizedBox.shrink();
                                      final v = top[idx].value;
                                      return SideTitleWidget(
                                        meta: meta,
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Text(_formatYAxis(v), style: const TextStyle(fontSize: 10, color: Colors.black87)),
                                        ),
                                      );
                                    },
                                    interval: 1,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= top.length) return const SizedBox.shrink();
                                      final label = top[idx].key;
                                      // rotate labels slightly for readability
                                      return SideTitleWidget(
                                        meta: meta,
                                        child: Transform.rotate(
                                          angle: -math.pi / 6,
                                          child: SizedBox(
                                            width: minWidthPerBar,
                                            child: Text(label, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      );
                                    },
                                    interval: 1,
                                  ),
                                ),
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 70, getTitlesWidget: (value, meta) => Text(_formatYAxis(value), style: const TextStyle(fontSize: 11, color: Colors.black54)))),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(color: Theme.of(context).dividerColor.withOpacity(0.35), strokeWidth: 0.6),
                              ),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Compact selection chip instead of heavy tooltip
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _selectedIdx != null
                          ? Row(
                              key: ValueKey(_selectedIdx),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Chip(
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  label: Text('${top[_selectedIdx!].key}: ${_formatCurrency(top[_selectedIdx!].value)}', style: const TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                TextButton(onPressed: () => setState(() => _selectedIdx = null), child: const Text('Clear')),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
