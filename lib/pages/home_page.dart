import 'package:flutter/material.dart';
import 'package:elura_skincare_app/utils/routes.dart';

class HomePage extends StatefulWidget{
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Welcome to Elura Skincare!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
