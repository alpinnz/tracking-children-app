import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/app/app_bloc.dart';
import 'config/bloc_config.dart';
import 'config/flavor_config.dart';
import 'main_app.dart';
import 'models/location.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';

final AuthService authService = AuthService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = BlocConfig();

  await Firebase.initializeApp();

  await FlutterBackgroundService.initialize(onStart, autoStart: true, foreground: false);

  FlavorConfig(
    appName: 'Lokasi Anak',
    flavor: Flavor.USER,
    values: FlavorValues(),
  );

  runApp(
    BlocProvider(
      create: (context) => AppBloc(authService: authService)..add(AppStartedEvent()),
      child: MainApp(),
    ),
  );
}

void onStart() async {
  bool isRunning = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final service = FlutterBackgroundService();

  Timer.periodic(Duration(seconds: 5), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();
    service.setNotificationInfo(
      title: "Lokasi Anak",
      content: "Updated at ${DateTime.now()}",
    );

    if (isRunning) {
      try {
        bool hasUser = await authService.hasUser();
        if (hasUser) {
          User user = await authService.getUser();

          if (user != null) {
            try {
              Location location = await LocatorService(uid: user.uid).getLocation();
              if (location is Location) {
                location.createdAt = DateTime.now().millisecondsSinceEpoch;
                location.updatedAt = DateTime.now().millisecondsSinceEpoch;
                LocatorService.saveLocation(location: location);
                print({'service': isRunning, 'email': user.email, 'location': location.toJson()});
              } else {
                print({'service': isRunning, 'email': user.email, 'location': null});
              }
            } catch (e) {
              print({'service': isRunning, 'email': user.email, 'location': e.toString()});
            }
          } else {
            print({'service': isRunning, 'email': null});
          }
        } else {
          print({'service': isRunning, 'email': null});
        }
      } catch (e) {
        print({'service': isRunning, 'email': e.toString()});
      }
    } else {
      print({'service': isRunning});
    }
  });
}
