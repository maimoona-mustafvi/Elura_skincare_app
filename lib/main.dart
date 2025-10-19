// lib/main.dart
import 'package:flutter/material.dart';
import 'package:elura_skincare_app/pages/login_page.dart';
import 'package:elura_skincare_app/pages/bottomNavBar.dart';
import 'package:elura_skincare_app/utils/routes.dart';
import 'screens/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elura Skincare',
      theme: ThemeData(
        primaryColor: Color(0xFF9B8780),
        scaffoldBackgroundColor: Color(0xFFFAF7F5),
        fontFamily: 'Roboto',
      ),
      initialRoute: MyRoutes.loginRoute,
      routes: {
        MyRoutes.loginRoute: (context) => LoginPage(),
        MyRoutes.homeRoute: (context) => MainNavigation(),
        '/welcome': (context) => Welcome(),  
      },
    );
  }
}