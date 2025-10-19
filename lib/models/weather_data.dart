class WeatherData {
  final String condition;
  final double temperature;
  final int humidity;
  final String city;

  WeatherData({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.city,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    String mainCondition = json['weather'][0]['main'].toString().toLowerCase();

    String condition;
    if (mainCondition.contains('clear')) {
      condition = 'sunny';
    } else if (mainCondition.contains('cloud')) {
      condition = 'cloudy';
    } else if (mainCondition.contains('rain') || mainCondition.contains('drizzle')) {
      condition = 'rainy';
    } else if (mainCondition.contains('snow')) {
      condition = 'snowy';
    } else {
      condition = 'cloudy';
    }

    return WeatherData(
      condition: condition,
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      city: json['name'] as String,
    );
  }
}