import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';

import '../models/address.dart';
import '../models/location.dart';

class LocatorService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  static const LocationCollection = 'locations';
  String uid;

  StreamController<Location> _locationController = StreamController<Location>();
  Stream<Location> get locationStream => _locationController.stream;

  LocatorService({this.uid}) {
    Geolocator.requestPermission().then((granted) {
      if (granted == LocationPermission.always) {
        Geolocator.getPositionStream(intervalDuration: Duration(seconds: 3)).listen((Position position) async {
          if (position != null) {
            Location location = await createLocation(position: position);
            if (location != null) {
              _locationController.add(location);
            }
          }
        });
      }
    });
  }

  Future<Location> getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      return await createLocation(position: position, isAddress: true);
    } on Exception catch (e) {
      print('getLocation error: ${e.toString()}');
      return null;
    }
  }

  Future<Location> createLocation({@required Position position, bool isAddress = false}) async {
    Address address;
    if (isAddress) {
      address = await getAddress(latitude: position.latitude, longitude: position.longitude);
    }
    return Location(
      uid: uid,
      accuracy: position.accuracy,
      altitude: position.altitude,
      heading: position.heading,
      latitude: position.latitude,
      longitude: position.longitude,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy,
      address: address,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<Address> getAddress({@required double latitude, @required double longitude}) async {
    List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
    geocoding.Placemark geoPlacemark = placemarks.first;

    Address placemark = Address(
      name: geoPlacemark.name,
      street: geoPlacemark.street,
      isoCountryCode: geoPlacemark.isoCountryCode,
      country: geoPlacemark.country,
      postalCode: geoPlacemark.postalCode,
      administrativeArea: geoPlacemark.administrativeArea,
      subAdministrativeArea: geoPlacemark.subAdministrativeArea,
      locality: geoPlacemark.locality,
      subLocality: geoPlacemark.subLocality,
      thoroughfare: geoPlacemark.thoroughfare,
      subThoroughfare: geoPlacemark.subThoroughfare,
    );

    print('placemark ' + placemark.toJson().toString());

    return placemark;
  }

  static saveLocation({@required Location location}) async {
    print(location.toJson().toString());
    _db.collection(LocationCollection).add(location.toJson());
  }
}
