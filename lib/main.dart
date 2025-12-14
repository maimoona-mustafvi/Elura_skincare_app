// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/app_initializer.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/quizwelcome.dart'; // Add this import
import 'utils/routes.dart';
import 'pages/signup.dart';
import 'pages/bottomNavBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBwQLzlY8lNZ1HoRImlpX7h3QM5NdedwM0",
        authDomain: "elura-e49ee.firebaseapp.com",
        databaseURL: "https://elura-e49ee-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "elura-e49ee",
        storageBucket: "elura-e49ee.firebasestorage.app",
        messagingSenderId: "499664339630",
        appId: "1:499664339630:web:47cddd967f2438ddaf633f",
        measurementId: "G-F8ENHTHXFF"
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elura Skincare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF9B8780),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF9B8780),
        ),
        useMaterial3: true,
      ),
      home: AuthWrapper(),
      routes: {
        MyRoutes.loginRoute: (context) => LoginPage(),
        MyRoutes.signupRoute: (context) => SignupPage(),
        MyRoutes.homeRoute: (context) => MainNavigation(),
        MyRoutes.quizWelcomeRoute: (context) => Welcome(),
      },
    );
  }
}

/// Wrapper to handle authentication state and initialization
class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AppInitializer _initializer = AppInitializer();
  bool _isInitializing = false;
  bool _initializationAttempted = false;
  Exception? _initializationError;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null && !_initializationAttempted) {
        print('👤 User logged in: ${user.email}');
        await _initializeUserData();
      } else if (user == null) {
        print('👤 User logged out');
        // Reset state when user logs out
        setState(() {
          _initializationAttempted = false;
          _initializationError = null;
          _isInitializing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen('Checking authentication...');
        }

        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // Show loading while initializing
          if (_isInitializing) {
            return _buildLoadingScreen('Setting up your skincare routine...');
          }

          // Show error if initialization failed
          if (_initializationError != null) {
            return _buildErrorScreen(_initializationError.toString());
          }

          // Show home if initialization completed successfully
          if (_initializationAttempted) {
            // Don't auto-navigate here - let login page handle routing
            return MainNavigation();
          }

          // Fallback to loading
          return _buildLoadingScreen('Loading...');
        }

        // User is not logged in
        return LoginPage();
      },
    );
  }

  /// Initialize user data on first login or app launch
  Future<void> _initializeUserData() async {
    if (_isInitializing || _initializationAttempted) return;

    setState(() => _isInitializing = true);
    _initializationError = null;

    try {
      print('🚀 Initializing user data...');
      await _initializer.initialize();
      print('✅ User data initialized successfully');

      setState(() {
        _isInitializing = false;
        _initializationAttempted = true;
      });
    } catch (e) {
      print('❌ Error initializing user data: $e');
      setState(() {
        _isInitializing = false;
        _initializationError = e as Exception;
      });
    }
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF7F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF9B8780),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF7F5),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                'Initialization Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initializationError = null;
                    _initializationAttempted = false;
                  });
                  _initializeUserData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9B8780),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}