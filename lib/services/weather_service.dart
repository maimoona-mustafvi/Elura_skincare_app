import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_data.dart';

class WeatherService {
  static const String api_key = '49d089b9b1cc9356db0f4b4783cb630a';
  static const String base_url = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<WeatherData> getWeatherData() async {
    try {
      Position position = await getCurrentLocation();

      final url = Uri.parse(
          '$base_url?lat=${position.latitude}&lon=${position.longitude}&appid=$api_key&units=metric'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return WeatherData.fromJson(json);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }
}