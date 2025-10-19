import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../models/weather_recommendation.dart';
import '../services/weather_service.dart';
import '../services/recommendation_service.dart';

class WeatherCardDynamic extends StatefulWidget {
  const WeatherCardDynamic({Key? key}) : super(key: key);

  @override
  State<WeatherCardDynamic> createState() => _WeatherCardDynamicState();
}

class _WeatherCardDynamicState extends State<WeatherCardDynamic> {
  final WeatherService _weatherService = WeatherService();
  final RecommendationService _recommendationService = RecommendationService();

  bool _isLoading = false;
  WeatherData? _weatherData;
  WeatherRecommendation? _recommendation;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weatherData = await _weatherService.getWeatherData();
      final recommendation = _recommendationService.getRecommendation(weatherData);

      setState(() {
        _weatherData = weatherData;
        _recommendation = recommendation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_recommendation != null) {
          _showRecommendationDetails(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEFE7E1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
            ? _buildErrorState()
            : _buildWeatherState(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Checking weather...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF4A9FD8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unable to load',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tap to retry',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _fetchWeather,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherState() {
    if (_weatherData == null || _recommendation == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _weatherData!.condition.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_weatherData!.temperature.round()}°C • ${_weatherData!.city}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _getWeatherColor(_weatherData!.condition),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            _getWeatherIcon(_weatherData!.condition),
            color: Colors.white,
            size: 40,
          ),
        ),
      ],
    );
  }

  Color _getWeatherColor(String condition) {
    switch (condition) {
      case 'sunny':
        return const Color(0xFFFDB813);
      case 'cloudy':
        return const Color(0xFF9E9E9E);
      case 'rainy':
        return const Color(0xFF4A9FD8);
      case 'snowy':
        return const Color(0xFF81D4FA);
      default:
        return const Color(0xFF4A9FD8);
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.water_drop;
      case 'snowy':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  void _showRecommendationDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _getWeatherColor(_weatherData!.condition),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getWeatherIcon(_weatherData!.condition),
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _recommendation!.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_weatherData!.temperature.round()}°C • ${_weatherData!.city}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE7E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _recommendation!.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Skincare Tips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ..._recommendation!.tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.split(' ')[0],
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip.substring(tip.indexOf(' ') + 1),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A9FD8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}