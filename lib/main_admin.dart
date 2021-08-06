import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking/config/bloc_config.dart';
import 'package:tracking/services/auth_service.dart';

import 'bloc/app/app_bloc.dart';
import 'config/flavor_config.dart';
import 'main_app.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final AuthService authService = AuthService();
  Bloc.observer = BlocConfig();

  FlavorConfig(
    flavor: Flavor.ADMIN,
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
