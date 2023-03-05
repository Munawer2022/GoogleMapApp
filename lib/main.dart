import 'package:flutter/material.dart';
import 'package:wedding_services_app/search_location_screen.dart';
import 'package:wedding_services_app/signup_screen.dart';
import 'package:wedding_services_app/theme.dart';
import 'package:wedding_services_app/tracking_screen.dart';

import 'login_screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightTheme(context),
      home: const SignUpScreen(),
    );
  }
}
