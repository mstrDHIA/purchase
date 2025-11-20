import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/models/purchase_request.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/Purchase%20Request/Request_Edit_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20Request/purchase_request_view_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseRequestDataSource extends DataTableSource {
  final List<PurchaseRequest> requests;
  final BuildContext context;
  final String someArgument;

  PurchaseRequestDataSource(this.requests, this.context, this.someArgument) {
  }

  @override
  DataRow? getRow(int index) {
    if (index >= requests.length) return null;
    final request = requests[index];
    return DataRow(
      cells: [
        DataCell(Text(request.id.toString())),
        // Show user display name if available, otherwise fallback to id
        DataCell(Builder(builder: (cellContext) {
          // The API may return either an id or a nested user object for requested_by/approved_by.
          // Prefer any name provided on the request model (requestedByName/approvedByName).
          final isRequester = Provider.of<UserController>(cellContext, listen: false).currentUser.role!.id != 2;
          final dynamic userField = isRequester ? request.requestedBy : request.approvedBy;
          final String? modelName = isRequester ? request.requestedByName : request.approvedByName;
          if (modelName != null && modelName.isNotEmpty) return Text(modelName);

          if (userField == null) return const Text('');

          // If backend provided a nested user object
          if (userField is Map) {
            final String fname = (userField['first_name'] ?? userField['firstName'] ?? '')?.toString() ?? '';
            final String lname = (userField['last_name'] ?? userField['lastName'] ?? '')?.toString() ?? '';
            final String uname = (userField['username'] ?? userField['user'] ?? '')?.toString() ?? '';
            if (fname.isNotEmpty) return Text('$fname${lname.isNotEmpty ? ' $lname' : ''}'.trim());
            if (uname.isNotEmpty) return Text(uname);
            if (userField['id'] != null) return Text(userField['id'].toString());
            return const Text('');
          }

          // Otherwise assume an id was provided; try to parse it
          final int? userId = int.tryParse(userField.toString()) ?? (userField is int ? userField : null);
          if (userId == null) return Text(userField.toString());

          // Listen to UserController so this cell rebuilds when users load
          final userController = Provider.of<UserController>(cellContext, listen: true);
          final found = userController.users.firstWhere((u) => u.id == userId, orElse: () => User(id: userId, username: userId.toString()));
          final displayName = (found.firstName != null && (found.firstName ?? '').isNotEmpty)
              ? '${found.firstName} ${found.lastName ?? ''}'.trim()
              : (found.username != null && (found.username ?? '').isNotEmpty)
                  ? found.username
                  : userId.toString();
          return Text(displayName ?? userId.toString());
        })),
        DataCell(Text(
          request.startDate != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.tryParse(request.startDate.toString()) ?? DateTime.now())
              : ''
        )),
        DataCell(Text(
          request.endDate != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.tryParse(request.endDate.toString()) ?? DateTime.now())
              : ''
        )),
        // DataCell(Container(

        //   decoration: BoxDecoration(
        //     color: request.priority == 'high' ? Colors.red[300] : request.priority == 'medium' ? Colors.orange[300] : Colors.blue[300],
        //     borderRadius: BorderRadius.circular(4),
        //   ),
        //   child: Padding(

        //     padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 0),
        //     child: Center(child: Text(request.priority?? 'medium',
        //       style: const TextStyle(
        //         color: Colors.white),
        //     )),
        //   ))),
        DataCell(Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0),
          child: Container(
            width: 80,
            decoration: BoxDecoration(
              color: request.priority == 'high' ? Colors.red[300] : request.priority == 'medium' ? Colors.orange[300] : Colors.blue[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Text(
                  request.priority ?? 'medium',
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ),
        )),
        DataCell(Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0),
          child: Container(
            width: 80,
            decoration: BoxDecoration(
              color: request.status == 'approved' ? Colors.green : request.status == 'rejected' ? Colors.red:Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Text(
                  request.status ?? 'pending',
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ),
        )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye_outlined, size: 28),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseRequestView(
                      purchaseRequest: request, order: {}, onSave: (newOrder) {  },
                    ),
                  ),
                );
                await Provider.of<PurchaseRequestController>(context, listen: false).fetchRequests(context,Provider.of<UserController>(context, listen: false).currentUser);
              },
              tooltip: 'View',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 25),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: () async {
                // Build a lightweight Map for the edit page to avoid relying on a class method
                final Map<String, dynamic> requestMap = {
                  'id': request.id,
                  'start_date': request.startDate?.toIso8601String(),
                  'end_date': request.endDate?.toIso8601String(),
                  'title': request.title,
                  'description': request.description,
                  'status': request.status,
                  'priority': request.priority,
                  'products': request.products?.map((p) => p.toJson()).toList(),
                  'is_archived': request.isArchived ?? false,
                };

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestEditPage(
                      request: requestMap,
                      onSave: (updatedRequest) {},
                      purchaseRequest: request,
                      order: {},
                    ),
                  ),
                );
                Provider.of<PurchaseRequestController>(context, listen: false).fetchRequests(context,Provider.of<UserController>(context, listen: false).currentUser);
              },
              tooltip: 'Edit',
            ),
              IconButton(
                icon: const Icon(Icons.archive_outlined, size: 25),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final bool? confirmed = await showDialog<bool>(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.2),
                    builder: (context) => Dialog(
                      backgroundColor: const Color(0xF7F3F7FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340, minWidth: 260),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Archive Purchase Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                              const SizedBox(height: 16),
                              Text('Are you sure you want to archive request ${request.id}?', style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.deepPurple, fontSize: 16))),
                                  const SizedBox(width: 12),
                                  ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0), child: const Text('Archive', style: TextStyle(fontSize: 16))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  if (confirmed == true) {
                    try {
                      await Provider.of<PurchaseRequestController>(context, listen: false).archivePurchaseRequest(request.id!);
                      await Provider.of<PurchaseRequestController>(context, listen: false).fetchRequests(context, Provider.of<UserController>(context, listen: false).currentUser);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))), backgroundColor: const Color(0xFF7C3AED), content: Text('Purchase request ${request.id} archived')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))), backgroundColor: Colors.red, content: Text('Failed to archive purchase request: $e')));
                    }
                  }
                },
                tooltip: 'Archive',
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 25),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              color: Colors.black,
              tooltip: 'Delete',
              onPressed: () async {
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.2),
                  builder: (context) => Dialog(
                    backgroundColor: const Color(0xF7F3F7FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340, minWidth: 260),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Delete Purchase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                            const SizedBox(height: 16),
                            Text('Are you sure you want to delete ${request.id}?', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.deepPurple, fontSize: 16))),
                                const SizedBox(width: 12),
                                ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 237, 4, 4), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0), child: const Text('Delete', style: TextStyle(fontSize: 16))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                if (confirmed == true) {
                  try {
                    await Provider.of<PurchaseRequestController>(context, listen: false).deleteRequest(request.id!, context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))), backgroundColor: const Color.fromARGB(255, 26, 6, 243), content: Text('Purchase request ${request.id} deleted')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))), backgroundColor: const Color.fromARGB(255, 26, 6, 243), content: Text('Error deleting purchase request: $e')));
                  }
                }
              },
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => requests.length;

  @override
  int get selectedRowCount => 0;

  Null get selectedRow => null;
  
  Null get order => null;
}
