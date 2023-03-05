import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wedding_services_app/signup_screen.dart';
import 'package:wedding_services_app/tracking_screen.dart';

import 'component/round_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isVisible = false;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty ||
                                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                                    .hasMatch(value)) {
                              return 'Enter email';
                            } else
                              null;
                          },
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'example@gmail.com',
                            // prefixIcon: Icon(Icons.email_outlined)
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          obscureText: !_isVisible,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty ||
                                !RegExp(r'^[a-zA-Z0-9]{6,16}')
                                    .hasMatch(value)) {
                              return 'Enter Password';
                            } else
                              null;
                          },
                          controller: passwordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isVisible = !_isVisible;
                                });
                              },
                              icon: _isVisible
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                            ),
                            hintText: '******',
                            // prefixIcon: Icon(Icons.password_outlined)
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      )),
                ),
                SizedBox(height: 40),
                RoundButton(
                  loading: loading,
                  title: 'Login',
                  onTap: () {
                    Get.to(TrackingScreen());
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                    }
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                        onPressed: () {
                          Get.to(
                            SignUpScreen(),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ))
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
