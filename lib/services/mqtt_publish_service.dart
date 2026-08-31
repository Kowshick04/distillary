import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:path_provider/path_provider.dart';
import 'local_pipeline_service.dart';

/// Persistently stores telemetry payloads that failed to publish due to offline network states.
class PendingMqttQueue {
  static Future<void>? _activeOperation;

  static Future<T> _synchronized<T>(FutureOr<T> Function() action) async {
    final previous = _activeOperation;
    final completer = Completer<void>();
    _activeOperation = completer.future;
    if (previous != null) {
      await previous;
    }
    try {
      return await action();
    } finally {
      completer.complete();
    }
  }

  static Future<File> _getQueueFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/mqtt_pending_telemetry.json');
  }

  static Future<List<Map<String, dynamic>>> loadQueue() {
    return _synchronized(() async {
      try {
        final file = await _getQueueFile();
        if (!await file.exists()) return [];
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (e) {
        debugPrint('MQTT Publisher Queue: Failed to load: $e');
        try {
          final file = await _getQueueFile();
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
        return [];
      }
    });
  }

  static Future<void> saveQueue(List<Map<String, dynamic>> queue) {
    return _synchronized(() async {
      try {
        final file = await _getQueueFile();
        await file.writeAsString(jsonEncode(queue));
      } catch (e) {
        debugPrint('MQTT Publisher Queue: Failed to save: $e');
      }
    });
  }

  static Future<void> enqueue(String factoryCode, Map<String, dynamic> payload) {
    return _synchronized(() async {
      List<Map<String, dynamic>> queue = [];
      try {
        final file = await _getQueueFile();
        if (await file.exists()) {
          final content = await file.readAsString();
          final List<dynamic> jsonList = jsonDecode(content);
          queue = jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      } catch (e) {
        debugPrint('MQTT Publisher Queue: Failed to load in enqueue: $e');
        try {
          final file = await _getQueueFile();
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }

      queue.add({
        'factoryCode': factoryCode,
        'payload': payload,
        'queuedAt': DateTime.now().toIso8601String(),
      });

      try {
        final file = await _getQueueFile();
        await file.writeAsString(jsonEncode(queue));
      } catch (e) {
        debugPrint('MQTT Publisher Queue: Failed to save in enqueue: $e');
      }
      debugPrint('MQTT Publisher Queue: Enqueued packet for $factoryCode. Current queue size: ${queue.length}');
    });
  }
}

class MqttPublishService {
  static final MqttPublishService _instance = MqttPublishService._internal();
  factory MqttPublishService() => _instance;
  
  MqttPublishService._internal() {
    _startSyncTimer();
  }

  MqttServerClient? _client;
  bool isConnected = false;
  bool _isConnecting = false;
  Timer? _syncTimer;

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (isConnected && _client != null) {
        await flushQueue();
      } else {
        // If disconnected, attempt connection silently to flush queue later
        debugPrint('MQTT Publisher: Sync timer fired (offline). Retrying connection...');
        await connect();
      }
    });
  }

  Future<void> connect({
    String host = 'broker.hivemq.com/mqtt',
    int port = 8000,
    String clientIdentifier = 'distillery_primary_publisher',
  }) async {
    if (isConnected || _isConnecting) return;
    _isConnecting = true;

    // Unique client ID to prevent broker session collision with other clients
    final uniqueId = DateTime.now().millisecondsSinceEpoch % 100000;
    final finalClientId = '${clientIdentifier}_$uniqueId';

    // Prepend scheme for WebSocket if missing (required by mqtt_client Uri scheme validation)
    String finalHost = host;
    if (!finalHost.startsWith('ws://') && !finalHost.startsWith('wss://')) {
      finalHost = 'ws://$finalHost';
    }

    // Use WebSocket transport (port 8083) — plain TCP port 1883 is blocked by most ISPs/mobile networks
    _client = MqttServerClient.withPort(finalHost, finalClientId, port);
    _client!.useWebSocket = true;
    _client!.useAlternateWebSocketImplementation = false;
    _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.autoReconnect = true;
    _client!.setProtocolV311(); // Force MQTT v3.1.1 to comply with modern brokers
    _client!.onDisconnected = () {
      isConnected = false;
      _isConnecting = false;
      debugPrint('MQTT Publisher: Disconnected');
    };
    _client!.onConnected = () {
      isConnected = true;
      _isConnecting = false;
      debugPrint('MQTT Publisher: Connected. Flushing queue + replaying persisted payloads...');
      flushQueue();
      // Replay last known packets from disk so empty_app syncs immediately on startup
      Future.delayed(const Duration(milliseconds: 800), localPipelineService.replayPersistedPayloads);
    };
    _client!.onAutoReconnected = () {
      isConnected = true;
      debugPrint('MQTT Publisher: Auto-reconnected. Flushing queue + replaying persisted payloads...');
      flushQueue();
      Future.delayed(const Duration(milliseconds: 800), localPipelineService.replayPersistedPayloads);
    };

    final connMess = MqttConnectMessage()
        .withClientIdentifier(finalClientId)
        .startClean();
    _client!.connectionMessage = connMess;

    try {
      debugPrint('MQTT Publisher: Connecting to $host:$port as $finalClientId...');
      await _client!.connect();
      isConnected = _client!.connectionStatus?.state == MqttConnectionState.connected;
      _isConnecting = false;
    } catch (e) {
      debugPrint('MQTT Publisher: Connection exception: $e');
      _client?.disconnect();
      isConnected = false;
      _isConnecting = false;
    }
  }

  Future<void> publishTelemetry(String factoryCode, Map<String, dynamic> payload) async {
    if (!isConnected || _client == null) {
      debugPrint('MQTT Publisher: Not connected, attempting to reconnect before publish...');
      await connect();
    }

    if (isConnected && _client != null) {
      try {
        final topic = 'distillery/factory/$factoryCode/telemetry';
        final builder = MqttClientPayloadBuilder();
        builder.addString(jsonEncode(payload));
        _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!, retain: false);
        debugPrint('MQTT Publisher: Published ${jsonEncode(payload).length} bytes to $topic');
        return; // Success
      } catch (e) {
        debugPrint('MQTT Publisher: Direct publish failed: $e. Saving to offline queue.');
      }
    } else {
      debugPrint('MQTT Publisher: Cannot publish (offline). Saving to offline queue.');
    }

    // Queue payload if offline or connection threw error
    await PendingMqttQueue.enqueue(factoryCode, payload);
  }

  Future<void> replayLastPackets() async {
    final packets = localPipelineService.lastEmittedPackets;
    if (packets.isEmpty) {
      debugPrint('MQTT Publisher: No cached packets to replay.');
      return;
    }
    debugPrint('MQTT Publisher: Replaying ${packets.length} cached telemetry packet(s) to MQTT...');
    for (final entry in packets.entries) {
      final factoryCode = entry.key;
      final t = entry.value;
      final payload = <String, dynamic>{
        'factoryCode': factoryCode,
        'excelTimestamp': DateTime.now().toString().split(' ')[1].substring(0, 5),
        'fermenter': t.fermenter,
        'alert': t.predictionLabel,
        'ethanolPct': t.productAlcoholFinal,
        'temperature': t.analyserTemp,
        'pressure': 0.63,
        'vacuum': -0.62,
        'deltaP': 0.22,
        'setupPh': t.ph,
        'finalPh': t.ph,
        'confidence': t.predictionConfidence,
        'spentwashRecycle': t.spentwashRecycle,
        'analyserTemp': t.analyserTemp,
        'feedRate': t.feedRate,
        'concSpentwashBrix': t.concSpentwashBrix,
        'alcoholLossSpentwash': t.alcoholLossSpentwash,
        'washAlcoholFeed': t.washAlcoholFeed,
        'bottomSpentwashBrix': t.bottomSpentwashBrix,
        'rawSpentwashBrix': t.rawSpentwashBrix,
        'ffeOutletBrix': t.ffeOutletBrix,
        'productAlcoholFinal': t.productAlcoholFinal,
        'fermenters': t.fermentersList.map((f) => {
          'id': f.id,
          'status': f.status,
          'subStatus': f.subStatus,
          'temp': f.temp,
          'ph': f.ph,
          'brix': f.brix,
          'yeast': f.yeast,
          'va': f.va,
          'vol': f.vol,
          'aiPredict': f.aiPredict,
        }).toList(),
      };
      await publishTelemetry(factoryCode, payload);
    }
  }

  Future<void> flushQueue() async {
    if (!isConnected || _client == null) return;

    final queue = await PendingMqttQueue.loadQueue();
    if (queue.isEmpty) return;

    debugPrint('MQTT Publisher: Flushing ${queue.length} pending offline telemetry packets...');
    final List<Map<String, dynamic>> failed = [];

    for (final item in queue) {
      final String factoryCode = item['factoryCode'] ?? 'F01';
      final Map<String, dynamic> payload = item['payload'] ?? {};

      try {
        final topic = 'distillery/factory/$factoryCode/telemetry';
        final builder = MqttClientPayloadBuilder();
        builder.addString(jsonEncode(payload));
        _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!, retain: false);
        debugPrint('MQTT Publisher: Flushed buffered telemetry packet for $factoryCode successfully');
      } catch (e) {
        debugPrint('MQTT Publisher: Failed to flush buffered packet for $factoryCode: $e');
        failed.add(item);
      }
    }

    await PendingMqttQueue.saveQueue(failed);
  }

  void disconnect() {
    _syncTimer?.cancel();
    _client?.disconnect();
    isConnected = false;
    _isConnecting = false;
  }
}

final mqttPublishService = MqttPublishService();
