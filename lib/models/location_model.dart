class LocationModel {
  String uid;
  double accuracy;
  double latitude;
  double longitude;
  double altitude;
  double heading;
  double speed;
  double speedAccuracy;
  Address address;
  int createdAt;
  int updatedAt;

  LocationModel(
      {this.uid,
      this.accuracy,
      this.latitude,
      this.longitude,
      this.altitude,
      this.heading,
      this.speed,
      this.speedAccuracy,
      this.address,
      this.createdAt,
      this.updatedAt});

  LocationModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    accuracy = json['accuracy'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    altitude = json['altitude'];
    heading = json['heading'];
    speed = json['speed'];
    speedAccuracy = json['speedAccuracy'];
    address = json['address'] != null ? new Address.fromJson(json['address']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['accuracy'] = this.accuracy;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['altitude'] = this.altitude;
    data['heading'] = this.heading;
    data['speed'] = this.speed;
    data['speedAccuracy'] = this.speedAccuracy;
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Address {
  double elevation;
  String timezone;
  int geoNumber;
  int streetNumber;
  String streetAddress;
  String city;
  String countryCode;
  String countryName;
  String region;
  String postal;
  double distance;

  Address({
    this.elevation,
    this.timezone,
    this.geoNumber,
    this.streetNumber,
    this.streetAddress,
    this.city,
    this.countryCode,
    this.countryName,
    this.region,
    this.postal,
    this.distance,
  });

  Address.fromJson(Map<String, dynamic> json) {
    elevation = json['elevation'];
    timezone = json['timezone'];
    geoNumber = json['geoNumber'];
    streetNumber = json['streetNumber'];
    streetAddress = json['streetAddress'];
    city = json['city'];
    countryCode = json['countryCode'];
    countryName = json['countryName'];
    region = json['region'];
    postal = json['postal'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['elevation'] = this.elevation;
    data['timezone'] = this.timezone;
    data['geoNumber'] = this.geoNumber;
    data['streetNumber'] = this.streetNumber;
    data['streetAddress'] = this.streetAddress;
    data['city'] = this.city;
    data['countryCode'] = this.countryCode;
    data['countryName'] = this.countryName;
    data['region'] = this.region;
    data['postal'] = this.postal;
    data['distance'] = this.distance;
    return data;
  }
}
