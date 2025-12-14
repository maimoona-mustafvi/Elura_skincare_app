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
    required this.products,  // Changed to required
  });

  @override
  State<StatefulWidget> createState() => _SymptomPageState();
}

class _SymptomPageState extends State<SymptomPage> {
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
          duration: Duration(seconds: 2),
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

    // Navigate to results
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
  Widget build(BuildContext context) {
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
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Question ${currentIndex + 1} of ${symptomQuestions.length}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFD4A574),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${((progress) * 100).round()}%",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFD4A574),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              color: Color(0xFFD4A574),
              backgroundColor: Colors.grey.shade200,
              minHeight: 6.0,
              borderRadius: BorderRadius.circular(3),
            ),
            SizedBox(height: 30),

            // Question
            Text(
              currentQuestion.question,
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),

            // Options
            Expanded(
              child: ListView.separated(
                itemCount: currentQuestion.options.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  String option = currentQuestion.options[index];
                  bool isSelected = selectedOption == option;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = option;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFFD4A574).withOpacity(0.1) : Colors.white,
                        border: Border.all(
                          color: isSelected ? Color(0xFFD4A574) : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: Color(0xFFD4A574).withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ] : [],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Color(0xFFD4A574) : Colors.grey.shade400,
                                width: isSelected ? 8 : 2,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Next Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD4A574),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  currentIndex == symptomQuestions.length - 1
                      ? 'Get Results'
                      : 'Next',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}