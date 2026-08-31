import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() async {
  print("--- Standalone MQTT WebSocket Test ---");
  final host = 'broker.hivemq.com/mqtt';
  final port = 8000;
  final clientIdentifier = 'distillery_empty_test_client';
  
  // Prepend scheme for WebSocket if missing (required by mqtt_client Uri scheme validation)
  String finalHost = host;
  if (!finalHost.startsWith('ws://') && !finalHost.startsWith('wss://')) {
    finalHost = 'ws://$finalHost';
  }
  
  final uniqueId = DateTime.now().millisecondsSinceEpoch % 100000;
  final finalClientId = '${clientIdentifier}_$uniqueId';
  
  print("Connecting to: $finalHost on port $port with Client ID: $finalClientId");
  
  final client = MqttServerClient.withPort(finalHost, finalClientId, port);
  client.useWebSocket = true;
  client.useAlternateWebSocketImplementation = false;
  client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  client.logging(on: true);
  client.keepAlivePeriod = 20;
  client.setProtocolV311();
  
  client.onDisconnected = () {
    print("CALLBACK: Disconnected!");
  };
  client.onConnected = () {
    print("CALLBACK: Connected!");
  };
  
  try {
    print("Calling connect()...");
    final status = await client.connect();
    print("Connect completed! Status state: ${status?.state}");
    
    // Subscribe and listen
    const topic = 'distillery/factory/+/telemetry';
    client.subscribe(topic, MqttQos.atLeastOnce);
    print("Subscribed to: $topic");
    
    client.updates?.listen((messages) {
      if (messages == null || messages.isEmpty) return;
      for (final message in messages) {
        final recMess = message.payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        print("RECEIVED: ${message.topic} -> $pt");
      }
    });
    
    // Keep alive for 15 seconds to listen
    await Future.delayed(const Duration(seconds: 15));
    
  } catch (e, stack) {
    print("EXCEPTION CAUGHT: $e");
    print(stack);
  }
  client.disconnect();
}
