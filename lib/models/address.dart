class Address {
  String name;
  String street;
  String isoCountryCode;
  String country;
  String postalCode;
  String administrativeArea;
  String subAdministrativeArea;
  String locality;
  String subLocality;
  String thoroughfare;
  String subThoroughfare;

  Address({
    this.name,
    this.street,
    this.isoCountryCode,
    this.country,
    this.postalCode,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.locality,
    this.subLocality,
    this.thoroughfare,
    this.subThoroughfare,
  });

  Address.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    street = json['street'];
    isoCountryCode = json['isoCountryCode'];
    country = json['country'];
    postalCode = json['postalCode'];
    administrativeArea = json['administrativeArea'];
    subAdministrativeArea = json['subAdministrativeArea'];
    locality = json['locality'];
    subLocality = json['subLocality'];
    thoroughfare = json['thoroughfare'];
    subThoroughfare = json['subThoroughfare'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['street'] = this.street;
    data['isoCountryCode'] = this.isoCountryCode;
    data['country'] = this.country;
    data['postalCode'] = this.postalCode;
    data['administrativeArea'] = this.administrativeArea;
    data['subAdministrativeArea'] = this.subAdministrativeArea;
    data['locality'] = this.locality;
    data['subLocality'] = this.subLocality;
    data['thoroughfare'] = this.thoroughfare;
    data['subThoroughfare'] = this.subThoroughfare;
    return data;
  }
}
