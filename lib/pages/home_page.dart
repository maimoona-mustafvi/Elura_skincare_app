import 'package:flutter/material.dart';
import 'package:elura_skincare_app/data/appData.dart';
import 'package:elura_skincare_app/models/quickTipsModel.dart';
import 'package:elura_skincare_app/models/routineModel.dart';
import 'package:elura_skincare_app/pages/routine_page.dart';
import 'package:elura_skincare_app/pages/AddRoutineForm.dart';
import 'package:elura_skincare_app/widgets/quickTipsDialogBox.dart';
import 'package:elura_skincare_app/services/firebase_service.dart';
import '../widgets/weather_card_dynamic.dart';
import 'bottomNavBar.dart';
import 'login_page.dart'; // ADD THIS IMPORT

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseService _firebaseService = FirebaseService();

  List<Routine> _routines = [];
  List<Tip> _quickTips = [];
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    print('done');
    _initializeApp();
  }

  /// Initialize app: Set up Firebase data and fetch everything
  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);

    try {
      // Step 1: Initialize default data in Firebase (only happens once for new users)
      if (!_isInitialized) {
        print('🔄 Initializing app data...');
        await _firebaseService.initializeDefaultData(
          [AppData.morningRoutine, AppData.eveningRoutine],
          AppData.quickTips,
        );
        _isInitialized = true;
      }

      // Step 2: Fetch all data from Firebase
      await _fetchAllData();

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error initializing app: $e');

      // Fallback to local data if Firebase fails
      _routines = [AppData.morningRoutine, AppData.eveningRoutine];
      _quickTips = AppData.quickTips;

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Using offline data. Check your connection.')),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Fetch all data from Firebase
  Future<void> _fetchAllData() async {
    try {
      // Fetch routines
      final fetchedRoutines = await _firebaseService.fetchRoutines();

      // Fetch quick tips
      final fetchedTips = await _firebaseService.fetchQuickTips();

      // Use fetched data or fallback to defaults
      _routines = fetchedRoutines.isNotEmpty
          ? fetchedRoutines
          : [AppData.morningRoutine, AppData.eveningRoutine];

      _quickTips = fetchedTips.isNotEmpty
          ? fetchedTips
          : AppData.quickTips;

      print('✅ Data loaded: ${_routines.length} routines, ${_quickTips.length} tips');

      setState(() {});
    } catch (e) {
      print('❌ Error fetching data: $e');
      rethrow;
    }
  }

  /// Refresh data from Firebase
  Future<void> _refreshData() async {
    try {
      await _fetchAllData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Data refreshed successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error refreshing data: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFFAF7F5),
      endDrawer: _buildDrawer(),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : RefreshIndicator(
          onRefresh: _refreshData,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF9B8780),
          ),
          SizedBox(height: 20),
          Text(
            'Loading your skincare routines...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 30),
            _buildRoutinesSection(),
            SizedBox(height: 30),
            _buildQuickTipsSection(),
            SizedBox(height: 30),
            _buildWeatherSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elura',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            // Text(
            //   _firebaseService.userEmail ?? 'Welcome',
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Color(0xFF9B8780),
            //   ),
            // ),
          ],
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
    );
  }

  Widget _buildRoutinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          itemCount: _routines.length,
          itemBuilder: (context, index) {
            final routine = _routines[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: _buildRoutineCard(routine, index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoutineCard(Routine routine, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoutineDetailPage(routine: routine),
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
                color: _getRoutineColor(routine.title, index),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  routine.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      _getRoutineIcon(routine.title),
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
    );
  }

  Widget _buildQuickTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            children: _quickTips.map((tip) {
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
      ],
    );
  }

  Widget _buildWeatherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Weather-Based Advice',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: WeatherCardDynamic(),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
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
              SizedBox(height: 10),
              Text(
                _firebaseService.userEmail ?? 'User',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
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
                  ).then((_) => _refreshData());
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.refresh, color: Color(0xFF9B8780)),
                title: Text('Refresh Data', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _refreshData();
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.cloud_outlined, color: Color(0xFF9B8780)),
                title: Text('Sync Status', style: TextStyle(fontSize: 16)),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                onTap: () {},
              ),
              Divider(),
              Spacer(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Sign Out', style: TextStyle(fontSize: 16, color: Colors.red)),
                onTap: () async {
                  // First close the drawer
                  Navigator.pop(context);

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF9B8780),
                      ),
                    ),
                  );

                  try {
                    // Sign out from Firebase
                    await _firebaseService.signOut();

                    // Close loading indicator
                    Navigator.pop(context);

                    // Navigate back to login page - USING DIRECT NAVIGATION
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                          (route) => false, // Remove all routes
                    );

                  } catch (e) {
                    // Close loading indicator if error
                    Navigator.pop(context);

                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoutineColor(String title, int index) {
    if (title.toLowerCase().contains('morning')) {
      return Color(0xFF8B8171);
    } else if (title.toLowerCase().contains('evening') || title.toLowerCase().contains('night')) {
      return Color(0xFFD5D5D5);
    } else if (title.toLowerCase().contains('recommended') || title.toLowerCase().contains('adjusted')) {
      return Color(0xFFD4A574);
    }
    return index % 2 == 0 ? Color(0xFF8B8171) : Color(0xFFD5D5D5);
  }

  IconData _getRoutineIcon(String title) {
    if (title.toLowerCase().contains('morning')) {
      return Icons.wb_sunny;
    } else if (title.toLowerCase().contains('evening') || title.toLowerCase().contains('night')) {
      return Icons.nightlight_round;
    } else if (title.toLowerCase().contains('recommended') || title.toLowerCase().contains('adjusted')) {
      return Icons.auto_awesome;
    }
    return Icons.spa;
  }
}