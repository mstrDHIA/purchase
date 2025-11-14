import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/role_controller.dart';
import 'package:flutter_application_1/screens/Role/add_Role_screen.dart';
import 'package:flutter_application_1/screens/Role/edit_Role_screen.dart';
import 'package:flutter_application_1/screens/Role/view_Role_screen.dart';
import 'package:provider/provider.dart';

class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoleController>(context, listen: false).fetchRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleController>(
      builder: (context, roleController, child) {
        final roles = roleController.roles;
        final isLoading = roleController.isLoading;
        final error = roleController.error;
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8FB),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: const [
                          Icon(Icons.assignment_ind_outlined, size: 32, color: Colors.black87),
                          SizedBox(width: 12),
                          Text(
                            'Roles',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final newRole = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddRolePage()),
                              );
                              if (newRole != null) {
                                await roleController.fetchRoles();
                              }
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
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(error, style: const TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                              padding: const EdgeInsets.all(0),
                              itemCount: roles.length + 1,
                              separatorBuilder: (context, index) {
                                if (index == roles.length) {
                                  return const Divider(height: 0, color: Colors.transparent);
                                }
                                return const Divider(height: 1, color: Color(0xFFE0E0E0));
                              },
                              itemBuilder: (context, index) {
                                if (index == 0) {
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
                                        SizedBox(width: 120),
                                      ],
                                    ),
                                  );
                                }
                                final role = roles[index - 1];
                                final String title = (role.name ?? '').toString();
                                final String desc = (role.description ?? '').toString();
                                String teammatesText = '';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title.isNotEmpty ? title : '(Sans nom)',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              desc.isNotEmpty ? desc : '(Aucune description)',
                                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                                            ),
                                            Text(
                                              'ID: ${role.id}',
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          _actionIcon(
                                            context,
                                            icon: Icons.remove_red_eye,
                                            tooltip: 'View',
                                            onTap: () async {
                                              final roleId = role.id;
                                              if (roleId == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('ID du rôle invalide'), backgroundColor: Colors.red),
                                                );
                                                return;
                                              }
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) => const Center(child: CircularProgressIndicator()),
                                              );
                                              final roleData = await roleController.viewRole(roleId);
                                              Navigator.of(context, rootNavigator: true).pop();
                                              if (roleData == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Erreur lors du chargement du rôle'), backgroundColor: Colors.red),
                                                );
                                                return;
                                              }
                                              showDialog(
                                                context: context,
                                                builder: (context) => ViewRolePage(
                                                  roleName: (roleData['title'] ?? roleData['name'] ?? '').toString(),
                                                  description: (roleData['desc'] ?? roleData['description'] ?? '').toString(),
                                                  permissions: (roleData['permissions'] is List)
                                                      ? List<String>.from(roleData['permissions'].whereType<String>())
                                                      : <String>[],
                                                  teammates: roleData['teammates'] is int
                                                      ? roleData['teammates'] as int
                                                      : (roleData['teammates'] is List ? (roleData['teammates'] as List).length : 0),
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
                                              final result = await showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(18),
                                                  ),
                                                  child: SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.32,
                                                    height: MediaQuery.of(context).size.height * 0.48,
                                                    child: EditRolePage(
                                                      id: roleData.id ?? 0,
                                                      initialName: (roleData.name ?? '').toString(),
                                                      initialDescription: (roleData.description ?? '').toString(),
                                                    ),
                                                  ),
                                                ),
                                              );
                                              if (result != null) {
                                                await roleController.fetchRoles();
                                              }
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
