import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ProductLine {
  String? product;
  String? brand;
  int quantity;
  double unitPrice;

  ProductLine({
    this.product,
    this.brand,
    this.quantity = 1,
    this.unitPrice = 12.33,
  });
}

class PurchaseOrderForm extends StatefulWidget {
  const PurchaseOrderForm({super.key, required Null Function(dynamic newOrder) onSave, required Map<String, dynamic> initialOrder});

  @override
  State<PurchaseOrderForm> createState() => _PurchaseOrderFormState();
}

class _PurchaseOrderFormState extends State<PurchaseOrderForm> {
  final List<ProductLine> productLines = [ProductLine()];
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  final List<String> suppliers = ['Supplier A', 'Supplier B', 'Supplier C'];
  final List<String> products = ['Product X', 'Product Y', 'Product Z'];
  final List<String> brands = ['Brand 1', 'Brand 2', 'Brand 3'];

  String? selectedSupplier;

  @override
  void initState() {
    super.initState();
    dueDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  double get totalPrice => productLines.fold(
      0, (sum, p) => sum + (p.unitPrice * p.quantity.toDouble()));

  @override
  void dispose() {
    noteController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Supplier Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSupplier,
              decoration: const InputDecoration(
                labelText: 'Supplier name',
                border: OutlineInputBorder(),
              ),
              items: suppliers
                  .map((sup) =>
                      DropdownMenuItem(value: sup, child: Text(sup)))
                  .toList(),
              onChanged: (val) => setState(() => selectedSupplier = val),
            ),
            const SizedBox(height: 24),

            const Text('Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...productLines.asMap().entries.map((entry) {
              int index = entry.key;
              ProductLine product = entry.value;
              return _buildProductLine(product, index);
            }).toList(),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C7AE6),
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    setState(() => productLines.add(ProductLine())),
              ),
            ),

            const SizedBox(height: 32),

            const Text('Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            TextFormField(
              controller: dueDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Due date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    dueDateController.text =
                        DateFormat('dd-MM-yyyy').format(pickedDate);
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Note',
                filled: true,
                fillColor: Color(0xFFF0F0F0),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C7AE6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductLine(ProductLine product, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: product.product,
                  decoration: const InputDecoration(
                    labelText: 'Product',
                    border: OutlineInputBorder(),
                  ),
                  items: products
                      .map((prod) =>
                          DropdownMenuItem(value: prod, child: Text(prod)))
                      .toList(),
                  onChanged: (val) => setState(() => product.product = val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: product.quantity.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() {
                    final parsed = int.tryParse(val);
                    if (parsed != null && parsed > 0) {
                      product.quantity = parsed;
                    }
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: product.brand,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                  items: brands
                      .map((brand) =>
                          DropdownMenuItem(value: brand, child: Text(brand)))
                      .toList(),
                  onChanged: (val) => setState(() => product.brand = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: product.unitPrice.toStringAsFixed(2),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Unit Price',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() {
                    final parsed = double.tryParse(val);
                    if (parsed != null && parsed >= 0) {
                      product.unitPrice = parsed;
                    }
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    '\$${(product.unitPrice * product.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                tooltip: 'Remove product line',
                onPressed: () {
                  if (productLines.length > 1) {
                    setState(() {
                      productLines.removeAt(index);
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFF0F0F0)),
            child: Text('Menu', style: TextStyle(color: Colors.black, fontSize: 24)),
          ),
          _buildDrawerItem(Icons.home, 'Home'),
          _buildDrawerItem(Icons.dashboard, 'Dashboard'),
          _buildDrawerItem(Icons.group, 'Users'),
          _buildDrawerItem(Icons.lock, 'Password'),
          _buildDrawerItem(Icons.request_quote, 'Request Order'),
          _buildDrawerItem(Icons.shopping_cart, 'Purchase Order'),
          _buildDrawerItem(Icons.lock_open, 'Roles and access'),
          _buildDrawerItem(Icons.support_agent, 'Support centre'),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.pop(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Purchase Order Form',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      actions: [
        // IconButton(
        //   icon: const Icon(Icons.person_outline, size: 28),
        //   onPressed: () => Navigator.of(context).push(
        //     // MaterialPageRoute(builder: (context) => ProfilePage(user: {})),
        //   ),
        //   tooltip: 'User Profile',
        // ),
      ],
    );
  }
}
