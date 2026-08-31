import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/telemetry_data_model.dart';

class MqttTelemetryService {
  static final MqttTelemetryService _instance = MqttTelemetryService._internal();
  factory MqttTelemetryService() => _instance;
  MqttTelemetryService._internal();

  final _telemetryStreamController = StreamController<TelemetryDataModel>.broadcast();
  Stream<TelemetryDataModel> get telemetryStream => _telemetryStreamController.stream;

  final Map<String, TelemetryDataModel> lastEmittedPackets = {};
  final ValueNotifier<bool> connectionState = ValueNotifier<bool>(false);

  MqttServerClient? _client;
  bool isConnected = false;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 15;
  String _lastHost = 'broker.hivemq.com/mqtt';
  int _lastPort = 8000;
  StreamSubscription? _updatesSubscription;

  Future<void> connect({
    String host = 'broker.hivemq.com/mqtt',
    int port = 8000,
    String clientIdentifier = 'distillery_empty_client',
  }) async {
    if (isConnected || _isConnecting) return;
    _isConnecting = true;
    _lastHost = host;
    _lastPort = port;

    final uniqueId = DateTime.now().millisecondsSinceEpoch % 100000;
    final finalClientId = '${clientIdentifier}_$uniqueId';

    debugPrint('MQTT: Attempting to connect via WebSocket as $finalClientId to $host:$port');

    await _updatesSubscription?.cancel();
    _updatesSubscription = null;

    String finalHost = host;
    if (!finalHost.startsWith('ws://') && !finalHost.startsWith('wss://')) {
      finalHost = 'ws://$finalHost';
    }

    _client = MqttServerClient.withPort(finalHost, finalClientId, port);
    _client!.useWebSocket = true;
    _client!.useAlternateWebSocketImplementation = false;
    _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    _client!.logging(on: kDebugMode);
    _client!.keepAlivePeriod = 20;
    _client!.autoReconnect = true;
    _client!.setProtocolV311();
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onAutoReconnect = _onAutoReconnect;
    _client!.onAutoReconnected = _onAutoReconnected;
    _client!.onSubscribed = _onSubscribed;
    _client!.onSubscribeFail = (topic) => debugPrint('MQTT: Subscribe FAILED to $topic');

    final connMess = MqttConnectMessage()
        .withClientIdentifier(finalClientId)
        .startClean();
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
    } catch (e) {
      debugPrint('MQTT: Connection exception: $e');
      _client?.disconnect();
      _isConnecting = false;
      _onDisconnected();
      return;
    }

    if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
      _onConnected();
    } else {
      debugPrint('MQTT: Connection failed - status: ${_client!.connectionStatus}');
      _client?.disconnect();
      _isConnecting = false;
      _onDisconnected();
    }
  }

  /// Force a full reset and reconnect.
  /// Call this when the app resumes from background so stale singleton state is cleared.
  Future<void> forceReconnect() async {
    debugPrint('MQTT: Force reconnecting — resetting all state...');

    await _updatesSubscription?.cancel();
    _updatesSubscription = null;

    try {
      _client?.disconnect();
    } catch (_) {
      // ignore errors on stale client
    }
    _client = null;

    // *** THIS IS THE KEY FIX: reset all blocking flags before reconnecting ***
    isConnected = false;
    _isConnecting = false;
    _reconnectAttempts = 0;
    connectionState.value = false;

    // Strip any ws:// prefix — connect() will re-add it
    String cleanHost = _lastHost;
    if (cleanHost.startsWith('ws://')) cleanHost = cleanHost.replaceFirst('ws://', '');
    if (cleanHost.startsWith('wss://')) cleanHost = cleanHost.replaceFirst('wss://', '');

    await connect(host: cleanHost, port: _lastPort);
  }

  void _onConnected() {
    isConnected = true;
    _isConnecting = false;
    _reconnectAttempts = 0;
    connectionState.value = true;
    debugPrint('MQTT: Connected successfully!');

    const topic = 'distillery/factory/+/telemetry';
    _client!.subscribe(topic, MqttQos.atLeastOnce);
    debugPrint('MQTT: Subscribed to $topic');

    _updatesSubscription?.cancel();
    _updatesSubscription = _client!.updates?.listen(_onMessageReceived);
    debugPrint('MQTT: Message listener registered');
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> messages) {
    if (messages.isEmpty) return;

    for (final message in messages) {
      final recMess = message.payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      if (pt.trim().isEmpty) {
        debugPrint('MQTT: Received empty payload (retained message deleted) for ${message.topic}');
        continue;
      }
      debugPrint('MQTT: Received [${message.topic}]: ${pt.length > 200 ? "${pt.substring(0, 200)}..." : pt}');

      try {
        final Map<String, dynamic> data = jsonDecode(pt);
        final packet = TelemetryDataModel.fromJson(data);
        debugPrint('MQTT: Parsed packet factoryCode=${packet.factoryCode}, fermenters=${packet.fermentersList.length}');
        lastEmittedPackets[packet.factoryCode] = packet;
        _telemetryStreamController.add(packet);
      } catch (e) {
        debugPrint('MQTT: Error parsing payload JSON: $e');
        debugPrint('MQTT: Raw payload was: $pt');
      }
    }
  }

  void _onDisconnected() {
    isConnected = false;
    _isConnecting = false;
    connectionState.value = false;
    debugPrint('MQTT: Disconnected');
    if (!(_client?.autoReconnect ?? false)) {
      _scheduleReconnect();
    }
  }

  void _onAutoReconnect() {
    debugPrint('MQTT: Auto-reconnecting...');
    connectionState.value = false;
  }

  void _onAutoReconnected() {
    debugPrint('MQTT: Auto-reconnected!');
    connectionState.value = true;
    isConnected = true;
    _reconnectAttempts = 0;
    const topic = 'distillery/factory/+/telemetry';
    _client?.subscribe(topic, MqttQos.atLeastOnce);
    _updatesSubscription?.cancel();
    _updatesSubscription = _client?.updates?.listen(_onMessageReceived);
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('MQTT: Max reconnect attempts ($_maxReconnectAttempts) reached. Stopping.');
      return;
    }
    _reconnectAttempts++;
    final delaySec = (_reconnectAttempts * 3).clamp(3, 30);
    debugPrint('MQTT: Scheduling reconnect attempt $_reconnectAttempts in ${delaySec}s');
    Future.delayed(Duration(seconds: delaySec), () {
      if (!isConnected && !_isConnecting) {
        connect(host: _lastHost, port: _lastPort);
      }
    });
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTT: Successfully subscribed to $topic');
  }

  void disconnect() {
    _updatesSubscription?.cancel();
    _updatesSubscription = null;
    _client?.disconnect();
    isConnected = false;
    _isConnecting = false;
    connectionState.value = false;
  }
}

final mqttTelemetryService = MqttTelemetryService();
