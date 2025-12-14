import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elura_skincare_app/utils/routes.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isLoading = false;
  bool changeButton = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  createUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        isLoading = true;
        changeButton = true;
      });

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);

      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Signup failed';

        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email already registered';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Password is too weak';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email address';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
          changeButton = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Color(0xFFFAF7F5),
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
              SizedBox(height: 20.0),
              Text(
                "Create Account",
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
                        hintText: "Enter Email",
                        labelText: "Email",
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
                          return "Email is required";
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Create Password",
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
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "At least 6 characters";
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          return "Add uppercase letter";
                        }
                        if (!value.contains(RegExp(r'[0-9]'))) {
                          return "Add a number";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        labelText: "Confirm Password",
                        filled: true,
                        fillColor: Color(0xFFEFE7E1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Confirm your password";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.0),

                    InkWell(
                      splashColor: Color(0xFF9B8780),
                      onTap: isLoading ? null : () => createUser(context),
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
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Color(0xFF9B8780),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}