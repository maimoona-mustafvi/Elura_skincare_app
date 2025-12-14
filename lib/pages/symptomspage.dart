import 'package:elura_skincare_app/pages/quizresult.dart';
import 'package:flutter/material.dart';
import '../models/questions.dart';
import '../models/product.dart';
import '../services/symptom_analysis.dart';
import '../services/symptom_adjustment_service.dart';

class SymptomPage extends StatefulWidget {
  final List<Product> products;

  const SymptomPage({
    super.key,
    this.products = const [],
  });

  @override
  State<StatefulWidget> createState() => quizState();
}

class quizState extends State<SymptomPage> {
  int currentIndex = 0;
  final Map<int, String> userLogs = {};
  String selectedOption = '';

  final List<Questions> symptomQuestions = [
    Questions(
      question: "What symptoms are you experiencing?",
      options: [
        'Redness',
        'Burning / Stinging',
        'Breakouts',
        'Dry patches',
        'Itching',
        'None',
      ],
    ),
    Questions(
      question: "How severe are these symptoms?",
      options: [
        'Mild',
        'Moderate',
        'Severe',
      ],
    ),
    Questions(
      question: "When did the symptoms first appear?",
      options: [
        'Immediately after use',
        'Within 24 hours',
        'After 2–3 days',
        'After 4+ days',
      ],
    ),
    Questions(
      question: "Where are the symptoms located?",
      options: [
        'Entire face',
        'Cheeks',
        'Forehead',
        'Chin / jawline',
        'Around eyes',
      ],
    ),
    Questions(
      question: "Which product do you think caused it?",
      options: [
        'Cleanser',
        'Treatment',
        'Moisturizer',
        'Sunscreen',
        'Not sure',
      ],
    ),
    Questions(
      question: "How does your skin feel right after applying the products?",
      options: [
        'Comfortable',
        'Tight',
        'Warm',
        'Burning',
        'Itchy',
      ],
    ),
  ];

  void nextQuestion() {
    // 1️⃣ No option selected
    if (selectedOption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select an option before pressing next!"),
        ),
      );
      return;
    }

    // 2️⃣ Save answer
    userLogs[currentIndex] = selectedOption;

    // 3️⃣ More questions left
    if (currentIndex < symptomQuestions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = '';
      });
      return;
    }

    // 4️⃣ FINISHED → analyze symptoms
    final analysis = analyzeSymptoms(userLogs);

    final adjustedRoutine = SymptomAdjustmentService().adjustRoutine(
      currentRoutine: widget.products,
      analysis: analysis,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizRecommendations(
          userLogs: userLogs,
          questions: symptomQuestions,
          isAdjusted: true,
          adjustedProducts: adjustedRoutine,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext build) {
    final currentQuestion = symptomQuestions[currentIndex];
    final progress = (currentIndex + 1) / symptomQuestions.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Symptom Check",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Question ${currentIndex + 1} of ${symptomQuestions.length}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(210, 206, 156, 90),
                  )),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              color: Color.fromARGB(210, 206, 156, 90),
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
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    String option = currentQuestion.options[index];
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                        ));
                  }),
            ),
            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 55),
                backgroundColor: Color.fromARGB(210, 206, 156, 90),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                currentIndex == symptomQuestions.length - 1
                    ? 'Get Results'
                    : 'Next',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}