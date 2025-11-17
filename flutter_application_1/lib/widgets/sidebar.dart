import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/screens/Product/family_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Supplier_registration_screen.dart';
import 'package:go_router/go_router.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  const MyHomePage();
   
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
                  // Keep the sidebar open when selecting Product so the user sees the Families page alongside the sidebar
                  if (label != 'Product') {
                    showSidebar = false; // Ferme le sidebar après sélection for other pages
                  }
                });
              },
            ),
          Expanded(
            child: Stack(
              children: [
                // Render main content according to the selected item. For 'Product', show FamiliesPage within the layout so the sidebar stays visible.
                Builder(builder: (context) {
                  if (selected == 'Product') {
                    return const Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: SizedBox.expand(child: FamiliesPage()),
                    );
                  }
                  if (selected == 'Supplier') {
                    return const Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: SizedBox.expand(child: SupplierRegistrationPage()),
                    );
                  }
                  return Center(
                    child: Text(
                      '📄 Page: $selected',
                      style: const TextStyle(fontSize: 24),
                    ),
                  );
                }),
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
  late UserController userController;

  bool isCollapsed = false;

  final items = [
    // ...existing code...
  ];

// 1 admin
// 2 user
// 3 manager
// 4 supervisor
// 5 visitor
  void initSideBarItems() {
    if(userController.currentUser.role_id==1){
      items.addAll([
      // {'label': 'Home', 'icon': Icons.home},
      // {'label': 'Dashboard', 'icon': Icons.dashboard},
      // {'label': 'Profile', 'icon': Icons.account_circle},
      {'label': 'Users', 'icon': Icons.people},
      {'label': 'Password', 'icon': Icons.lock},
      {'label': 'PurchaseRequest', 'icon': Icons.note_add},
      {'label': 'Purchase Order', 'icon': Icons.shopping_cart},
      {'label': 'Roles and access', 'icon': Icons.security},
      // {'label': 'Support centre', 'icon': Icons.help},
      {'label': 'Settings', 'icon': Icons.settings},
      {'label': 'Supplier', 'icon': Icons.store},
      {'label': 'Product', 'icon': Icons.production_quantity_limits},
    ]);
    }
    else if(userController.currentUser.role_id==2){
      items.addAll([
      // {'label': 'Home', 'icon': Icons.home},
      // {'label': 'Dashboard', 'icon': Icons.dashboard},
      {'label': 'Profile', 'icon': Icons.account_circle},
      // {'label': 'Users', 'icon': Icons.people},
      {'label': 'Password', 'icon': Icons.lock},
      {'label': 'PurchaseRequest', 'icon': Icons.note_add},
      // {'label': 'Purchase Order', 'icon': Icons.shopping_cart},
      // {'label': 'Support centre', 'icon': Icons.help},
      {'label': 'Settings', 'icon': Icons.settings},
    ]);
    }
    else if(userController.currentUser.role_id==3){
      items.addAll([
      // {'label': 'Home', 'icon': Icons.home},
      // {'label': 'Dashboard', 'icon': Icons.dashboard},
      {'label': 'Profile', 'icon': Icons.account_circle},
      // {'label': 'Users', 'icon': Icons.people},
      {'label': 'Password', 'icon': Icons.lock},
      {'label': 'PurchaseRequest', 'icon': Icons.note_add},
      // {'label': 'Purchase Order', 'icon': Icons.shopping_cart},
      // {'label': 'Support centre', 'icon': Icons.help},
      {'label': 'Settings', 'icon': Icons.settings},
    ]);
    }
     else if((userController.currentUser.role_id==4)){
      items.addAll([
      // {'label': 'Home', 'icon': Icons.home},
      // {'label': 'Dashboard', 'icon': Icons.dashboard},
      {'label': 'Profile', 'icon': Icons.account_circle},
      // {'label': 'Users', 'icon': Icons.people},
      {'label': 'Password', 'icon': Icons.lock},
      {'label': 'PurchaseRequest', 'icon': Icons.note_add},
      {'label': 'Purchase Order', 'icon': Icons.shopping_cart},
      // {'label': 'Support centre', 'icon': Icons.help},
      {'label': 'Settings', 'icon': Icons.settings},
    ]);
    // (userController.currentUser.role_id==4)
    }
    else if((userController.currentUser.role_id==6)){
      items.addAll([
      // {'label': 'Home', 'icon': Icons.home},
      // {'label': 'Dashboard', 'icon': Icons.dashboard},
      {'label': 'Profile', 'icon': Icons.account_circle},
      // {'label': 'Users', 'icon': Icons.people},
      {'label': 'Password', 'icon': Icons.lock},
      // {'label': 'PurchaseRequest', 'icon': Icons.note_add},
      {'label': 'Purchase Order', 'icon': Icons.shopping_cart},
      // {'label': 'Support centre', 'icon': Icons.help},
      {'label': 'Settings', 'icon': Icons.settings},
    ]);
    // (userController.currentUser.role_id==4)
    }
    else if(userController.currentUser.role_id==5){
       items.addAll([
      // {'label': 'Home', 'icon': Icons.home},
      // {'label': 'Dashboard', 'icon': Icons.dashboard},
      {'label': 'Profile', 'icon': Icons.account_circle},
      // {'label': 'Users', 'icon': Icons.people},
      {'label': 'Password', 'icon': Icons.lock},
      // {'label': 'PurchaseRequest', 'icon': Icons.note_add},
      // {'label': 'Purchase Order', 'icon': Icons.shopping_cart},
      // {'label': 'Support centre', 'icon': Icons.help},
      {'label': 'Settings', 'icon': Icons.settings},
    ]);
    }
    else{
       items.addAll([
      // {'label': 'Home', 'icon': Icons.home},
      // {'label': 'Dashboard', 'icon': Icons.dashboard},
      {'label': 'Profile', 'icon': Icons.account_circle},
      // {'label': 'Users', 'icon': Icons.people},
      {'label': 'Password', 'icon': Icons.lock},
      // {'label': 'PurchaseRequest', 'icon': Icons.note_add},
      // {'label': 'Purchase Order', 'icon': Icons.shopping_cart},
      // {'label': 'Support centre', 'icon': Icons.help},
      {'label': 'Settings', 'icon': Icons.settings},
    ]);
    }
  }

  @override
  void initState() {
    userController = Provider.of<UserController>(context, listen: false);
    initSideBarItems();
    // TODO: implement initState
    super.initState();
  }

  void _onItemTap(String label) {
    // update selected state in parent
    widget.onItemSelected(label);

    // Navigate to specific routes for some items
    // if (label == 'Supplier') {
    //   // Use GoRouter to navigate because the app uses MaterialApp.router
    //   GoRouter.of(context).go('/supplier_registration');
    //   return;
    // }

    // For other items we keep current behavior (the parent will show the appropriate content)
  }

  // added: confirmation + logout helper
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Do you really want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout")),
        ],
      ),
    );
    if (confirmed == true) {
      userController.logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: Alignment.topCenter,
      duration: const Duration(milliseconds: 250),
      width: isCollapsed ? 72 : 220,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 227, 227, 233),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: [
                  const Text(
                    "My App",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Consumer<UserController>(
                    builder: (context, userController, _) {
                      final user = userController.currentUser;
                      final username = user.username ?? "";
                      final roleName = user.role?.name ?? "";
                      return Column(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (roleName.isNotEmpty)
                            Text(
                              roleName,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          const Divider(),
          Expanded(
            child: isCollapsed
                // Place icons at the top when sidebar is collapsed
                ? Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // existing item icons
                      ...items.map((item) {
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
                            onPressed: () => _onItemTap(label),
                            iconSize: 28,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        );
                      }).toList(),
                      // logout icon for collapsed state
                      Tooltip(
                        message: 'Logout',
                        child: IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: _confirmLogout,
                          iconSize: 28,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    children: [
                      // existing list items
                      ...items.map((item) {
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
                            onTap: () => _onItemTap(label),
                          ),
                        );
                      }).toList(),
                      const Divider(),
                      // Logout tile in expanded sidebar
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                        onTap: _confirmLogout,
                      ),
                    ],
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
