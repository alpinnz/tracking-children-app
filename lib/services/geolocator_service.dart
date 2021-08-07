import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart' as geocode;
import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

class GeolocatorService {
  final String uid;

  StreamController<LocationModel> _locationController = StreamController<LocationModel>();
  Stream<LocationModel> get locationStream => _locationController.stream;

  GeolocatorService({@required this.uid}) {
    Geolocator.checkPermission().then((granted) {
      if (granted == LocationPermission.always) {
        Geolocator.getPositionStream().listen((Position position) async {
          if (position != null) {
            final address = await getAddress(latitude: position.latitude, longitude: position.longitude);
            if (address is Address) {
              _locationController.add(
                LocationModel(
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
                ),
              );
            }
          }
        });
      }
    });
  }

  Future<dynamic> getPosition() async {
    try {
      LocationModel locationModel;

      // bool serviceEnabled;
      // LocationPermission permission;

      // Test if location services are enabled.
      // serviceEnabled = await Geolocator.isLocationServiceEnabled();
      // if (!serviceEnabled) {
      //   // Location services are not enabled don't continue
      //   // accessing the position and request users of the
      //   // App to enable the location services.
      //   return Future.error('Location services are disabled.');
      // }

      // permission = await Geolocator.checkPermission();
      // if (permission != LocationPermission.always) {
      //   permission = await Geolocator.requestPermission();
      //   if (permission == LocationPermission.denied) {
      //     // Permissions are denied, next time you could try
      //     // requesting permissions again (this is also where
      //     // Android's shouldShowRequestPermissionRationale
      //     // returned true. According to Android guidelines
      //     // your App should show an explanatory UI now.
      //     return Future.error('Location permissions are denied');
      //   }
      // }

      // if (permission == LocationPermission.deniedForever) {
      //   // Permissions are denied forever, handle appropriately.
      //   return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      // }

      // if (permission == LocationPermission.whileInUse) {
      //   return Future.error('Location permissions are whileInUse, we cannot request permissions.');
      // }

      Position position = await Geolocator.getCurrentPosition();
      if (position != null) {
        final address = await getAddress(latitude: position.latitude, longitude: position.longitude);

        if (address is Address) {
          locationModel = LocationModel(
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
