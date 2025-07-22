class Profile {
  int? id;
  String? bio;
  String? location;
  String? country;
  String? state;
  String? city;
  int? zipCode;
  String? address;
  String? firstName;
  String? lastName;

  Profile(
      {this.id,
      this.bio,
      this.location,
      this.country,
      this.state,
      this.city,
      this.zipCode,
      this.address,
      this.firstName,
      this.lastName, required int userId});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bio = json['bio'];
    location = json['location'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    zipCode = json['zip_code'];
    address = json['address'];
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['bio'] = this.bio;
    data['location'] = this.location;
    data['country'] = this.country;
    data['state'] = this.state;
    data['city'] = this.city;
    data['zip_code'] = this.zipCode;
    data['address'] = this.address;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    return data;
  }
}
