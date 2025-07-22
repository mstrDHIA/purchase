import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  // Données simulées des utilisateurs
  List<Map<String, String>> users = [];
  
  // Variables pour la recherche et les filtres
  String searchQuery = '';
  String selectedPermission = 'User Permissions';

  @override
  void initState() {
    super.initState();
    // Appeler une fonction fictive pour simuler l'obtention des utilisateurs
    _fetchUsers();
  }

  // Simulation d'un appel API
  Future<void> _fetchUsers() async {
    await Future.delayed(Duration(seconds: 2)); // Simuler un délai d'attente
    
    setState(() {
      users = List.generate(
        5,
        (index) => {
          "email": "deanna.curtis@example.com",
          "name": "Jenny Wilsonx",
          "status": index == 1 ? "Inactive" : "Active",
          "permission": index == 0 ? "Operational" : index == 1 ? "Full" : "Basic",
        },
      );
    });
  }

  // Fonction de recherche et de filtrage
  List<Map<String, String>> getFilteredUsers() {
    return users.where((user) {
      final matchesSearchQuery = user["name"]!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user["email"]!.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesPermission = selectedPermission == "User Permissions" ||
          user["permission"] == selectedPermission;
      return matchesSearchQuery && matchesPermission;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 200,
      color: Colors.grey[200],
      child: ListView(
        children: [
          SizedBox(height: 30),
          _buildSidebarItem("Home"),
          _buildSidebarItem("Dashboard"),
          _buildSidebarItem("Users"),
          _buildSidebarItem("Password"),
          _buildSidebarItem("Request Order"),
          _buildSidebarItem("Purchase Order"),
          _buildSidebarItem("Roles and access"),
          _buildSidebarItem("Support centre"),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String label) {
    return ListTile(
      title: Text(label, style: TextStyle(fontSize: 14)),
      onTap: () {},
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("User’s List", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
              ],
            ),
            SizedBox(height: 20),
            _buildSearchAndFilters(),
            SizedBox(height: 20),
            _buildUserList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Search user name, email …",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        SizedBox(width: 12),
        DropdownButton<String>(
          value: selectedPermission,
          items: ["User Permissions", "Operational", "Full", "Basic"]
              .map((item) => DropdownMenuItem(child: Text(item), value: item))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedPermission = value!;
            });
          },
        ),
        SizedBox(width: 12),
        ElevatedButton(onPressed: () {}, child: Text("Search")),
        SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          child: Text("+ Add New User"),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    return FutureBuilder(
      future: _fetchUsers(), // Appel fictif pour charger les utilisateurs
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Afficher un loader
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        } else if (!snapshot.hasData || users.isEmpty) {
          return Center(child: Text('Aucun utilisateur trouvé'));
        } else {
          // Appliquer les filtres sur les utilisateurs
          final filteredUsers = getFilteredUsers();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("User Permission")),
                DataColumn(label: Text("Actions")),
              ],
              rows: filteredUsers.map((user) {
                final isActive = user["status"] == "Active";
                return DataRow(
                  cells: [
                    DataCell(Text(user["email"]!)),
                    DataCell(Text(user["name"]!)),
                    DataCell(Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user["status"]!,
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    )),
                    DataCell(Text(user["permission"]!)),
                    DataCell(Row(
                      children: const [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 8),
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Icon(Icons.delete, size: 18),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
