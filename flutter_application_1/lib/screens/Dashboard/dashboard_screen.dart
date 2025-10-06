import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fake stats for demo, replace with real data if needed
    const int suppliers = 31;
    const int purchaseOrders = 10;
    const int pendingRequests = 4;
    const int users = 8;

    // Exemple: récupération du nom et rôle utilisateur (à remplacer par Provider ou autre)
    final String userName = "John Doe"; // À remplacer par la vraie source
    final String userRole = "Administrateur";
    // Ajout d'un menu déroulant pour filtrer la période
    final List<String> periods = ['Jour', 'Semaine', 'Mois', 'Année'];
    String selectedPeriod = periods[2];
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedPeriod,
              icon: const Icon(Icons.arrow_drop_down),
              items: periods.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                // Ici, tu peux gérer le changement de période
              },
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les statistiques',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dashboard refreshed!'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header utilisateur
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, size: 32, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade900)),
                    Text(userRole, style: TextStyle(fontSize: 15, color: Colors.blue.shade700)),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Searching for "$value"...'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bigStatCard(
                  context,
                  label: "Suppliers",
                  value: suppliers.toString(),
                  icon: Icons.people,
                  color: Colors.deepPurple,
                  trend: 8,
                  onTap: () => Navigator.pushNamed(context, '/supplier_registration'),
                ),
                _bigStatCard(
                  context,
                  label: "Orders",
                  value: purchaseOrders.toString(),
                  icon: Icons.shopping_cart,
                  color: Colors.green,
                  trend: 2,
                  onTap: () => Navigator.pushNamed(context, '/purchase_order'),
                ),
                _bigStatCard(
                  context,
                  label: "Pending",
                  value: pendingRequests.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  trend: -1,
                  onTap: () => Navigator.pushNamed(context, '/pending_requests'),
                ),
                _bigStatCard(
                  context,
                  label: "Users",
                  value: users.toString(),
                  icon: Icons.person,
                  color: Colors.blue,
                  trend: 0,
                  onTap: () => Navigator.pushNamed(context, '/Users'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Cards Grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.7,
              children: [
                _dashboardPanel(
                  title: "Suppliers Overview",
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/supplier_registration'),
                    child: _circleStat("Total", suppliers, Colors.deepPurple),
                  ),
                ),
                _dashboardPanel(
                  title: "Orders Overview",
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/purchase_order'),
                    child: _circleStat("Total", purchaseOrders, Colors.green),
                  ),
                ),
                _dashboardPanel(
                  title: "Pending Requests",
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/pending_requests'),
                    child: _circleStat("Pending", pendingRequests, Colors.orange),
                  ),
                ),
                _dashboardPanel(
                  title: "Users Overview",
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/Users'),
                    child: _circleStat("Total", users, Colors.blue),
                  ),
                ),
                _dashboardPanel(
                  title: "Revenue Updates",
                  child: _barChartPlaceholder(),
                ),
                _dashboardPanel(
                  title: "Yearly Orders",
                  child: _lineChartPlaceholder(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Row(
              children: [
                _quickAction(
                  context,
                  icon: Icons.add,
                  label: 'Add Purchase Request',
                  color: Colors.deepPurple,
                  route: '/add_purchase_request',
                  onTap: () => Navigator.pushNamed(context, '/add_purchase_request'),
                ),
                const SizedBox(width: 18),
                _quickAction(
                  context,
                  icon: Icons.add_shopping_cart,
                  label: 'Add Order',
                  color: Colors.green,
                  route: '/purchase_order',
                  onTap: () => Navigator.pushNamed(context, '/purchase_order'),
                ),
                const SizedBox(width: 18),
                _quickAction(
                  context,
                  icon: Icons.list,
                  label: 'View Suppliers',
                  color: Colors.blue,
                  route: '/supplier_registration',
                  onTap: () => Navigator.pushNamed(context, '/supplier_registration'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Footer
            Center(
              child: Text(
                "© 2025 MyApp Dashboard",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bigStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    int trend = 0,
    VoidCallback? onTap,
  }) {
    IconData? trendIcon;
    Color? trendColor;
    String trendText = '';
    if (trend > 0) {
      trendIcon = Icons.arrow_upward;
      trendColor = Colors.green;
      trendText = '+$trend%';
    } else if (trend < 0) {
      trendIcon = Icons.arrow_downward;
      trendColor = Colors.red;
      trendText = '$trend%';
    }

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.13),
                radius: 28,
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  if (trendIcon != null)
                    Row(
                      children: [
                        Icon(trendIcon, color: trendColor, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          trendText,
                          style: TextStyle(color: trendColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardPanel({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                )),
            const SizedBox(height: 18),
            Expanded(child: Center(child: child)),
          ],
        ),
      ),
    );
  }

  Widget _circleStat(String label, int value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 7,
                backgroundColor: color.withOpacity(0.13),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              value.toString(),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }

  Widget _barChartPlaceholder() {
    // Bar chart avec fl_chart
    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(titles[value.toInt() % titles.length], style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.blue, width: 18)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: Colors.green, width: 18)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 6, color: Colors.orange, width: 18)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 10, color: Colors.purple, width: 18)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 14, color: Colors.red, width: 18)]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 9, color: Colors.teal, width: 18)]),
          ],
        ),
      ),
    );
  }

  Widget _lineChartPlaceholder() {
    // Line chart avec fl_chart
    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(titles[value.toInt() % titles.length], style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 8),
                FlSpot(1, 12),
                FlSpot(2, 6),
                FlSpot(3, 10),
                FlSpot(4, 14),
                FlSpot(5, 9),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: label,
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 22),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          onPressed: () {
            if (label == 'Add Purchase Request') {
              Navigator.pushNamed(context, '/purchase_requestor_form');
            } else {
              onTap();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            minimumSize: const Size(180, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            shadowColor: color.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}