// lib/services/csv_dataset_loader.dart
// Loads ACTUAL Kaggle Sephora dataset from CSV file

import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
// ignore: depend_on_referenced_packages
import 'package:csv/csv.dart';
import '../models/sephora_product.dart';

class CSVDatasetLoader {
  static List<SephoraProduct>? _cachedProducts;
  static bool _isLoading = false;
  
  /// Load products from CSV file (with caching)
  static Future<List<SephoraProduct>> loadProducts() async {
    // Return cached data if available
    if (_cachedProducts != null) {
      return _cachedProducts!;
    }
    
    // Wait if already loading
    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      return _cachedProducts!;
    }
    
    _isLoading = true;
    
    try {
      print('📥 Loading Sephora dataset from CSV...');
      
      // Load CSV file from assets
      final String csvString = await rootBundle.loadString('assets/data/product_info.csv');
      
      // Parse CSV
      List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
      
      if (csvData.isEmpty) {
        throw Exception('CSV file is empty');
      }
      
      // First row is headers
      List<String> headers = csvData[0].map((e) => e.toString()).toList();
      print('✓ Found ${headers.length} columns: ${headers.take(5).join(", ")}...');
      
      // Parse products (skip header row)
      List<SephoraProduct> products = [];
      int skipped = 0;
      
      for (int i = 1; i < csvData.length; i++) {
        try {
          SephoraProduct product = SephoraProduct.fromCsvRow(csvData[i], headers);
          
          // Only include skincare products with valid ratings
          if (product.primaryCategory.toLowerCase().contains('skincare') &&
              product.rating > 0 &&
              product.reviewCount > 0) {
            products.add(product);
          } else {
            skipped++;
          }
        } catch (e) {
          skipped++;
          // Continue parsing other rows
        }
      }
      
      print('✓ Loaded ${products.length} skincare products');
      print('✓ Skipped $skipped non-skincare or invalid products');
      
      // Filter to only keep relevant categories
      products = _filterRelevantProducts(products);
      
      print('✓ Final dataset: ${products.length} products');
      
      _cachedProducts = products;
      _isLoading = false;
      
      return products;
      
    } catch (e) {
      _isLoading = false;
      print('❌ Error loading CSV: $e');
      throw Exception('Failed to load dataset: $e');
    }
  }
  
  /// Filter to keep only relevant skincare products
  static List<SephoraProduct> _filterRelevantProducts(List<SephoraProduct> products) {
    return products.where((product) {
      String category = product.secondaryCategory.toLowerCase();
      
      // Keep only cleansers, treatments, moisturizers, sunscreens
      return category.contains('cleanser') ||
             category.contains('serum') ||
             category.contains('treatment') ||
             category.contains('moisturizer') ||
             category.contains('cream') ||
             category.contains('lotion') ||
             category.contains('sunscreen') ||
             category.contains('spf');
    }).toList();
  }
  
  /// Get products by category
  static Future<List<SephoraProduct>> getProductsByCategory(String category) async {
    List<SephoraProduct> allProducts = await loadProducts();
    
    return allProducts.where((product) {
      String lower = product.secondaryCategory.toLowerCase();
      String catLower = category.toLowerCase();
      
      if (catLower == 'cleanser') {
        return lower.contains('cleanser') || lower.contains('cleansing');
      } else if (catLower == 'treatment') {
        return lower.contains('serum') || lower.contains('treatment');
      } else if (catLower == 'moisturizer') {
        return lower.contains('moisturizer') || lower.contains('cream') || 
               lower.contains('lotion');
      } else if (catLower == 'sunscreen') {
        return lower.contains('sunscreen') || lower.contains('spf');
      }
      
      return false;
    }).toList();
  }
  
  /// Get dataset statistics
  static Future<Map<String, dynamic>> getDatasetInfo() async {
    List<SephoraProduct> products = await loadProducts();
    
    // Calculate statistics
    double avgRating = products.isEmpty 
        ? 0.0 
        : products.map((p) => p.rating).reduce((a, b) => a + b) / products.length;
    
    int totalReviews = products.map((p) => p.reviewCount).reduce((a, b) => a + b);
    
    // Get unique brands
    Set<String> brands = products.map((p) => p.brandName).toSet();
    
    // Get category distribution
    Map<String, int> categoryCount = {};
    for (var product in products) {
      String cat = product.secondaryCategory;
      categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
    }
    
    return {
      'total_products': products.length,
      'average_rating': avgRating,
      'total_reviews': totalReviews,
      'unique_brands': brands.length,
      'category_distribution': categoryCount,
      'data_source': 'Kaggle - Sephora Products Dataset',
      'loaded_from': 'assets/data/product_info.csv',
    };
  }
  
  /// Search products by name or brand
  static Future<List<SephoraProduct>> searchProducts(String query) async {
    List<SephoraProduct> allProducts = await loadProducts();
    String lowerQuery = query.toLowerCase();
    
    return allProducts.where((product) {
      return product.productName.toLowerCase().contains(lowerQuery) ||
             product.brandName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  /// Get top rated products
  static Future<List<SephoraProduct>> getTopRatedProducts({int limit = 10}) async {
    List<SephoraProduct> allProducts = await loadProducts();
    
    // Sort by rating (descending) and review count
    allProducts.sort((a, b) {
      int ratingCompare = b.rating.compareTo(a.rating);
      if (ratingCompare != 0) return ratingCompare;
      return b.reviewCount.compareTo(a.reviewCount);
    });
    
    return allProducts.take(limit).toList();
  }
  
  /// Clear cache (useful for testing)
  static void clearCache() {
    _cachedProducts = null;
  }
}