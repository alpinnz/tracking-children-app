import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:tracking/models/user_model.dart';
import 'package:tracking/services/auth_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService authService;
  LoginBloc({@required this.authService}) : super(LoginInitialState());

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
            yield LoginSuccessState(user: user, userModel: userModel);
            return;
          }
        }

        yield LoginFailedState(error: 'gagal login');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          yield LoginFailedState(error: 'data tidak ada');
        } else if (e.code == 'wrong-password') {
          yield LoginFailedState(error: 'password salah');
        }
      } catch (e) {
        print(e.toString());
        yield LoginFailedState(error: e.toString());
      }
    }
  }
}
