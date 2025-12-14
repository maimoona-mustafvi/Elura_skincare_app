import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elura_skincare_app/utils/routes.dart';
import 'package:elura_skincare_app/services/firebase_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String name = "";
  bool changeButton = false;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> moveToHomePage(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        changeButton = true;
        isLoading = true;
      });

      try {
        // Sign in user
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        print('✅ User logged in: ${userCredential.user?.email}');

        // Clear form fields
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          name = "";
        });

        // Check if user has recommended routine
        bool hasRecommendedRoutine = await _checkIfUserHasRecommendedRoutine();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Login successful!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Small delay for better UX
        await Future.delayed(Duration(milliseconds: 500));

        // Navigate based on whether user has completed quiz
        if (mounted) {
          if (hasRecommendedRoutine) {
            print('📍 User has recommended routine → Navigate to Home');
            Navigator.pushReplacementNamed(context, MyRoutes.homeRoute);
          } else {
            print('📍 User has NO recommended routine → Navigate to Quiz Welcome');
            Navigator.pushReplacementNamed(context, MyRoutes.quizWelcomeRoute);
          }
        }

      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Login failed';

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts. Try again later';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid email or password';
            break;
        }

        print('❌ Login error: ${e.code}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

      } catch (e) {
        print('❌ Unexpected error: $e');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            changeButton = false;
            isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fix the errors in the form'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Check if user has a recommended routine in Firebase
  Future<bool> _checkIfUserHasRecommendedRoutine() async {
    try {
      print('🔍 Checking if user has recommended routine...');

      // Check if recommended routine exists
      bool hasRecommended = await _firebaseService.routineExists('Recommended Routine');
      bool hasAdjusted = await _firebaseService.routineExists('Adjusted Routine');

      bool hasRoutine = hasRecommended || hasAdjusted;

      if (hasRoutine) {
        print('✅ User has recommended/adjusted routine');
      } else {
        print('ℹ️ User has NO recommended routine - needs to take quiz');
      }

      return hasRoutine;

    } catch (e) {
      print('❌ Error checking recommended routine: $e');
      // If there's an error, assume no routine and redirect to quiz
      return false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFFAF7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.55,
                  child: Image.asset(
                    "assets/images/login_pic.jpg",
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image, size: 100, color: Colors.grey);
                    },
                  ),
                ),
                SizedBox(height: 30.0),
                Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter Email Address",
                          labelText: "Email Address",
                          filled: true,
                          fillColor: Color(0xFFEFE7E1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Email cannot be empty.";
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return "Please enter a valid email address.";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          name = value;
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          filled: true,
                          fillColor: Color(0xFFEFE7E1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Password cannot be empty.";
                          } else if (value.length < 6) {
                            return "Password length should be at least 6 characters.";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30.0),
                      InkWell(
                        splashColor: Color(0xFF9B8780),
                        onTap: isLoading ? null : () => moveToHomePage(context),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: changeButton ? 50 : 150,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isLoading ? Colors.grey : const Color.fromARGB(255, 227, 192, 162),
                            borderRadius: BorderRadius.circular(changeButton ? 50 : 8),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                              : changeButton
                              ? Icon(Icons.done, color: Colors.white)
                              : Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, MyRoutes.signupRoute);
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF9B8780),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}