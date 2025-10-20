import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quizpage.dart';

class Welcome extends StatelessWidget{
  const Welcome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/elura_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child:
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            iconSize: 30,
                            color: Color.fromARGB(255, 37, 33, 25),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),),
                        SizedBox(height: 20),
                        Text(
                            "Welcome, user!",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 37, 33, 25),
                            )
                        ),
                        SizedBox(height:20),

                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(0, 215, 194, 173),
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(0, 189, 155, 175),
                                spreadRadius: 3,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            "Answer a few questions to get personalized skincare recommendations",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.lora(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color:  Color.fromARGB(255, 74, 60, 34),
                              height: 2,
                            ),
                          ),
                        ),
                        SizedBox(height:40),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QuizStart()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                            backgroundColor: Color.fromARGB(255, 179, 124, 43),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Start Quiz',
                            style: GoogleFonts.lora(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),),
                        )
                      ],
                    )) )
        )
    );
  }
}

