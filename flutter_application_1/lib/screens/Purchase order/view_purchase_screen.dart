import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_order.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';


/// Helper to wrap PurchaseOrderView with required providers if not already provided higher up.
/// Use this in your navigation or parent widget if you get ProviderNotFoundException.
/// Example usage:
/// Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseOrderView.withProviders(order: order)));
class PurchaseOrderView extends StatefulWidget {
  final PurchaseOrder order;
  const PurchaseOrderView({super.key, required this.order});

  static Widget withProviders({Key? key, required PurchaseOrder order, UserController? userController}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PurchaseOrderController()),
        if (userController != null)
          ChangeNotifierProvider.value(value: userController)
        else
          ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: PurchaseOrderView(key: key, order: order),
    );
  }

  @override
  State<PurchaseOrderView> createState() => _PurchaseOrderViewState();
}

class _PurchaseOrderViewState extends State<PurchaseOrderView> {
  late PurchaseOrder _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  /// Utilisez ce helper pour injecter le UserController global si besoin.
  static Widget withProviders({Key? key, required PurchaseOrder order, UserController? userController}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PurchaseOrderController()),
        if (userController != null)
          ChangeNotifierProvider.value(value: userController)
        else
          ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: PurchaseOrderView(key: key, order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final submittedDate = _order.startDate != null ? dateFormat.format(_order.startDate!) : '-';
    final dueDate = _order.endDate != null ? dateFormat.format(_order.endDate!) : '-';
    final status = _order.status ?? '-';
    final priority = _order.priority ?? '-';
    final note = _order.description ?? '';
    final products = _order.products ?? [];
    double totalOrderPrice = 0;

    final userController = Provider.of<UserController>(context, listen: false);
    final purchaseOrderController = Provider.of<PurchaseOrderController>(context, listen: false);
    final isApproved = status.toLowerCase() == 'approved';
    final isRejected = status.toLowerCase() == 'rejected';

    List<Widget> productRows = products.map((prod) {
      final quantity = prod.quantity ?? 0;
      final unitPrice = 0.0; // If you have unit price, add it to Products model and parse here
      final totalPrice = unitPrice * quantity;
      totalOrderPrice += totalPrice;
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              _buildField('Product', prod.product ?? '-', width: 120),
              const SizedBox(width: 8),
              _buildField('Quantity', quantity.toString(), width: 70),
              const SizedBox(width: 8),
              _buildField('Brand', prod.brand ?? '-', width: 90),
              const SizedBox(width: 8),
              _buildField('Unit Price', (prod.unitPrice ?? 0.0).toStringAsFixed(2), width: 90, prefix: '\$'),
              // _buildField('Unit Price', (prod.unitPrice ?? 0.0).toStringAsFixed(2), width: 90, prefix: '\$'),
            
              const SizedBox(width: 8),
              _buildField('Supplier', prod.supplier ?? '-', width: 100),
              const SizedBox(width: 8),
              // _buildField('Total Price', prod.price.toStringAsFixed(2), width: 100, prefix: '\$'),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Purchase Order Details'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        color: const Color(0xFFF8F8FC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // _buildField('Supplier', products.isNotEmpty ? (products[0].supplier ?? '-') : '-', width: 180),
                      // const SizedBox(width: 18),
                      _buildField('Submitted', submittedDate, width: 120),
                      const SizedBox(width: 18),
                      _buildField('Due', dueDate, width: 120),
                      const SizedBox(width: 18),
                      _buildChipField('Priority', priority, width: 100, color: _priorityColor(priority)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Products',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[700],
                ),
              ),
              const SizedBox(height: 8),
              ...productRows,
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topRight,
                child: _buildField(
                  'Total Price',
                  (() {
                    if (products.isEmpty) return '0.00';
                    final sum = products.fold<double>(0.0, (total, p) {
                      final price = (p.price is num) ? (p.price as num).toDouble() : 0.0;
                      return total + price;
                    });
                    return sum.toStringAsFixed(2);
                  })(),
                  width: 140,
                  prefix: '\$',
                ),
              ),
              const SizedBox(height: 24),
              Text('Note', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  note.isNotEmpty ? note : 'No notes for this order.',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildChipField('Status', status, width: 140, color: _statusColor(status)),
                  const Spacer(),
                  if (!isApproved && !isRejected && (userController.currentUser.role?.id == 1 || userController.currentUser.role?.id == 3)) ...[
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final updatedOrderJson = {
                            'id': _order.id,
                            'requested_by_user': _order.requestedByUser,
                            'approved_by': userController.currentUser.id,
                            'status': 'approved',
                            'start_date': _order.startDate != null ? DateFormat('yyyy-MM-dd').format(_order.startDate!) : null,
                            'end_date': _order.endDate != null ? DateFormat('yyyy-MM-dd').format(_order.endDate!) : null,
                            'priority': _order.priority,
                            'description': _order.description,
                            'products': (_order.products ?? []).map((p) => p.toJson()).toList(),
                            'title': _order.title ?? '',
                            'created_at': _order.createdAt != null ? DateFormat('yyyy-MM-dd').format(_order.createdAt!) : null,
                            'updated_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          };
                          await purchaseOrderController.updateOrder(updatedOrderJson);
                          await purchaseOrderController.fetchOrders();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order approved!'), backgroundColor: Colors.green),
                            );
                            setState(() {
                              _order = PurchaseOrder(
                                id: _order.id,
                                requestedByUser: _order.requestedByUser,
                                approvedBy: userController.currentUser.id,
                                status: 'Approved',
                                startDate: _order.startDate,
                                endDate: _order.endDate,
                                priority: _order.priority,
                                description: _order.description,
                                products: _order.products,
                                title: _order.title,
                                createdAt: _order.createdAt,
                                updatedAt: DateTime.now(),
                              );
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF635BFF),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Accept'),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final updatedOrderJson = {
                            'id': _order.id,
                            'requested_by_user': _order.requestedByUser,
                            'approved_by': userController.currentUser.id,
                            'status': 'rejected',
                            'start_date': _order.startDate != null ? DateFormat('yyyy-MM-dd').format(_order.startDate!) : null,
                            'end_date': _order.endDate != null ? DateFormat('yyyy-MM-dd').format(_order.endDate!) : null,
                            'priority': _order.priority,
                            'description': _order.description,
                            'products': (_order.products ?? []).map((p) => p.toJson()).toList(),
                            'title': _order.title ?? '',
                            'created_at': _order.createdAt != null ? DateFormat('yyyy-MM-dd').format(_order.createdAt!) : null,
                            'updated_at': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          };
                          await purchaseOrderController.updateOrder(updatedOrderJson);
                          await purchaseOrderController.fetchOrders();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order rejected!'), backgroundColor: Colors.red),
                            );
                            setState(() {
                              _order = PurchaseOrder(
                                id: _order.id,
                                requestedByUser: _order.requestedByUser,
                                approvedBy: userController.currentUser.id,
                                status: 'Rejected',
                                startDate: _order.startDate,
                                endDate: _order.endDate,
                                priority: _order.priority,
                                description: _order.description,
                                products: _order.products,
                                title: _order.title,
                                createdAt: _order.createdAt,
                                updatedAt: DateTime.now(),
                              );
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5),
                        foregroundColor: Colors.black87,
                        minimumSize: const Size(120, 44),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Refuse'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, {double width = 180, String prefix = ''}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.deepPurple.shade50),
            ),
            child: Text(
              '$prefix$value',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipField(String label, String value, {double width = 120, required Color color}) {
    // Custom design for "priority" and "status" chips to match your screenshot
    final v = value.toLowerCase();
    Color bg;
    Color fg;

    if (label.toLowerCase() == 'priority') {
      if (v == 'low') {
        bg = const Color(0xFF64B5F6); // blue
        fg = Colors.white;
      } else if (v == 'medium') {
        bg = const Color(0xFFFFB74D); // orange
        fg = Colors.white;
      } else if (v == 'high') {
        bg = const Color(0xFFE57373); // red
        fg = Colors.white;
      } else {
        bg = Colors.grey[300]!;
        fg = Colors.black;
      }
    } else if (label.toLowerCase() == 'status') {
      if (v == 'approved') {
        bg = const Color(0xFF4CAF50); // green
        fg = Colors.white;
      } else if (v == 'pending') {
        bg = const Color(0xFFFFB74D); // orange
        fg = Colors.white;
      } else if (v == 'rejected') {
        bg = const Color(0xFFEF5350); // red
        fg = Colors.white;
      } else {
        bg = Colors.grey[300]!;
        fg = Colors.black;
      }
    } else {
      bg = color;
      fg = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              v,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: fg,
                letterSpacing: 0.5,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red[300]!;
      case 'Medium':
        return Colors.orange[300]!;
      case 'Low':
        return Colors.green[300]!;
      default:
        return Colors.grey[400]!;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange[200]!;
      case 'Approved':
        return Colors.green[200]!;
      case 'Rejected':
        return Colors.red[200]!;
      default:
        return Colors.grey[300]!;
    }
  }
}
