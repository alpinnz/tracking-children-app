part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitialState extends AppState {}

class AppLoadingState extends AppState {}

class AppAuthenticatedState extends AppState {
  final User user;
  final UserModel userModel;
  AppAuthenticatedState({@required this.user, @required this.userModel});
}

class AppUnauthenticatedState extends AppState {
  final String error;
  AppUnauthenticatedState({@required this.error});
}
