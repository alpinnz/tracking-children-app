import 'package:geocoder/model.dart';

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
    address = json['address'] != null ? new Address.fromMap(json['address']) : null;
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
      data['address'] = this.address.toMap();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
