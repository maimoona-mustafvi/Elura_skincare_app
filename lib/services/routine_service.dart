// lib/services/routine_service.dart
// Service to manage routine operations in AppData

import '../models/product.dart';
import '../models/routineModel.dart';
import '../data/appData.dart';

class RoutineService {
  /// Convert routine steps back to Product objects
  /// Parses format: "Step 1: Cleanser - Product Name - Description"
  static List<Product> getProductsFromRoutine(Routine routine) {
    List<Product> products = [];

    for (String step in routine.steps) {
      if (step.contains(':') && step.contains('-')) {
        List<String> parts = step.split('-').map((s) => s.trim()).toList();

        if (parts.length >= 2) {
          String stepPart = parts[0].trim(); // "Step 1: Cleanser"
          String name = parts.length > 1 ? parts[1].trim() : 'Unknown Product';
          String description = parts.length > 2 ? parts[2].trim() : '';

          products.add(Product(
            name: name,
            description: description,
            step: stepPart,
            image: 'assets/images/product_placeholder.png',
          ));
        }
      }
    }

    return products;
  }

  /// Get products from the recommended/adjusted routine
  static List<Product> getRecommendedProducts() {
    // Find the recommended or adjusted routine
    final recommendedRoutine = AppData.allRoutines.firstWhere(
          (routine) => routine.title == 'Recommended Routine' ||
          routine.title == 'Adjusted Routine',
      orElse: () => AppData.morningRoutine, // Fallback to morning routine
    );

    return getProductsFromRoutine(recommendedRoutine);
  }

  /// Create a Routine from a list of Products
  static Routine createRoutineFromProducts({
    required List<Product> products,
    required String title,
    required String subtitle,
    String image = 'assets/images/routine.jpg',
  }) {
    // Sort products by step for proper order
    final sortedProducts = List<Product>.from(products);
    sortedProducts.sort((a, b) {
      int stepA = _extractStepNumber(a.step);
      int stepB = _extractStepNumber(b.step);
      return stepA.compareTo(stepB);
    });

    // Create step descriptions
    List<String> steps = sortedProducts.map((product) {
      return '${product.step} - ${product.name} - ${product.description}';
    }).toList();

    return Routine(
      title: title,
      subtitle: subtitle,
      image: image,
      steps: steps,
    );
  }

  /// Update or add a routine to AppData
  static bool saveOrUpdateRoutine(Routine routine) {
    // Check if a routine with the same title already exists
    final existingIndex = AppData.allRoutines.indexWhere(
            (r) => r.title == routine.title
    );

    if (existingIndex != -1) {
      // Update existing routine
      AppData.allRoutines[existingIndex] = routine;
      return true; // Returns true if updated
    } else {
      // Add new routine
      AppData.allRoutines.add(routine);
      return false; // Returns false if newly added
    }
  }

  /// Remove a routine from AppData by title
  static bool removeRoutine(String title) {
    final index = AppData.allRoutines.indexWhere((r) => r.title == title);

    if (index != -1) {
      AppData.allRoutines.removeAt(index);
      return true;
    }
    return false;
  }

  /// Check if a recommended routine exists
  static bool hasRecommendedRoutine() {
    return AppData.allRoutines.any(
            (routine) => routine.title == 'Recommended Routine' ||
            routine.title == 'Adjusted Routine'
    );
  }

  /// Get the recommended routine if it exists
  static Routine? getRecommendedRoutine() {
    try {
      return AppData.allRoutines.firstWhere(
              (routine) => routine.title == 'Recommended Routine' ||
              routine.title == 'Adjusted Routine'
      );
    } catch (e) {
      return null;
    }
  }

  /// Extract step number from step string (e.g., "Step 1: Cleanser" -> 1)
  static int _extractStepNumber(String step) {
    try {
      final match = RegExp(r'Step (\d+)').firstMatch(step);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    } catch (e) {
      // If parsing fails, return high number to sort to end
    }
    return 99;
  }
}