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
        products!.add(new Products.fromJson(v));
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    data['dueDate'] = this.dueDate;
    data['priority'] = this.priority;
    data['note'] = this.note;
    data['dateSubmitted'] = this.dateSubmitted;
    data['requested_by'] = this.requestedBy;
    data['approved_by'] = this.approvedBy;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product'] = this.product;
    data['quantity'] = this.quantity;
    return data;
  }
}
