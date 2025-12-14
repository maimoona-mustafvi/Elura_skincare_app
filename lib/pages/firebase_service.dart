// lib/services/firebase_service.dart
import 'package:firebase_database/firebase_database.dart';
import '../models/routineModel.dart';
import '../models/quickTipsModel.dart';
import '../models/product.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Assuming you have user authentication, replace with actual user ID
  String get userId => 'user_123'; // TODO: Replace with Firebase Auth user ID

  // ==================== ROUTINES ====================

  /// Save a routine to Firebase
  Future<void> saveRoutine(Routine routine) async {
    try {
      // Create a unique key for the routine based on title
      String routineKey = _sanitizeKey(routine.title);

      await _database.child('users/$userId/routines/$routineKey').set({
        'title': routine.title,
        'subtitle': routine.subtitle,
        'image': routine.image,
        'steps': routine.steps,
        'createdAt': ServerValue.timestamp,
      });

      print('Routine saved successfully: ${routine.title}');
    } catch (e) {
      print('Error saving routine: $e');
      rethrow;
    }
  }

  /// Fetch all routines from Firebase
  Future<List<Routine>> fetchRoutines() async {
    try {
      final snapshot = await _database.child('users/$userId/routines').get();

      if (!snapshot.exists) {
        print('No routines found in Firebase');
        return [];
      }

      List<Routine> routines = [];
      Map<dynamic, dynamic> routinesMap = snapshot.value as Map<dynamic, dynamic>;

      routinesMap.forEach((key, value) {
        routines.add(Routine(
          title: value['title'] ?? 'Untitled',
          subtitle: value['subtitle'] ?? '',
          image: value['image'] ?? 'assets/images/routine.jpg',
          steps: List<String>.from(value['steps'] ?? []),
        ));
      });

      print('Fetched ${routines.length} routines from Firebase');
      return routines;
    } catch (e) {
      print('Error fetching routines: $e');
      return [];
    }
  }

  /// Update an existing routine
  Future<void> updateRoutine(Routine routine) async {
    await saveRoutine(routine); // Same as save, will overwrite
  }

  /// Delete a routine
  Future<void> deleteRoutine(String routineTitle) async {
    try {
      String routineKey = _sanitizeKey(routineTitle);
      await _database.child('users/$userId/routines/$routineKey').remove();
      print('Routine deleted: $routineTitle');
    } catch (e) {
      print('Error deleting routine: $e');
      rethrow;
    }
  }

  // ==================== QUICK TIPS ====================

  /// Save quick tips to Firebase (admin/global data)
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
      print('Quick tips saved successfully');
    } catch (e) {
      print('Error saving quick tips: $e');
      rethrow;
    }
  }

  /// Fetch quick tips from Firebase
  Future<List<Tip>> fetchQuickTips() async {
    try {
      final snapshot = await _database.child('quickTips').get();

      if (!snapshot.exists) {
        print('No quick tips found in Firebase');
        return [];
      }

      List<Tip> tips = [];
      List<dynamic> tipsData = snapshot.value as List<dynamic>;

      for (var tipData in tipsData) {
        if (tipData != null) {
          tips.add(Tip(
            title: tipData['title'] ?? '',
            subtitle: tipData['subtitle'] ?? '',
            image: tipData['image'] ?? '',
            backgroundColor: tipData['backgroundColor'] ?? '0xFFE8E8E8',
            description: tipData['description'] ?? '',
          ));
        }
      }

      print('Fetched ${tips.length} quick tips from Firebase');
      return tips;
    } catch (e) {
      print('Error fetching quick tips: $e');
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

      print('Recommended products saved successfully');
    } catch (e) {
      print('Error saving recommended products: $e');
      rethrow;
    }
  }

  /// Fetch recommended products from Firebase
  Future<List<Product>> fetchRecommendedProducts() async {
    try {
      final snapshot = await _database.child('users/$userId/recommendedProducts/products').get();

      if (!snapshot.exists) {
        print('No recommended products found in Firebase');
        return [];
      }

      List<Product> products = [];
      List<dynamic> productsData = snapshot.value as List<dynamic>;

      for (var productData in productsData) {
        if (productData != null) {
          products.add(Product(
            name: productData['name'] ?? 'Unknown Product',
            description: productData['description'] ?? '',
            step: productData['step'] ?? '',
            image: productData['image'] ?? 'assets/images/product_placeholder.png',
          ));
        }
      }

      print('Fetched ${products.length} recommended products from Firebase');
      return products;
    } catch (e) {
      print('Error fetching recommended products: $e');
      return [];
    }
  }

  /// Update recommended products (used when symptoms are re-analyzed)
  Future<void> updateRecommendedProducts(List<Product> products) async {
    await saveRecommendedProducts(products); // Same as save, will overwrite
  }

  /// Delete recommended products
  Future<void> deleteRecommendedProducts() async {
    try {
      await _database.child('users/$userId/recommendedProducts').remove();
      print('Recommended products deleted');
    } catch (e) {
      print('Error deleting recommended products: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Sanitize string to be used as Firebase key (no special characters)
  String _sanitizeKey(String key) {
    return key
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\s]'), '');
  }

  /// Initialize default data (call once on first app launch)
  Future<void> initializeDefaultData(List<Routine> defaultRoutines, List<Tip> defaultTips) async {
    try {
      // Check if user already has data
      final routinesSnapshot = await _database.child('users/$userId/routines').get();

      if (!routinesSnapshot.exists) {
        // Save default routines
        for (var routine in defaultRoutines) {
          await saveRoutine(routine);
        }
      }

      // Check if quick tips exist (global data)
      final tipsSnapshot = await _database.child('quickTips').get();
      if (!tipsSnapshot.exists) {
        await saveQuickTips(defaultTips);
      }

      print('Default data initialized');
    } catch (e) {
      print('Error initializing default data: $e');
    }
  }

  /// Listen to routine changes in real-time
  Stream<List<Routine>> watchRoutines() {
    return _database.child('users/$userId/routines').onValue.map((event) {
      if (!event.snapshot.exists) {
        return <Routine>[];
      }

      List<Routine> routines = [];
      Map<dynamic, dynamic> routinesMap = event.snapshot.value as Map<dynamic, dynamic>;

      routinesMap.forEach((key, value) {
        routines.add(Routine(
          title: value['title'] ?? 'Untitled',
          subtitle: value['subtitle'] ?? '',
          image: value['image'] ?? 'assets/images/routine.jpg',
          steps: List<String>.from(value['steps'] ?? []),
        ));
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
          products.add(Product(
            name: productData['name'] ?? 'Unknown Product',
            description: productData['description'] ?? '',
            step: productData['step'] ?? '',
            image: productData['image'] ?? 'assets/images/product_placeholder.png',
          ));
        }
      }

      return products;
    });
  }
}