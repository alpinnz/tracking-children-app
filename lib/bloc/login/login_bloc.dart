import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../config/flavor_config.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../app/app_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService authService;
  final AppBloc appBloc;
  LoginBloc({@required this.authService, @required this.appBloc}) : super(LoginInitialState());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginSubmitEvent) {
      try {
        yield LoginLoadingState();

        final user = await authService.signInWithEmail(email: event.email, password: event.password);
        if (user is User) {
          final userModel = await authService.saveUser(user: user);
          if (userModel is UserModel) {
            if (FlavorConfig.isAdmin()) {
              if (userModel.role == 'admin') {
                appBloc..add(AppLoginEvent(user: user, userModel: userModel));
                yield LoginSuccessState(user: user, userModel: userModel);
                return;
              } else {
                authService.logOut();
              }
            }

            if (FlavorConfig.isUser()) {
              if (userModel.role == 'user') {
                appBloc..add(AppLoginEvent(user: user, userModel: userModel));
                yield LoginSuccessState(user: user, userModel: userModel);
                return;
              } else {
                authService.logOut();
              }
            }
          }
        }

        yield LoginFailedState(error: 'gagal login');
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'invalid-email':
            message = 'Email tidak valid';
            break;
          case 'weak-password':
            message = 'Password minimal 6 karakter';
            break;
          case 'network-request-failed':
            message = 'Kesalahan jaringan';
            break;
          case 'email-already-in-use':
            message = 'Email telah digunakan';
            break;
          case 'user-not-found':
            message = 'User tidak ditemukan';
            break;
          case 'wrong-password':
            message = 'Password salah';
            break;
          default:
            message = e.message;
            break;
        }
        yield LoginFailedState(error: '$message');
        print({'code': e.code, 'message': e.message});
      } catch (e) {
        print(e.toString());
        yield LoginFailedState(error: e.toString());
      }
    }
  }
}
