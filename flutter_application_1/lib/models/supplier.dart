class Supplier {
  int? id;
  String? name;
  String? contactEmail;
  dynamic phoneNumber;
  String? address;
  String? codeFournisseur;
  String? matricule;
  String? cin;
  String? groupName;
  String? contactName;
  String? approvalStatus;
  DateTime? createdAt;
  DateTime? updatedAt;

  Supplier({
    this.id,
    this.name,
    this.contactEmail,
    this.phoneNumber,
    this.address,
    this.codeFournisseur,
    this.matricule,
    this.cin,
    this.groupName,
    this.contactName,
    this.approvalStatus,
    this.createdAt,
    this.updatedAt,
  });

  Supplier.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    contactEmail = json['contact_email'];
    phoneNumber = json['phone_number'] ?? json['phone'] ?? json['contact_phone'];
    address = json['address'];
    codeFournisseur = json['code_fournisseur'] ?? json['code'] ?? json['codeFournisseur'];
    matricule = json['matricule_fiscale'] ?? json['matricule'];
    cin = json['cin'];
    groupName = json['group_name'] ?? json['groupName'];
    contactName = json['contact_name'] ?? json['contactName'];
    approvalStatus = json['approval_status'] ?? json['status'];
    createdAt = json['created_at'] is String ? DateTime.tryParse(json['created_at']) : json['created_at'];
    updatedAt = json['updated_at'] is String ? DateTime.tryParse(json['updated_at']) : json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['contact_email'] = contactEmail;
    data['phone_number'] = phoneNumber;
    data['address'] = address;
    data['code_fournisseur'] = codeFournisseur;
    data['matricule_fiscale'] = matricule;
    data['cin'] = cin;
    data['group_name'] = groupName;
    data['contact_name'] = contactName;
    data['approval_status'] = approvalStatus;
    data['created_at'] = createdAt?.toIso8601String();
    data['updated_at'] = updatedAt?.toIso8601String();
    return data;
  }
}
