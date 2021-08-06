import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracking/bloc/login/login_bloc.dart';
import 'package:tracking/services/auth_service.dart';
import 'package:tracking/widget/c_button.dart';
import 'package:tracking/widget/c_input.dart';
import '../config/flavor_config.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();

  DateTime currentBackPressTime;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to leave')),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(authService: authService),
      child: Scaffold(
        backgroundColor: Colors.redAccent,
        body: WillPopScope(
          onWillPop: onWillPop,
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
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          if (FlavorConfig.isUser())
                            Text(
                              'Login Anak',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Divider(
                              thickness: 3,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Selamat datang',
                        style: TextStyle(
                          color: Colors.white,
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
                                          SnackBar(content: Text('tidak boleh kosong email, password')),
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
                              'Don\'t have account ?',
                              style: TextStyle(color: Colors.white),
                            ),
                          if (FlavorConfig.isUser())
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                              },
                              child: Text(
                                'Register Now',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
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
