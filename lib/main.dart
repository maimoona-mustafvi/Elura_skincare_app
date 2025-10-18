import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:elura_skincare_app/pages/login_page.dart';
import 'package:elura_skincare_app/utils/routes.dart';
import 'package:elura_skincare_app/pages/home_page.dart'; // <-- Make sure you import this

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Online Shopping Store",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => LoginPage(),
        "/home": (context) => HomePage(),
        MyRoutes.loginRoute: (context) => LoginPage(),
        MyRoutes.homeRoute: (context) => HomePage(),
      },
    );
  }
}
