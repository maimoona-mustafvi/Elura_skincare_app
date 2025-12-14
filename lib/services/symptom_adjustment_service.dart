import '../models/product.dart';
import 'symptom_analysis.dart';

class SymptomAdjustmentService {

  List<Product> adjustRoutine({
    required List<Product> currentRoutine,
    required SymptomAnalysis analysis,
  }) {
    List<Product> adjusted = List.from(currentRoutine);

    // 🔴 Immediate + severe irritation → remove treatment
    if (analysis.irritationDetected && analysis.severeReaction) {
      adjusted.removeWhere(
        (p) => p.step.contains('Treatment'),
      );
    }

    // 🧊 Barrier damage → simplify routine
    if (analysis.barrierDamageLikely) {
      adjusted.removeWhere(
        (p) => p.step.contains('Treatment'),
      );
    }

    // 💥 Breakouts linked to moisturizer
    if (analysis.breakoutDetected &&
        analysis.suspectedProduct == 'Moisturizer') {
      adjusted.removeWhere(
        (p) => p.step.contains('Moisturize'),
      );
      adjusted.add(_oilFreeMoisturizer());
    }

    return adjusted;
  }

  Product _oilFreeMoisturizer() {
    return Product(
      name: 'Oil-Free Gel Moisturizer',
      description: 'Lightweight, non-comedogenic formula',
      step: 'Step 3: Moisturize',
      image: 'assets/images/cosrx.png',
    );
  }
}
