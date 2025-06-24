import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/users/Add_Password.dart';
import 'package:flutter_application_1/screens/users/Add_user.dart';
import 'package:flutter_application_1/screens/users/Modify_user.dart';
import 'package:flutter_application_1/screens/users/View_Profile.dart'; // Ajoute cet import

class User {
  final String email;
  final String name;
  final String status;
  final String permission;

  User(this.email, this.name, this.status, this.permission);
}

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final List<User> users = List.generate(
    10,
    (index) => User(
      'deanna.curtis@example.com',
      'Jenny Wilson',
      index == 1 ? 'Inactive' : 'Active',
      index == 1 ? 'Full' : index == 0 ? 'Operational' : 'Basic',
    ),
  );

  String searchText = '';
  String? selectedPermission;
  String? selectedStatus;

  // Add sorting state
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // Sorting logic
  void _onSort<T>(Comparable<T> Function(User user) getField, int columnIndex, bool ascending) {
    setState(() {
      users.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
      });
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filtrage dynamique
    final filteredUsers = users.where((user) {
      final matchesSearch = searchText.isEmpty ||
          user.email.toLowerCase().contains(searchText.toLowerCase()) ||
          user.name.toLowerCase().contains(searchText.toLowerCase());
      final matchesPermission = selectedPermission == null || user.permission == selectedPermission;
      final matchesStatus = selectedStatus == null || user.status == selectedStatus;
      return matchesSearch && matchesPermission && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F5),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // <-- important !
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "User’s List",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddPasswordPage()),
                    );
                  },
                  icon: const Icon(Icons.add,color: Colors.white),
                  label: const Text("Add New User"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Correction : la barre de recherche est centrée sur toute la largeur
            Center(
              child: _buildSearchBar(context),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildUserTable(filteredUsers)),
            const SizedBox(height: 20),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Sépare gauche/droite
      children: [
        // Partie gauche : Search field + Search button
        Row(
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search user name, email ...",
                  hintStyle: const TextStyle(fontSize: 18),
                  filled: true,
                  fillColor: const Color(0xFFEFEFEF),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 32,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C8CFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  textStyle: const TextStyle(fontSize: 18),
                  elevation: 0,
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                },
                child: const Text("Search"),
              ),
            ),
          ],
        ),
        // Partie droite : Filtres
        Row(
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
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                onPressed: null,
                child: Text(
                  selectedStatus ?? "Filter by Status",
                  style: TextStyle(
                    color: const Color(0xFF6F4DBF),
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
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                onPressed: null,
                child: Text(
                  selectedPermission ?? "Filter by User Permission",
                  style: TextStyle(
                    color: const Color(0xFF6F4DBF),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFF6F4DBF),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                setState(() {
                  selectedStatus = null;
                  selectedPermission = null;
                  searchText = '';
                });
              },
              child: const Text("Clear Filters"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTable(List<User> filteredUsers) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.2), // Outer border
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columnSpacing: 250,
          dataRowHeight: 56,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          dividerThickness: 1.0, // Horizontal borders
          columns: [
            DataColumn(
              label: const Text('Email'),
              onSort: (columnIndex, ascending) =>
                  _onSort((u) => u.email.toLowerCase(), columnIndex, ascending),
            ),
            DataColumn(
              label: const Text('Name'),
              onSort: (columnIndex, ascending) =>
                  _onSort((u) => u.name.toLowerCase(), columnIndex, ascending),
            ),
            DataColumn(
              label: const Text('Status'),
              onSort: (columnIndex, ascending) =>
                  _onSort((u) => u.status.toLowerCase(), columnIndex, ascending),
            ),
            DataColumn(
              label: const Text('User Permission'),
              onSort: (columnIndex, ascending) =>
                  _onSort((u) => u.permission.toLowerCase(), columnIndex, ascending),
            ),
            const DataColumn(label: Text('Actions')),
          ],
          rows: filteredUsers.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.email)),
                DataCell(Text(user.name)),
                DataCell(_buildStatusBadge(user.status)),
                DataCell(Text(user.permission)),
                DataCell(Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfilePage(user: {
                              'email': user.email,
                              'name': user.name,
                              'status': user.status,
                              'permission': user.permission,
                            }), // <-- Passe un Map<String, String>
                          ),
                        );
                      },
                      icon: const Icon(Icons.remove_red_eye, size: 18),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ModifyUserPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 18),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete User'),
                            content: Text('Are you sure you want to delete ${user.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 243, 5, 5),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    users.remove(user);
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${user.name} deleted')),
                                  );
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete, size: 18, color: Color.fromARGB(255, 7, 7, 7)),
                      tooltip: 'Delete',
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'Active' ? Colors.green.shade200 : Colors.red.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: status == 'Active' ? Colors.green.shade900 : Colors.red.shade900,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      children: [
        Icon(Icons.chevron_left, size: 20),
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: index == 1 ? Colors.blue : Colors.grey.shade200,
              child: Text("${index + 1}", style: TextStyle(fontSize: 12)),
            ),
          );
        }),
        Icon(Icons.chevron_right, size: 20),
      ],
    );
  }
}

// Ajoute ou adapte la page ProfileUserPage pour recevoir un User :
class ProfileUserPage extends StatefulWidget {
  final User user;
  const ProfileUserPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileUserPage> createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController roleController;

  @override
  void initState() {
    super.initState();
    final nameParts = widget.user.name.split(' ');
    firstNameController = TextEditingController(text: nameParts.first);
    lastNameController = TextEditingController(text: nameParts.length > 1 ? nameParts.last : '');
    emailController = TextEditingController(text: widget.user.email);
    usernameController = TextEditingController(text: 'amelie'); // Example username
    roleController = TextEditingController(text: widget.user.permission == 'Full' ? 'Admin' : 'Member');
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black, size: 32),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile photo
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    "${firstNameController.text} ${lastNameController.text}",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emailController.text,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  // Copy link button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C9EFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      ),
                      onPressed: () {},
                      child: const Text('Copy link'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Form fields
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: firstNameController,
                                    decoration: _profileFieldDecoration(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: lastNameController,
                                    decoration: _profileFieldDecoration(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email address', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          decoration: _profileFieldDecoration(
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('untitledui.com/', style: TextStyle(color: Colors.black54)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: usernameController,
                                decoration: _profileFieldDecoration(
                                  suffixIcon: Icon(Icons.verified, color: Colors.blue.shade400, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('Role', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: roleController,
                          decoration: _profileFieldDecoration(),
                        ),
                        const SizedBox(height: 20),
                        const Text('Profile photo', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: AssetImage('assets/profile_placeholder.png'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: () {},
                              child: const Text('Click to replace'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete user'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Save logic here (update user info)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Changes saved!')),
                          );
                        },
                        child: const Text('Save changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _profileFieldDecoration({Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
}

