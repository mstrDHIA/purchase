class PurchaseRequest {
  String? title;
  String? description;
  List<Products>? products;
  String? dueDate;
  String? priority;
  String? note;
  String? dateSubmitted;
  int? requestedBy;
  int? approvedBy;

  PurchaseRequest(
      {this.title,
      this.description,
      this.products,
      this.dueDate,
      this.priority,
      this.note,
      this.dateSubmitted,
      this.requestedBy,
      this.approvedBy});

  PurchaseRequest.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
    dueDate = json['dueDate'];
    priority = json['priority'];
    note = json['note'];
    dateSubmitted = json['dateSubmitted'];
    requestedBy = json['requested_by'];
    approvedBy = json['approved_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    data['dueDate'] = dueDate;
    data['priority'] = priority;
    data['note'] = note;
    data['dateSubmitted'] = dateSubmitted;
    data['requested_by'] = requestedBy;
    data['approved_by'] = approvedBy;
    return data;
  }
}

class Products {
  String? product;
  int? quantity;

  Products({this.product, this.quantity});

  Products.fromJson(Map<String, dynamic> json) {
    product = json['product'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product'] = product;
    data['quantity'] = quantity;
    return data;
  }
}
