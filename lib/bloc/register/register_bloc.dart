import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthService authService;
  RegisterBloc({@required this.authService}) : super(RegisterInitialState());

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is RegisterSubmitEvent) {
      try {
        yield RegisterLoadingState();

        final user = await authService.signupWithEmail(username: event.username, email: event.email, password: event.password);
        if (user is User) {
          authService.logOut();
          yield RegisterSuccessState();
          return;
        }

        yield RegisterFailedState(error: 'gagal Register');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          yield RegisterFailedState(error: 'password lemah');
        } else if (e.code == 'email-already-in-use') {
          yield RegisterFailedState(error: 'email telah digunakan');
        }
      } catch (e) {
        print(e.toString());
        yield RegisterFailedState(error: e.toString());
      }
    }
  }
}
