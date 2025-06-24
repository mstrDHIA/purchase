import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserListPage extends StatelessWidget {
  final List<Map<String, String>> users = List.generate(
    5,
    (index) => {
      "email": "deanna.curtis@example.com",
      "name": "Jenny Wilson",
      "status": index == 1 ? "Inactive" : "Active",
      "permission": index == 0 ? "Operational" : index == 1 ? "Full" : "Basic",
    },
  );

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
          _buildSidebarItem("Useres"),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("User’s List", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search user name, email …",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              DropdownButton<String>(
                value: "User Permissions",
                items: ["User Permissions", "Operational", "Full", "Basic"]
                    .map((item) => DropdownMenuItem(child: Text(item), value: item))
                    .toList(),
                onChanged: (_) {},
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
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // Navigate to Sign In page
            },
            child: const Text(
              "Sign In",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Email"),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: "abc123@gmail.com",
              filled: true,
              fillColor: Colors.blue[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Email")),
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Statuts")),
                  DataColumn(label: Text("User Permission")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: users.map((user) {
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
            ),
          ),
        ],
      ),
    );
  }
}
