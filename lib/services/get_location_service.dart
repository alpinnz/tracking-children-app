import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart' as geocode;
import 'package:location/location.dart';

import '../models/location_model.dart';

class GetLocationService {
  final String uid;
  Location location = Location();

  StreamController<LocationModel> _locationController = StreamController<LocationModel>();
  Stream<LocationModel> get locationStream => _locationController.stream;

  GetLocationService({@required this.uid}) {
    // Request permission to use location
    location.requestPermission().then((granted) {
      if (granted != null) {
        location.onLocationChanged.listen((LocationData currentLocation) async {
          if (currentLocation != null) {
            final address = await getAddress(latitude: currentLocation.latitude, longitude: currentLocation.longitude);
            if (address is Address) {
              _locationController.add(
                LocationModel(
                  uid: uid,
                  accuracy: currentLocation.accuracy,
                  altitude: currentLocation.altitude,
                  heading: currentLocation.heading,
                  latitude: currentLocation.latitude,
                  longitude: currentLocation.longitude,
                  speed: currentLocation.speed,
                  speedAccuracy: currentLocation.speedAccuracy,
                  address: address,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                ),
              );
            }
          }
        });
      }
    });
  }

  Future<dynamic> getLocation() async {
    try {
      location.enableBackgroundMode(enable: true);
      print('getLocation ' + location.isBackgroundModeEnabled().toString());
      LocationModel locationModel;

      var userLocation = await location.getLocation();

      final address = await getAddress(latitude: userLocation.latitude, longitude: userLocation.longitude);

      if (address is Address) {
        locationModel = LocationModel(
          uid: uid,
          accuracy: userLocation.accuracy,
          altitude: userLocation.altitude,
          heading: userLocation.heading,
          latitude: userLocation.latitude,
          longitude: userLocation.longitude,
          speed: userLocation.speed,
          speedAccuracy: userLocation.speedAccuracy,
          address: address,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
      }

      return locationModel;
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
  }

  Future<Address> getAddress({@required double latitude, @required double longitude}) async {
    try {
      final String apiKey = 'AIzaSyBNPVnDltdELSusjJiacUGjuPdNmn0yCMQ';
      final address = await geocode.GeoCode(apiKey: apiKey).reverseGeocoding(latitude: latitude, longitude: longitude);

      if (address is geocode.Address) {
        return Address(
          elevation: address.elevation,
          timezone: address.timezone,
          geoNumber: address.geoNumber,
          streetNumber: address.streetNumber,
          streetAddress: address.streetAddress,
          city: address.city,
          countryCode: address.countryCode,
          countryName: address.countryName,
          region: address.region,
          postal: address.postal,
          distance: address.distance,
        );
      }
      return null;
    } catch (e) {
      print('getAddress : ${e.toString()}');
      return null;
    }
  }
}
