import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Support Center/Add_Ticket.dart';

class SupportCenterPage extends StatefulWidget {
  const SupportCenterPage({super.key});

  @override
  State<SupportCenterPage> createState() => _SupportCenterPageState();
}

class _SupportCenterPageState extends State<SupportCenterPage> {
  String filter = 'All';
  String search = '';
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> tickets = [
    {
      'id': '#123',
      'subject': 'Cannot reset password',
      'requester': 'John smith',
      'category': 'aa',
      'periority': 'High',
      'createdOn': '18/02/2025',
      'status': 'Open',
    },
    {
      'id': '#124',
      'subject': 'Issue with logging in',
      'requester': 'John smith',
      'category': 'bb',
      'periority': 'Medium',
      'createdOn': '18/02/2025',
      'status': 'Resolved',
    },
    {
      'id': '#125',
      'subject': 'Payment not going thr..',
      'requester': 'John smith',
      'category': 'cc',
      'periority': 'Medium',
      'createdOn': '18/02/2025',
      'status': 'Pending',
    },
    {
      'id': '#126',
      'subject': 'Payment not going thr..',
      'requester': 'John smith',
      'category': 'dd',
      'periority': 'High',
      'createdOn': '18/02/2025',
      'status': 'Pending',
    },
    {
      'id': '#127',
      'subject': 'Issue with logging in',
      'requester': 'John smith',
      'category': 'ee',
      'periority': 'Low',
      'createdOn': '18/02/2025',
      'status': 'Resolved',
    },
    {
      'id': '#128',
      'subject': 'Issue with logging in',
      'requester': 'John smith',
      'category': 'ff',
      'periority': 'Medium',
      'createdOn': '18/02/2025',
      'status': 'Treated',
    },
  ];

  List<Map<String, dynamic>> get filteredTickets {
    return tickets.where((ticket) {
      final matchesFilter = filter == 'All' || ticket['status'] == filter;
      final matchesSearch = search.isEmpty ||
          ticket['subject'].toString().toLowerCase().contains(search.toLowerCase()) ||
          ticket['id'].toString().toLowerCase().contains(search.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Color _periorityColor(String periority) {
    switch (periority) {
      case 'High':
        return const Color.fromARGB(255, 110, 2, 2);
      case 'Medium':
        return const Color.fromARGB(255, 238, 183, 45);
      case 'Low':
        return const Color.fromARGB(255, 1, 83, 53);
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return const Color.fromARGB(255, 0, 42, 93);
      case 'Resolved':
        return const Color.fromARGB(255, 0, 71, 45);
      case 'Pending':
        return const Color(0xFFFBBF24);
      case 'Treated':
        return const Color(0xFF9CA3AF);
      default:
        return Colors.grey;
    }
  }

  void _onView(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ticket Details'),
        content: Text(
          'ID: ${ticket['id']}\n'
          'Subject: ${ticket['subject']}\n'
          'Requester: ${ticket['requester']}\n'
          'Category: ${ticket['category']}\n'
          'Periority: ${ticket['periority']}\n'
          'Created on: ${ticket['createdOn']}\n'
          'Status: ${ticket['status']}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onEdit(Map<String, dynamic> ticket) {
    final TextEditingController subjectController = TextEditingController(text: ticket['subject']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Ticket'),
        content: TextField(
          controller: subjectController,
          decoration: const InputDecoration(labelText: 'Subject'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                ticket['subject'] = subjectController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onDelete(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: Text('Are you sure you want to delete ticket ${ticket['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                tickets.remove(ticket);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title + Add Ticket
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Support centre',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddTicketPage()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6F4DBF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Tickets title
              const Text('Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),

              // Filters + Search
              Row(
                children: [
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(16),
                    isSelected: [
                      filter == 'All',
                      filter == 'Open',
                      filter == 'Pending',
                      filter == 'Resolved'
                    ],
                    onPressed: (index) {
                      setState(() {
                        switch (index) {
                          case 0:
                            filter = 'All';
                            break;
                          case 1:
                            filter = 'Open';
                            break;
                          case 2:
                            filter = 'Pending';
                            break;
                          case 3:
                            filter = 'Resolved';
                            break;
                        }
                      });
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('All'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Open'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Pending'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Resolved'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_alt_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filter coming soon!')),
                      );
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 180,
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          search = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        filled: true,
                        fillColor: const Color(0xFFEDEDED),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        search = searchController.text;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB7A6F7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Table header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Row(
                  children: const [
                    SizedBox(width: 50, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Requester', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Periority', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Created on', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 120),
                  ],
                ),
              ),

              // Table rows
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = filteredTickets[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              ticket['id'],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              ticket['subject'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ticket['requester'],
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ticket['category'],
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                            width: 210,
                            color: Colors.white,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 80,
                              ),

                              width: 80,
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                              decoration: BoxDecoration(
                                color: ticket['periority'] == 'High'
                                    ? const Color(0xFFF87171)
                                    : ticket['periority'] == 'Medium'
                                        ? const Color(0xFFFBBF24)
                                        : ticket['periority'] == 'Low'
                                            ? const Color(0xFFA7F3D0)
                                            : Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  ticket['periority'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ticket['createdOn'],
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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
                                ticket['status'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Tooltip(
                                  message: 'View',
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_red_eye_outlined, color: Color.fromARGB(255, 0, 0, 0)),
                                    onPressed: () => _onView(ticket),
                                  ),
                                ),
                                Tooltip(
                                  message: 'Edit',
                                  child: IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Color.fromARGB(255, 0, 0, 0)),
                                    onPressed: () => _onEdit(ticket),
                                  ),
                                ),
                                Tooltip(
                                  message: 'Delete',
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Color.fromARGB(255, 0, 0, 0)),
                                    onPressed: () => _onDelete(ticket),
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}