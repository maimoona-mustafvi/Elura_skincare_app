import 'package:flutter/material.dart';
import '../models/questions.dart';
import 'quizresult.dart';

class QuizStart extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => quizState();
}

class quizState extends State<QuizStart>{

  int currentIndex = 0;
  final Map<int, String> userLogs = {};
  String selectedOption = '';

  final List<Questions> questions = [
    Questions(
      question: "What's your skin type?",
      options: ['Normal', 'Oily', 'Dry', 'Combination', 'Sensitive'],
    ),
    Questions(
      question: "What is your main skin concern?",
      options: ['Acne', 'Pigmentation', 'Aging', 'Dryness', 'Redness'],
    ),
    Questions(
      question: "How sensitive is your skin?",
      options: ['Very Sensitive', 'Somewhat Sensitive', 'Not Sensitive', 'Normal', 'Very Tolerant'],
    ),
    Questions(
      question: "Do you have any skin conditions?",
      options: ['Eczema', 'Rosacea', 'Psoriasis', 'Dermatitis', 'None'],
    ),
    Questions(
      question: "What's your climate?",
      options: ['Hot & Humid', 'Cold & Dry', 'Moderate', 'Rainy', 'Desert'],
    ),
  ];

  void nextQuestion(){
    if(selectedOption != ''){
      userLogs[currentIndex] = selectedOption;
      if(currentIndex < questions.length-1){
        setState(() {
          currentIndex++;
          selectedOption =  '';
        });
      }
      else{
        Navigator.push(context,
          MaterialPageRoute(
              builder: (context) => QuizRecommendations(userLogs: userLogs, questions: questions)
          ),
        );
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                "Select an option before pressing next!",
              )));
    }
  }

  @override
  Widget build(BuildContext build){
    final currentQuestion = questions[currentIndex];
    final progress = (currentIndex+1)/questions.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color:Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Quiz",
          style: TextStyle(
            color: Colors.black,
          ),),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Question ${currentIndex+1} of ${questions.length}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                  )
              ),
            ),
            SizedBox(height: 8),

            LinearProgressIndicator(
              value: progress,
              color: Colors.orange,
              backgroundColor: Colors.grey,
              minHeight: 6.0,
            ),
            SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                currentQuestion.question,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height:20),

            Expanded(//error de raha cannot hit test render box that has never been laid out
              child:
              ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index){
                    String option = currentQuestion.options[index];
                    return Padding(//options are not spaced without this
                        padding :const EdgeInsets.symmetric(vertical: 6.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: RadioListTile<String>(
                            title: Text(
                              option,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            value: option,
                            groupValue: selectedOption,
                            onChanged: (value){//is not clickable without this
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                        ));
                  }),),

            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 55),
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                currentIndex == questions.length-1 ? 'Results' : 'Next',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),),
            )
          ],
        ),
      ),

    );

  }


}