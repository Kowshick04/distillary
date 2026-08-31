import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';
import 'services/mqtt_telemetry_service.dart';
import 'utils/app_colors.dart';

/// AuralissApp is a StatefulWidget so it can observe the app lifecycle.
/// When the app resumes from background (user reopens it), we force-reconnect
/// the MQTT service to clear stale singleton state that blocks re-connection.
class AuralissApp extends StatefulWidget {
  const AuralissApp({super.key});

  @override
  State<AuralissApp> createState() => _AuralissAppState();
}

class _AuralissAppState extends State<AuralissApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground — force-reconnect MQTT in case
      // it dropped while backgrounded or if stale flags are blocking reconnect
      debugPrint('APP LIFECYCLE: resumed — triggering MQTT forceReconnect()');
      mqttTelemetryService.forceReconnect();
    } else if (state == AppLifecycleState.paused) {
      debugPrint('APP LIFECYCLE: paused — app went to background');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AURALISS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'GeneralSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
