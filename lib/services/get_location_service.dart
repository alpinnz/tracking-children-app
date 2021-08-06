import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

import '../models/location_model.dart';

class GetLocationService {
  final String uid;
  LocationModel _currentLocation;
  var location = Location();

  StreamController<LocationModel> _locationController = StreamController<LocationModel>();
  Stream<LocationModel> get locationStream => _locationController.stream;

  GetLocationService({@required this.uid}) {
    location.serviceEnabled();
    // Request permission to use location
    location.requestPermission().then((granted) {
      if (granted != null) {
        // If granted listen to the onLocationChanged stream and emit over our controller
        location.onLocationChanged().listen((locationData) async {
          if (locationData != null) {
            final address = await getAddress(latitude: locationData.latitude, longitude: locationData.longitude);
            if (address is Address) {
              _locationController.add(
                LocationModel(
                  uid: uid,
                  accuracy: locationData.accuracy,
                  altitude: locationData.altitude,
                  heading: locationData.heading,
                  latitude: locationData.latitude,
                  longitude: locationData.longitude,
                  speed: locationData.speed,
                  speedAccuracy: locationData.speedAccuracy,
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
    location.serviceEnabled();
    try {
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

      print('teeee' + locationModel.toJson().toString());
      return locationModel;
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }
  }

  Future<Address> getAddress({@required double latitude, @required double longitude}) async {
    final coordinates = new Coordinates(latitude, longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);

    if (addresses is List<Address>) {
      var first = addresses.first;
      return first;
    }
    return null;
  }
}
