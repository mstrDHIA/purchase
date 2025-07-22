import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Icon(Icons.home_rounded, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              'MyApp Dashboard',
              style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: Colors.blue[700],
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          const SizedBox(width: 8),
          
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.home_rounded, size: 80, color: Colors.blue[700]),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to MyApp!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Manage your purchase requests, orders, users, and more from the sidebar.\n'
                      'Use the navigation to access different modules of the application.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Quick Actions Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _HomeCard(
                    icon: Icons.add_shopping_cart,
                    label: 'Create Purchase Request',
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.of(context).pushNamed('/PurchaseRequest');
                    },
                    description: 'Start a new purchase request for your needs.',
                  ),
                  _HomeCard(
                    icon: Icons.shopping_bag,
                    label: 'View Purchase Orders',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).pushNamed('/Purchase Order');
                    },
                    description: 'Browse and manage all purchase orders.',
                  ),
                  _HomeCard(
                    icon: Icons.people,
                    label: 'Manage Users',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(context).pushNamed('/Users');
                    },
                    description: 'Add, edit, or remove users and permissions.',
                  ),
                  _HomeCard(
                    icon: Icons.help_center,
                    label: 'Support Centre',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.of(context).pushNamed('/Support centre');
                    },
                    description: 'Get help and find answers to your questions.',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Feedback Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.feedback_outlined, color: Colors.blue),
                    const SizedBox(width: 12),
                    const Text(
                      "Have feedback or need help? ",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/Support centre');
                      },
                      child: const Text("Contact Support"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String description;

  const _HomeCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        hoverColor: color.withOpacity(0.18),
        child: Container(
          width: 220,
          height: 150,
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 38, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}