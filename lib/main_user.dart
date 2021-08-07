import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

import 'bloc/app/app_bloc.dart';
import 'config/bloc_config.dart';
import 'config/flavor_config.dart';
import 'main_app.dart';
import 'models/location_model.dart';
import 'services/auth_service.dart';
import 'services/get_location_service.dart';

final AuthService authService = AuthService();

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = BlocConfig();

  await Firebase.initializeApp();

  await FlutterBackgroundService.initialize(onStart, autoStart: true, foreground: false);

  FlavorConfig(
    flavor: Flavor.USER,
    values: FlavorValues(
      baseUrl: '',
    ),
  );

  return runApp(
    BlocProvider(
      create: (context) => AppBloc(
        authService: authService,
      )..add(AppStartedEvent()),
      child: MainApp(),
    ),
  );
}

void onStart() async {
  bool isDisabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Location location = Location();

  final service = FlutterBackgroundService();

  service.onDataReceived.listen((event) {
    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
  });

  Timer.periodic(Duration(seconds: 10), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();
    service.setNotificationInfo(
      title: "My App Service",
      content: "Updated at ${DateTime.now()}",
    );

    if (isDisabled) {
      try {
        bool isSend = await authService.getIsSend();

        if (isSend) {
          try {
            bool hasUser = await authService.hasUser();
            if (hasUser) {
              User user = await authService.getUser();

              if (user != null) {
                try {
                  Position position = await _determinePosition();
                  print('position' + position.toJson().toString());
                  // final locationResult = geo.Geolocation.currentLocation(accuracy: geo.LocationAccuracy.best, inBackground: true);
                  // print('test' + locationResult.toString());

                  // Geolocation.locationUpdates(
                  //         // accuracy: LocationAccuracy.best,
                  //         displacementFilter: 10.0, // in meters
                  //         inBackground: true)
                  //     .listen((event) {});

                  // await location.enableBackgroundMode(enable: true);

                  // bool isBackground = await location.isBackgroundModeEnabled();

                  // if (isBackground) {
                  //   final locationData = await location.getLocation();

                  //   print('service location' + locationData.toString());
                  // } else {
                  //   print({'service': isDisabled, 'send': isSend, 'user': user.email, 'location': isBackground}.toString());
                  // }

                  // LocationModel locationModel = await GetLocationService(uid: user.uid).getLocation();
                  // if (locationModel != null) {
                  // } else {
                  //   print({'service': isDisabled, 'send': isSend, 'user': user.email, 'location': null}.toString());
                  // }
                } catch (e) {
                  print({'service': isDisabled, 'send': isSend, 'user': user.email, 'location': e.toString()}.toString());
                }
              } else {
                print({'service': isDisabled, 'send': isSend, 'username': null}.toString());
              }
            } else {
              print({'service': isDisabled, 'send': isSend, 'username': null}.toString());
            }
          } catch (e) {
            print({'service': isDisabled, 'send': isSend, 'username': e.toString()}.toString());
          }
        } else {
          print({'service': isDisabled, 'send': isSend}.toString());
        }
      } catch (e) {
        print({'service': isDisabled, 'send': e.toString()}.toString());
      }
    } else {
      print({'service': isDisabled}.toString());
    }
  });
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error('Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
