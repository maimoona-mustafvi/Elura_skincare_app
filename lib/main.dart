import 'package:flutter/material.dart';
import 'screens/welcome.dart';

void main(){
  runApp(EluraApp());
}

class EluraApp extends StatelessWidget{
  const EluraApp({super.key});
  @override
  Widget build(BuildContext build){
    return MaterialApp(
      title:'Elura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 190, 168, 125),
        fontFamily: 'Roboto',
      ),
      home: Welcome(),

    );
    
  }
}