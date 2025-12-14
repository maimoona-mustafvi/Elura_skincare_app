// lib/services/app_initializer.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';
import '../data/appData.dart';

/// Service to handle app initialization and first-time setup
class AppInitializer {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _keyIsInitialized = 'app_initialized_';

  /// Check if app has been initialized for current user
  Future<bool> isAppInitialized() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyIsInitialized${user.uid}';
      return prefs.getBool(key) ?? false;
    } catch (e) {
      print('❌ Error checking initialization status: $e');
      return false;
    }
  }

  /// Mark app as initialized for current user
  Future<void> markAsInitialized() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyIsInitialized${user.uid}';
      await prefs.setBool(key, true);
      print('✅ App marked as initialized for user: ${user.uid}');
    } catch (e) {
      print('❌ Error marking as initialized: $e');
    }
  }

  /// Initialize app data for new user
  Future<void> initializeForNewUser() async {
    try {
      print('🚀 Initializing app for new user...');

      // Initialize default routines
      print('📝 Setting up default routines...');
      await _firebaseService.saveRoutine(AppData.morningRoutine);
      await _firebaseService.saveRoutine(AppData.eveningRoutine);

      // Initialize quick tips (global data)
      print('💡 Setting up quick tips...');
      final tipsExist = await _firebaseService.fetchQuickTips();
      if (tipsExist.isEmpty) {
        await _firebaseService.saveQuickTips(AppData.quickTips);
      }

      // Mark as initialized
      await markAsInitialized();

      print('✅ App initialization complete!');
    } catch (e) {
      print('❌ Error during initialization: $e');
      rethrow;
    }
  }

  /// Initialize app on first launch or after login
  Future<void> initialize() async {
    try {
      // Check if already initialized
      final initialized = await isAppInitialized();

      if (!initialized) {
        print('🔄 First time setup for user...');
        await initializeForNewUser();
      } else {
        print('✅ User data already initialized');
      }
    } catch (e) {
      print('❌ Initialization error: $e');
      rethrow;
    }
  }

  /// Reset initialization (for testing or troubleshooting)
  Future<void> resetInitialization() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyIsInitialized${user.uid}';
      await prefs.remove(key);

      print('✅ Initialization status reset');
    } catch (e) {
      print('❌ Error resetting initialization: $e');
    }
  }
}