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
        yield RegisterFailedState(error: '$message');
        print({'code': e.code, 'message': e.message});
      } catch (e) {
        print(e.toString());
        yield RegisterFailedState(error: e.toString());
      }
    }
  }
}
