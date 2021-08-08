import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking/models/location_model.dart';
import 'package:tracking/services/location_service.dart';

import 'bloc/app/app_bloc.dart';
import 'config/bloc_config.dart';
import 'config/flavor_config.dart';
import 'main_app.dart';
import 'services/auth_service.dart';
import 'services/geolocator_service.dart';

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
  bool isDisabled = false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final service = FlutterBackgroundService();

  Timer.periodic(Duration(seconds: 5), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();
    service.setNotificationInfo(
      title: "My App Service",
      content: "Updated at ${DateTime.now()}",
    );

    if (!isDisabled) {
      try {
        bool hasUser = await authService.hasUser();
        if (hasUser) {
          User user = await authService.getUser();

          if (user != null) {
            try {
              final locationModel = await GeolocatorService(uid: user.uid).getPosition();
              if (locationModel is LocationModel) {
                locationModel.createdAt = DateTime.now().millisecondsSinceEpoch;
                locationModel.updatedAt = DateTime.now().millisecondsSinceEpoch;
                LocationService.saveLocation(locationModel: locationModel);
                print({'service': !isDisabled, 'user': user.email, 'location': locationModel.toJson()}.toString());
              } else {
                print({'service': !isDisabled, 'user': user.email, 'location': null}.toString());
              }
            } catch (e) {
              print({'service': !isDisabled, 'user': user.email, 'location': e.toString()}.toString());
            }
          } else {
            print({'service': !isDisabled, 'username': null}.toString());
          }
        } else {
          print({'service': !isDisabled, 'username': null}.toString());
        }
      } catch (e) {
        print({'service': !isDisabled, 'username': e.toString()}.toString());
      }
    } else {
      print({'service': isDisabled}.toString());
    }
  });
}
