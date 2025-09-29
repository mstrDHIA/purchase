class PurchaseOrder {
  int? id;
  int? requestedByUser;
  int? approvedBy;
  DateTime? startDate;
  DateTime? endDate;
  List<dynamic>? products;
  String? title;
  String? description;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? priority;

  PurchaseOrder(
      {this.id,
      this.requestedByUser,
      this.approvedBy,
      this.startDate,
      this.endDate,
      this.products,
      this.title,
      this.description,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.priority});

  PurchaseOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    requestedByUser = json['requested_by_user'];
    approvedBy = json['approved_by'];
    startDate = _parseDate(json['start_date']);
    endDate = _parseDate(json['end_date']);
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    title = json['title'];
    description = json['description'];
    status = json['status'];
    createdAt = _parseDate(json['created_at']);
    updatedAt = _parseDate(json['updated_at']);
    priority = json['priority'];
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['requested_by_user'] = requestedByUser;
    data['approved_by'] = approvedBy;
    data['start_date'] = startDate?.toIso8601String();
    data['end_date'] = endDate?.toIso8601String();
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['title'] = title;
    data['description'] = description;
    data['status'] = status;
    data['created_at'] = createdAt?.toIso8601String();
    data['updated_at'] = updatedAt?.toIso8601String();
    data['priority'] = priority;
    return data;
  }
}

class Products {
  String? product;
  int? quantity;
  String? brand;
  String? supplier;
  double? price;
  double? unitPrice;

  Products({this.product, this.quantity, this.brand, this.supplier, this.price, this.unitPrice});

  Products.fromJson(Map<String, dynamic> json) {
    product = json['product'];
    quantity = json['quantity'];
    brand = json['brand'];
    supplier = json['supplier'];
    price = (json['price'] is int)
        ? (json['price'] as int).toDouble()
        : (json['price'] is double)
            ? json['price']
            : double.tryParse(json['price']?.toString() ?? '');
    unitPrice = (json['unit_price'] is int)
        ? (json['unit_price'] as int).toDouble()
        : (json['unit_price'] is double)
            ? json['unit_price']
            : double.tryParse(json['unit_price']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product'] = product;
    data['quantity'] = quantity;
    data['brand'] = brand;
    data['supplier'] = supplier;
    data['price'] = price;
    data['unit_price'] = unitPrice;
    return data;
  }
}
