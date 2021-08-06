part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {
  final User user;
  final UserModel userModel;
  LoginSuccessState({@required this.user, @required this.userModel});
}

class LoginFailedState extends LoginState {
  final String error;
  LoginFailedState({@required this.error});
}
