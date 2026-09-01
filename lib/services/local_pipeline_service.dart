import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/telemetry_data_model.dart';
import 'mqtt_publish_service.dart';
import 'random_forest_predictor.dart';

/// Status emitted by the pipeline service for UI feedback.
class PipelineStatus {
  final PipelineStatusType type;
  final String message;
  final String? fileName;
  const PipelineStatus({required this.type, required this.message, this.fileName});
}

enum PipelineStatusType { scanning, fileLoaded, permissionDenied, error, idle }

class LocalPipelineService {
  static final LocalPipelineService _instance = LocalPipelineService._internal();

  final Map<String, List<Map<String, dynamic>>> _vesselsState = {
    'F01': _createInitialVessels(),
    'F02': _createInitialVessels(),
    'F03': _createInitialVessels(),
    'F04': _createInitialVessels(),
    'F05': _createInitialVessels(),
  };

  static List<Map<String, dynamic>> _createInitialVessels() {
    return [
      { "id": 1, "status": "AWAITING_SYNC", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "AWAITING SYNC" },
      { "id": 2, "status": "AWAITING_SYNC", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "AWAITING SYNC" },
      { "id": 3, "status": "AWAITING_SYNC", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "AWAITING SYNC" },
      { "id": 4, "status": "AWAITING_SYNC", "subStatus": "", "temp": 0.0, "ph": 0.0, "brix": 0.0, "yeast": "0M", "va": "0p", "vol": 0, "aiPredict": "AWAITING SYNC" }
    ];
  }

  factory LocalPipelineService() => _instance;
  LocalPipelineService._internal();

  final _telemetryStreamController = StreamController<TelemetryDataModel>.broadcast();
  Stream<TelemetryDataModel> get telemetryStream => _telemetryStreamController.stream;

  final _statusStreamController = StreamController<PipelineStatus>.broadcast();
  Stream<PipelineStatus> get statusStream => _statusStreamController.stream;

  PipelineStatus _lastStatus = const PipelineStatus(type: PipelineStatusType.idle, message: 'Initialising...');
  PipelineStatus get lastStatus => _lastStatus;

  Timer? _scanTimer;
  final Set<String> _processedFileHashes = {};
  final Set<String> _activeStreams = {};
  bool _isScanning = false;
  final Map<String, TelemetryDataModel> lastEmittedPackets = {};
  // Last MQTT payload per factory persisted to disk for replay after restart
  final Map<String, Map<String, dynamic>> _lastMqttPayloads = {};

  final Map<String, double> _featureMedians = {
    "feeding_hours": 20.0, "retention_hours": 24.0,
    "setup_sg": 1.055, "final_sg": 1.010, "sg_diff": 0.045,
    "setup_alc": 0.0, "final_alc": 9.5, "setup_ph": 4.5, "final_ph": 3.8,
  };

  void _emitStatus(PipelineStatus s) { _lastStatus = s; _statusStreamController.add(s); }

  void startAutoScanning() {
    _scanTimer?.cancel();
    loadPersistedPayloadsLocal().then((_) {
      scanLocalFolder();
    });
    _scanTimer = Timer.periodic(const Duration(seconds: 10), (_) => scanLocalFolder());
  }

  void stopAutoScanning() { _scanTimer?.cancel(); _scanTimer = null; }

  Future<List<Directory>> getScanDirectories() async {
    final dirs = <Directory>[];
    if (Platform.isAndroid) {
      final dlDist = Directory('/storage/emulated/0/Download/Distillery');
      if (!await dlDist.exists()) {
        try {
          await dlDist.create(recursive: true);
        } catch (_) {}
      }
      if (await dlDist.exists()) dirs.add(dlDist);

      final dl = Directory('/storage/emulated/0/Download');
      if (await dl.exists()) dirs.add(dl);
      try {
        final ext = await getExternalStorageDirectory();
        if (ext != null) { dirs.add(ext); final d = Directory('${ext.path}/Distillery'); if (!await d.exists()) await d.create(recursive: true); dirs.add(d); }
      } catch (_) {}
      try { final app = await getApplicationDocumentsDirectory(); dirs.add(app); } catch (_) {}
    } else {
      final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '.';
      final d = Directory('$home/Downloads/Distillery');
      if (!await d.exists()) await d.create(recursive: true);
      dirs.add(d);
    }
    return dirs;
  }

  Future<bool> requestStoragePermissions() async {
    if (!Platform.isAndroid) return true;
    if (await Permission.manageExternalStorage.isGranted) return true;
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
    return true;
  }

  Future<void> openFilesAccessSettings() async => openAppSettings();

  Future<void> scanLocalFolder() async {
    if (_isScanning) return;
    _isScanning = true;
    try {
      _emitStatus(const PipelineStatus(type: PipelineStatusType.scanning, message: 'Scanning for Excel files...'));
      requestStoragePermissions().ignore();
      final dirs = await getScanDirectories();
      bool foundNew = false;
      final scanned = <String>{};
      for (final dir in dirs) {
        try {
          if (!await dir.exists() || scanned.contains(dir.path)) continue;
          scanned.add(dir.path);
          final entities = await dir.list(recursive: true).toList();
          for (final e in entities) {
            if (e is File && e.path.toLowerCase().endsWith('.xlsx')) {
              final name = e.uri.pathSegments.last;
              if (name.startsWith('~') || name.startsWith('.')) continue;
              final stat = await e.stat();
              final hash = "${e.path}_${stat.size}_${stat.modified.millisecondsSinceEpoch}";
              if (!_processedFileHashes.contains(hash)) {
                print("LocalPipelineService: Found new file: $name at ${e.path}");
                _processedFileHashes.add(hash);
                await _processExcelFile(e);
                foundNew = true;
              }
            }
          }
        } catch (e) { print("LocalPipelineService: Scan error ${dir.path}: $e"); }
      }
      if (!foundNew && _processedFileHashes.isEmpty) {
        _emitStatus(const PipelineStatus(type: PipelineStatusType.scanning, message: 'Waiting for Excel files in Download folder...'));
      }
    } catch (e) {
      _emitStatus(PipelineStatus(type: PipelineStatusType.error, message: 'Scan error: $e'));
    } finally { _isScanning = false; }
  }

  Future<void> _processExcelFile(File file) async {
    final fileName = file.uri.pathSegments.last;
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return;

      // Custom xlsx parser — reads raw XML, handles formula cached values for up to 2 active fermenters
      final activeRows = _readRecentFermenterRowsFromXlsx(bytes, maxFermenters: 2);
      if (activeRows.isEmpty) {
        print("LocalPipelineService: No data rows found in $fileName");
        return;
      }
      print("LocalPipelineService: Processing $fileName with ${activeRows.length} active fermenter row(s)");

      if (!randomForestPredictor.isLoaded) await randomForestPredictor.loadModel();

      String factoryCode = "F01";
      final fn = file.path.toLowerCase();
      if (fn.contains("haliyal") || fn.contains("f01"))     factoryCode = "F01";
      if (fn.contains("sankili") || fn.contains("f02"))     factoryCode = "F02";
      if (fn.contains("nellikuppam") || fn.contains("f03")) factoryCode = "F03";
      if (fn.contains("sivaganga") || fn.contains("sivagangai") || fn.contains("f04"))  factoryCode = "F04";
      if (fn.contains("bagalkot") || fn.contains("f05"))    factoryCode = "F05";

      final factoryVessels = _createInitialVessels();

      String primaryPredLabel = 'NORMAL';
      double primaryConfidence = 90.0;
      int primaryFermenterNum = 1;
      double primaryEfficiency = 91.8;
      double primaryProductAlcohol = 97.6;
      double primaryAnalyserTemp = 76.1;
      double primarySetupPh = 4.5;
      double primaryFinalPh = 4.48;
      double primarySetupSg = 1.085;
      double primaryFinalSg = 1.010;
      double primaryFeedingHours = 18.5;
      double primaryRetentHours = 48.0;
      double primarySpentwashRecycle = 6.0;
      double primaryFeedRate = 54.7;
      double primaryConcSpentwashBrix = 56.4;
      double primaryAlcoholLoss = 0.05;
      double primaryWashAlcoholFeed = 12.9;
      double primaryBottomSpentwashBrix = 4.6;
      double primaryRawSpentwashBrix = 14.7;
      double primaryFfeOutletBrix = 27.7;
      double primaryActualProduction = 1575.9;
      double primaryFinalRs = 2.3;

      for (int i = 0; i < activeRows.length; i++) {
        final row = activeRows[i];
        final int rawFermenterNum = _parseInt(row.length > 4 ? row[4] : null) ?? (i + 1);
        final int targetVesselNum = rawFermenterNum.clamp(1, 4);

        final double feedingHours = _parseD(row, 8) ?? _featureMedians["feeding_hours"]!;
        final double retentHours = _parseD(row, 9) ?? _featureMedians["retention_hours"]!;
        final double setupSg = _parseD(row, 28) ?? _featureMedians["setup_sg"]!;
        final double finalSg = _parseD(row, 29) ?? _featureMedians["final_sg"]!;
        final double sgDiff = (setupSg - finalSg).abs();
        final double setupAlc = _parseD(row, 31) ?? _featureMedians["setup_alc"]!;
        final double finalAlc = _parseD(row, 32) ?? _featureMedians["final_alc"]!;
        final double setupPh = _parseD(row, 35) ?? _featureMedians["setup_ph"]!;
        final double finalPh = _parseD(row, 36) ?? _featureMedians["final_ph"]!;

        final prediction = randomForestPredictor.predict({
          "feeding_hours": feedingHours, "retention_hours": retentHours,
          "setup_sg": setupSg, "final_sg": finalSg, "sg_diff": sgDiff,
          "setup_alc": setupAlc, "final_alc": finalAlc,
          "setup_ph": setupPh, "final_ph": finalPh,
        });
        final predLabel = prediction['predictionLabel']?.toString() ?? 'NORMAL';
        final confidence = prediction['confidence'] != null ? (prediction['confidence'] as num).toDouble() : 90.0;

        factoryVessels[targetVesselNum - 1] = {
          "id": targetVesselNum,
          "status": predLabel.toUpperCase().contains('GOLDEN') ? 'GOLDEN BATCH'
              : (predLabel.toUpperCase().contains('INFECTION') ? 'RISK (INFECTION)' : 'NORMAL'),
          "subStatus": "FERMENTING",
          "temp": 30.5 + ((feedingHours * 0.1) % 3.0),
          "ph": finalPh,
          "brix": (finalSg * 100.0 - 100.0).clamp(0.5, 12.0),
          "yeast": targetVesselNum == 1 ? "320M" : "310M",
          "va": targetVesselNum == 1 ? "80p" : "75p",
          "vol": targetVesselNum == 4 ? 92 : (targetVesselNum == 1 ? 85 : 80),
          "aiPredict": predLabel.toUpperCase().contains('GOLDEN') ? 'GOLDEN BATCH'
              : (predLabel.toUpperCase().contains('INFECTION') ? 'RISK (INFECTION)' : 'NORMAL'),
        };

        if (i == 0) {
          primaryPredLabel = predLabel;
          primaryConfidence = confidence;
          primaryFermenterNum = targetVesselNum;
          primarySpentwashRecycle = _parseD(row, 11) ?? 6.0;
          primaryFinalRs = _parseD(row, 34) ?? 2.3;
          primaryAnalyserTemp = 75.0 + primaryFinalRs;
          primaryFeedRate = _parseD(row, 49) ?? 54.7;
          primaryConcSpentwashBrix = _parseD(row, 55) ?? 56.4;
          primaryAlcoholLoss = _parseD(row, 62) ?? 0.05;
          primaryWashAlcoholFeed = _parseD(row, 63) ?? 12.9;
          primaryBottomSpentwashBrix = _parseD(row, 65) ?? 4.6;
          primaryRawSpentwashBrix = _parseD(row, 66) ?? 14.7;
          primaryFfeOutletBrix = _parseD(row, 67) ?? 27.7;
          primaryProductAlcohol = _parseD(row, 68) ?? 97.6;
          primaryActualProduction = _parseD(row, 45) ?? 1575.9;
          double rawEff = _parseD(row, 46) ?? 91.8;
          if (rawEff > 0.0 && rawEff <= 1.0) rawEff *= 100.0;
          primaryEfficiency = rawEff;
          primarySetupPh = setupPh;
          primaryFinalPh = finalPh;
          primarySetupSg = setupSg;
          primaryFinalSg = finalSg;
          primaryFeedingHours = feedingHours;
          primaryRetentHours = retentHours;
        }
      }

      _vesselsState[factoryCode] = factoryVessels;

      final telemetry = TelemetryDataModel(
        factoryCode: factoryCode, timestampMinute: 0,
        batchId: 1000 + primaryFermenterNum, fermenter: primaryFermenterNum,
        state: 'DRIVE_INGEST',
        temperature: primaryAnalyserTemp,
        alcohol: primaryProductAlcohol,
        brix: primaryFinalRs * 3.0,
        ph: primaryFinalPh,
        plantPowerKw: 1.0, fermenterPowerKw: 28.0, steamConsumptionKgph: 92.0,
        coolingWaterFlowLpm: 400.0, energyCostPerHour: 1600.0,
        fermentationEfficiency: primaryEfficiency, yieldPercentage: primaryEfficiency,
        batchQualityScore: primaryConfidence, agitatorHealthScore: 95.0,
        valveCoolingHealth: 98.0, valveSteamHealth: 99.0,
        serverTimestamp: DateTime.now().toString().split(' ')[1].substring(0, 5),
        predictionLabel: primaryPredLabel, predictionConfidence: primaryConfidence,
        fileName: fileName, fileUrl: file.path,
        spentwashRecycle: primarySpentwashRecycle, analyserTemp: primaryAnalyserTemp,
        feedRate: primaryFeedRate, concSpentwashBrix: primaryConcSpentwashBrix,
        alcoholLossSpentwash: primaryAlcoholLoss, washAlcoholFeed: primaryWashAlcoholFeed,
        bottomSpentwashBrix: primaryBottomSpentwashBrix, rawSpentwashBrix: primaryRawSpentwashBrix,
        ffeOutletBrix: primaryFfeOutletBrix, productAlcoholFinal: primaryProductAlcohol,
        fermentersList: factoryVessels.map((f) => FermenterItem.fromJson(f)).toList(),
      );

      final syncTimeStr = DateTime.now().toString().split(' ')[1].substring(0, 5);
      final mqttPayload = {
        "factoryCode": factoryCode,
        "fileName": fileName,
        "excelTimestamp": syncTimeStr,
        "fermenter": primaryFermenterNum,
        "pf": "PF-1",
        "alert": primaryPredLabel.toUpperCase().contains('GOLDEN') ? 'GOLDEN BATCH'
            : (primaryPredLabel.toUpperCase().contains('INFECTION') ? 'RISK (INFECTION)' : 'NORMAL'),
        "actualProduction": primaryActualProduction,
        "feEfficiency": primaryEfficiency,
        "washAlcohol": primaryWashAlcoholFeed,
        "ethanolPct": primaryProductAlcohol,
        "temperature": primaryAnalyserTemp,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": primarySetupPh,
        "finalPh": primaryFinalPh,
        "setupSg": primarySetupSg,
        "finalSg": primaryFinalSg,
        "feedingHours": primaryFeedingHours,
        "retentionHours": primaryRetentHours,
        "confidence": primaryConfidence,
        "spentwashRecycle": primarySpentwashRecycle,
        "analyserTemp": primaryAnalyserTemp,
        "feedRate": primaryFeedRate,
        "concSpentwashBrix": primaryConcSpentwashBrix,
        "alcoholLossSpentwash": primaryAlcoholLoss,
        "washAlcoholFeed": primaryWashAlcoholFeed,
        "bottomSpentwashBrix": primaryBottomSpentwashBrix,
        "rawSpentwashBrix": primaryRawSpentwashBrix,
        "ffeOutletBrix": primaryFfeOutletBrix,
        "productAlcoholFinal": primaryProductAlcohol,
        "fermenters": factoryVessels,
        "distillation": {
          "washAlcohol": primaryWashAlcoholFeed,
          "feedRate": primaryFeedRate,
          "finalAlcohol": primaryProductAlcohol,
          "alcoholLoss": primaryAlcoholLoss,
          "spentWashFeed": primaryFeedRate,
          "analyserColumn": primaryAnalyserTemp,
          "ffe": primaryFfeOutletBrix,
          "spentWashTank": primarySpentwashRecycle,
          "rcStrength": primaryProductAlcohol,
          "msdh": 98.2,
          "ethanol": primaryProductAlcohol,
          "rawSpentWashBrix": primaryRawSpentwashBrix,
          "bottomSpentWashBrix": primaryBottomSpentwashBrix,
          "ffeOutletBrix": primaryFfeOutletBrix,
          "concentratedBrix": primaryConcSpentwashBrix,
          "spentWashRecycle": primarySpentwashRecycle
        }
      };

      mqttPublishService.publishTelemetry(factoryCode, mqttPayload).ignore();
      _lastMqttPayloads[factoryCode] = mqttPayload;
      _persistLastMqttPayload(factoryCode, mqttPayload).ignore();

      lastEmittedPackets[factoryCode] = telemetry;
      _telemetryStreamController.add(telemetry);
      _emitStatus(PipelineStatus(
        type: PipelineStatusType.fileLoaded,
        message: 'Loaded: $fileName | Alcohol: ${primaryProductAlcohol.toStringAsFixed(1)}% | $primaryPredLabel',
        fileName: fileName,
      ));
      print("LocalPipelineService: SUCCESS — $fileName | $primaryPredLabel @ ${primaryConfidence.toStringAsFixed(1)}%");
    } catch (e, st) {
      print("LocalPipelineService: Error parsing $fileName: $e\n$st");
      _emitStatus(PipelineStatus(type: PipelineStatusType.error, message: 'Error: $fileName'));
    }
  }

  Future<void> _persistLastMqttPayload(String factoryCode, Map<String, dynamic> payload) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/last_telemetry_$factoryCode.json');
      await file.writeAsString(jsonEncode(payload));
      print('LocalPipelineService: Persisted telemetry for $factoryCode to disk.');
    } catch (e) {
      print('LocalPipelineService: Failed to persist telemetry: $e');
    }
  }

  Map<String, dynamic>? getLastPayload(String factoryCode) {
    return _lastMqttPayloads[factoryCode];
  }

  Future<void> replayPersistedPayloads() async {
    try {
      final dir = await getApplicationSupportDirectory();
      for (final factoryCode in ['F01', 'F02', 'F03', 'F04', 'F05']) {
        final file = File('${dir.path}/last_telemetry_$factoryCode.json');
        if (!await file.exists()) continue;
        try {
          final content = await file.readAsString();
          final payload = Map<String, dynamic>.from(jsonDecode(content));
          
          final fermenters = payload['fermenters'] as List?;
          if (fermenters != null) {
            final activeCount = fermenters.where((f) => f['status'] != 'AWAITING_SYNC').length;
            if (activeCount > 1) {
              print('LocalPipelineService: Deleting legacy buggy telemetry payload for $factoryCode from disk.');
              try {
                await file.delete();
              } catch (_) {}
              continue;
            }
          }

          // Populate last emitted packets in memory
          final telemetry = TelemetryDataModel.fromJson(payload);
          lastEmittedPackets[factoryCode] = telemetry;
          _lastMqttPayloads[factoryCode] = payload;

          if (fermenters != null) {
            _vesselsState[factoryCode] = List<Map<String, dynamic>>.from(
              fermenters.map((f) => Map<String, dynamic>.from(f))
            );
          }

          // Emit to local UI listeners
          _telemetryStreamController.add(telemetry);

          print('LocalPipelineService: Replaying persisted telemetry for $factoryCode from disk...');
          await mqttPublishService.publishTelemetry(factoryCode, payload);
        } catch (e) {
          print('LocalPipelineService: Failed to replay persisted telemetry for $factoryCode: $e');
        }
      }
    } catch (e) {
      print('LocalPipelineService: Failed to load persisted payloads dir: $e');
    }
  }

  Future<void> loadPersistedPayloadsLocal() async {
    try {
      final dir = await getApplicationSupportDirectory();
      for (final factoryCode in ['F01', 'F02', 'F03', 'F04', 'F05']) {
        final file = File('${dir.path}/last_telemetry_$factoryCode.json');
        if (!await file.exists()) continue;
        try {
          final content = await file.readAsString();
          final payload = Map<String, dynamic>.from(jsonDecode(content));
          
          final fermenters = payload['fermenters'] as List?;
          if (fermenters != null) {
            final activeCount = fermenters.where((f) => f['status'] != 'AWAITING_SYNC').length;
            if (activeCount > 1) continue;
          }

          final telemetry = TelemetryDataModel.fromJson(payload);
          lastEmittedPackets[factoryCode] = telemetry;
          _lastMqttPayloads[factoryCode] = payload;

          if (fermenters != null) {
            _vesselsState[factoryCode] = List<Map<String, dynamic>>.from(
              fermenters.map((f) => Map<String, dynamic>.from(f))
            );
          }

          _telemetryStreamController.add(telemetry);
          _emitStatus(PipelineStatus(
            type: PipelineStatusType.fileLoaded,
            message: 'Loaded: ${telemetry.fileName} | Alcohol: ${telemetry.alcohol.toStringAsFixed(1)}% | ${telemetry.predictionLabel.toUpperCase()}',
            fileName: telemetry.fileName,
          ));
          print('LocalPipelineService: Locally loaded persisted telemetry for $factoryCode.');
        } catch (e) {
          print('LocalPipelineService: Failed to locally load telemetry for $factoryCode: $e');
        }
      }
    } catch (e) {
      print('LocalPipelineService: Failed to load local payloads dir: $e');
    }
  }

  // ─── Custom XLSX Parser ──────────────────────────────────────────────────
  // Reads xlsx as ZIP, parses raw XML. Formula cells expose their CACHED <v>
  // element which contains the already-computed numeric result.

  List<List<dynamic>> _readRecentFermenterRowsFromXlsx(Uint8List bytes, {int maxFermenters = 2}) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);

      // 1. Load shared strings table
      final ssEntry = archive.findFile('xl/sharedStrings.xml');
      final List<String> sharedStrings = [];
      if (ssEntry != null) {
        final ssDoc = XmlDocument.parse(utf8.decode(ssEntry.content as List<int>));
        for (final si in ssDoc.findAllElements('si')) {
          final text = si.findAllElements('t').map((t) => t.innerText).join('');
          sharedStrings.add(text);
        }
      }

      // 2. Find the first worksheet
      ArchiveFile? wsEntry;
      for (int i = 1; i <= 5; i++) {
        wsEntry = archive.findFile('xl/worksheets/sheet$i.xml');
        if (wsEntry != null) break;
      }
      if (wsEntry == null) return [];

      final wsDoc = XmlDocument.parse(utf8.decode(wsEntry.content as List<int>));
      final allRows = wsDoc.findAllElements('row').toList();
      if (allRows.isEmpty) return [];

      final Map<int, List<dynamic>> fermenterRows = {};

      for (final r in allRows.reversed) {
        final cells = r.findElements('c').toList();
        if (cells.isEmpty) continue;

        const maxCols = 75;
        final rowData = List<dynamic>.filled(maxCols, null);

        for (final c in cells) {
          final ref = c.getAttribute('r') ?? '';
          final colIdx = _colRefToIndex(ref);
          if (colIdx < 0 || colIdx >= maxCols) continue;

          final type = c.getAttribute('t') ?? '';
          if (type == 'inlineStr') {
            final isEl = c.findElements('is').firstOrNull;
            if (isEl != null) {
              final tEl = isEl.findElements('t').firstOrNull;
              rowData[colIdx] = tEl?.innerText ?? '';
            }
            continue;
          }

          final vEl = c.findElements('v').firstOrNull;
          final vText = vEl?.innerText.trim() ?? '';
          if (vText.isEmpty) { rowData[colIdx] = null; continue; }

          if (type == 's') {
            final idx = int.tryParse(vText);
            rowData[colIdx] = (idx != null && idx < sharedStrings.length) ? sharedStrings[idx] : null;
          } else if (type == 'str') {
            rowData[colIdx] = vText;
          } else if (type == 'b') {
            rowData[colIdx] = vText == '1';
          } else {
            rowData[colIdx] = num.tryParse(vText);
          }
        }

        final fNum = _parseInt(rowData.length > 4 ? rowData[4] : null);
        final hasData = _parseD(rowData, 8) != null || _parseD(rowData, 29) != null;
        if (fNum != null && fNum > 0 && hasData) {
          final mappedNum = fNum.clamp(1, 4);
          if (!fermenterRows.containsKey(mappedNum)) {
            fermenterRows[mappedNum] = rowData;
            if (fermenterRows.length >= maxFermenters) {
              break;
            }
          }
        }
      }

      if (fermenterRows.isEmpty) {
        final lastRow = _readLastDataRowFromXlsx(bytes);
        if (lastRow.isNotEmpty) return [lastRow];
        return [];
      }

      return fermenterRows.values.toList();
    } catch (e, st) {
      print("LocalPipelineService: Multi-XLSX parse error: $e\n$st");
      final lastRow = _readLastDataRowFromXlsx(bytes);
      if (lastRow.isNotEmpty) return [lastRow];
      return [];
    }
  }

  List<List<dynamic>> readRecentFermenterRowsForTesting(Uint8List bytes, {int maxFermenters = 2}) =>
      _readRecentFermenterRowsFromXlsx(bytes, maxFermenters: maxFermenters);

  List<dynamic> _readLastDataRowFromXlsx(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);

      // 1. Load shared strings table
      final ssEntry = archive.findFile('xl/sharedStrings.xml');
      final List<String> sharedStrings = [];
      if (ssEntry != null) {
        final ssDoc = XmlDocument.parse(utf8.decode(ssEntry.content as List<int>));
        for (final si in ssDoc.findAllElements('si')) {
          final text = si.findAllElements('t').map((t) => t.innerText).join('');
          sharedStrings.add(text);
        }
      }

      // 2. Find the first worksheet
      ArchiveFile? wsEntry;
      for (int i = 1; i <= 5; i++) {
        wsEntry = archive.findFile('xl/worksheets/sheet$i.xml');
        if (wsEntry != null) break;
      }
      if (wsEntry == null) return [];

      final wsDoc = XmlDocument.parse(utf8.decode(wsEntry.content as List<int>));
      final allRows = wsDoc.findAllElements('row').toList();
      if (allRows.isEmpty) return [];

      // 3. Find the last row that actually has <c> (cell) elements
      XmlElement? lastDataRow;
      for (final r in allRows.reversed) {
        final cells = r.findElements('c');
        if (cells.isNotEmpty) {
          lastDataRow = r;
          break;
        }
      }
      lastDataRow ??= allRows.last;
      print("LocalPipelineService: Selected XML row: r=${lastDataRow.getAttribute('r')}");

      // 4. Build a sparse column array (up to col 72)
      const maxCols = 75;
      final rowData = List<dynamic>.filled(maxCols, null);

      for (final c in lastDataRow.findElements('c')) {
        final ref = c.getAttribute('r') ?? '';
        final colIdx = _colRefToIndex(ref);
        if (colIdx < 0 || colIdx >= maxCols) continue;

        final type = c.getAttribute('t') ?? ''; 
        
        // Handle inlineStr
        if (type == 'inlineStr') {
          final isEl = c.findElements('is').firstOrNull;
          if (isEl != null) {
            final tEl = isEl.findElements('t').firstOrNull;
            rowData[colIdx] = tEl?.innerText ?? '';
          }
          continue;
        }

        final vEl = c.findElements('v').firstOrNull;
        final vText = vEl?.innerText.trim() ?? '';
        if (vText.isEmpty) { rowData[colIdx] = null; continue; }

        if (type == 's') {
          final idx = int.tryParse(vText);
          rowData[colIdx] = (idx != null && idx < sharedStrings.length) ? sharedStrings[idx] : null;
        } else if (type == 'str') {
          rowData[colIdx] = vText;
        } else if (type == 'b') {
          // Boolean cell (0 or 1)
          rowData[colIdx] = vText == '1';
        } else {
          // Numeric cell or formula cached numeric result
          rowData[colIdx] = num.tryParse(vText);
        }
      }
      return rowData;
    } catch (e, st) {
      print("LocalPipelineService: XLSX parse error: $e\n$st");
      return [];
    }
  }

  /// Converts Excel column reference letters to 0-based index.
  /// "A" → 0, "B" → 1, "Z" → 25, "AA" → 26, "AC" → 28
  int _colRefToIndex(String ref) {
    final letters = ref.replaceAll(RegExp(r'[0-9]'), '').toUpperCase();
    if (letters.isEmpty) return -1;
    int idx = 0;
    for (final ch in letters.codeUnits) {
      idx = idx * 26 + (ch - 64);
    }
    return idx - 1;
  }

  // ─── Safe value helpers ──────────────────────────────────────────────────

  double? _parseD(List<dynamic> row, int idx) {
    if (idx >= row.length) return null;
    return _parseDouble(row[idx]);
  }

  double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is num) return val.toDouble();
    final str = val.toString().trim().replaceAll('%', '').replaceAll(',', '.');
    if (str.isEmpty || str == '-' || str.startsWith('=') || str == 'N/A') return null;
    return double.tryParse(str);
  }

  int? _parseInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is num) return val.toInt();
    final str = val.toString().trim();
    if (str.isEmpty || str == '-' || str.startsWith('=')) return null;
    return int.tryParse(str);
  }

  String _getFactoryName(String code) {
    switch (code) {
      case 'F01': return 'Haliyal';
      case 'F02': return 'Sankili';
      case 'F03': return 'Nellikuppam';
      case 'F04': return 'Sivagangai';
      case 'F05': return 'Bagalkot';
      default: return 'Haliyal';
    }
  }
}

final localPipelineService = LocalPipelineService();



