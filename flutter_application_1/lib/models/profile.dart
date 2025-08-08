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
      this.lastName,  int? userId});

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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bio'] = bio;
    data['location'] = location;
    data['country'] = country;
    data['state'] = state;
    data['city'] = city;
    data['zip_code'] = zipCode;
    data['address'] = address;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    return data;
  }
}
