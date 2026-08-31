import 'package:flutter/material.dart';
import 'app.dart';

import 'services/distillery_background_worker.dart';
import 'services/distillery_service.dart';
import 'services/local_pipeline_service.dart';
import 'services/mqtt_publish_service.dart';
import 'services/mqtt_telemetry_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Android WorkManager for continuous background execution
  await DistilleryBackgroundWorker.initialize();
  await DistilleryBackgroundWorker.schedulePeriodicSync();

  // Initialize all 5 plant databases and seed factory identity metadata
  await distilleryService.initialize();

  // Start automatic file scanner — permissions will be requested on first scan
  // NOTE: do NOT await requestStoragePermissions() here — needs UI context
  localPipelineService.startAutoScanning();

  // Connect to live MQTT telemetry stream (broker.hivemq.com by default)
  mqttTelemetryService.connect();
  mqttPublishService.connect();

  runApp(const AuralissApp());
}

