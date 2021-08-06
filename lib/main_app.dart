import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking/bloc/app/app_bloc.dart';

import 'config/flavor_config.dart';
import 'models/user_model.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'services/auth_service.dart';

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: FlavorConfig.instance.name,
      // home: MainScreen(),
      home: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AppAuthenticatedState) {
            print(state.userModel.toJson().toString());
            if (FlavorConfig.isAdmin()) {
              if (state.userModel.role == 'admin') {
                return AdminDashboardScreen(userModel: state.userModel);
              }
            }

            if (FlavorConfig.isUser()) {
              if (state.userModel.role == 'user') {
                return UserDashboardScreen(userModel: state.userModel);
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

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // UserService.saveUser(user: snapshot.data, username: 'username');
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection(AuthService.UserCollection).doc(snapshot.data.uid).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final userDoc = snapshot.data;
                final user = userDoc.data();
                UserModel userModel = UserModel.fromJson(user);
                if (FlavorConfig.isAdmin()) {
                  if (user['role'] == 'admin') {
                    return AdminDashboardScreen(userModel: userModel);
                  } else {
                    // AuthService.logOut();
                  }
                }

                if (FlavorConfig.isUser()) {
                  if (user['role'] == 'user') {
                    return UserDashboardScreen(userModel: userModel);
                  } else {
                    // AuthService.logOut();
                  }
                }
              }
              return Material(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        }
        return LoginScreen();
      },
    );
  }
}
