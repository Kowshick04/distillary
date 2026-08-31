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
    scanLocalFolder();
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

      // Custom xlsx parser — reads raw XML, handles formula cached values
      final row = _readLastDataRowFromXlsx(bytes);
      if (row.isEmpty) {
        print("LocalPipelineService: No data row found in $fileName");
        return;
      }
      print("LocalPipelineService: Row length=${row.length}, processing $fileName");

      final int fermenterNum    = _parseInt(row.length > 4  ? row[4]  : null) ?? 1;
      final double feedingHours = _parseD(row, 8)  ?? _featureMedians["feeding_hours"]!;
      final double retentHours  = _parseD(row, 9)  ?? _featureMedians["retention_hours"]!;
      final double setupSg      = _parseD(row, 28) ?? _featureMedians["setup_sg"]!;
      final double finalSg      = _parseD(row, 29) ?? _featureMedians["final_sg"]!;
      final double sgDiff       = (setupSg - finalSg).abs();
      final double setupAlc     = _parseD(row, 31) ?? _featureMedians["setup_alc"]!;
      final double finalAlc     = _parseD(row, 32) ?? _featureMedians["final_alc"]!;
      final double setupPh      = _parseD(row, 35) ?? _featureMedians["setup_ph"]!;
      final double finalPh      = _parseD(row, 36) ?? _featureMedians["final_ph"]!;

      final double spentwashRecycle     = _parseD(row, 11) ?? 6.0;
      final double finalRs              = _parseD(row, 34) ?? 2.3;
      final double analyserTemp         = 75.0 + finalRs;
      final double feedRate             = _parseD(row, 49) ?? 54.7;
      final double concSpentwashBrix    = _parseD(row, 55) ?? 56.4;
      final double alcoholLossSpentwash = _parseD(row, 62) ?? 0.05;
      final double washAlcoholFeed      = _parseD(row, 63) ?? 12.9;
      final double bottomSpentwashBrix  = _parseD(row, 65) ?? 4.6;
      final double rawSpentwashBrix     = _parseD(row, 66) ?? 14.7;
      final double ffeOutletBrix        = _parseD(row, 67) ?? 27.7;
      final double productAlcohol       = _parseD(row, 68) ?? 97.6;
      final double actualProduction     = _parseD(row, 45) ?? 1575.9;
      double rawEfficiency = _parseD(row, 46) ?? 91.8;
      if (rawEfficiency > 0.0 && rawEfficiency <= 1.0) {
        rawEfficiency *= 100.0;
      }
      final double efficiency = rawEfficiency;

      if (!randomForestPredictor.isLoaded) await randomForestPredictor.loadModel();

      final prediction = randomForestPredictor.predict({
        "feeding_hours": feedingHours, "retention_hours": retentHours,
        "setup_sg": setupSg, "final_sg": finalSg, "sg_diff": sgDiff,
        "setup_alc": setupAlc, "final_alc": finalAlc,
        "setup_ph": setupPh, "final_ph": finalPh,
      });
      final predLabel = prediction['predictionLabel']?.toString() ?? 'normal';
      final confidence = prediction['confidence'] != null ? (prediction['confidence'] as num).toDouble() : 90.0;

      String factoryCode = "F01";
      final fn = file.path.toLowerCase();
      if (fn.contains("haliyal") || fn.contains("f01"))     factoryCode = "F01";
      if (fn.contains("sankili") || fn.contains("f02"))     factoryCode = "F02";
      if (fn.contains("nellikuppam") || fn.contains("f03")) factoryCode = "F03";
      if (fn.contains("sivaganga") || fn.contains("sivagangai") || fn.contains("f04"))  factoryCode = "F04";
      if (fn.contains("bagalkot") || fn.contains("f05"))    factoryCode = "F05";

      final int targetVesselNum = fermenterNum.clamp(1, 4);
      final factoryVessels = _createInitialVessels();
      factoryVessels[targetVesselNum - 1] = {
        "id": fermenterNum,
        "status": predLabel.toUpperCase().contains('GOLDEN') ? 'GOLDEN BATCH'
            : (predLabel.toUpperCase().contains('INFECTION') ? 'RISK (INFECTION)' : 'NORMAL'),
        "subStatus": "FERMENTING",
        "temp": 30.5 + ((feedingHours * 0.1) % 3.0),
        "ph": finalPh,
        "brix": finalSg * 100.0 - 100.0,
        "yeast": "320M",
        "va": "80p",
        "vol": targetVesselNum == 4 ? 92 : 80,
        "aiPredict": predLabel.toUpperCase().contains('GOLDEN') ? 'GOLDEN BATCH'
            : (predLabel.toUpperCase().contains('INFECTION') ? 'RISK (INFECTION)' : 'NORMAL'),
      };
      _vesselsState[factoryCode] = factoryVessels;

      final telemetry = TelemetryDataModel(
        factoryCode: factoryCode, timestampMinute: 0,
        batchId: 1000 + fermenterNum, fermenter: fermenterNum,
        state: 'DRIVE_INGEST',
        temperature: 30.5 + ((feedingHours * 0.1) % 3.0),
        alcohol: productAlcohol,
        brix: finalRs * 3.0,
        ph: finalPh,
        plantPowerKw: 1.0, fermenterPowerKw: 28.0, steamConsumptionKgph: 92.0,
        coolingWaterFlowLpm: 400.0, energyCostPerHour: 1600.0,
        fermentationEfficiency: efficiency, yieldPercentage: efficiency,
        batchQualityScore: confidence, agitatorHealthScore: 95.0,
        valveCoolingHealth: 98.0, valveSteamHealth: 99.0,
        serverTimestamp: DateTime.now().toString().split(' ')[1].substring(0, 5),
        predictionLabel: predLabel, predictionConfidence: confidence,
        fileName: fileName, fileUrl: file.path,
        spentwashRecycle: spentwashRecycle, analyserTemp: analyserTemp,
        feedRate: feedRate, concSpentwashBrix: concSpentwashBrix,
        alcoholLossSpentwash: alcoholLossSpentwash, washAlcoholFeed: washAlcoholFeed,
        bottomSpentwashBrix: bottomSpentwashBrix, rawSpentwashBrix: rawSpentwashBrix,
        ffeOutletBrix: ffeOutletBrix, productAlcoholFinal: productAlcohol,
        fermentersList: factoryVessels.map((f) => FermenterItem.fromJson(f)).toList(),
      );

      final syncTimeStr = DateTime.now().toString().split(' ')[1].substring(0, 5);
      final mqttPayload = {
        "factoryCode": factoryCode,
        "excelTimestamp": syncTimeStr,
        "fermenter": fermenterNum,
        "pf": "PF-1",
        "alert": predLabel.toUpperCase().contains('GOLDEN') ? 'GOLDEN BATCH'
            : (predLabel.toUpperCase().contains('INFECTION') ? 'RISK (INFECTION)' : 'NORMAL'),
        "actualProduction": actualProduction,
        "feEfficiency": efficiency,
        "washAlcohol": finalAlc,
        "ethanolPct": productAlcohol,
        "temperature": analyserTemp,
        "pressure": 0.63,
        "vacuum": -0.62,
        "deltaP": 0.22,
        "setupPh": setupPh,
        "finalPh": finalPh,
        "setupSg": setupSg,
        "finalSg": finalSg,
        "feedingHours": feedingHours,
        "retentionHours": retentHours,
        "confidence": confidence,
        "spentwashRecycle": spentwashRecycle,
        "analyserTemp": analyserTemp,
        "feedRate": feedRate,
        "concSpentwashBrix": concSpentwashBrix,
        "alcoholLossSpentwash": alcoholLossSpentwash,
        "washAlcoholFeed": washAlcoholFeed,
        "bottomSpentwashBrix": bottomSpentwashBrix,
        "rawSpentwashBrix": rawSpentwashBrix,
        "ffeOutletBrix": ffeOutletBrix,
        "productAlcoholFinal": productAlcohol,
        "fermenters": factoryVessels,
        "distillation": {
          "washAlcohol": washAlcoholFeed,
          "feedRate": feedRate,
          "finalAlcohol": productAlcohol,
          "alcoholLoss": alcoholLossSpentwash,
          "spentWashFeed": feedRate,
          "analyserColumn": analyserTemp,
          "ffe": ffeOutletBrix,
          "spentWashTank": spentwashRecycle,
          "rcStrength": productAlcohol,
          "msdh": 98.2,
          "ethanol": productAlcohol,
          "rawSpentWashBrix": rawSpentwashBrix,
          "bottomSpentWashBrix": bottomSpentwashBrix,
          "ffeOutletBrix": ffeOutletBrix,
          "concentratedBrix": concSpentwashBrix,
          "spentWashRecycle": spentwashRecycle
        }
      };

      mqttPublishService.publishTelemetry(factoryCode, mqttPayload).ignore();
      _lastMqttPayloads[factoryCode] = mqttPayload;
      _persistLastMqttPayload(factoryCode, mqttPayload).ignore();

      lastEmittedPackets[factoryCode] = telemetry;
      _telemetryStreamController.add(telemetry);
      _emitStatus(PipelineStatus(
        type: PipelineStatusType.fileLoaded,
        message: 'Loaded: $fileName | Alcohol: ${productAlcohol.toStringAsFixed(1)}% | $predLabel',
        fileName: fileName,
      ));
      print("LocalPipelineService: SUCCESS — $fileName | $predLabel @ ${confidence.toStringAsFixed(1)}%");
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

  /// Load persisted last MQTT payloads from disk and replay them over MQTT.
  /// Call this once after the MQTT publisher has connected on startup.
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

  // ─── Custom XLSX Parser ──────────────────────────────────────────────────
  // Reads xlsx as ZIP, parses raw XML. Formula cells expose their CACHED <v>
  // element which contains the already-computed numeric result.

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
}

final localPipelineService = LocalPipelineService();



