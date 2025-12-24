import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/network/user_network.dart';
import 'package:flutter_application_1/screens/profile/profile_user.dart';
import 'package:flutter_application_1/screens/users/modify_user_screen.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late UserController userController;
  Future<void>? _usersFuture;

  @override
  void initState() {
    userController = Provider.of<UserController>(context, listen: false);
    
    super.initState();
  }
  // We use a FutureBuilder to load users instead of calling getUsers() in init/didChangeDependencies.

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
                Expanded(
                  child: Text(
                    _getLocalizedText(context, 'users_list', "User's List"),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
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
                    context.push('/add_user').then((value) {
                      if(userController.displaySnackBar) {
                        userController.displaySnackBar = false; // Reset the flag
                        SnackBar snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(_getLocalizedText(context, 'user_added', 'User added successfully.')),
      );
                      userController.getUsers();
                        ScaffoldMessenger.of(context).showSnackBar(
                          snackBar
                        );
                        userController.displaySnackBar = false; // Reset the flag
                      }
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(_getLocalizedText(context, 'add_new_user', "Add New User")),
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
                      hintText: _getLocalizedText(context, 'search_user', "Search user name, email ..."),
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
                  child: FutureBuilder<void>(
                    future: _usersFuture ??= userController.getUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
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
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(child: Text(snapshot.error.toString(), style: TextStyle(color: Colors.red.shade800),)),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _usersFuture = userController.getUsers();
                                  });
                                },
                                icon: const Icon(Icons.refresh, color: Color(0xFF6F4DBF)),
                                label: Text(_getLocalizedText(context, 'retry', 'Retry'), style: const TextStyle(color: Color(0xFF6F4DBF))),
                              ),
                            ],
                          ),
                        );
                      }

                      // Normal finished state (either loaded or controller-managed loading)
                      return Container(
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
                                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F5F5)),
                                    dataRowHeight: 56,
                                    dividerThickness: 0.6,
                                    columns: [
                                  DataColumn(
                                    label: Text(_getLocalizedText(context, 'email', 'Email'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    onSort: (columnIndex, ascending) {
                                      userController.sortUsers(columnIndex, ascending);
                                    },
                                  ),
                                  DataColumn(
                                    label: Text(_getLocalizedText(context, 'name', 'Name'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    onSort: (columnIndex, ascending) {
                                      userController.sortUsers(columnIndex, ascending);
                                    },
                                  ),
                                  DataColumn(
                                    label: Text(_getLocalizedText(context, 'status', 'Status'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    onSort: (columnIndex, ascending) {
                                      userController.sortUsers(columnIndex, ascending);
                                    },
                                  ),
                                  DataColumn(
                                    label: Text(_getLocalizedText(context, 'user_permission', 'User Permission'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    onSort: (columnIndex, ascending) {
                                      userController.sortUsers(columnIndex, ascending);
                                    },
                                  ),
                                  DataColumn(label: Text(_getLocalizedText(context, 'actions', 'Actions'), style: const TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: userController.filteredUsers.map((user) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(user.email!, style: const TextStyle(fontSize: 15))),
                                      DataCell(Text(user.username!, style: const TextStyle(fontSize: 15))),
                                      DataCell(
                                         GestureDetector(
                                              onTap: () async {
                                                userController.selectedUserId = user.id!;
                                                userController.selectedUser = user;
                                                await userController.toggleUserStatus(id:user.id!,isActive:  !user.isActive!,context:  context);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: user.isActive!
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade200,
                                                  borderRadius: BorderRadius.circular(18),
                                                ),
                                                child: Text(
                                                  user.isActive! ? _getLocalizedText(context, 'active', 'Active') : _getLocalizedText(context, 'inactive', 'Inactive'),
                                                  style: TextStyle(
                                                    color: user.isActive!
                                                        ? Colors.green.shade800
                                                        : Colors.red.shade800,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            )
                                      ),
                                      DataCell(Text(user.role!=null?user.role!.name??_getLocalizedText(context, 'unknown', 'Unknown'):_getLocalizedText(context, 'none', 'None'), style: const TextStyle(fontSize: 15))),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20, color: Color(0xFF6F4DBF)),
                                            onPressed: () {
                                              userController.selectedUserId = user.id!;
                                              userController.selectedUser = user;
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ModifyUserPage(user: user),
                                                ),
                                              ).then((value) {
                                                // If ModifyUserPage returned the refreshed user, update it in the local list
                                                if (value != null && value is User) {
                                                  final idx = userController.users.indexWhere((u) => u.id == value.id);
                                                  if (idx != -1) {
                                                    userController.users[idx] = value;
                                                    userController.notify();
                                                  }
                                                  // show immediate snack
                                                  SnackBar snackBar = SnackBar(
                                                    backgroundColor: Colors.green,
                                                    content: Text(_getLocalizedText(context, 'user_updated', 'User updated successfully.')),
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                } else if(userController.displaySnackBar) {
                                                  userController.displaySnackBar = false; // Reset the flag
                                                SnackBar snackBar = SnackBar(
                                                  backgroundColor: Colors.green,
                                                  content: Text(_getLocalizedText(context, 'user_updated', 'User updated successfully.')),
                                                );
                                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  userController.getUsers();
                                                }
                                              });
                                            },
                                            tooltip: _getLocalizedText(context, 'edit', 'Edit'),
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
                                              final userDetails = await UserNetwork().viewUser(user.id!);
                                              Navigator.of(context, rootNavigator: true).pop(); // Ferme le loader
                                              if (userDetails != null) {
                                                userController.selectedUserId=user.id!;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ProfilePageScreen(
                                                      userId: userController.selectedUserId!,
                                                    )
                                                    ,
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(_getLocalizedText(context, 'load_profile_error', 'Unable to load user profile.'))),
                                                );
                                              }
                                            },
                                            tooltip: _getLocalizedText(context, 'view', 'View'),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: Color(0xFF6F4DBF)),
                                            onPressed: () {
                                              _confirmDelete(context, user);
                                            },
                                            tooltip: _getLocalizedText(context, 'delete', 'Delete'),
                                          ),
                                        ],
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                              ),
                            ),
                          );
                      },
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
            PopupMenuItem(value: 'All', child: Text(_getLocalizedText(context, 'all', 'All'))),
            PopupMenuItem(value: 'Active', child: Text(_getLocalizedText(context, 'active', 'Active'))),
            PopupMenuItem(value: 'Inactive', child: Text(_getLocalizedText(context, 'inactive', 'Inactive'))),
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
              userController.selectedStatus ?? _getLocalizedText(context, 'filter_status', "Filter by Status"),
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
            PopupMenuItem(value: 'All', child: Text(_getLocalizedText(context, 'all', 'All'))),
            PopupMenuItem(value: 'Operational', child: Text(_getLocalizedText(context, 'operational', 'Operational'))),
            PopupMenuItem(value: 'Full', child: Text(_getLocalizedText(context, 'full', 'Full'))),
            PopupMenuItem(value: 'Basic', child: Text(_getLocalizedText(context, 'basic', 'Basic'))),
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
              userController.selectedPermission ?? _getLocalizedText(context, 'filter_permission', "Filter by User Permission"),
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
    final parentContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_getLocalizedText(context, 'delete_user', 'Delete User')),
        content: Text('${_getLocalizedText(context, 'confirm_delete_user', 'Are you sure you want to delete')} ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_getLocalizedText(context, 'cancel', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Provider.of<UserController>(parentContext, listen: false).deleteUser(parentContext, user);
            },
            child: Text(_getLocalizedText(context, 'delete', 'Delete')),
          ),
        ],
      ),
    );
  }

  String _getLocalizedText(BuildContext context, String key, String defaultValue) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return defaultValue;
    
    final keyMap = {
      'users_list': l10n.usersList,
      'add_new_user': l10n.addNewUser,
      'user_added': l10n.userAdded,
      'search_user': l10n.searchUser,
      'email': l10n.email,
      'name': l10n.name,
      'status': l10n.status,
      'user_permission': l10n.userPermission,
      'actions': l10n.actions,
      'active': l10n.active,
      'inactive': l10n.inactive,
      'unknown': l10n.unknown,
      'none': l10n.none,
      'edit': l10n.edit,
      'view': l10n.view,
      'delete': l10n.delete,
      'load_profile_error': l10n.loadProfileError,
      'user_updated': l10n.userUpdated,
      'all': l10n.all,
      'filter_status': l10n.filterStatus,
      'filter_permission': l10n.filterPermission,
      'operational': l10n.operational,
      'full': l10n.full,
      'basic': l10n.basic,
      'delete_user': l10n.deleteUser,
      'confirm_delete_user': l10n.confirmDeleteUser,
      'cancel': l10n.cancel,
    };
    
    return keyMap[key] ?? defaultValue;
  }
}

