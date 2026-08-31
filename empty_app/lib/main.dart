import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

import 'services/mqtt_telemetry_service.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();



  // Configure transparent immersive system overlay space

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(

    statusBarColor: Colors.transparent,

    statusBarIconBrightness: Brightness.light,

    statusBarBrightness: Brightness.dark,

    systemNavigationBarColor: Colors.black,

    systemNavigationBarIconBrightness: Brightness.light,

  ));



  // Connect to live MQTT telemetry stream (broker.hivemq.com by default)

  mqttTelemetryService.connect();



  runApp(const AuralissApp());

}

