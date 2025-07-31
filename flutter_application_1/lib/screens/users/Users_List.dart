import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/profile_network.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:flutter_application_1/screens/users/Modify_user.dart';
import 'package:flutter_application_1/screens/users/profile.dart';
import 'package:flutter_application_1/screens/users/profile_user.dart' as profile_user;
import 'package:flutter_application_1/screens/users/add_user.dart';
import 'package:provider/provider.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late UserController userController;

  @override
  void initState() {
    userController = Provider.of<UserController>(context, listen: false);
    userController.getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F5),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre, bouton et refresh
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "User’s List",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                // IconButton(
                //   icon: const Icon(Icons.refresh, color: Colors.deepPurple, size: 28),
                //   tooltip: 'Rafraîchir',
                //   onPressed: _loadUsers,
                // ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  AddUserPage()),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add New User"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Barre de recherche et filtres
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      Provider.of<UserController>(context, listen: false).setSearchText(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search user name, email ...",
                      hintStyle: const TextStyle(fontSize: 16),
                      filled: true,
                      fillColor: const Color(0xFFEFEFEF),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildFilterButtons(context),
              ],
            ),
            const SizedBox(height: 20),
            Consumer<UserController>(
              builder: (context, userController, child) {
                return Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: userController.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: MediaQuery.of(context).size.width,
                              ),
                              child: DataTable(
                                sortColumnIndex: userController.sortColumnIndex,
                                sortAscending: userController.sortAscending,
                                columnSpacing: 48,
                                headingRowColor: MaterialStateProperty.all(const Color(0xFFF5F5F5)),
                                dataRowHeight: 56,
                                dividerThickness: 0.6,
                                columns: [
                                  DataColumn(
                                    label: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                                    onSort: (columnIndex, ascending) {
                                      userController.sortUsers(columnIndex, ascending);
                                    },
                                  ),
                                  DataColumn(
                                    label: const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                    onSort: (columnIndex, ascending) {
                                      userController.sortUsers(columnIndex, ascending);
                                    },
                                  ),
                                  DataColumn(
                                    label: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                    onSort: (columnIndex, ascending) {
                                      userController.sortUsers(columnIndex, ascending);
                                    },
                                  ),
                                  DataColumn(
                                    label: const Text('User Permission', style: TextStyle(fontWeight: FontWeight.bold)),
                                    onSort: (columnIndex, ascending) {
                                      userController.sortUsers(columnIndex, ascending);
                                    },
                                  ),
                                  const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: userController.filteredUsers.map((user) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(user.email, style: const TextStyle(fontSize: 15))),
                                      DataCell(Text(user.username, style: const TextStyle(fontSize: 15))),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: user.status == 'Active'
                                                ? Colors.green.shade100
                                                : Colors.red.shade200,
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          child: Text(
                                            user.status,
                                            style: TextStyle(
                                              color: user.status == 'Active'
                                                  ? Colors.green.shade800
                                                  : Colors.red.shade800,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(user.permission, style: const TextStyle(fontSize: 15))),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20, color: Color(0xFF6F4DBF)),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ModifyUserPage(user: user),
                                                ),
                                              );
                                            },
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.visibility, size: 18, color: Color(0xFF6F4DBF)),
                                            onPressed: () async {
                                              // Affiche un loader pendant la récupération
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) => const Center(child: CircularProgressIndicator()),
                                              );
                                              final userDetails = await UserNetwork().viewUser(user.id);
                                              Navigator.of(context, rootNavigator: true).pop(); // Ferme le loader

                                              if (userDetails != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => profile_user.ProfilePage(user: {
                                                      "id": user.id,
                                                      "first_name": userDetails.firstName,
                                                      "last_name": userDetails.lastName,
                                                      "bio": userDetails.bio ?? "",
                                                      "location": userDetails.location ?? "",
                                                      "country": userDetails.country ?? "",
                                                      "state": userDetails.state ?? "",
                                                      "city": userDetails.city ?? "",
                                                      "zip_code": userDetails.zipCode?.toString() ?? "",
                                                      "address": userDetails.address ?? "",
                                                      "email": userDetails.email,
                                                      "username": userDetails.username,
                                                    }),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Impossible de charger le profil utilisateur.')),
                                                );
                                              }
                                            },
                                            tooltip: 'View',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: Color(0xFF6F4DBF)),
                                            onPressed: () {
                                              _confirmDelete(context, user);
                                            },
                                            tooltip: 'Delete',
                                          ),
                                        ],
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
                );
              },

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButtons(BuildContext context) {
    final userController = Provider.of<UserController>(context, listen: false);
    return Row(
      children: [
        PopupMenuButton<String>(
          onSelected: (value) {
            userController.setStatus(value);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'All', child: Text('All')),
            const PopupMenuItem(value: 'Active', child: Text('Active')),
            const PopupMenuItem(value: 'Inactive', child: Text('Inactive')),
          ],
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 228, 227, 229),
              foregroundColor: const Color(0xFF6F4DBF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            onPressed: null,
            child: Text(
              userController.selectedStatus ?? "Filter by Status",
              style: const TextStyle(
                color: Color(0xFF6F4DBF),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          onSelected: (value) {
            userController.setPermission(value);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'All', child: Text('All')),
            const PopupMenuItem(value: 'Operational', child: Text('Operational')),
            const PopupMenuItem(value: 'Full', child: Text('Full')),
            const PopupMenuItem(value: 'Basic', child: Text('Basic')),
          ],
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 228, 227, 229),
              foregroundColor: const Color(0xFF6F4DBF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            onPressed: null,
            child: Text(
              userController.selectedPermission ?? "Filter by User Permission",
              style: const TextStyle(
                color: Color(0xFF6F4DBF),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, User user) {
    final parentContext = context; // Capture le contexte parent
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Provider.of<UserController>(parentContext, listen: false).deleteUser(parentContext, user);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
