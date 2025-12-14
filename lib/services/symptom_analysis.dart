class SymptomAnalysis {
  final bool irritationDetected;
  final bool breakoutDetected;
  final bool severeReaction;
  final bool immediateReaction;
  final bool localizedReaction;
  final String suspectedProduct;
  final bool barrierDamageLikely;

  SymptomAnalysis({
    required this.irritationDetected,
    required this.breakoutDetected,
    required this.severeReaction,
    required this.immediateReaction,
    required this.localizedReaction,
    required this.suspectedProduct,
    required this.barrierDamageLikely,
  });
}

SymptomAnalysis analyzeSymptoms(Map<int, String> symptoms) {
  final symptomType = symptoms[0] ?? 'None';
  final severity = symptoms[1] ?? 'Mild';
  final onset = symptoms[2] ?? '';
  final location = symptoms[3] ?? '';
  final suspected = symptoms[4] ?? 'Not sure';
  final sensation = symptoms[5] ?? '';

  final irritation = symptomType == 'Redness' || symptomType == 'Burning / Stinging' || symptomType == 'Itching';

  final breakout = symptomType == 'Breakouts';

  final severe = severity == 'Severe';

  final immediate = onset.contains('Immediately');

  final localized = location != 'Entire face';

  final barrierDamage = sensation == 'Burning' || sensation == 'Tight' || sensation == 'Warm';

  return SymptomAnalysis(
    irritationDetected: irritation,
    breakoutDetected: breakout,
    severeReaction: severe,
    immediateReaction: immediate,
    localizedReaction: localized,
    suspectedProduct: suspected,
    barrierDamageLikely: barrierDamage,
  );
}
