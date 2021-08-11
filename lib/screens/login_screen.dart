import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app/app_bloc.dart';
import '../bloc/login/login_bloc.dart';
import '../config/flavor_config.dart';
import '../services/auth_service.dart';
import '../widget/c_button.dart';
import '../widget/c_input.dart';
import '../widget/c_will_pop_scope.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(authService: authService, appBloc: BlocProvider.of<AppBloc>(context)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CWillPopScope(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: <Widget>[
                          if (FlavorConfig.isAdmin())
                            Text(
                              'Login Orang Tua',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          if (FlavorConfig.isUser())
                            Text(
                              'Login Anak',
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
                          children: <Widget>[
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
                            BlocConsumer<LoginBloc, LoginState>(
                              listener: (context, state) {
                                if (state is LoginFailedState) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.error)),
                                  );
                                }

                                if (state is LoginSuccessState) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Login berhasil')),
                                  );
                                }
                              },
                              builder: (context, state) {
                                return CButton(
                                  loading: state is LoginLoadingState,
                                  label: 'Login',
                                  onPressed: () {
                                    if (state is! LoginLoadingState) {
                                      if (formKey.currentState.validate()) {
                                        String email = emailController.text;
                                        String password = passwordController.text;
                                        context.read<LoginBloc>()..add(LoginSubmitEvent(email: email, password: password));
                                      } else {
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Tidak boleh kosong email, password')),
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
                          if (FlavorConfig.isUser())
                            Text(
                              'Tidak punya akun ?',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          if (FlavorConfig.isUser())
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                return GestureDetector(
                                  onTap: () {
                                    if (state is! LoginLoadingState) {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                                    }
                                  },
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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
      ),
    );
  }
}
