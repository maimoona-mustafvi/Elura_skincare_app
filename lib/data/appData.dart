import 'package:elura_skincare_app/models/routineModel.dart';
import 'package:elura_skincare_app/models/quickTipsModel.dart';

class AppData {
  static Routine morningRoutine = Routine(
    title: 'Morning Routine',
    subtitle: 'Cleanse, serum, moisturize, sunscreen',
    image: 'assets/images/morning_routine.jpg',
    steps: [
      'Cleanse your face with a gentle cleanser',
      'Apply vitamin C serum',
      'Use a hydrating moisturizer',
      'Apply SPF 30+ sunscreen',
      'Don\'t forget your neck and hands',
    ],
  );

  static Routine eveningRoutine = Routine(
    title: 'Evening Routine',
    subtitle: 'Makeup removal, cleanse, serum, night cream',
    image: 'assets/images/evening_routine.jpg',
    steps: [
      'Remove makeup with cleansing oil',
      'Double cleanse with gentle cleanser',
      'Apply retinol or night serum',
      'Use rich night cream',
      'Apply eye cream around eyes',
    ],
  );

  static List<Routine> allRoutines = [
    morningRoutine,
    eveningRoutine,
  ];

  static List<Tip> quickTips = [
    Tip(
      title: 'Hydration is key',
      subtitle: 'Drink plenty of water',
      image: 'assets/images/hydration.jpg',
      backgroundColor: '0xFFE8E8E8',
      description: 'Drinking at least 8 glasses of water daily helps keep your skin hydrated from within. Water flushes out toxins and helps maintain skin elasticity.',
    ),
    Tip(
      title: 'Sunscreen every day',
      subtitle: 'Even on cloudy days',
      image: 'assets/images/sunscreen.jpg',
      backgroundColor: '0xFFD4E5D4',
      description: 'UV rays penetrate through clouds and can damage your skin even on overcast days. Always wear SPF 30 or higher to protect against premature aging and skin cancer.',
    ),
    Tip(
      title: 'Gentle cleansing',
      subtitle: 'Once or twice daily',
      image: 'assets/images/cleansing.jpg',
      backgroundColor: '0xFFF5E6D3',
      description: 'Over-cleansing can strip your skin of natural oils. Cleanse once in the evening, and in the morning if needed. Use lukewarm water and gentle circular motions.',
    ),
  ];
}