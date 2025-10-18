import 'package:flutter/material.dart';
import 'package:elura_skincare_app/data/appData.dart';
import 'package:elura_skincare_app/models/routineModel.dart';

class AddRoutinePage extends StatefulWidget {
  @override
  State<AddRoutinePage> createState() => _AddRoutinePageState();
}

class _AddRoutinePageState extends State<AddRoutinePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController subtitleController = TextEditingController();
  List<TextEditingController> stepControllers = [TextEditingController()];
  void addStepField() {
    setState(() {
      stepControllers.add(TextEditingController());
    });
  }
  void removeStepField(int index) {
    setState(() {
      stepControllers.removeAt(index);
    });
  }
  void saveRoutine() {
    List<String> steps = [];
    for (var controller in stepControllers) {
      if (controller.text.isNotEmpty) {
        steps.add(controller.text);
      }
    }
    if (titleController.text.isEmpty || steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill title and at least one step')),
      );
      return;
    }
    Routine newRoutine = Routine(
      title: titleController.text,
      subtitle: subtitleController.text,
      image: 'assets/images/routine.jpg',
      steps: steps,
    );
    AppData.allRoutines.add(newRoutine);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Routine added successfully!')),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF7F5),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAF7F5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Routine',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              Text(
                'Routine Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Weekend Routine',
                  filled: true,
                  fillColor: Color(0xFFEFE7E1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Short Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: subtitleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Special care for weekends',
                  filled: true,
                  fillColor: Color(0xFFEFE7E1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Routine Steps',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Color(0xFF9B8780)),
                    onPressed: addStepField,
                  ),
                ],
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: stepControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stepControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Step ${index + 1}',
                              filled: true,
                              fillColor: Color(0xFFEFE7E1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        if (stepControllers.length > 1)
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => removeStepField(index),
                          ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9B8780),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Save Routine',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}