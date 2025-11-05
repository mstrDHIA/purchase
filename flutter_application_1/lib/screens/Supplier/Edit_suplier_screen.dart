import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

class EditSupplierPage extends StatefulWidget {
  final String? email;
  final String? name;
  final String? category;
  final String? status;

  const EditSupplierPage({
    super.key,
    this.email,
    this.name,
    this.category,
    this.status,
  });

  @override
  State<EditSupplierPage> createState() => _EditSupplierPageState();
}

class _EditSupplierPageState extends State<EditSupplierPage> {
  final _formKey = GlobalKey<FormState>();
  String? doesDeliver;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController taxNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? _logoFile;
  Uint8List? _logoBytes;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with widget values
    emailController.text = widget.email ?? '';
    nameController.text = widget.name ?? '';
    categoryController.text = widget.category ?? '';
    // status is not used for any TextEditingController as per the provided code
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      emailController.text = args['email'] ?? '';
      nameController.text = args['name'] ?? '';
      categoryController.text = args['category'] ?? '';
      // ...
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildSectionTitle('Contact Information'),
                            _buildTextField(emailController, 'Email', validator: _validateEmail),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(nameController, 'Name Supplier', validator: _notEmptyValidator)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField(taxNumberController, 'Tax Number')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(phoneController, 'Phone Number')),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: _inputDecoration('Does deliver'),
                                    initialValue: doesDeliver,
                                    items: const [
                                      DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                                      DropdownMenuItem(value: 'No', child: Text('No')),
                                    ],
                                    onChanged: (v) => setState(() => doesDeliver = v),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSectionTitle('Company Information'),
                            Row(
                              children: [
                                Expanded(child: _buildLogoPicker()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField(categoryController, 'Category')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSectionTitle('Location'),
                            _buildTextField(positionController, 'Position'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: _mapButtonStyle(),
                                  onPressed: _openMap,
                                  child: const Text('Find on MAP'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: _mapButtonStyle(),
                                  onPressed: () async {
                                    // Pour la démo, ouvre Google Maps à la position actuelle (si tu as la géoloc, tu peux l'utiliser ici)
                                    const url = 'https://www.google.com/maps/search/?api=1&query=Current+Location';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Could not open the map.')),
                                      );
                                    }
                                  },
                                  child: const Text('Current position (GPS)'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(countryController, 'Country')),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField(cityController, 'City')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(stateController, 'State')),
                                const SizedBox(width: 16),
                                Expanded(child: _buildTextField(zipController, 'ZIP')),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(addressController, 'Address'),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildActionButton('Save', Colors.deepPurpleAccent, () {
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Supplier saved')),
                                    );
                                  }
                                }),
                                const SizedBox(width: 12),
                                _buildActionButton('Cancel', Colors.grey.shade300, () {
                                  Navigator.of(context).pop();
                                }, textColor: Colors.black),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      color: const Color(0xFFF4F4F6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _sidebarItem(Icons.home, 'Home', '/home'),
          _sidebarItem(Icons.dashboard, 'Dashboard', '/dashboard'),
          _sidebarItem(Icons.people, 'Users', '/users'),
          _sidebarItem(Icons.lock, 'Password', '/password'),
          _sidebarItem(Icons.add, 'Request Order', '/request_order'),
          _sidebarItem(Icons.shopping_cart, 'Purchase Order', '/purchase_order'),
          _sidebarItem(Icons.security, 'Roles and access', '/roles'),
          _sidebarItem(Icons.help, 'Support centre', '/support'),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      selected: ModalRoute.of(context)?.settings.name == route,
      selectedTileColor: const Color(0xFFD6D6F4),
      onTap: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      dense: true,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Text("Edit Supplier", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.account_circle, size: 36),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          tooltip: 'Profile',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 24),
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label),
      validator: validator,
    );
  }

  Widget _buildLogoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Logo', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 60,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: kIsWeb
                ? (_logoBytes != null
                    ? Image.memory(_logoBytes!, height: 40, fit: BoxFit.contain)
                    : Image.asset('assets/images/Company.jpg', height: 40, fit: BoxFit.contain))
                : (_logoFile != null
                    ? Image.file(_logoFile!, height: 40, fit: BoxFit.contain)
                    : Image.asset('assets/images/Company.jpg', height: 40, fit: BoxFit.contain)),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _pickLogo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade400,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Choose Logo'),
        ),
      ],
    );
  }

  ButtonStyle _mapButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade200,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed, {Color textColor = Colors.white}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(fontSize: 16, color: textColor)),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label.isNotEmpty ? label : null,
      filled: true,
      fillColor: const Color(0xFFEDEDED),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email';
    return null;
  }

  String? _notEmptyValidator(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  Future<void> _openMap() async {
    // Utilise la valeur du champ position si elle existe, sinon ouvre Google Maps
    final query = positionController.text.isNotEmpty
        ? Uri.encodeComponent(positionController.text)
        : '';
    final url = query.isNotEmpty
        ? 'https://www.google.com/maps/search/?api=1&query=$query'
        : 'https://www.google.com/maps';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the map.')),
      );
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _logoBytes = bytes;
        });
      } else {
        setState(() {
          _logoFile = File(pickedFile.path);
        });
      }
    }
  }
}
