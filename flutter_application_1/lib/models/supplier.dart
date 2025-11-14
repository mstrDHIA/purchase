class Supplier {
  int? id;
  String? name;
  String? contactEmail;
  int? phoneNumber;
  String? address;
  DateTime? createdAt;
  DateTime? updatedAt;

  Supplier(
      {this.id,
      this.name,
      this.contactEmail,
      this.phoneNumber,
      this.address,
      this.createdAt,
      this.updatedAt});

  Supplier.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    contactEmail = json['contact_email'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['contact_email'] = this.contactEmail;
    data['phone_number'] = this.phoneNumber;
    data['address'] = this.address;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
