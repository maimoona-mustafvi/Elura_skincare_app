import 'package:flutter/material.dart';
import 'package:elura_skincare_app/pages/home_page.dart';
import 'package:elura_skincare_app/pages/quiz_Page.dart';
import 'package:elura_skincare_app/pages/calender_Page.dart';
import 'package:elura_skincare_app/pages/logs_page.dart';
import 'package:elura_skincare_app/pages/reminders_page.dart';

class MainNavigation extends StatefulWidget {
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;
  final List<Widget> pages = [
    HomePage(),
    QuizPage(),
    CalendarPage(),
    LogPage(),
    RemindersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFAF7F5),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(Icons.home_outlined, 0),
              buildNavItem(Icons.quiz_outlined, 1),
              buildNavItem(Icons.calendar_today_outlined, 2),
              buildNavItem(Icons.description_outlined, 3),
              buildNavItem(Icons.notifications_outlined, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF9B8780) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Color(0xFF9B8780),
          size: 28,
        ),
      ),
    );
  }
}