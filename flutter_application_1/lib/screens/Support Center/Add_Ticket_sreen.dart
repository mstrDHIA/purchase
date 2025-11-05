import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddTicketPage extends StatefulWidget {
  const AddTicketPage({super.key});

  @override
  State<AddTicketPage> createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String? _selectedPeriority;
  String? _selectedKeyword;
  String? _subject;
  PlatformFile? _pickedFile;
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = ['Technical', 'Billing', 'Support', 'Other'];
  final List<String> _periorities = ['High', 'Medium', 'Low'];
  final List<String> _keywords = ['Connection', 'Payment', 'Error', 'Request', 'Other'];
  int _selectedStatusIndex = 0;
  final List<String> _statuses = ['New', 'On hold', 'In progress', 'Treated'];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  void _saveTicket() {
    if (_formKey.currentState!.validate()) {
      final newTicket = {
        'id': '#${DateTime.now().millisecondsSinceEpoch}', // Génère un ID unique
        'subject': _subject ?? '',
        'requester': 'John smith', // Ou récupère le vrai utilisateur si besoin
        'category': _selectedCategory ?? '',
        'periority': _selectedPeriority ?? '',
        'createdOn': '${DateTime.now().day.toString().padLeft(2, '0')}/'
            '${DateTime.now().month.toString().padLeft(2, '0')}/'
            '${DateTime.now().year}',
        'status': _statuses[_selectedStatusIndex],
        'keywords': _selectedKeyword ?? '',
        'description': _descriptionController.text,
      };
      Navigator.of(context).pop(newTicket); // <-- renvoie le ticket à la page précédente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket added!')),
      );
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  Widget _statusTab(String label, int index) {
    final selected = _selectedStatusIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: selected ? Colors.blue[100] : Colors.white,
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          minimumSize: const Size(80, 36),
        ),
        onPressed: () {
          setState(() {
            _selectedStatusIndex = index;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: const [
                  Text(
                    'Support centre',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                  Spacer(),
                  // IconButton(
                  //   icon: const Icon(Icons.account_circle_outlined, size: 32),
                  //   onPressed: () {},
                  // ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Tickets',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Text(' / New', style: TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 18),
              // Actions & Status Tabs
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _saveTicket();
                      setState(() {
                        _selectedStatusIndex = 1; // Passe à "On hold" après ajout
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Add'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _cancel,
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                  const Spacer(),
                  for (int i = 0; i < _statuses.length; i++)
                    _statusTab(_statuses[i], i),
                ],
              ),
              const SizedBox(height: 24),
              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Category & Periority
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Category'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                items: _categories
                                    .map((cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat),
                                        ))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedCategory = val),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                ),
                                validator: (val) =>
                                    val == null ? 'Please select a category' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Periority'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedPeriority,
                                items: _periorities
                                    .map((p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(p),
                                        ))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedPeriority = val),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                ),
                                validator: (val) =>
                                    val == null ? 'Please select a periority' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Keywords & Subject
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Keywords'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedKeyword,
                                items: _keywords
                                    .map((k) => DropdownMenuItem(
                                          value: k,
                                          child: Text(k),
                                        ))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedKeyword = val),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                ),
                                validator: (val) =>
                                    val == null ? 'Please select a keyword' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Subject'),
                              const SizedBox(height: 6),
                              TextFormField(
                                onChanged: (val) => _subject = val,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                ),
                                validator: (val) =>
                                    val == null || val.isEmpty ? 'Please enter a subject' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Add file
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add file'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black45),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_pickedFile != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(_pickedFile!.name),
                                  ),
                                ElevatedButton(
                                  onPressed: _pickFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.black87,
                                    minimumSize: const Size(100, 32),
                                  ),
                                  child: const Text('Choose File'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _pickFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(120, 32),
                                  ),
                                  child: const Text('Drop this file'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Description
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      minLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Please enter a description' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}