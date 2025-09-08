import 'package:flutter_application_1/screens/Purchase order/purchase_form_screen.dart';

class PurchaseRequest {
  int? id;
  DateTime? startDate;
  DateTime? endDate;
  List<dynamic>? products;
  String? title;
  String? description;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? approvedBy;
  int? requestedBy;
  String? priority;

  PurchaseRequest(
      {this.id,
      this.startDate,
      this.endDate,
      this.products,
      this.title,
      this.description,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.approvedBy,
      this.requestedBy,
      this.priority
      });

  PurchaseRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startDate = DateTime.parse(json['start_date']);
    endDate = DateTime.parse(json['end_date']);
    products = (json['products'] as List<dynamic>?)
        ?.map((item) {
          return ProductLine(
            product: item['product'],
            brand: item['brand'],
            quantity: item['quantity'] ?? 1,
            unitPrice: (item['unit_price'] ?? 0).toDouble(),
          );
        })
        .toList();
    title = json['title'];
    description = json['description'];
    status = json['status'];
    createdAt = DateTime.parse(json['created_at']);
    updatedAt = DateTime.parse(json['updated_at']);
    approvedBy = json['approved_by'];
    requestedBy = json['requested_by'];
    priority = json['priority'];
  }

  // get priority => null;

  // get quantity => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['products'] = this.products;
    data['title'] = this.title;
    data['description'] = this.description;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['approved_by'] = this.approvedBy;
    data['requested_by'] = this.requestedBy;
    data['priority'] = this.priority;
    return data;
  }
}
