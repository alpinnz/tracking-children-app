import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/register/register_bloc.dart';
import '../services/auth_service.dart';
import '../widget/c_button.dart';
import '../widget/c_input.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(authService: authService),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: <Widget>[
                        Text(
                          'Register Anak',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Divider(
                            thickness: 3,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Selamat datang',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w300,
                        fontSize: 24,
                        letterSpacing: 5,
                      ),
                    ),
                    SizedBox(height: 40),
                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CInput(
                            label: 'Username',
                            onChanged: (controller) {
                              setState(() {
                                controller = usernameController;
                              });
                            },
                            controller: usernameController,
                          ),
                          SizedBox(height: 16),
                          CInput(
                            label: 'Email',
                            onChanged: (controller) {
                              setState(() {
                                controller = emailController;
                              });
                            },
                            controller: emailController,
                          ),
                          SizedBox(height: 16),
                          CInput(
                            label: 'Password',
                            obscureText: true,
                            onChanged: (controller) {
                              setState(() {
                                controller = passwordController;
                              });
                            },
                            controller: passwordController,
                          ),
                          SizedBox(height: 20),
                          BlocConsumer<RegisterBloc, RegisterState>(
                            listener: (context, state) {
                              if (state is RegisterFailedState) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.error)),
                                );
                              }

                              if (state is RegisterSuccessState) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Register berhasil')),
                                );
                              }
                            },
                            builder: (context, state) {
                              return CButton(
                                loading: state is RegisterLoadingState,
                                label: 'Register',
                                onPressed: () {
                                  if (state is! RegisterLoadingState) {
                                    if (formKey.currentState.validate()) {
                                      String username = usernameController.text;
                                      String email = emailController.text;
                                      String password = passwordController.text;
                                      context.read<RegisterBloc>()..add(RegisterSubmitEvent(username: username, email: email, password: password));
                                    } else {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Tidak boleh kosong username, email, password')),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ]),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Sudah memiliki akun ?',
                          style: TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                        BlocBuilder<RegisterBloc, RegisterState>(
                          builder: (context, state) {
                            return GestureDetector(
                              onTap: () {
                                if (state is! RegisterLoadingState) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text('Login',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  )),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
