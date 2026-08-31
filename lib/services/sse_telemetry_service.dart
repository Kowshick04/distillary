import 'dart:async';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/telemetry_data_model.dart';
import 'package:intl/intl.dart';

enum SseConnectionStatus { connecting, connected, disconnected, simulating }

class SseTelemetryService {
  final String streamUrl;

  final StreamController<TelemetryDataModel> _telemetryController =
      StreamController<TelemetryDataModel>.broadcast();
  final StreamController<SseConnectionStatus> _statusController =
      StreamController<SseConnectionStatus>.broadcast();

  http.Client? _client;
  Timer? _reconnectTimer;
  bool _isDisposed = false;


  Stream<TelemetryDataModel> get telemetryStream => _telemetryController.stream;
  Stream<SseConnectionStatus> get statusStream => _statusController.stream;

  SseTelemetryService({
    String? url,
  }) : streamUrl = url ??
            (Platform.isAndroid
                ? "http://192.168.2.126:5000/api/v1/fermentation/stream"
                : "http://127.0.0.1:5000/api/v1/fermentation/stream");

  void connect() async {
    if (_isDisposed) return;
    _reconnectTimer?.cancel();
    _stopSimulation();
    _emit(SseConnectionStatus.connecting);

    try {
      _client = http.Client();
      final request = http.Request('GET', Uri.parse(streamUrl));
      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      // 8-second connection attempt timeout
      final response = await _client!.send(request).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw TimeoutException('Connection timed out after 8s');
        },
      );

      if (response.statusCode == 200) {
        _emit(SseConnectionStatus.connected);

        StringBuffer lineBuffer = StringBuffer();
        response.stream.transform(utf8.decoder).listen(
          (chunk) {
            lineBuffer.write(chunk);
            final lines = lineBuffer.toString().split('\n');
            lineBuffer = StringBuffer(lines.last);

            for (int i = 0; i < lines.length - 1; i++) {
              final line = lines[i].trim();
              if (line.startsWith('data:')) {
                final jsonStr = line.substring(5).trim();
                if (jsonStr.isNotEmpty) {
                  try {
                    final jsonData = jsonDecode(jsonStr);
                    if (jsonData is Map<String, dynamic>) {
                      if (jsonData.containsKey('event') && jsonData['event'] == 'new_distillery_batch') {
                        // Flask broadcasts all batch fields nested inside 'data' key:
                        // { "event": "new_distillery_batch", "data": { "factoryCode", "alert", "feEfficiency", ... } }
                        final raw = (jsonData['data'] as Map<String, dynamic>?) ?? {};

                        final String factoryCode = raw['factoryCode']?.toString() ?? 'F01';
                        final int fermenterNum = raw['fermenter'] as int? ?? 1;

                        // FE Efficiency comes as decimal (0.85) → multiply by 100 for percent
                        final double feEfficiencyRaw = (raw['feEfficiency'] as num? ?? 0.0).toDouble();
                        final double feEfficiencyPct = feEfficiencyRaw <= 1.0
                            ? feEfficiencyRaw * 100.0   // 0.85 → 85.0%
                            : feEfficiencyRaw;           // already in percent form

                        // ethanolPct = product purity (e.g. 99.8%) — used for yield display
                        final double ethanolPct = (raw['ethanolPct'] as num? ?? 0.0).toDouble();

                        // finalPh and setupPh — real fermentation pH from Excel
                        final double finalPh = (raw['finalPh'] as num? ?? 4.65).toDouble();

                        final double actualProduction = (raw['actualProduction'] as num? ?? 0.0).toDouble();
                        final double confidence = (raw['confidence'] as num? ?? 0.0).toDouble();

                        // confidence comes as decimal (0.85) → multiply by 100 for percent
                        final double confidencePct = confidence <= 1.0
                            ? confidence * 100.0
                            : confidence;

                        final String predLabel = raw['alert']?.toString().toLowerCase() ?? 'normal';
                        final String dateStr = raw['date']?.toString() ?? '';
                        final String syncTime = raw['sync_time']?.toString() ?? dateStr;

                        final telemetry = TelemetryDataModel(
                          factoryCode: factoryCode,
                          fileName: raw['fileName']?.toString() ?? '',
                          fileUrl: raw['fileUrl']?.toString() ?? '',
                          timestampMinute: 0,
                          batchId: 1000 + fermenterNum,
                          fermenter: fermenterNum,
                          state: 'DRIVE_INGEST',
                          temperature: 32.5,           // Not in Excel export — uses process default
                          alcohol: ethanolPct,          // Product ethanol purity % (e.g. 99.8)
                          brix: 2.0,                   // Not in Excel export — uses process default
                          ph: finalPh,                 // Real final pH from Excel (e.g. 4.69)
                          plantPowerKw: 1.0,
                          fermenterPowerKw: 28.0,
                          steamConsumptionKgph: 92.0,
                          coolingWaterFlowLpm: 400.0,
                          energyCostPerHour: 1600.0,
                          fermentationEfficiency: feEfficiencyPct, // Real FE efficiency % (e.g. 85.0)
                          yieldPercentage: actualProduction,        // Real KL production (e.g. 107.53)
                          batchQualityScore: confidencePct,         // AI confidence % (e.g. 85.0)
                          agitatorHealthScore: 95.0,
                          valveCoolingHealth: 98.0,
                          valveSteamHealth: 99.0,
                          serverTimestamp: syncTime,
                          predictionLabel: predLabel,
                          predictionConfidence: confidencePct,
                        );
                        if (!_telemetryController.isClosed) {
                          _telemetryController.add(telemetry);
                        }
                      } else {
                        final telemetry = TelemetryDataModel.fromJson(jsonData);
                        if (!_telemetryController.isClosed) {
                          _telemetryController.add(telemetry);
                        }
                      }
                    }
                  } catch (e) { debugPrint('[SSE] Parse error: \$e'); }
                }
              }
            }
          },
          onError: (_) => _handleDisconnect(),
          onDone: () => _handleDisconnect(),
          cancelOnError: true,
        );
      } else {
        _handleDisconnect();
      }
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (_isDisposed) return;
    _client?.close();
    _client = null;
    // SSE server (192.168.2.126:5000) is not available in standalone tablet mode.
    // Primary app uses local Excel pipeline (LocalPipelineService) for all data.
    // Do NOT reconnect — avoids port exhaustion from repeated timeout attempts.
    _emit(SseConnectionStatus.disconnected);
  }

  void _stopSimulation() {}

  void _emit(SseConnectionStatus status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  Future<List<TelemetryDataModel>> fetchSnapshots(String factoryCode) async {
    // SSE server (192.168.2.126:5000) is not available in standalone tablet mode.
    // Primary app populates data directly from local Excel files via LocalPipelineService.
    // Returning empty list immediately to prevent connection timeout spam and port exhaustion.
    debugPrint('[SSE] fetchSnapshots skipped (no server) for $factoryCode');
    return [];
  }

  Future<bool> submitOperatorAction(String action, String factoryCode) async {
    try {
      final baseUrl = Platform.isAndroid
          ? "http://192.168.2.126:5000"
          : "http://127.0.0.1:5000";
      final response = await http.post(
        Uri.parse("$baseUrl/api/v1/distillery/action_log"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': action,
          'factoryCode': factoryCode,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Error submitting operator action: $e");
      return false;
    }
  }

  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _client?.close();
    _telemetryController.close();
    _statusController.close();
  }
}
