import 'package:flutter/material.dart';
import 'Edit_Ticket.dart';

class ViewTicketPage extends StatelessWidget {
  final Map<String, dynamic> ticket;
  const ViewTicketPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket['id'] ?? '',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticket['subject'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _pillButton('Save', onTap: () {}),
                          const SizedBox(width: 12),
                          _pillButton('Edit', onTap: () async {
                            // Navigue vers la page d'édition avec les infos du ticket
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTicketPage(ticket: ticket),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Info grid
                  Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                      2: IntrinsicColumnWidth(),
                      3: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Text(
                              ticket['category'] ?? '',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Text('Created by', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Text(
                              ticket['requester'] ?? '',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Text('Periority', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: ticket['periority'] == 'High'
                                    ? const Color(0xFFF87171)
                                    : ticket['periority'] == 'Medium'
                                        ? const Color(0xFFFBBF24)
                                        : ticket['periority'] == 'Low'
                                            ? const Color(0xFFA7F3D0)
                                            : Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ticket['periority'] ?? '',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Text('Created on', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Text(ticket['createdOn'] ?? ''),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: ticket['status'] == 'Open'
                                    ? const Color(0xFF60A5FA)
                                    : ticket['status'] == 'Resolved'
                                        ? const Color(0xFF34D399)
                                        : ticket['status'] == 'Pending'
                                            ? const Color(0xFFFBBF24)
                                            : ticket['status'] == 'Treated'
                                                ? const Color(0xFF9CA3AF)
                                                : Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ticket['status'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(),
                          const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _pillButton(String label, {required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8F96FF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        elevation: 0,
      ),
      child: Text(label),
    );
  }
}
