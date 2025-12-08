import 'package:flutter_application_1/screens/Purchase order/purchase_form_screen.dart';

class PurchaseRequest {
  int? id;
  DateTime? startDate;
  DateTime? endDate;
  List<ProductLine>? products;
  String? title;
  String? description;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? approvedBy;
  int? requestedBy;
  String? approvedByName;
  String? requestedByName;
  String? priority;

  bool? isArchived;

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
      this.priority,
      this.isArchived
      });

  PurchaseRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // Dates: check for null and parse
    startDate = json['start_date'] != null ? DateTime.tryParse(json['start_date'].toString()) : null;
    endDate = json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null;
    createdAt = json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null;
    updatedAt = json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null;
    // Products
    if (json['products'] is List) {
      products = (json['products'] as List).map((item) {
        if (item is ProductLine) return item;
        return ProductLine(
          product: item['product'],
          brand: item['brand'],
          family: item['family'] ?? item['family_name'] ?? item['category'] ?? null,
          subFamily: item['subFamily'] ?? item['sub_family'] ?? item['subcategory'] ?? null,
          quantity: item['quantity'] is int ? item['quantity'] : int.tryParse(item['quantity']?.toString() ?? '') ?? 1,
          unitPrice: item['unit_price'] is double
              ? item['unit_price']
              : (item['unit_price'] is int)
                  ? (item['unit_price'] as int).toDouble()
                  : double.tryParse(item['unit_price']?.toString() ?? '') ?? 0.0,
        );
      }).toList();
    } else {
      products = [];
    }
    title = json['title'];
    description = json['description'];
    status = json['status'];
    // Handle nested user objects for requested_by and approved_by
    if (json['requested_by'] is Map) {
      requestedBy = json['requested_by']['id'];
      // try to capture a display name if backend provides it
      requestedByName = (json['requested_by']['first_name'] ?? json['requested_by']['username'] ?? json['requested_by']['name'])?.toString();
    } else {
      requestedBy = json['requested_by'];
    }
    if (json['approved_by'] is Map) {
      approvedBy = json['approved_by']['id'];
      approvedByName = (json['approved_by']['first_name'] ?? json['approved_by']['username'] ?? json['approved_by']['name'])?.toString();
    } else {
      approvedBy = json['approved_by'];
    }
    priority = json['priority'];
    isArchived = json['is_archived'] ?? false;

  // get priority => null;

  // get quantity => null;

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = id;
  data['start_date'] = startDate?.toIso8601String();
  data['end_date'] = endDate?.toIso8601String();
  // Convert ProductLine objects to Map
  data['products'] = products?.map((item) => item.toJson()).toList();
  data['title'] = title;
  data['description'] = description;
  data['status'] = status;
  data['created_at'] = createdAt?.toIso8601String();
  data['updated_at'] = updatedAt?.toIso8601String();
  data['approved_by'] = approvedBy;
  data['requested_by'] = requestedBy;
  data['approved_by_name'] = approvedByName;
  data['requested_by_name'] = requestedByName;
  data['priority'] = priority;
  data['is_archived'] = isArchived ?? false;
  return data;
   }
}
}