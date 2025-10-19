import 'package:flutter/material.dart';
import 'package:elura_skincare_app/pages/login_page.dart';
import 'package:elura_skincare_app/pages/bottomNavBar.dart';
import 'package:elura_skincare_app/utils/routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elura Skincare',
      theme: ThemeData(
        primaryColor: Color(0xFF9B8780),
        scaffoldBackgroundColor: Color(0xFFFAF7F5),
      ),
      initialRoute: MyRoutes.loginRoute,
      routes: {
        MyRoutes.loginRoute: (context) => LoginPage(),
        MyRoutes.homeRoute: (context) => MainNavigation(),
      },
    );
  }
}