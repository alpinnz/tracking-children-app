import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking/models/location_model.dart';
import 'package:tracking/models/user_model.dart';
import 'package:tracking/services/auth_service.dart';
import 'package:tracking/config/bloc_config.dart';
import 'package:tracking/services/get_location_service.dart';
import 'package:tracking/services/location_service.dart';

import 'bloc/app/app_bloc.dart';
import 'config/flavor_config.dart';
import 'main_app.dart';

final AuthService authService = AuthService();

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = BlocConfig();

  await Firebase.initializeApp();

  await FlutterBackgroundService.initialize(onStart, autoStart: true, foreground: true);

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
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  UserModel userModel;
  service.onDataReceived.listen((event) {
    if (event["action"] == "startService" && event["UserModel"] != null) {
      userModel = UserModel.fromJson(event["UserModel"]);
      print('FlutterBackgroundService ' + userModel.toJson().toString());
    }

    if (event["action"] == "stopService") {
      userModel = null;
      service.stopBackgroundService();
    }
  });

  Timer.periodic(Duration(seconds: 10), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();
    service.setNotificationInfo(
      title: "My App Service",
      content: "Updated at ${DateTime.now()}",
    );

    bool isSend = await authService.getIsSend();
    if (isSend) {
      if (userModel != null) {
        try {
          LocationModel locationModel = await GetLocationService(uid: userModel.uid).getLocation();

          print('locationModel asdads' + locationModel.toJson().toString() + 'aasdasdaxx');
        } catch (e) {
          print('locationModel asdads' + e.toString());
        }

        // if (locationModel is LocationModel) {
        //   LocationService.saveLocation(locationModel: locationModel);
        //   final data = {"location": locationModel.toJson()};
        //   print(data.toString());
        //   // service.sendData(data);
        // } else {
        //   final data = {"error": 'failed location'};
        //   print(data.toString());
        //   // service.sendData(data);
        // }
      } else {
        final data = {"error": 'failed user'};
        print(data.toString());
        // service.sendData(data);
      }
    } else {
      final data = {"current_date": DateTime.now().toIso8601String()};
      print(data.toString());
      // service.sendData(data);
    }
  });
}
