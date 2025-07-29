import 'package:flutter/material.dart';

class ViewRolePage extends StatelessWidget {
  final String roleName;
  final String description;
  final List<String> permissions;
  final int teammates;

  const ViewRolePage({
    Key? key,
    String? roleName,
    String? description,
    List<String>? permissions,
    int? teammates,
  })  : roleName = roleName ?? '',
        description = description ?? '',
        permissions = permissions ?? const [],
        teammates = teammates ?? 0,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.visibility, color: Colors.deepPurple, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Role Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                (roleName.isNotEmpty ? roleName : '(Sans nom)'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                (description.isNotEmpty ? description : '(Aucune description)'),
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.people, size: 20, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '$teammates teammate${teammates > 1 ? "s" : ""}',
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                "Permissions",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              permissions.isEmpty || permissions.whereType<String>().isEmpty
                  ? const Text("No permissions assigned.", style: TextStyle(color: Colors.black54))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: permissions
                          .whereType<String>()
                          .where((perm) => perm.isNotEmpty)
                          .map((perm) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        perm,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}