class PurchaseRequest {
  int? id;
  Null? startDate;
  Null? endDate;
  List<Products>? products;
  String? title = 'qqqqq';
  String? description = 'Description of the purchase request';

  PurchaseRequest({this.id, this.startDate, this.endDate, this.products});

  PurchaseRequest.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    id = json['id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
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
