class PurchaseOrder {
  int? id;
  int? requestedByUser;
  int? approvedBy;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? supplierDeliveryDate;
  List<dynamic>? products;
  String? title;
  String? description;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? priority;
  String? currency; // ISO code or currency label (e.g. 'USD', 'EUR' or 'Dollar')
  int? purchaseRequestId;
  String? refuseReason;
  bool? isArchived;

  PurchaseOrder(
      {this.id,
      this.requestedByUser,
      this.purchaseRequestId,
      this.approvedBy,
      this.startDate,
      this.endDate,
      this.products,
      this.title,
      this.description,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.priority,
      this.refuseReason,
      this.isArchived});

  PurchaseOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    requestedByUser = json['requested_by_user'];
    // Backwards-compatible parsing: accept both 'approved_by' and 'approved_by_user' field names
    approvedBy = json['approved_by'] ?? json['approved_by_user'] ?? json['approvedBy'];
    startDate = _parseDate(json['start_date'] ?? json['startDate']);
    endDate = _parseDate(json['end_date'] ?? json['endDate']);
    // Accept both snake_case and camelCase keys from different backends
    supplierDeliveryDate = _parseDate(json['supplier_delivery_date'] ?? json['supplierDeliveryDate']);
    purchaseRequestId = json['purchase_request_id'] ?? json['purchaseRequestId'] ?? json['purchase_request'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    title = json['title'];
    description = json['description'];
    // Accept status from either 'statuss' (existing) or 'status' (some backends)
    status = (json['statuss'] ?? json['status'])?.toString();
    createdAt = _parseDate(json['created_at']);
    updatedAt = _parseDate(json['updated_at']);
    priority = json['priority'];
    // Accept either 'currency' (ISO code) or older names
    currency = json['currency']?.toString() ?? json['currency_code']?.toString();
    refuseReason = json['refuse_reason'];
    isArchived = json['is_archived'] ?? false;
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
    data['supplier_delivery_date'] = supplierDeliveryDate?.toIso8601String();
    // Also provide camelCase key for compatibility
    data['supplierDeliveryDate'] = supplierDeliveryDate?.toIso8601String();
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['title'] = title;
    data['description'] = description;
    // Write both fields to maximize backend compatibility
    data['statuss'] = status;
    data['status'] = status;
    data['created_at'] = createdAt?.toIso8601String();
    data['updated_at'] = updatedAt?.toIso8601String();
    data['priority'] = priority;
    data['currency'] = currency;
    data['refuse_reason'] = refuseReason;
    data['is_archived'] = isArchived ?? false;
    purchaseRequestId != null ? data['purchase_request_id'] = purchaseRequestId : null;
    return data;
  }
}

class Products {
  String? product;
  int? quantity;
  String? brand;
  String? supplier;
  int? supplierId;
  double? price;
  double? unitPrice;
  String? unit; // unit of measure (e.g., pcs)
  String? family;
  String? subFamily;

  Products({this.product, this.quantity, this.brand, this.supplier, this.supplierId, this.price, this.unitPrice, this.unit, this.family, this.subFamily});

  Products.fromJson(Map<String, dynamic> json) {
    product = json['product'];
    quantity = json['quantity'];
    brand = json['brand'];
    final sup = json['supplier'];
    if (sup is Map) {
      supplier = sup['name']?.toString() ?? sup['supplier']?.toString();
      // try to capture supplier id if present
      supplierId = sup['id'] is int ? sup['id'] as int : (sup['id'] != null ? int.tryParse(sup['id'].toString()) : null);
    } else {
      supplier = sup?.toString();
    }
    // Also accept supplier_id at top-level (some payloads provide it separately)
    if (supplierId == null && json['supplier_id'] != null) {
      supplierId = json['supplier_id'] is int ? json['supplier_id'] as int : (json['supplier_id'] != null ? int.tryParse(json['supplier_id'].toString()) : null);
    }
    family = json['family'] ?? json['family_name'] ?? json['category'] ?? null;
    subFamily = json['subFamily'] ?? json['sub_family'] ?? json['subfamily'] ?? json['subcategory'] ?? null;
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
    // unit may be provided under different keys
    unit = json['unit']?.toString() ?? json['unit_name']?.toString() ?? json['unit_label']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product'] = product;
    data['quantity'] = quantity;
    data['brand'] = brand;
    data['supplier'] = supplier;
    if (supplierId != null) data['supplier_id'] = supplierId;
    data['family'] = family;
    data['subfamily'] = subFamily;
    data['price'] = price;
    data['unit_price'] = unitPrice;
    data['unit'] = unit;
    return data;
  }
}
