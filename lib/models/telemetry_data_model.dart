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
    );
  }
}

class TelemetryDataModel {
  final String factoryCode; // Added factoryCode routing key
  final int timestampMinute;
  final int batchId;
  final int fermenter;
  final String state;
  final double temperature;
  final double alcohol;
  final double brix;
  final double ph;
  final double plantPowerKw;
  final double fermenterPowerKw;
  final double steamConsumptionKgph;
  final double coolingWaterFlowLpm;
  final double energyCostPerHour;
  final double fermentationEfficiency;
  final double yieldPercentage;
  final double batchQualityScore;
  final double agitatorHealthScore;
  final double valveCoolingHealth;
  final double valveSteamHealth;
  final String serverTimestamp;
  final String predictionLabel;
  final double predictionConfidence;
  final String fileName;
  final String fileUrl;
  final double spentwashRecycle;
  final double analyserTemp;
  final double feedRate;
  final double concSpentwashBrix;
  final double alcoholLossSpentwash;
  final double washAlcoholFeed;
  final double bottomSpentwashBrix;
  final double rawSpentwashBrix;
  final double ffeOutletBrix;
  final double productAlcoholFinal;
  final List<FermenterItem> fermentersList;

  const TelemetryDataModel({
    this.factoryCode = 'F01',
    required this.timestampMinute,
    required this.batchId,
    required this.fermenter,
    required this.state,
    required this.temperature,
    required this.alcohol,
    required this.brix,
    required this.ph,
    required this.plantPowerKw,
    required this.fermenterPowerKw,
    required this.steamConsumptionKgph,
    required this.coolingWaterFlowLpm,
    required this.energyCostPerHour,
    required this.fermentationEfficiency,
    required this.yieldPercentage,
    required this.batchQualityScore,
    required this.agitatorHealthScore,
    required this.valveCoolingHealth,
    required this.valveSteamHealth,
    required this.serverTimestamp,
    required this.predictionLabel,
    required this.predictionConfidence,
    this.fileName = '',
    this.fileUrl = '',
    this.spentwashRecycle = 0.0,
    this.analyserTemp = 0.0,
    this.feedRate = 0.0,
    this.concSpentwashBrix = 0.0,
    this.alcoholLossSpentwash = 0.0,
    this.washAlcoholFeed = 0.0,
    this.bottomSpentwashBrix = 0.0,
    this.rawSpentwashBrix = 0.0,
    this.ffeOutletBrix = 0.0,
    this.productAlcoholFinal = 0.0,
    this.fermentersList = const [],
  });

  factory TelemetryDataModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      if (val is double) return val;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    List<FermenterItem> fermenters = [];
    if (json['fermenters'] != null && json['fermenters'] is List) {
      fermenters = (json['fermenters'] as List)
          .map((i) => FermenterItem.fromJson(i as Map<String, dynamic>))
          .toList();
    } else {
      fermenters = [
        FermenterItem(id: 1, status: 'AWAITING_SYNC', subStatus: '', temp: 0.0, ph: 0.0, brix: 0.0, yeast: '0M', va: '0p', vol: 0, aiPredict: 'AWAITING SYNC'),
        FermenterItem(id: 2, status: 'AWAITING_SYNC', subStatus: '', temp: 0.0, ph: 0.0, brix: 0.0, yeast: '0M', va: '0p', vol: 0, aiPredict: 'AWAITING SYNC'),
        FermenterItem(id: 3, status: 'AWAITING_SYNC', subStatus: '', temp: 0.0, ph: 0.0, brix: 0.0, yeast: '0M', va: '0p', vol: 0, aiPredict: 'AWAITING SYNC'),
        FermenterItem(id: 4, status: 'AWAITING_SYNC', subStatus: '', temp: 0.0, ph: 0.0, brix: 0.0, yeast: '0M', va: '0p', vol: 0, aiPredict: 'AWAITING SYNC'),
      ];
    }

    final dist = json['distillation'] as Map<String, dynamic>? ?? {};

    return TelemetryDataModel(
      factoryCode: json['factoryCode']?.toString() ?? 'F01',
      fileUrl: json['fileUrl']?.toString() ?? '',
      timestampMinute: toInt(json['timestamp_minute']),
      batchId: toInt(json['batch_id']),
      fermenter: toInt(json['fermenter']),
      state: json['state']?.toString() ?? 'IDLE',
      temperature: toDouble(json['temperature']),
      alcohol: toDouble(json['alcohol']),
      brix: toDouble(json['brix']),
      ph: toDouble(json['ph']),
      plantPowerKw: toDouble(json['plant_power_kw']),
      fermenterPowerKw: toDouble(json['fermenter_power_kw']),
      steamConsumptionKgph: toDouble(json['steam_consumption_kgph']),
      coolingWaterFlowLpm: toDouble(json['cooling_water_flow_lpm']),
      energyCostPerHour: toDouble(json['energy_cost_per_hour']),
      fermentationEfficiency: toDouble(json['fermentation_efficiency']),
      yieldPercentage: toDouble(json['yield_percentage']),
      batchQualityScore: toDouble(json['batch_quality_score']),
      agitatorHealthScore: toDouble(json['agitator_health_score']),
      valveCoolingHealth: toDouble(json['valve_cooling_health']),
      valveSteamHealth: toDouble(json['valve_steam_health']),
      serverTimestamp: json['server_timestamp']?.toString() ?? '',
      predictionLabel: json['prediction_label']?.toString() ?? 'normal',
      predictionConfidence: toDouble(json['prediction_confidence'] ?? 78.0),
      spentwashRecycle: toDouble(json['spentwashRecycle'] ?? dist['spentWashRecycle'] ?? dist['spentwashRecycle']),
      analyserTemp: toDouble(json['analyserTemp'] ?? dist['analyserColumn'] ?? dist['analyserTemp']),
      feedRate: toDouble(json['feedRate'] ?? dist['feedRate']),
      concSpentwashBrix: toDouble(json['concSpentwashBrix'] ?? dist['concentratedBrix'] ?? dist['concSpentwashBrix']),
      alcoholLossSpentwash: toDouble(json['alcoholLossSpentwash'] ?? dist['alcoholLoss'] ?? dist['alcoholLossSpentwash']),
      washAlcoholFeed: toDouble(json['washAlcoholFeed'] ?? dist['washAlcohol'] ?? dist['washAlcoholFeed']),
      bottomSpentwashBrix: toDouble(json['bottomSpentwashBrix'] ?? dist['bottomSpentWashBrix'] ?? dist['bottomSpentwashBrix']),
      rawSpentwashBrix: toDouble(json['rawSpentwashBrix'] ?? dist['rawSpentWashBrix'] ?? dist['rawSpentwashBrix']),
      ffeOutletBrix: toDouble(json['ffeOutletBrix'] ?? dist['ffeOutletBrix'] ?? dist['ffe']),
      productAlcoholFinal: toDouble(json['productAlcoholFinal'] ?? dist['finalAlcohol'] ?? dist['productAlcoholFinal']),
      fermentersList: fermenters,
    );
  }

  factory TelemetryDataModel.initial() {
    return const TelemetryDataModel(
      factoryCode: 'F01',
      timestampMinute: 0,
      batchId: 1000,
      fermenter: 1,
      state: 'IDLE',
      temperature: 32.1,
      alcohol: 8.2,
      brix: 1.5,
      ph: 4.65,
      plantPowerKw: 89.2,
      fermenterPowerKw: 28.0,
      steamConsumptionKgph: 92.0,
      coolingWaterFlowLpm: 400.0,
      energyCostPerHour: 1666.7,
      fermentationEfficiency: 91.8,
      yieldPercentage: 91.8,
      batchQualityScore: 70.0,
      agitatorHealthScore: 92.0,
      valveCoolingHealth: 97.0,
      valveSteamHealth: 99.0,
      serverTimestamp: '',
      predictionLabel: 'normal',
      predictionConfidence: 78.0,
    );
  }

  // Fermentation Specific Computed Getters
  String get activeFermentersText => "12 / 16 Running";
  String get predictedEthanolText => "${(48.2 + (alcohol > 0 ? (alcohol - 12.0) * 0.5 : 0.0)).toStringAsFixed(1)} KL";
  String get avgAlcoholText => "${(alcohol > 0 ? alcohol * 0.68 : 8.2).toStringAsFixed(1)} %";
  String get fermenterHealthText => "${(valveCoolingHealth > 0 ? valveCoolingHealth : 97.0).toStringAsFixed(0)}%";
  String get batchProgressText => "${(fermentationEfficiency > 0 ? (fermentationEfficiency * 0.74).clamp(10.0, 99.0) : 68.0).toStringAsFixed(0)}%";
  String get completedBatchesText => "${5 + (batchId % 3)}";
  String get avgTempText => "${(temperature > 0 ? temperature : 32.1).toStringAsFixed(1)}\u00B0C";
  String get avgPhText => (ph > 0 ? ph : 4.65).toStringAsFixed(2);
  
  double get feEfficiency => fermentationEfficiency;
  double get actualProduction => (48.2 + (alcohol > 0 ? (alcohol - 12.0) * 0.5 : 0.0));
}
