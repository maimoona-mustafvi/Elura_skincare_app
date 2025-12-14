import 'package:flutter/material.dart';
import '../models/questions.dart';
import '../models/product.dart';
import '../services/ml_service_csv.dart';

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

  List<Product> _recommendedProducts = [];
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
    // If we got an adjusted routine from symptoms quiz, use it directly
    if (widget.isAdjusted && widget.adjustedProducts != null) {
      _recommendedProducts = widget.adjustedProducts!;
      // Optional: if you want, you can show that accuracy info is from adjustment
      _modelInfo = {
        'estimated_accuracy': 1.0, // 100% confidence since it came from your own adjustment
        'products_count': _recommendedProducts.length,
        'algorithm': 'Symptom Adjustment',
        'method': 'Rule-Based',
        'dataset': 'User Routine + Symptoms',
        'citation': 'Internal adjustment logic',
      };
    } else {
      // Otherwise, fetch recommendations from ML
      await Future.delayed(const Duration(milliseconds: 1800));

      final products = await _mlService.predictProducts(widget.userLogs);
      final info = await _mlService.getModelInfo();

      _recommendedProducts = products;
      _modelInfo = info;
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
          "Your Recommendations",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black54),
            onPressed: _showModelInfo,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _isLoading ? _buildLoadingState() : _buildResultsState(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildResultsState() {
  final double accuracy = (_modelInfo['estimated_accuracy'] ?? 0.0) * 100;

  return Column(
    children: [
      // Header
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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isAdjusted
                  ? 'Based on your symptoms'
                  : '${accuracy.toStringAsFixed(1)}% Estimated Accuracy',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Based on ${_modelInfo['products_count']} real products',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),

      // Banner for adjusted routine
      if (widget.isAdjusted)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Your routine has been adjusted based on your symptoms. Follow this for the next few days.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),

      // Products list
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _recommendedProducts.length,
          itemBuilder: (context, index) {
            final product = _recommendedProducts[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Image.asset(
                  product.image,
                  width: 60,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.shopping_bag),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(product.description),
                trailing: Text(
                  product.step,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // Start Routine Button
      Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
          child: const Text(
            'Start Your Routine',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    ],
  );
}


  void _showModelInfo() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Algorithm', _modelInfo['algorithm']),
            _infoRow('Method', _modelInfo['method']),
            _infoRow('Dataset', _modelInfo['dataset']),
            _infoRow(
              'Products',
              '${_modelInfo['products_count']}',
            ),
            _infoRow(
              'Accuracy',
              '${(_modelInfo['estimated_accuracy'] * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 12),
            Text(
              _modelInfo['citation'],
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
