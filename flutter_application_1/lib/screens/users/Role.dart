import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/users/Add_Role.dart';
import 'package:flutter_application_1/screens/users/View_Role.dart';
import 'package:flutter_application_1/screens/users/Edit_Role.dart';

class RolePage extends StatelessWidget {
  const RolePage({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = [
      {
        'title': 'Owner',
        'desc': 'The owner complete control over workspace and organization, including billing and account management. There is only one owner per organization',
        'teammates': 1,
      },
      {
        'title': 'Admin',
        'desc': 'Admins have complete control over the workspace, except for the Owner role and following permissions like billing and payments.',
        'teammates': 2,
      },
      {
        'title': 'Editor',
        'desc': 'Editors can access almost all features, including automation and contact management.',
        'teammates': 2,
      },
      {
        'title': 'LiveChat agent',
        'desc': 'LiveChat agents can access and communicate with bot-subscribed contacts inside the LiveChat module.',
        'teammates': 3,
      },
      {
        'title': 'Member',
        'desc': 'Members can access almost all features with "view only" mode.',
        'teammates': 6,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.assignment_ind_outlined, size: 32, color: Colors.black87),
                const SizedBox(width: 12),
                const Text(
                  'Roles',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // IconButton(
                //   icon: const Icon(Icons.account_circle, size: 32),
                //   onPressed: () {},
                //   tooltip: 'Profile',
                //   splashRadius: 22,
                // ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox(
                          width: 500,
                          child: AddRolePage(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB7A6F7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  label: const Text('Create new role'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // ListView for roles
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black12),
              ),
              child: ListView.separated(
                shrinkWrap: true, // <-- Important !
                physics: const NeverScrollableScrollPhysics(), // <-- Important !
                padding: const EdgeInsets.all(0),
                itemCount: roles.length + 1,
                separatorBuilder: (context, index) {
                  if (index == roles.length) {
                    return const Divider(
                      height: 0,
                      color: Colors.transparent,
                    );
                  }
                  return const Divider(height: 1, color: Color(0xFFE0E0E0));
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Header row
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      color: const Color(0xFFF4F4F6),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Icon(Icons.groups, size: 18, color: Colors.black54),
                                SizedBox(width: 8),
                                Text('Roles', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text('Teammates', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(width: 120),
                        ],
                      ),
                    );
                  }
                  final role = roles[index - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Role info
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role['title'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                role['desc'] as String,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        // Teammates
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              "${role['teammates']} teammate${role['teammates'] == 1 ? '' : 's'}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                        // Actions
                        Row(
                          children: [
                            _actionIcon(
                              context,
                              icon: Icons.remove_red_eye,
                              tooltip: 'View',
                              onTap: () {
                                final roleData = role;
                                showDialog(
                                  context: context,
                                  builder: (context) => ViewRolePage(
                                    roleName: roleData['title'] as String,
                                    description: roleData['desc'] as String,
                                    permissions: const [
                                      // Remplace par les vraies permissions si tu les as dans tes données
                                      "View Dashboard",
                                      "Manage Users",
                                      "Edit Roles",
                                    ],
                                    teammates: roleData['teammates'] as int,
                                  ),
                                );
                              },
                            ),
                            _actionIcon(
                              context,
                              icon: Icons.edit,
                              tooltip: 'Edit',
                              onTap: () async {
                                final roleData = role;
                                await showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: EditRolePage(
                                      initialName: roleData['title'] as String,
                                      initialDescription: roleData['desc'] as String,
                                      initialPermissions: const [
                                        // Remplace par les vraies permissions si tu les as dans tes données
                                        "View Dashboard",
                                        "Manage Users",
                                        "Edit Roles",
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            _actionIcon(
                              context,
                              icon: Icons.delete,
                              tooltip: 'Delete',
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Role'),
                                    content: Text('Are you sure you want to delete the role "${role['title']}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Role "${role['title']}" deleted')),
                                          );
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, {bool selected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: selected
          ? BoxDecoration(
              color: const Color(0xFFD6C9F4),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        onTap: () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        hoverColor: const Color(0xFFE0E0F7),
      ),
    );
  }

  Widget _actionIcon(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
    Color? hoverColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          hoverColor: hoverColor ?? const Color(0xFFE6E6FA),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: color ?? _getIconColor(icon),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Color _getIconColor(IconData icon) {
    if (icon == Icons.remove_red_eye) return const Color(0xFF4F8AF7);
    if (icon == Icons.edit) return const Color(0xFF4FC3A1);
    if (icon == Icons.delete) return const Color(0xFFF75F5F);
    return const Color(0xFF8CA1B8);
  }
}