part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterSubmitEvent extends RegisterEvent {
  final String username;
  final String email;
  final String password;
  RegisterSubmitEvent({@required this.username, @required this.email, @required this.password});
}
