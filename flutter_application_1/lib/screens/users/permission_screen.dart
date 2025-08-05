// ... imports
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Role/Role_screen.dart';
// import 'package:flutter_application_1/screens/profile/profile_user_screen.dart';
// import 'package:flutter_application_1/screens/users/role.dart'; // <-- Ajoute cet import

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  final List<String> roles = [
    'Owner',
    'Admin',
    'Editor',
    'LiveChat Agent',
    'Member',
  ];

  final List<String> privileges = [
    'Access data',
    'Edit content',
    'Delete content',
    'Manage users',
    'Live chat access',
    'Billing / Invoicing',
  ];

  List<List<bool>> permissions = [
    [true,  true,  true,  true,  true,  true ],
    [true,  true,  true,  true,  true,  false],
    [true,  true,  false, false, false, false],
    [true,  false, false, false, true,  false],
    [false, false, false, false, false, false],
  ];

  bool editMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Row(
        children: [
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        'Roles and permissions',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      // IconButton supprimé ici (profil)
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Search bar
                  Container(
                    width: 350,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search user name, email ...',
                        filled: true,
                        fillColor: const Color(0xFFEDEDED),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      ),
                    ),
                  ),
                  // Action buttons + Add Role
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigue vers la page role.dart
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RolePage()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add role'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C4DDE),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: editMode
                                ? () {
                                    setState(() {
                                      editMode = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Permissions saved')),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 78, 77, 78),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                              elevation: 0,
                            ),
                            child: const Text('Save'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: !editMode
                                ? () {
                                    setState(() {
                                      editMode = true;
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 133, 11, 213),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                              elevation: 0,
                            ),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Permissions Table
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 12000,
                          minWidth: 9000,
                        ),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color.fromARGB(255, 8, 8, 8), width: 1.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F4F6)),
                                dataRowMinHeight: 48,
                                dataRowMaxHeight: 60,
                                columnSpacing: 200,
                                columns: [
                                  const DataColumn(
                                    label: Text('Privilege', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  ...roles.map((role) => DataColumn(
                                        label: Text(role, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      )),
                                ],
                                rows: List.generate(privileges.length, (privIndex) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(privileges[privIndex])),
                                      ...List.generate(roles.length, (roleIndex) {
                                        if (roleIndex == 4 && privIndex == 0) {
                                          return const DataCell(Icon(Icons.visibility, color: Colors.black54, size: 20));
                                        }
                                        if (editMode && roleIndex != 0) {
                                          return DataCell(
                                            Checkbox(
                                              value: permissions[roleIndex][privIndex],
                                              onChanged: (val) {
                                                setState(() {
                                                  permissions[roleIndex][privIndex] = val ?? false;
                                                });
                                              },
                                              activeColor: Colors.green[800],
                                            ),
                                          );
                                        } else {
                                          return DataCell(
                                            permissions[roleIndex][privIndex]
                                                ? const Icon(Icons.check_box, color: Colors.green, size: 22)
                                                : const Icon(Icons.check_box_outline_blank, color: Colors.black26, size: 22),
                                          );
                                        }
                                      }),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
