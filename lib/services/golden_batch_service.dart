import 'dart:math';

class GoldenBatchProfilePoint {
  final double temperature;
  final double alcohol;
  final double ph;
  final double brix;
  final double fermentationEfficiency;
  final double plantPowerKw;
  final double coolingWaterFlowLpm;
  final double agitatorHealthScore;
  final double batchQualityScore;

  const GoldenBatchProfilePoint({
    required this.temperature,
    required this.alcohol,
    required this.ph,
    required this.brix,
    required this.fermentationEfficiency,
    required this.plantPowerKw,
    required this.coolingWaterFlowLpm,
    required this.agitatorHealthScore,
    required this.batchQualityScore,
  });
}

class GoldenBatchService {
  // Returns reference Golden Profile targets for a given elapsed batch minute
  static GoldenBatchProfilePoint getTargetForMinute(int minute) {
    // Normalize minute to standard 24h batch window (1440 mins)
    final int m = minute.clamp(0, 1440);
    final double fraction = m / 1440.0;

    // 1. Temperature Curve (starts at 30.0, peaks at 33.5 at hour 12, cools to 31.0)
    double temp;
    if (fraction <= 0.5) {
      temp = 30.0 + sin(fraction * pi) * 3.5;
    } else {
      temp = 31.0 + cos((fraction - 0.5) * pi) * 2.5;
    }

    // 2. Alcohol Accumulation Curve (ideal logistic curve growth to 8.4%)
    final double alcohol = 8.4 / (1.0 + exp(-10.0 * (fraction - 0.3)));

    // 3. pH Decline Curve (decline from 5.4 to 4.5)
    final double ph = 5.4 - (0.9 * fraction);

    // 4. Brix Curve (consumption of sugar from 8.0 down to 1.5)
    final double brix = 8.0 - (6.5 * fraction);

    // 5. Static standard targets
    const double eff = 94.0;
    const double power = 88.0;
    const double cooling = 405.0;
    const double agitator = 95.0;
    const double quality = 92.0;

    return GoldenBatchProfilePoint(
      temperature: double.parse(temp.toStringAsFixed(2)),
      alcohol: double.parse(alcohol.toStringAsFixed(2)),
      ph: double.parse(ph.toStringAsFixed(3)),
      brix: double.parse(brix.toStringAsFixed(2)),
      fermentationEfficiency: eff,
      plantPowerKw: power,
      coolingWaterFlowLpm: cooling,
      agitatorHealthScore: agitator,
      batchQualityScore: quality,
    );
  }
}
