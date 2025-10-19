import 'package:flutter/material.dart';
import 'package:elura_skincare_app/data/appData.dart';
import 'package:elura_skincare_app/models/quickTipsModel.dart';
import 'package:elura_skincare_app/pages/routine_page.dart';
import 'package:elura_skincare_app/pages/AddRoutineForm.dart';
import 'package:elura_skincare_app/widgets/quickTipsDialogBox.dart';
import '../widgets/weather_card_dynamic.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFFAF7F5),
      endDrawer: Drawer(
        child: Container(
          color: Color(0xFFFAF7F5),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF9B8780),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(height: 30),
                ListTile(
                  leading: Icon(Icons.add_circle_outline, color: Color(0xFF9B8780)),
                  title: Text('Add Routine', style: TextStyle(fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddRoutinePage(),
                      ),
                    ).then((_) => setState(() {}));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Color(0xFF9B8780)),
                  title: Text('Sign Out', style: TextStyle(fontSize: 16)),
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Elura',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF9B8780),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Text(
                  "Today's Routine",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),

                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: AppData.allRoutines.length,
                  itemBuilder: (context, index) {
                    final routine = AppData.allRoutines[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoutineDetailPage(
                                routine: routine,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFFEFE7E1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      routine.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      routine.subtitle,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF9B8780),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: index % 2 == 0
                                      ? Color(0xFF8B8171)
                                      : Color(0xFFD5D5D5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    routine.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        index % 2 == 0
                                            ? Icons.wb_sunny
                                            : Icons.nightlight_round,
                                        color: Colors.white,
                                        size: 40,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 30),
                Text(
                  'Quick Tips',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppData.quickTips.map((tip) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => TipDialog(tip: tip),
                          );
                        },
                        child: Container(
                          width: 160,
                          margin: EdgeInsets.only(right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(tip.backgroundColor)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    tip.image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(Icons.lightbulb_outline,
                                            size: 50, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                tip.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                tip.subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9B8780),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 30),

                Text(
                  'Weather-Based Advice',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 15),

                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFEFE7E1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Sunny',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFF4A9FD8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.wb_sunny,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80), // Extra space for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }
}