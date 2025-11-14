import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/purchase_order.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/screens/Purchase order/refuse_purchase_screen.dart';

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
    // final submittedDate = _order.startDate != null ? dateFormat.format(_order.startDate!) : '-';
    final dueDate = _order.endDate != null ? dateFormat.format(_order.endDate!) : '-';
    final status = _order.status ?? '-';
    final priority = _order.priority ?? '-';
    final note = _order.description ?? '';
    final products = _order.products ?? [];
    final userController = Provider.of<UserController>(context, listen: false);
    final purchaseOrderController = Provider.of<PurchaseOrderController>(context, listen: false);
    final isApproved = status.toLowerCase() == 'approved';
    final isRejected = status.toLowerCase() == 'rejected';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with back button and centered title
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back',
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Purchase Order',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Supplier name & Priority row (harmonized)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Supplier name'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: TextEditingController(text: products.isNotEmpty ? (products[0].supplier ?? '-') : '-'),
                          readOnly: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Priority'),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: priority.toLowerCase() == 'high'
                                ? Colors.red.shade100
                                : priority.toLowerCase() == 'medium'
                                    ? Colors.orange.shade100
                                    : priority.toLowerCase() == 'low'
                                        ? Colors.green.shade100
                                        : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priority.toLowerCase(),
                            style: TextStyle(
                              color: priority.toLowerCase() == 'high'
                                  ? Colors.red
                                  : priority.toLowerCase() == 'medium'
                                      ? Colors.orange
                                      : priority.toLowerCase() == 'low'
                                          ? Colors.green
                                          : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Due Date
              const Text('Due Date'),
              const SizedBox(height: 4),
              TextField(
                controller: TextEditingController(text: dueDate),
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black87),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 24),
              // Products section
              const Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...products.asMap().entries.map((entry) {
                final prod = entry.value;
                final unitPrice = prod.unitPrice ?? 0.0;
                final quantity = prod.quantity ?? 0;
                final totalPrice = unitPrice * quantity;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: TextEditingController(text: prod.product ?? '-'),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Product',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: TextEditingController(text: (prod.brand ?? '').toString()),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Brand',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: TextEditingController(text: quantity.toString()),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: TextEditingController(text: unitPrice.toStringAsFixed(2)),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Unit Price',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: TextEditingController(text: totalPrice.toStringAsFixed(2)),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Total Price',
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              // Note
              const Text('Note'),
              const SizedBox(height: 4),
              TextField(
                controller: TextEditingController(text: note),
                readOnly: true,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black87),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              // Status badge
              const Text('Status'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status.toLowerCase() == 'approved'
                      ? Colors.green.shade100
                      : status.toLowerCase() == 'pending'
                          ? Colors.orange.shade100
                          : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toLowerCase(),
                  style: TextStyle(
                    color: status.toLowerCase() == 'approved'
                        ? Colors.green
                        : status.toLowerCase() == 'pending'
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Accept/Refuse buttons (unchanged)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  if (!isApproved && !isRejected && (userController.currentUser.role?.id == 1 || userController.currentUser.role?.id == 6)) ...[
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
                        final result = await showDialog(
                          context: context,
                          builder: (context) => const RefusePurchaseDialog(),
                        );
                        if (result != null && result is Map && result['reason'] != null) {
                          try {
                            final updatedOrderJson = {
                              'id': _order.id,
                              'requested_by_user': _order.requestedByUser,
                              'approved_by': userController.currentUser.id,
                              'status': 'rejected',
                              'start_date': _order.startDate != null ? DateFormat('yyyy-MM-dd').format(_order.startDate!) : null,
                              'end_date': _order.endDate != null ? DateFormat('yyyy-MM-dd').format(_order.endDate!) : null,
                              'priority': _order.priority,
                              'description': result['reason'],
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
                                  description: result['reason'],
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
}
