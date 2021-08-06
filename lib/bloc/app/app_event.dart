part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppStartedEvent extends AppEvent {}

class AppLoginEvent extends AppEvent {
  final User user;
  final UserModel userModel;
  AppLoginEvent({@required this.user, @required this.userModel});
}

class AppLogoutEvent extends AppEvent {}
