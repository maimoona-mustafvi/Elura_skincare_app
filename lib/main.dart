import 'package:flutter/material.dart';
import 'package:elura_skincare_app/pages/login_page.dart';
import 'package:elura_skincare_app/pages/bottomNavBar.dart';
import 'package:elura_skincare_app/utils/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:elura_skincare_app/pages/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: "AIzaSyBwQLzlY8lNZ1HoRImlpX7h3QM5NdedwM0",
      authDomain: "elura-e49ee.firebaseapp.com",
      projectId: "elura-e49ee",
      storageBucket: "elura-e49ee.firebasestorage.app",
      messagingSenderId: "499664339630",
      appId: "1:499664339630:web:47cddd967f2438ddaf633f",
      measurementId: "G-F8ENHTHXFF"
  ),);
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
        MyRoutes.signupRoute: (context) => SignupPage(),
        MyRoutes.homeRoute: (context) => MainNavigation(),
      },
    );
  }
}