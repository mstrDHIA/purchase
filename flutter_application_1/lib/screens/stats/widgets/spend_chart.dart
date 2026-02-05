import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SpendChart extends StatelessWidget {
  final List<FlSpot> spots;
  final DateTime? anchorDate;
  final Map<int, String> labels;
  final Map<int, int>? counts;
  final String? dateRange;
  final String? dateNote;

  const SpendChart({
    super.key,
    required this.spots,
    required this.anchorDate,
    required this.labels,
    this.counts,
    this.dateRange,
    this.dateNote,
  });

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



  String _formatCurrency(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return Card(elevation: 1, child: Container(height: 220, padding: const EdgeInsets.all(12), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.insert_chart_outlined, size: 36, color: Colors.black26), SizedBox(height: 8), Text('No data', style: TextStyle(color: Colors.black38))]))));
    }

    final maxX = spots.map((s) => s.x).fold(0.0, (p, c) => c > p ? c : p);
    final maxY = spots.map((s) => s.y).fold(0.0, (p, c) => c > p ? c : p);
    double interval = maxX > 0 ? (maxX / 4.0) : 1.0;
    if (interval <= 0) interval = 1.0;

    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        height: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Spend (TND)', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    // Legend
                    Container(width: 12, height: 12, color: Colors.deepOrange),
                    const SizedBox(width: 6),
                    const Text('Spend', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 12),
                    // Info button
                    IconButton(
                      icon: const Icon(Icons.info_outline, size: 18, color: Colors.black54),
                      tooltip: 'Show details',
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Spend chart'),
                            content: const Text('Daily spend totals aggregated from PO product lines. Dates prioritized: createdAt → startDate → endDate. Currency: TND.'),
                            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxX > 0 ? maxX : 1.0,
                  minY: 0,
                  maxY: (maxY * 1.2) > 1 ? (maxY * 1.2) : 1.0,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          // Only show a title when a label exists for the exact integer x
                          final key = value.toInt();
                          final label = labels.containsKey(key) ? labels[key] : null;
                          if (label == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: SizedBox(
                              width: 64,
                              child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54), overflow: TextOverflow.ellipsis),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval: (maxY > 0 ? maxY / 4 : 1),
                      getTitlesWidget: (value, meta) => Text(_formatYAxis(value), style: const TextStyle(fontSize: 10, color: Colors.black54)),
                    )),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.deepOrange,
                      barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 3, color: Colors.deepOrange),
                      ),
                      belowBarData: BarAreaData(show: true, color: Colors.deepOrange.withOpacity(0.15)),
                    ),
                  ],
                  borderData: FlBorderData(show: true),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {
                        return spots.map((s) {
                          final x = s.x.toInt();
                          final date = anchorDate != null ? anchorDate!.add(Duration(days: x)) : null;
                          final dateStr = date != null ? DateFormat('dd-MM-yyyy').format(date) : '';
                          final count = counts != null ? (counts![x] ?? 0) : 0;
                          final ordersPart = count > 0 ? '\nOrders: $count' : '';
                          return LineTooltipItem('$dateStr\n${_formatCurrency(s.y)}$ordersPart', const TextStyle(color: Colors.white));
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (dateRange != null) Padding(
              padding: const EdgeInsets.only(left: 2.0, bottom: 6.0),
              child: Text(dateRange!, style: const TextStyle(fontSize: 12, color: Colors.black45)),
            ),
            Center(child: Text('Date', style: const TextStyle(color: Colors.black54))),
          ],
        ),
      ),
    );
  }
}
