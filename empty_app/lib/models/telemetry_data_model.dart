class FermenterItem {
  final int id;
  final String status;
  final String subStatus;
  final double temp;
  final double ph;
  final double brix;
  final String yeast;
  final String va;
  final int vol;
  final String aiPredict;
  final double confidence;
  final double recovery;
  final double alcohol;

  FermenterItem({
    required this.id,
    required this.status,
    required this.subStatus,
    required this.temp,
    required this.ph,
    required this.brix,
    required this.yeast,
    required this.va,
    required this.vol,
    required this.aiPredict,
    this.confidence = 0.0,
    this.recovery = 0.0,
    this.alcohol = 0.0,
  });

  factory FermenterItem.fromJson(Map<String, dynamic> json) {
    return FermenterItem(
      id: (json['id'] as num?)?.toInt() ?? 1,
      status: json['status']?.toString() ?? 'AWAITING_SYNC',
      subStatus: json['subStatus']?.toString() ?? '',
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
      ph: (json['ph'] as num?)?.toDouble() ?? 0.0,
      brix: (json['brix'] as num?)?.toDouble() ?? 0.0,
      yeast: json['yeast']?.toString() ?? '0M',
      va: json['va']?.toString() ?? '0p',
      vol: (json['vol'] as num?)?.toInt() ?? 0,
      aiPredict: json['aiPredict']?.toString() ?? 'AWAITING SYNC',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      recovery: (json['recovery'] as num?)?.toDouble() ?? 0.0,
      alcohol: (json['alcohol'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TelemetryDataModel {
  double get analyserTemp => analyserColumn > 0 ? analyserColumn : 76.1;
  double get productAlcoholFinal => finalAlcohol > 0 ? finalAlcohol : 99.9;
  double get washAlcoholFeed => washAlcohol > 0 ? washAlcohol : 12.9;
  double get alcoholLossSpentwash => alcoholLoss > 0 ? alcoholLoss : 0.05;
  double get bottomSpentwashBrix => bottomSpentWashBrix > 0 ? bottomSpentWashBrix : 4.6;
  double get fermenterPowerKw => plantPowerKw;
  double get steamConsumptionKgph => 1250.0;
  double get spentwashRecycle => spentWashRecycle > 0 ? spentWashRecycle : 6.0;
  double get rawSpentwashBrix => rawSpentWashBrix > 0 ? rawSpentWashBrix : 14.7;
  double get concSpentwashBrix => concentratedBrix > 0 ? concentratedBrix : 56.4;

  final String factoryCode;
  final String excelTimestamp;
  final int fermenter;
  final String pf;
  final double temperature;
  final double pressure;
  final double vacuum;
  final double deltaP;
  final double setupPh;
  final double finalPh;
  final double setupSg;
  final double finalSg;
  final double feedingHours;
  final double retentionHours;
  final double actualProduction;
  final double feEfficiency;
  final double ethanolPct;
  final String predictionLabel;
  final double confidenceScore;

  // Distillery Overview specific fields
  final double washAlcohol;
  final double feedRate;
  final double finalAlcohol;
  final double alcoholLoss;
  final double spentWashFeed;
  final double analyserColumn;
  final double ffe;
  final double spentWashTank;
  final double rcStrength;
  final double msdh;
  final double ethanol;
  final double rawSpentWashBrix;
  final double bottomSpentWashBrix;
  final double ffeOutletBrix;
  final double concentratedBrix;
  final double spentWashRecycle;
  final String fileName;

  // Fermenter array items
  final List<FermenterItem> fermentersList;

  TelemetryDataModel({
    required this.factoryCode,
    required this.excelTimestamp,
    required this.fermenter,
    required this.pf,
    required this.temperature,
    required this.pressure,
    required this.vacuum,
    required this.deltaP,
    required this.setupPh,
    required this.finalPh,
    required this.setupSg,
    required this.finalSg,
    required this.feedingHours,
    required this.retentionHours,
    required this.actualProduction,
    required this.feEfficiency,
    required this.ethanolPct,
    required this.predictionLabel,
    required this.confidenceScore,
    required this.washAlcohol,
    required this.feedRate,
    required this.finalAlcohol,
    required this.alcoholLoss,
    required this.spentWashFeed,
    required this.analyserColumn,
    required this.ffe,
    required this.spentWashTank,
    required this.rcStrength,
    required this.msdh,
    required this.ethanol,
    required this.rawSpentWashBrix,
    required this.bottomSpentWashBrix,
    required this.ffeOutletBrix,
    required this.concentratedBrix,
    required this.spentWashRecycle,
    this.fileName = '',
    required this.fermentersList,
  });

  // Aliases for UI backwards compatibility
  double get brix => setupSg > 0 ? setupSg : 1.5;
  double get alcohol => ethanolPct > 0 ? ethanolPct : 10.8;
  double get ph => finalPh > 0 ? finalPh : 4.2;
  double get fermentationEfficiency => feEfficiency > 0 ? feEfficiency : 90.6;

  String get state => predictionLabel;
  String get serverTimestamp => excelTimestamp;
  double get plantPowerKw => 45.0;
  String get avgTempText => '${temperature.toStringAsFixed(1)} °C';
  String get avgPhText => ph.toStringAsFixed(2);
  String get avgAlcoholText => '${ethanolPct.toStringAsFixed(1)} %';
  String get activeFermentersText => '7 / 20';
  String get predictedEthanolText => '${actualProduction.toStringAsFixed(0)} KL';
  String get completedBatchesText => '12';
  String get batchId => 'BATCH-$factoryCode-01';
  double get agitatorHealthScore => 97.0;
  double get predictionConfidence => confidenceScore;
  double get coolingWaterFlowLpm => 385.0;
  double get batchQualityScore => 94.0;

  factory TelemetryDataModel.initial() {
    return TelemetryDataModel(
      factoryCode: 'F01',
      excelTimestamp: '12:49',
      fermenter: 1,
      pf: 'PF-1',
      temperature: 76.1,
      pressure: 0.63,
      vacuum: -0.62,
      deltaP: 0.22,
      setupPh: 4.5,
      finalPh: 4.48,
      setupSg: 1.085,
      finalSg: 1.010,
      feedingHours: 18.5,
      retentionHours: 48.0,
      actualProduction: 1575.9,
      feEfficiency: 90.6,
      ethanolPct: 12.9,
      predictionLabel: 'GOLDEN BATCH',
      confidenceScore: 0.94,
      washAlcohol: 12.9,
      feedRate: 54.7,
      finalAlcohol: 99.9,
      alcoholLoss: 0.05,
      spentWashFeed: 54.7,
      analyserColumn: 76.1,
      ffe: 27.7,
      spentWashTank: 4.6,
      rcStrength: 99.9,
      msdh: 98.2,
      ethanol: 99.9,
      rawSpentWashBrix: 14.7,
      bottomSpentWashBrix: 4.6,
      ffeOutletBrix: 27.7,
      concentratedBrix: 56.4,
      spentWashRecycle: 6.0,
      fermentersList: [
        FermenterItem(id: 1, status: 'AWAITING_SYNC', subStatus: '', temp: 0.0, ph: 0.0, brix: 0.0, yeast: '0M', va: '0p', vol: 0, aiPredict: 'AWAITING SYNC'),
        FermenterItem(id: 2, status: 'AWAITING_SYNC', subStatus: '', temp: 0.0, ph: 0.0, brix: 0.0, yeast: '0M', va: '0p', vol: 0, aiPredict: 'AWAITING SYNC'),
        FermenterItem(id: 3, status: 'AWAITING_SYNC', subStatus: '', temp: 0.0, ph: 0.0, brix: 0.0, yeast: '0M', va: '0p', vol: 0, aiPredict: 'AWAITING SYNC'),
        FermenterItem(id: 4, status: 'AWAITING_SYNC', subStatus: '', temp: 0.0, ph: 0.0, brix: 0.0, yeast: '0M', va: '0p', vol: 0, aiPredict: 'AWAITING SYNC'),
      ],
    );
  }

  factory TelemetryDataModel.fromJson(Map<String, dynamic> json) {
    List<FermenterItem> fermenters = [];
    if (json['fermenters'] != null && json['fermenters'] is List) {
      fermenters = (json['fermenters'] as List)
          .map((i) => FermenterItem.fromJson(i as Map<String, dynamic>))
          .toList();
    } else {
      fermenters = TelemetryDataModel.initial().fermentersList;
    }

    final dist = json['distillation'] as Map<String, dynamic>? ?? {};

    // Normalize feEfficiency: some sources send 0.89 (fraction), others send 89.0 (percent)
    double rawEfficiency = (json['feEfficiency'] as num?)?.toDouble() ?? 90.6;
    if (rawEfficiency > 0.0 && rawEfficiency <= 1.0) rawEfficiency *= 100.0;

    return TelemetryDataModel(
      factoryCode: json['factoryCode']?.toString() ?? 'F01',
      excelTimestamp: json['excelTimestamp']?.toString() ?? '12:49',
      fermenter: (json['fermenter'] as num?)?.toInt() ?? 1,
      pf: json['pf']?.toString() ?? 'PF-1',
      temperature: (json['temperature'] as num?)?.toDouble() ?? (dist['columnTemp'] as num?)?.toDouble() ?? 76.1,
      pressure: (json['pressure'] as num?)?.toDouble() ?? (dist['columnPressure'] as num?)?.toDouble() ?? 0.63,
      vacuum: (json['vacuum'] as num?)?.toDouble() ?? (dist['columnVacuum'] as num?)?.toDouble() ?? -0.62,
      deltaP: (json['deltaP'] as num?)?.toDouble() ?? (dist['columnDeltaP'] as num?)?.toDouble() ?? 0.22,
      setupPh: (json['setupPh'] as num?)?.toDouble() ?? 4.5,
      finalPh: (json['finalPh'] as num?)?.toDouble() ?? 4.48,
      setupSg: (json['setupSg'] as num?)?.toDouble() ?? 1.085,
      finalSg: (json['finalSg'] as num?)?.toDouble() ?? 1.010,
      feedingHours: (json['feedingHours'] as num?)?.toDouble() ?? 18.5,
      retentionHours: (json['retentionHours'] as num?)?.toDouble() ?? 48.0,
      actualProduction: (json['actualProduction'] as num?)?.toDouble() ?? 1575.9,
      feEfficiency: rawEfficiency,
      // ethanolPct = product purity (e.g. 99.64%) — read from ethanolPct key
      ethanolPct: (json['ethanolPct'] as num?)?.toDouble() ?? (dist['finalAlcohol'] as num?)?.toDouble() ?? 99.9,
      // Normalize alert: 'GOLDEN' and 'GOLDEN BATCH' both map to 'GOLDEN BATCH'
      predictionLabel: _normalizeAlert(json['alert']?.toString()),
      confidenceScore: (json['confidence'] as num?)?.toDouble() ?? 0.94,
      // washAlcohol = fermented wash alcohol (col 32, ~11-13%) — top-level 'washAlcohol' key
      washAlcohol: (json['washAlcohol'] as num?)?.toDouble()
          ?? (json['washAlcoholFeed'] as num?)?.toDouble()
          ?? (dist['washAlcohol'] as num?)?.toDouble()
          ?? 12.9,
      feedRate: (json['feedRate'] as num?)?.toDouble() ?? (dist['feedRate'] as num?)?.toDouble() ?? 54.7,
      finalAlcohol: (json['productAlcoholFinal'] as num?)?.toDouble() ?? (dist['finalAlcohol'] as num?)?.toDouble() ?? 99.9,
      alcoholLoss: (json['alcoholLossSpentwash'] as num?)?.toDouble() ?? (dist['alcoholLoss'] as num?)?.toDouble() ?? 0.05,
      spentWashFeed: (json['feedRate'] as num?)?.toDouble() ?? (dist['spentWashFeed'] as num?)?.toDouble() ?? 54.7,
      analyserColumn: (json['analyserTemp'] as num?)?.toDouble() ?? (dist['analyserColumn'] as num?)?.toDouble() ?? 76.1,
      ffe: (json['ffeOutletBrix'] as num?)?.toDouble() ?? (dist['ffe'] as num?)?.toDouble() ?? 27.7,
      spentWashTank: (json['spentwashRecycle'] as num?)?.toDouble() ?? (dist['spentWashTank'] as num?)?.toDouble() ?? 4.6,
      rcStrength: (json['productAlcoholFinal'] as num?)?.toDouble() ?? (dist['rcStrength'] as num?)?.toDouble() ?? 99.9,
      msdh: (json['msdh'] as num?)?.toDouble() ?? (dist['msdh'] as num?)?.toDouble() ?? 98.2,
      ethanol: (json['productAlcoholFinal'] as num?)?.toDouble() ?? (dist['ethanol'] as num?)?.toDouble() ?? 99.9,
      rawSpentWashBrix: (json['rawSpentwashBrix'] as num?)?.toDouble() ?? (dist['rawSpentWashBrix'] as num?)?.toDouble() ?? 14.7,
      bottomSpentWashBrix: (json['bottomSpentwashBrix'] as num?)?.toDouble() ?? (dist['bottomSpentWashBrix'] as num?)?.toDouble() ?? 4.6,
      ffeOutletBrix: (json['ffeOutletBrix'] as num?)?.toDouble() ?? (dist['ffeOutletBrix'] as num?)?.toDouble() ?? 27.7,
      concentratedBrix: (json['concSpentwashBrix'] as num?)?.toDouble() ?? (dist['concentratedBrix'] as num?)?.toDouble() ?? 56.4,
      spentWashRecycle: (json['spentwashRecycle'] as num?)?.toDouble() ?? (dist['spentWashRecycle'] as num?)?.toDouble() ?? 6.0,
      fileName: json['fileName']?.toString() ?? json['file_name']?.toString() ?? '',
      fermentersList: fermenters,
    );
  }

  /// Normalizes alert/prediction label strings from different sources into
  /// a consistent canonical form used throughout the empty_app UI.
  static String _normalizeAlert(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'NORMAL';
    final u = raw.trim().toUpperCase();
    if (u.contains('GOLDEN')) return 'GOLDEN BATCH';
    if (u.contains('RISK') || u.contains('INFECTION')) return 'RISK (INFECTION)';
    if (u.contains('NORMAL')) return 'NORMAL';
    return u; // pass through unknown labels as-is
  }
}
