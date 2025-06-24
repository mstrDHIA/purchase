import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sidebar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selected = 'Home';
  bool showSidebar = false; // Ajouté

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      body: Row(
        children: [
          // Affiche le sidebar seulement si showSidebar est true
          if (showSidebar)
            AppSidebar(
              selected: selected,
              onItemSelected: (label) {
                setState(() {
                  selected = label;
                  showSidebar = false; // Ferme le sidebar après sélection
                });
              },
            ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '📄 Page: $selected',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                // Bouton flottant pour ouvrir le sidebar
                Positioned(
                  top: 24,
                  left: 24,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    onPressed: () {
                      setState(() {
                        showSidebar = !showSidebar;
                      });
                    },
                    child: const Icon(Icons.menu),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppSidebar extends StatefulWidget {
  final String selected;
  final Function(String) onItemSelected;

  const AppSidebar({
    super.key,
    required this.selected,
    required this.onItemSelected,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool isCollapsed = false;

  final items = [
    {'label': 'Home', 'icon': Icons.home},
    {'label': 'Dashboard', 'icon': Icons.dashboard},
    {'label': 'Profile', 'icon': Icons.account_circle},
    {'label': 'Users', 'icon': Icons.people},
    {'label': 'Password', 'icon': Icons.lock},
    {'label': 'PurchaseRequest', 'icon': Icons.note_add},
    {'label': 'Purchase Order', 'icon': Icons.shopping_cart},
    {'label': 'Roles and access', 'icon': Icons.security},
    {'label': 'Support centre', 'icon': Icons.help},
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: Alignment.topCenter,
      duration: const Duration(milliseconds: 250),
      width: isCollapsed ? 72 : 220,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 227, 227, 233),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Ouvre/ferme le sidebar avec un seul clic sur l'icône menu
          GestureDetector(
            onTap: () => setState(() => isCollapsed = !isCollapsed),
            child: Icon(
              isCollapsed ? Icons.menu : Icons.menu_open,
              color: Colors.deepPurple,
              size: 28,
            ),
          ),
          if (!isCollapsed)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "My App",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          const Divider(),
          Expanded(
            child: isCollapsed
                // Place icons at the top when sidebar is collapsed
                ? Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: items.map((item) {
                      final label = item['label'] as String;
                      final icon = item['icon'] as IconData;
                      final selected = label == widget.selected;
                      return Tooltip(
                        message: label,
                        child: IconButton(
                          icon: Icon(
                            icon,
                            color: selected ? Colors.deepPurple : Colors.grey[700],
                          ),
                          onPressed: () => widget.onItemSelected(label),
                          iconSize: 28,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      );
                    }).toList(),
                  )
                : ListView(
                    children: items.map((item) {
                      final label = item['label'] as String;
                      final icon = item['icon'] as IconData;
                      final selected = label == widget.selected;

                      return Tooltip(
                        message: isCollapsed ? label : '',
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isCollapsed ? 8 : 16,
                            vertical: 4,
                          ),
                          leading: Icon(
                            icon,
                            color: selected ? Colors.deepPurple : Colors.grey[700],
                          ),
                          title: isCollapsed
                              ? null
                              : Text(
                                  label,
                                  style: TextStyle(
                                    color: selected ? Colors.deepPurple : Colors.black87,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: selected ? Colors.deepPurple.withOpacity(0.1) : null,
                          hoverColor: Colors.deepPurple.withOpacity(0.08),
                          onTap: () => widget.onItemSelected(label),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("v1.0.0", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
