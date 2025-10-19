import '../models/weather_data.dart';
import '../models/weather_recommendation.dart';

class RecommendationService {
  WeatherRecommendation getRecommendation(WeatherData weather) {
    // SUNNY WEATHER
    if (weather.condition == 'sunny') {
      return WeatherRecommendation(
        title: 'Sunny Day Protection',
        description: 'High UV exposure! Extra protection needed today.',
        tips: [
          '🧴 Apply SPF 50+ sunscreen every 2 hours',
          '😎 Wear sunglasses and a wide-brimmed hat',
          '💧 Stay extra hydrated - drink water frequently',
          '🌿 Use antioxidant serum before sunscreen',
          '⏰ Avoid sun between 10 AM - 4 PM if possible',
        ],
      );
    }

    // CLOUDY WEATHER
    else if (weather.condition == 'cloudy') {
      return WeatherRecommendation(
        title: 'Cloudy Day Care',
        description: 'UV rays still penetrate clouds. Don\'t skip protection!',
        tips: [
          '☁️ Apply SPF 30+ even on cloudy days',
          '💦 Focus on hydrating products',
          '✨ Great day for exfoliation and masks',
          '🌸 Use lighter moisturizers',
          '📸 Perfect lighting for checking your skin',
        ],
      );
    }

    // RAINY WEATHER
    else if (weather.condition == 'rainy') {
      if (weather.humidity > 70) {
        return WeatherRecommendation(
          title: 'Rainy & Humid',
          description: 'High humidity can affect your skin barrier.',
          tips: [
            '🌧️ Use lightweight, oil-free products',
            '💧 Skip heavy creams to avoid clogged pores',
            '🧪 Use mattifying serums if oily',
            '🧼 Cleanse twice to remove excess oil',
            '🌿 Great day for clay masks',
          ],
        );
      } else {
        return WeatherRecommendation(
          title: 'Rainy Day Routine',
          description: 'Perfect day for indoor skincare treatments!',
          tips: [
            '🏠 Great time for deep treatments and masks',
            '💆 Do a longer skincare routine',
            '🧖 Steam your face for better absorption',
            '📚 Try new products you\'ve been curious about',
            '☕ Cozy self-care day!',
          ],
        );
      }
    }

    // SNOWY/COLD WEATHER
    else if (weather.condition == 'snowy' || weather.temperature < 5) {
      return WeatherRecommendation(
        title: 'Cold Weather Protection',
        description: 'Cold air is harsh on skin. Barrier protection is key!',
        tips: [
          '❄️ Use rich, occlusive moisturizers',
          '🧴 Apply face oil for extra protection',
          '💋 Don\'t forget lip balm - reapply often',
          '🧣 Protect face with scarf when outdoors',
          '🚿 Use lukewarm water, not hot',
          '💧 Run a humidifier indoors',
        ],
      );
    }

    // HOT WEATHER
    else if (weather.temperature > 30) {
      return WeatherRecommendation(
        title: 'Hot Weather Care',
        description: 'Extreme heat can dehydrate and irritate skin.',
        tips: [
          '🔥 Use gel-based, cooling products',
          '💦 Mist your face throughout the day',
          '🧊 Keep skincare in the fridge',
          '☀️ SPF 50+ is a must',
          '💧 Drink extra water',
          '🌡️ Avoid hot showers',
        ],
      );
    }

    // DEFAULT
    else {
      return WeatherRecommendation(
        title: 'Perfect Weather',
        description: 'Ideal conditions for your regular routine!',
        tips: [
          '✨ Follow your normal skincare routine',
          '🧴 SPF 30 is sufficient',
          '🌸 Great day to try new products',
          '💆 Perfect for outdoor activities',
          '📸 Take skincare progress photos',
        ],
      );
    }
  }
}