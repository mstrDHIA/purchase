import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditTicketPage extends StatefulWidget {
  final Map<String, dynamic> ticket;
  const EditTicketPage({super.key, required this.ticket});

  @override
  State<EditTicketPage> createState() => _EditTicketPageState();
}

class _EditTicketPageState extends State<EditTicketPage> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [
    {
      "avatar": "https://randomuser.me/api/portraits/women/1.jpg",
      "name": "Amélie Laurent",
      "message": "I have reset the user's password, awaiting confirmation",
      "date": "15/05/2025 10:30",
      "isMe": "false",
    },
    {
      "avatar": "https://randomuser.me/api/portraits/men/2.jpg",
      "name": "Jasser b",
      "message": "Ticket transmis à l'équipe sécurité",
      "date": "15/05/2025 10:30",
      "isMe": "true",
    },
  ];

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      final now = DateTime.now();
      final formattedDate =
          "${now.day.toString().padLeft(2, '0')}/"
          "${now.month.toString().padLeft(2, '0')}/"
          "${now.year} "
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}";
      setState(() {
        _comments.add({
          "avatar": "https://randomuser.me/api/portraits/men/2.jpg",
          "name": "Jasser b",
          "message": text,
          "date": formattedDate, // <-- Fix: full date and time
          "isMe": "true",
        });
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Back button at the top
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Edit Ticket",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
              // Top right profile icon
              Row(
                children: [
                  Expanded(child: Container()),
                  // IconButton removed if you want to delete the profile icon
                ],
              ),
              // Ticket info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket['id'] ?? 'Id 123',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(
                              ticket['category'] ?? 'Planning',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Keywords', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(ticket['keywords'] ?? 'New request'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Created on', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(ticket['createdOn'] ?? '15/06/2025'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            const Text('Periority', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(
                              ticket['periority'] ?? 'High',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Subject', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text(
                              ticket['subject'] ?? 'aa',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Description button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8F96FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  elevation: 0,
                ),
                child: const Text('Description'),
              ),
              const SizedBox(height: 16),
              // Description box
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(height: 32),
              Divider(thickness: 1.2, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              // Comments
              for (final comment in _comments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _comment(
                    avatar: comment["avatar"]!,
                    name: comment["name"]!,
                    message: comment["message"]!,
                    date: comment["date"]!,
                    isMe: comment["isMe"] == "true",
                  ),
                ),
              const SizedBox(height: 24),
              // Comment input
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type your comment here...',
                        ),
                        onSubmitted: (_) => _addComment(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.black54),
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        Clipboard.setData(ClipboardData(text: _commentController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comment copied!')),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F96FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('Comment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _comment({
    required String avatar,
    required String name,
    required String message,
    required String date,
    required bool isMe,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          CircleAvatar(
            backgroundImage: NetworkImage(avatar),
            radius: 16,
          ),
        if (!isMe) const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        if (isMe) const SizedBox(width: 8),
        if (isMe)
          CircleAvatar(
            backgroundImage: NetworkImage(avatar),
            radius: 16,
          ),
      ],
    );
  }
}