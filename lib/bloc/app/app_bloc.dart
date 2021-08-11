import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:meta/meta.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final AuthService authService;
  AppBloc({@required this.authService}) : super(AppInitialState());

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if (event is AppStartedEvent) {
      try {
        final bool hasUser = await authService.hasUser();

        if (hasUser) {
          final firebase_auth.User firebaseAuthUser = await authService.getUser();
          final User user = await authService.saveUser(firebaseAuthUser: firebaseAuthUser);
          if (user is User) {
            yield AppAuthenticatedState(user: user);
          } else {
            yield AppUnauthenticatedState(error: 'gagal check');
          }
        } else {
          yield AppUnauthenticatedState(error: 'tidak login');
        }
      } catch (e) {
        yield AppUnauthenticatedState(error: e.toString());
      }
    }

    if (event is AppLoginEvent) {
      try {
        yield AppLoadingState();
        yield AppAuthenticatedState(user: event.user);
      } catch (e) {
        yield AppUnauthenticatedState(error: e.toString());
      }
    }

    if (event is AppLogoutEvent) {
      try {
        yield AppLoadingState();
        await authService.logOut();
        yield AppUnauthenticatedState(error: 'telah logout');
      } catch (e) {
        yield AppUnauthenticatedState(error: e.toString());
      }
    }
  }
}
