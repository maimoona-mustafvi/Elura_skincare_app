// lib/services/firebase_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/routineModel.dart';
import '../models/quickTipsModel.dart';
import '../models/product.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current authenticated user ID
  String get userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please log in.');
    }
    return user.uid;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // ==================== ROUTINES ====================

  /// Save a routine to Firebase
  Future<void> saveRoutine(Routine routine) async {
    try {
      String routineKey = _sanitizeKey(routine.title);

      await _database.child('users/$userId/routines/$routineKey').set({
        'title': routine.title,
        'subtitle': routine.subtitle,
        'image': routine.image,
        'steps': routine.steps,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });

      print('✅ Routine saved: ${routine.title}');
    } catch (e) {
      print('❌ Error saving routine: $e');
      rethrow;
    }
  }

  /// Fetch all routines from Firebase
  Future<List<Routine>> fetchRoutines() async {
    try {
      final snapshot = await _database.child('users/$userId/routines').get();

      if (!snapshot.exists) {
        print('ℹ️ No routines found in Firebase');
        return [];
      }

      List<Routine> routines = [];
      Map<dynamic, dynamic> routinesMap = snapshot.value as Map<dynamic, dynamic>;

      routinesMap.forEach((key, value) {
        try {
          routines.add(Routine(
            title: value['title'] ?? 'Untitled',
            subtitle: value['subtitle'] ?? '',
            image: value['image'] ?? 'assets/images/routine.jpg',
            steps: List<String>.from(value['steps'] ?? []),
          ));
        } catch (e) {
          print('⚠️ Error parsing routine $key: $e');
        }
      });

      print('✅ Fetched ${routines.length} routines from Firebase');
      return routines;
    } catch (e) {
      print('❌ Error fetching routines: $e');
      return [];
    }
  }

  /// Delete a routine
  Future<void> deleteRoutine(String routineTitle) async {
    try {
      String routineKey = _sanitizeKey(routineTitle);
      await _database.child('users/$userId/routines/$routineKey').remove();
      print('✅ Routine deleted: $routineTitle');
    } catch (e) {
      print('❌ Error deleting routine: $e');
      rethrow;
    }
  }

  /// Check if a specific routine exists
  Future<bool> routineExists(String routineTitle) async {
    try {
      String routineKey = _sanitizeKey(routineTitle);
      final snapshot = await _database.child('users/$userId/routines/$routineKey').get();
      return snapshot.exists;
    } catch (e) {
      print('❌ Error checking routine existence: $e');
      return false;
    }
  }

  // ==================== QUICK TIPS ====================

  /// Save quick tips to Firebase (global/admin data)
  Future<void> saveQuickTips(List<Tip> tips) async {
    try {
      List<Map<String, dynamic>> tipsData = tips.map((tip) => {
        'title': tip.title,
        'subtitle': tip.subtitle,
        'image': tip.image,
        'backgroundColor': tip.backgroundColor,
        'description': tip.description,
      }).toList();

      await _database.child('quickTips').set(tipsData);
      print('✅ Quick tips saved successfully');
    } catch (e) {
      print('❌ Error saving quick tips: $e');
      rethrow;
    }
  }

  /// Fetch quick tips from Firebase
  Future<List<Tip>> fetchQuickTips() async {
    try {
      final snapshot = await _database.child('quickTips').get();

      if (!snapshot.exists) {
        print('ℹ️ No quick tips found in Firebase');
        return [];
      }

      List<Tip> tips = [];
      List<dynamic> tipsData = snapshot.value as List<dynamic>;

      for (var tipData in tipsData) {
        if (tipData != null) {
          try {
            tips.add(Tip(
              title: tipData['title'] ?? '',
              subtitle: tipData['subtitle'] ?? '',
              image: tipData['image'] ?? '',
              backgroundColor: tipData['backgroundColor'] ?? '0xFFE8E8E8',
              description: tipData['description'] ?? '',
            ));
          } catch (e) {
            print('⚠️ Error parsing tip: $e');
          }
        }
      }

      print('✅ Fetched ${tips.length} quick tips from Firebase');
      return tips;
    } catch (e) {
      print('❌ Error fetching quick tips: $e');
      return [];
    }
  }

  // ==================== RECOMMENDED PRODUCTS ====================

  /// Save recommended products to Firebase
  Future<void> saveRecommendedProducts(List<Product> products) async {
    try {
      List<Map<String, dynamic>> productsData = products.map((product) => {
        'name': product.name,
        'description': product.description,
        'step': product.step,
        'image': product.image,
      }).toList();

      await _database.child('users/$userId/recommendedProducts').set({
        'products': productsData,
        'updatedAt': ServerValue.timestamp,
      });

      print('✅ Saved ${products.length} recommended products');
    } catch (e) {
      print('❌ Error saving recommended products: $e');
      rethrow;
    }
  }

  /// Fetch recommended products from Firebase
  Future<List<Product>> fetchRecommendedProducts() async {
    try {
      final snapshot = await _database.child('users/$userId/recommendedProducts/products').get();

      if (!snapshot.exists) {
        print('ℹ️ No recommended products found');
        return [];
      }

      List<Product> products = [];
      List<dynamic> productsData = snapshot.value as List<dynamic>;

      for (var productData in productsData) {
        if (productData != null) {
          try {
            products.add(Product(
              name: productData['name'] ?? 'Unknown Product',
              description: productData['description'] ?? '',
              step: productData['step'] ?? '',
              image: productData['image'] ?? 'assets/images/product_placeholder.png',
            ));
          } catch (e) {
            print('⚠️ Error parsing product: $e');
          }
        }
      }

      print('✅ Fetched ${products.length} recommended products');
      return products;
    } catch (e) {
      print('❌ Error fetching recommended products: $e');
      return [];
    }
  }

  /// Update recommended products (used when symptoms are re-analyzed)
  Future<void> updateRecommendedProducts(List<Product> products) async {
    await saveRecommendedProducts(products);
    print('✅ Recommended products updated');
  }

  /// Delete recommended products
  Future<void> deleteRecommendedProducts() async {
    try {
      await _database.child('users/$userId/recommendedProducts').remove();
      print('✅ Recommended products deleted');
    } catch (e) {
      print('❌ Error deleting recommended products: $e');
      rethrow;
    }
  }

  /// Check if user has recommended products
  Future<bool> hasRecommendedProducts() async {
    try {
      final snapshot = await _database.child('users/$userId/recommendedProducts').get();
      return snapshot.exists;
    } catch (e) {
      print('❌ Error checking recommended products: $e');
      return false;
    }
  }

  // ==================== INITIALIZATION ====================

  /// Initialize default data for new users
  Future<void> initializeDefaultData(List<Routine> defaultRoutines, List<Tip> defaultTips) async {
    try {
      // Check if user already has routines
      final routinesSnapshot = await _database.child('users/$userId/routines').get();

      if (!routinesSnapshot.exists) {
        print('🔄 Initializing default routines for new user...');
        for (var routine in defaultRoutines) {
          await saveRoutine(routine);
        }
      } else {
        print('ℹ️ User already has routines');
      }

      // Check if quick tips exist globally (only initialize once)
      final tipsSnapshot = await _database.child('quickTips').get();
      if (!tipsSnapshot.exists) {
        print('🔄 Initializing global quick tips...');
        await saveQuickTips(defaultTips);
      } else {
        print('ℹ️ Quick tips already initialized');
      }

      print('✅ Default data initialization complete');
    } catch (e) {
      print('❌ Error initializing default data: $e');
    }
  }

  /// Reset user data (useful for testing or account reset)
  Future<void> resetUserData() async {
    try {
      await _database.child('users/$userId').remove();
      print('✅ User data reset complete');
    } catch (e) {
      print('❌ Error resetting user data: $e');
      rethrow;
    }
  }

  // ==================== REAL-TIME LISTENERS ====================

  /// Listen to routine changes in real-time
  Stream<List<Routine>> watchRoutines() {
    return _database.child('users/$userId/routines').onValue.map((event) {
      if (!event.snapshot.exists) {
        return <Routine>[];
      }

      List<Routine> routines = [];
      Map<dynamic, dynamic> routinesMap = event.snapshot.value as Map<dynamic, dynamic>;

      routinesMap.forEach((key, value) {
        try {
          routines.add(Routine(
            title: value['title'] ?? 'Untitled',
            subtitle: value['subtitle'] ?? '',
            image: value['image'] ?? 'assets/images/routine.jpg',
            steps: List<String>.from(value['steps'] ?? []),
          ));
        } catch (e) {
          print('⚠️ Error in routine stream: $e');
        }
      });

      return routines;
    });
  }

  /// Listen to recommended products changes in real-time
  Stream<List<Product>> watchRecommendedProducts() {
    return _database.child('users/$userId/recommendedProducts/products').onValue.map((event) {
      if (!event.snapshot.exists) {
        return <Product>[];
      }

      List<Product> products = [];
      List<dynamic> productsData = event.snapshot.value as List<dynamic>;

      for (var productData in productsData) {
        if (productData != null) {
          try {
            products.add(Product(
              name: productData['name'] ?? 'Unknown Product',
              description: productData['description'] ?? '',
              step: productData['step'] ?? '',
              image: productData['image'] ?? 'assets/images/product_placeholder.png',
            ));
          } catch (e) {
            print('⚠️ Error in products stream: $e');
          }
        }
      }

      return products;
    });
  }

  // ==================== HELPER METHODS ====================

  /// Sanitize string to be used as Firebase key
  String _sanitizeKey(String key) {
    return key
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w]'), '');
  }

  /// Get current user email
  String? get userEmail => _auth.currentUser?.email;

  /// Sign out (cleanup method)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}