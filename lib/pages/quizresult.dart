import 'package:flutter/material.dart';
import '../models/questions.dart';
import '../models/product.dart';
import '../models/routineModel.dart';
import '../services/ml_service_csv.dart';
import '../utils/routes.dart';
import '../data/appData.dart';

class QuizRecommendations extends StatefulWidget {
  final Map<int, String> userLogs;
  final List<Questions> questions;

  final bool isAdjusted;
  final List<Product>? adjustedProducts;

  const QuizRecommendations({
    super.key,
    required this.userLogs,
    required this.questions,
    this.isAdjusted = false,
    this.adjustedProducts,
  });

  @override
  State<QuizRecommendations> createState() => _QuizRecommendationsState();
}

class _QuizRecommendationsState extends State<QuizRecommendations> {
  late MLServiceWithCSV _mlService;
  late List<Product> _recommendedProducts = [];
  Map<String, dynamic> _modelInfo = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mlService = MLServiceWithCSV();
    _processRecommendations();
  }

  Future<void> _processRecommendations() async {
    setState(() => _isLoading = true);

    try {
      if (widget.isAdjusted && widget.adjustedProducts != null) {
        _recommendedProducts = widget.adjustedProducts!;
        _modelInfo = {
          'estimated_accuracy': 1.0,
          'products_count': _recommendedProducts.length,
          'algorithm': 'Symptom Adjustment',
          'method': 'Rule-Based',
          'dataset': 'User Routine + Symptoms',
          'citation': 'Internal adjustment logic',
        };
      } else {
        await Future.delayed(const Duration(milliseconds: 1800));

        _recommendedProducts =
        await _mlService.predictProducts(widget.userLogs);
        _modelInfo = await _mlService.getModelInfo();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Create a Routine from the recommended products
  Routine _createRoutineFromProducts() {
    // Sort products by step for proper order
    final sortedProducts = List<Product>.from(_recommendedProducts);
    sortedProducts.sort((a, b) {
      int stepA = int.tryParse(a.step.split(':')[0].replaceAll('Step ', '')) ?? 99;
      int stepB = int.tryParse(b.step.split(':')[0].replaceAll('Step ', '')) ?? 99;
      return stepA.compareTo(stepB);
    });

    // Create step descriptions
    List<String> steps = sortedProducts.map((product) {
      return '${product.step} - ${product.name} - ${product.description}';
    }).toList();

    return Routine(
      title: widget.isAdjusted ? 'Adjusted Routine' : 'Recommended Routine',
      subtitle: widget.isAdjusted
          ? 'Based on your symptoms'
          : 'AI-personalized for your skin',
      image: 'assets/images/routine.jpg',
      steps: steps,
    );
  }

  /// Save or update the routine in AppData
  void _saveRoutineToProfile() {
    final newRoutine = _createRoutineFromProducts();

    // Check if a recommended/adjusted routine already exists
    final existingIndex = AppData.allRoutines.indexWhere(
            (routine) => routine.title == 'Recommended Routine' ||
            routine.title == 'Adjusted Routine'
    );

    if (existingIndex != -1) {
      // Update existing routine
      AppData.allRoutines[existingIndex] = newRoutine;

      // Show update message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.refresh, color: Colors.white),
              SizedBox(width: 10),
              Text('${newRoutine.title} updated successfully!'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Add new routine
      AppData.allRoutines.add(newRoutine);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('${newRoutine.title} saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Navigate to home
    Navigator.pushNamedAndRemoveUntil(
      context,
      MyRoutes.homeRoute,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isAdjusted ? 'Adjusted Routine' : 'Your Recommendations',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: _isLoading ? _buildLoadingState() : _buildResultsState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 6),
          SizedBox(height: 20),
          Text(
            widget.isAdjusted
                ? 'Analyzing your symptoms...'
                : 'Analyzing your skin profile...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsState() {
    final double accuracy = (_modelInfo['estimated_accuracy'] ?? 0.0) * 100;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            children: [
              Icon(
                widget.isAdjusted ? Icons.healing : Icons.verified,
                size: 56,
                color: widget.isAdjusted ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 12),
              Text(
                widget.isAdjusted
                    ? 'Routine Adjusted'
                    : 'Scientifically Validated',
                style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isAdjusted
                    ? 'Based on your symptoms'
                    : '${accuracy.toStringAsFixed(1)}% Estimated Accuracy',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.isAdjusted ? Colors.orange : Colors.green),
              ),
              const SizedBox(height: 8),
              Text(
                'Based on ${_modelInfo['products_count']} real products',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        if (widget.isAdjusted)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your routine has been adjusted based on your symptoms. This will replace your previous recommendations.',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
          ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recommendedProducts.length,
            itemBuilder: (context, index) {
              final product = _recommendedProducts[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        product.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.step,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _saveRoutineToProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: widget.isAdjusted
                      ? Colors.orange
                      : Theme.of(context).primaryColor,
                ),
                child: Text(
                  widget.isAdjusted
                      ? 'Update My Routine'
                      : 'Start Your Routine',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Go Back',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}