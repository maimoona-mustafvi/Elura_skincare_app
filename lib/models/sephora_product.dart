// lib/models/sephora_product.dart
// Model matching ACTUAL Kaggle Sephora dataset structure

class SephoraProduct {
  final String productId;
  final String productName;
  final String brandName;
  final double rating;
  final int reviewCount;
  final String ingredients;
  final double priceUsd;
  final String primaryCategory;
  final String secondaryCategory;
  final String highlights;
  
  SephoraProduct({
    required this.productId,
    required this.productName,
    required this.brandName,
    required this.rating,
    required this.reviewCount,
    required this.ingredients,
    required this.priceUsd,
    required this.primaryCategory,
    required this.secondaryCategory,
    required this.highlights,
  });
  
  /// Parse from CSV row (matches Kaggle dataset structure)
  factory SephoraProduct.fromCsvRow(List<dynamic> row, List<String> headers) {
    Map<String, dynamic> data = {};
    for (int i = 0; i < headers.length && i < row.length; i++) {
      data[headers[i].trim()] = row[i].toString().trim();
    }
    
    return SephoraProduct(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? 'Unknown Product',
      brandName: data['brand_name'] ?? 'Unknown Brand',
      rating: _parseDouble(data['rating']),
      reviewCount: _parseInt(data['reviews']),
      ingredients: data['ingredients'] ?? '',
      priceUsd: _parseDouble(data['price_usd']),
      primaryCategory: data['primary_category'] ?? '',
      secondaryCategory: data['secondary_category'] ?? '',
      highlights: data['highlights'] ?? '',
    );
  }
  
  static double _parseDouble(dynamic value) {
    if (value == null || value == '') return 0.0;
    try {
      return double.parse(value.toString());
    } catch (e) {
      return 0.0;
    }
  }
  
  static int _parseInt(dynamic value) {
    if (value == null || value == '') return 0;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return 0;
    }
  }
  
  /// Check if product is suitable for skin type
  bool isSuitableForSkinType(String skinType) {
    String lowerHighlights = highlights.toLowerCase();
    String lowerIngredients = ingredients.toLowerCase();
    String lowerName = productName.toLowerCase();
    
    switch (skinType.toLowerCase()) {
      case 'oily':
        return lowerHighlights.contains('oil-free') ||
               lowerHighlights.contains('mattifying') ||
               lowerHighlights.contains('lightweight') ||
               lowerName.contains('gel') ||
               lowerName.contains('foaming') ||
               !lowerName.contains('rich') && !lowerName.contains('cream');
               
      case 'dry':
        return lowerHighlights.contains('hydrating') ||
               lowerHighlights.contains('moisturizing') ||
               lowerHighlights.contains('nourishing') ||
               lowerIngredients.contains('hyaluronic') ||
               lowerIngredients.contains('ceramide') ||
               lowerName.contains('hydrating');
               
      case 'sensitive':
        return lowerHighlights.contains('gentle') ||
               lowerHighlights.contains('soothing') ||
               lowerHighlights.contains('calming') ||
               lowerHighlights.contains('sensitive') ||
               lowerIngredients.contains('centella') ||
               lowerName.contains('gentle');
               
      case 'combination':
        return lowerHighlights.contains('balance') ||
               lowerHighlights.contains('combination') ||
               !lowerName.contains('very rich');
               
      case 'normal':
        return true; // Normal skin can use most products
        
      default:
        return true;
    }
  }
  
  /// Check if product addresses skin concern
  bool addressesConcern(String concern) {
    String lowerHighlights = highlights.toLowerCase();
    String lowerIngredients = ingredients.toLowerCase();
    String lowerName = productName.toLowerCase();
    
    switch (concern.toLowerCase()) {
      case 'acne':
        return lowerHighlights.contains('acne') ||
               lowerHighlights.contains('blemish') ||
               lowerIngredients.contains('salicylic') ||
               lowerIngredients.contains('niacinamide') ||
               lowerIngredients.contains('zinc') ||
               lowerName.contains('acne') ||
               lowerName.contains('blemish');
               
      case 'aging':
        return lowerHighlights.contains('anti-aging') ||
               lowerHighlights.contains('wrinkle') ||
               lowerHighlights.contains('firm') ||
               lowerIngredients.contains('retinol') ||
               lowerIngredients.contains('peptide') ||
               lowerName.contains('anti-aging') ||
               lowerName.contains('retinol');
               
      case 'pigmentation':
        return lowerHighlights.contains('brighten') ||
               lowerHighlights.contains('dark spot') ||
               lowerHighlights.contains('even tone') ||
               lowerIngredients.contains('vitamin c') ||
               lowerIngredients.contains('niacinamide') ||
               lowerName.contains('brightening');
               
      case 'dryness':
        return lowerHighlights.contains('hydrat') ||
               lowerHighlights.contains('moisture') ||
               lowerIngredients.contains('hyaluronic') ||
               lowerIngredients.contains('glycerin');
               
      case 'redness':
        return lowerHighlights.contains('soothing') ||
               lowerHighlights.contains('calming') ||
               lowerHighlights.contains('redness') ||
               lowerIngredients.contains('centella') ||
               lowerIngredients.contains('azelaic');
               
      default:
        return false;
    }
  }
  
  /// Get product category for skincare routine
  String getRoutineStep() {
    String lower = secondaryCategory.toLowerCase();
    if (lower.contains('cleanser') || lower.contains('cleansing')) {
      return 'Step 1: Cleanser';
    } else if (lower.contains('serum') || lower.contains('treatment')) {
      return 'Step 2: Treatment';
    } else if (lower.contains('moisturizer') || lower.contains('cream') || 
               lower.contains('lotion')) {
      return 'Step 3: Moisturize';
    } else if (lower.contains('sunscreen') || lower.contains('spf')) {
      return 'Step 4: Sunscreen';
    }
    return 'Treatment';
  }
  
  /// Format review count for display (e.g., 1500 -> "1.5K")
  String getFormattedReviewCount() {
    if (reviewCount >= 1000) {
      return '${(reviewCount / 1000).toStringAsFixed(1)}K';
    }
    return reviewCount.toString();
  }
  
  @override
  String toString() {
    return 'SephoraProduct(name: $productName, brand: $brandName, rating: $rating, reviews: $reviewCount)';
  }
}