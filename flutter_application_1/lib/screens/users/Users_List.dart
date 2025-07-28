import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/profile_network.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:flutter_application_1/screens/users/Modify_user.dart';
import 'package:flutter_application_1/screens/users/profile.dart';
import 'package:flutter_application_1/screens/users/profile_user.dart' as profile_user;
import 'package:flutter_application_1/screens/users/add_user.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User> users = [];
  String searchText = '';
  String? selectedPermission;
  String? selectedStatus;
  bool _isLoading = false;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (users.isEmpty) {
      _loadUsers();
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final apiUsers = await UserNetwork().uesresList();
      setState(() {
        users = apiUsers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des utilisateurs: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final matchesSearch = searchText.isEmpty ||
          user.email.toLowerCase().contains(searchText.toLowerCase()) ||
          user.username.toLowerCase().contains(searchText.toLowerCase());
      final matchesPermission = selectedPermission == null || user.permission == selectedPermission;
      final matchesStatus = selectedStatus == null || user.status == selectedStatus;
      return matchesSearch && matchesPermission && matchesStatus;
    }).toList();

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
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.deepPurple, size: 28),
                  tooltip: 'Rafraîchir',
                  onPressed: _loadUsers,
                ),
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
                      setState(() {
                        searchText = value;
                      });
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
                _buildFilterButtons(),
              ],
            ),
            const SizedBox(height: 20),
            // Tableau stylé
            Expanded(
              

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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              sortColumnIndex: _sortColumnIndex,
                              sortAscending: _sortAscending,
                              columnSpacing: 48,
                              headingRowColor: MaterialStateProperty.all(const Color(0xFFF5F5F5)),
                              dataRowHeight: 56,
                              dividerThickness: 0.6,
                              columns: [
                                DataColumn(
                                  label: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      filteredUsers.sort((a, b) => ascending
                                          ? a.email.compareTo(b.email)
                                          : b.email.compareTo(a.email));
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      filteredUsers.sort((a, b) => ascending
                                          ? a.username.compareTo(b.username)
                                          : b.username.compareTo(a.username));
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      filteredUsers.sort((a, b) => ascending
                                          ? a.status.compareTo(b.status)
                                          : b.status.compareTo(a.status));
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: const Text('User Permission', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _sortColumnIndex = columnIndex;
                                      _sortAscending = ascending;
                                      filteredUsers.sort((a, b) => ascending
                                          ? a.permission.compareTo(b.permission)
                                          : b.permission.compareTo(a.permission));
                                    });
                                  },
                                ),
                                const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: filteredUsers.map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(user.email, style: const TextStyle(fontSize: 15))),      // 1
                                    DataCell(Text(user.username, style: const TextStyle(fontSize: 15))),   // 2
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
                                    ), // 3
                                    DataCell(Text(user.permission, style: const TextStyle(fontSize: 15))), // 4
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
                                            // Charge le profil depuis l'API
                                            final profile = await ProfileNetwork().viewProfile(user.profileId ?? user.id);
                                            if (profile != null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => profile_user.ProfilePage(user: {
                                                    "first_name": profile.firstName ?? "",
                                                    "last_name": profile.lastName ?? "",
                                                    "bio": profile.bio ?? "",
                                                    "location": profile.location ?? "",
                                                    "country": profile.country ?? "",
                                                    "state": profile.state ?? "",
                                                    "city": profile.city ?? "",
                                                    "zip_code": profile.zipCode?.toString() ?? "",
                                                    "address": profile.address ?? "",
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
                                            _deleteUser(user);
                                          },
                                          tooltip: 'Delete',
                                        ),
                                      ],
                                    )), // 5
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        PopupMenuButton<String>(
          onSelected: (value) {
            setState(() {
              selectedStatus = value == 'All' ? null : value;
            });
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
              selectedStatus ?? "Filter by Status",
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
            setState(() {
              selectedPermission = value == 'All' ? null : value;
            });
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
              selectedPermission ?? "Filter by User Permission",
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

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await UserNetwork().deleteUser(user.id);
              _loadUsers();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.username} deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
