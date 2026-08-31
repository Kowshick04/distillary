import 'package:intl/intl.dart';

class DistilleryExcelSnapshot {
  final DateTime uploadedAt;
  final double feedRate;
  final double analyserTemp;
  final double productAlcohol;
  final double spentWashKl;
  final double reboilerTemp;
  final double washAlcohol;
  final double recovery;
  final double loss;
  final double bottomBrix;
  final double pressure;
  final double vacuum;
  final double dp;

  const DistilleryExcelSnapshot({
    required this.uploadedAt,
    required this.feedRate,
    required this.analyserTemp,
    required this.productAlcohol,
    required this.spentWashKl,
    required this.reboilerTemp,
    required this.washAlcohol,
    required this.recovery,
    required this.loss,
    required this.bottomBrix,
    required this.pressure,
    required this.vacuum,
    required this.dp,
  });

  String get dateLabel => DateFormat('dd MMM yyyy').format(uploadedAt);
  String get timeLabel => DateFormat('hh:mm a').format(uploadedAt);

  factory DistilleryExcelSnapshot.fromTelemetry({
    required double feedRate,
    required double analyserTemp,
    required double productAlcohol,
    required double washAlcohol,
    required double recovery,
    required double loss,
    required double bottomBrix,
    required double pressure,
    required double vacuum,
    required double dp,
    required double spentWashKl,
    required double reboilerTemp,
  }) {
    return DistilleryExcelSnapshot(
      uploadedAt: DateTime.now(),
      feedRate: feedRate,
      analyserTemp: analyserTemp,
      productAlcohol: productAlcohol,
      spentWashKl: spentWashKl,
      reboilerTemp: reboilerTemp,
      washAlcohol: washAlcohol,
      recovery: recovery,
      loss: loss,
      bottomBrix: bottomBrix,
      pressure: pressure,
      vacuum: vacuum,
      dp: dp,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DistilleryExcelSnapshot &&
      other.uploadedAt.millisecondsSinceEpoch ==
          uploadedAt.millisecondsSinceEpoch;

  @override
  int get hashCode => uploadedAt.millisecondsSinceEpoch.hashCode;
}