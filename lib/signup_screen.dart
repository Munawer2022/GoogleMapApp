import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'component/round_button.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');
    setState(() {
      _isPasswordEightCharacters = false;
      if (password.length >= 6) {
        _isPasswordEightCharacters = true;

        _isPasswordOneNumber = false;
        if (numericRegex.hasMatch(password)) {
          _isPasswordOneNumber = true;
        }
      }
    });
  }

  bool _isPasswordEightCharacters = false;
  bool _isPasswordOneNumber = false;
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
    return Scaffold(
      
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
                            return 'Create email';
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
                        onChanged: (password) {
                          onPasswordChanged(password);
                        },
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty ||
                              !RegExp(r'^[a-zA-Z0-9]{6,16}').hasMatch(value)) {
                            return 'Create password';
                          } else
                            null;
                        },
                        obscureText: !_isVisible,
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
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: _isPasswordEightCharacters
                            ? Colors.green
                            : Colors.transparent,
                        border: _isPasswordEightCharacters
                            ? Border.all(color: Colors.transparent)
                            : Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(50)),
                    child: Icon(Icons.check, color: Colors.white, size: 15),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Contains at least 6 characters'),
                ],
              ),
              SizedBox(height: 50),
              RoundButton(
                loading: loading,
                title: 'Sign Up',
                onTap: () {
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
                  Text("Already have an account?"),
                  TextButton(
                      onPressed: () {
                        Get.to(LoginScreen());
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ))
                ],
              ),
            ]),
      ),
    );
  }
}
