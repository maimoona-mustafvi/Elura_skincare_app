import 'package:flutter/material.dart';
import '../models/questions.dart';
import '../models/product.dart';
import '../services/ml_service_csv.dart';
import '../utils/routes.dart';

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
  late List<Product> _recommendedProducts=[];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Recommendations',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: _isLoading ? _buildLoadingState() : _buildResultsState(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 6),
    );
  }

  Widget _buildResultsState() {
    final double accuracy =
        (_modelInfo['estimated_accuracy'] ?? 0.0) * 100;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            children: [
              const Icon(Icons.verified, size: 56, color: Colors.green),
              const SizedBox(height: 12),
              Text(
                widget.isAdjusted
                    ? 'Your Adjusted Routine'
                    : 'Scientifically Validated',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isAdjusted
                    ? 'Based on your symptoms'
                    : '${accuracy.toStringAsFixed(1)}% Estimated Accuracy',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.green),
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
            child: const Text(
              'Your routine has been adjusted based on your symptoms.',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Image.asset(
                    product.image,
                    width: 60,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.shopping_bag),
                  ),
                  title: Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(product.description),
                  trailing: Text(product.step,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                MyRoutes.homeRoute,
                    (route) => false,
              );
            },

            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            child:
                const Text('Start Your Routine', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}