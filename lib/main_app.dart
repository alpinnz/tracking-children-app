import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/app/app_bloc.dart';
import 'config/flavor_config.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/user_dashboard_screen.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: FlavorConfig.instance.appName,
      home: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AppAuthenticatedState) {
            print(state.user.toJson().toString());
            if (FlavorConfig.isAdmin()) {
              if (state.user.role == 'admin') {
                return AdminDashboardScreen(user: state.user);
              } else {
                context.read<AppBloc>()..add(AppLogoutEvent());
              }
            }

            if (FlavorConfig.isUser()) {
              if (state.user.role == 'user') {
                return UserDashboardScreen(user: state.user);
              } else {
                context.read<AppBloc>()..add(AppLogoutEvent());
              }
            }
          }

          if (state is AppUnauthenticatedState) {
            return LoginScreen();
          }

          return Scaffold(
            body: Container(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
