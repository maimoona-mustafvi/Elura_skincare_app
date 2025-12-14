import 'package:flutter/material.dart';
import 'symptomspage.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirebaseService _firebaseService = FirebaseService();

  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, String> _routineStatus = {};

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = DateTime.now();

    // Initialize with sample data (can be removed)
    _routineStatus[_normalizeDate(DateTime.now())] = 'completed';
    _routineStatus[_normalizeDate(DateTime.now().subtract(Duration(days: 1)))] = 'skipped';
    _routineStatus[_normalizeDate(DateTime.now().subtract(Duration(days: 2)))] = 'reaction';
    _routineStatus[_normalizeDate(DateTime.now().subtract(Duration(days: 3)))] = 'completed';
    _routineStatus[_normalizeDate(DateTime.now().subtract(Duration(days: 5)))] = 'completed';
    _routineStatus[_normalizeDate(DateTime.now().subtract(Duration(days: 7)))] = 'skipped';
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get recommended products from Firebase
  Future<List<Product>> _getRecommendedProducts() async {
    try {
      List<Product> products = await _firebaseService.fetchRecommendedProducts();

      if (products.isEmpty) {
        // Show message that no products found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No recommended products found. Complete the quiz first!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return [];
      }

      return products;
    } catch (e) {
      print('Error fetching products: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return [];
    }
  }

  List<DateTime> _getDaysInMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    final daysInMonth = lastDay.day;

    List<DateTime> days = [];
    for (int i = 0; i < daysInMonth; i++) {
      days.add(DateTime(date.year, date.month, i + 1));
    }

    int startingWeekday = firstDay.weekday;
    int emptyDays = startingWeekday - 1;

    for (int i = 0; i < emptyDays; i++) {
      days.insert(0, DateTime(date.year, date.month, 0));
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  void _selectDate(DateTime date) {
    if (date.month == _currentDate.month) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'January';
      case 2: return 'February';
      case 3: return 'March';
      case 4: return 'April';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'August';
      case 9: return 'September';
      case 10: return 'October';
      case 11: return 'November';
      case 12: return 'December';
      default: return '';
    }
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(Color(0xFF4CAF50), 'Completed'),
          _legendItem(Color(0xFFF44336), 'Skipped'),
          _legendItem(Color(0xFFFF9800), 'Reaction'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(DateTime date) {
    bool isCurrentMonth = date.month == _currentDate.month;
    bool isToday = isCurrentMonth &&
        _normalizeDate(date) == _normalizeDate(DateTime.now());
    bool isSelected = isCurrentMonth &&
        _normalizeDate(date) == _normalizeDate(_selectedDate);

    String? status = _routineStatus[_normalizeDate(date)];
    Color? dotColor;

    if (status == 'completed') {
      dotColor = Color(0xFF4CAF50);
    } else if (status == 'skipped') {
      dotColor = Color(0xFFF44336);
    } else if (status == 'reaction') {
      dotColor = Color(0xFFFF9800);
    }

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Container(
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFD4A574).withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isToday ? Border.all(color: Color(0xFFD4A574), width: 1.5) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isCurrentMonth ? '${date.day}' : '',
              style: TextStyle(
                fontSize: 18,
                color: isCurrentMonth
                    ? (isToday ? Color(0xFFD4A574) : Color(0xFF333333))
                    : Colors.grey.shade300,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            SizedBox(height: 4),
            if (dotColor != null && isCurrentMonth)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withOpacity(0.3),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRoutineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.spa,
                  size: 48,
                  color: Color(0xFFD4A574),
                ),
                SizedBox(height: 16),
                Text(
                  'Track Today\'s Routine',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Did you follow today\'s skincare routine?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 24),
                _dialogOptionButton(
                  context,
                  'Yes, completed my routine',
                  Icons.check_circle,
                  Color(0xFF4CAF50),
                  'completed',
                ),
                SizedBox(height: 12),
                _dialogOptionButton(
                  context,
                  'No, skipped today',
                  Icons.cancel,
                  Color(0xFFF44336),
                  'skipped',
                ),
                SizedBox(height: 12),

                // REACTION BUTTON - FIXED VERSION
                ElevatedButton(
                  onPressed: () {
                    // Close dialog first using root navigator
                    Navigator.of(context, rootNavigator: true).pop();

                    // Update status
                    _updateRoutineStatus('reaction');

                    // Start navigation process
                    _navigateToSymptomPage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9800),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Routine showed me reactions',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogOptionButton(BuildContext context, String text, IconData icon, Color color, String status) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _updateRoutineStatus(status);
          Navigator.of(context, rootNavigator: true).pop();
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  void _updateRoutineStatus(String status) {
    final today = DateTime.now();
    final normalizedDate = _normalizeDate(today);

    setState(() {
      _routineStatus[normalizedDate] = status;
      _selectedDate = today;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Routine status updated!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _navigateToSymptomPage() async {
    // Show loading indicator using root navigator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD4A574),
              strokeWidth: 3,
            ),
          ),
        );
      },
    );

    try {
      // Get products from Firebase
      List<Product> products = await _getRecommendedProducts();

      // Close loading indicator
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Small delay to ensure smooth transition
      await Future.delayed(Duration(milliseconds: 50));

      if (products.isNotEmpty && mounted) {
        // Navigate to symptom page with products
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SymptomPage(products: products),
          ),
        );

        // Refresh after returning
        if (mounted) setState(() {});
      } else if (mounted) {
        // Show message if no products
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No recommended products found. Please complete the quiz first.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if there's an error
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      print('Error navigating to symptom page: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> daysInMonth = _getDaysInMonth(_currentDate);
    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: Color(0xFFFAF7F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Routine Calendar',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_getMonthName(_currentDate.month)} ${_currentDate.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFD4A574),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: Color(0xFFD4A574), size: 28),
                    onPressed: () {
                      setState(() {
                        _currentDate = DateTime.now();
                        _selectedDate = DateTime.now();
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              _buildLegend(),
              SizedBox(height: 20),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFFFAF7F5),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_left, color: Color(0xFFD4A574), size: 28),
                              onPressed: _previousMonth,
                              padding: EdgeInsets.all(8),
                            ),
                            Text(
                              '${_getMonthName(_currentDate.month)} ${_currentDate.year}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_right, color: Color(0xFFD4A574), size: 28),
                              onPressed: _nextMonth,
                              padding: EdgeInsets.all(8),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        color: Colors.white,
                        child: Row(
                          children: weekdays.map((day) {
                            return Expanded(
                              child: Container(
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      Divider(height: 0, thickness: 1, color: Colors.grey.shade200),

                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: daysInMonth.length,
                            itemBuilder: (context, index) {
                              return _buildDayCell(daysInMonth[index]);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              if (_routineStatus.containsKey(_normalizeDate(_selectedDate)) &&
                  _selectedDate.month == _currentDate.month)
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getStatusColor(_routineStatus[_normalizeDate(_selectedDate)]!),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(_routineStatus[_normalizeDate(_selectedDate)]!).withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _getStatusIcon(_routineStatus[_normalizeDate(_selectedDate)]!),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _getStatusText(_routineStatus[_normalizeDate(_selectedDate)]!),
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: _routineStatus.containsKey(_normalizeDate(_selectedDate)) ? 20 : 0),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showRoutineDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD4A574),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_calendar, size: 22),
                      SizedBox(width: 12),
                      Text(
                        'Track Today\'s Routine',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Color(0xFF4CAF50);
      case 'skipped': return Color(0xFFF44336);
      case 'reaction': return Color(0xFFFF9800);
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed': return Icons.check;
      case 'skipped': return Icons.close;
      case 'reaction': return Icons.warning;
      default: return Icons.circle;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed': return 'You completed your routine';
      case 'skipped': return 'You skipped your routine';
      case 'reaction': return 'Routine caused skin reactions';
      default: return 'No data';
    }
  }
}