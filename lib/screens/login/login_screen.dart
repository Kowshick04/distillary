import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import '../../widgets/common/glass_card.dart';
import '../dashboard/dashboard_screen.dart';
import '../../services/mqtt_telemetry_service.dart';
import '../../models/telemetry_data_model.dart';
import '../../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final bool skipVideo;
  const LoginScreen({super.key, this.skipVideo = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Live telemetry subscription
  
  StreamSubscription<TelemetryDataModel>? _telemetrySubscription;

  // View state: 'consolidated' or 'login'
  String _currentSubView = 'intro';
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Selected Target Login configuration
  String _selectedRole = 'ceo';
  String _selectedTitle = 'CEO Corporate Portal';
  IconData _selectedIcon = Icons.admin_panel_settings_rounded;
  Color _selectedColor = AppColors.amber;

  // Unified Entrance animations controller
  late AnimationController _introController;
  late Animation<double> _logoYOffset;
  late Animation<double> _logoScale;
  late Animation<double> _contentFade;
  late Animation<double> _contentSlide;
  late List<Animation<double>> _cardFades;
  late List<Animation<double>> _cardSlides;


  // Predefined users & credentials
  static const Map<String, String> _credentials = {
    'ceo': 'ceo123',
    'operator01': 'factory1',
    'operator02': 'factory2',
    'operator03': 'factory3',
    'operator04': 'factory4',
    'operator05': 'factory5',
  };

  // Predefined User ID display mapping
  String _getOperatorId(String role) {
    if (role == 'ceo') return 'ceo';
    if (role == 'operator1') return 'operator01';
    if (role == 'operator2') return 'operator02';
    if (role == 'operator3') return 'operator03';
    if (role == 'operator4') return 'operator04';
    if (role == 'operator5') return 'operator05';
    return '';
  }

  String _getFactoryCodeForRole(String role) {
    if (role == 'operator1') return 'F03'; // Nellikuppam
    if (role == 'operator2') return 'F04'; // Sivaganga
    if (role == 'operator3') return 'F02'; // Sankili
    if (role == 'operator4') return 'F01'; // Haliyal
    if (role == 'operator5') return 'F05'; // Bagalkot
    return 'F01'; // Default
  }

  // Predefined mock facility summaries
  // Factory 1=Nellikuppam, 2=Sivaganga, 3=Sankili, 4=Haliyal, 5=Bagalkot
  final List<Map<String, dynamic>> _facilities = [
    {
      'id': 'operator1',
      'title': 'Nellikuppam',
      'vessels': '2 / 4 Fermenters Active',
      'efficiency': 0.918, // 91.8%
      'flag': 'GOLDEN BATCH',
      'color': AppColors.cyan,
      'icon': Icons.factory_rounded,
      'vesselsState': [true, false, true, false],
    },
    {
      'id': 'operator2',
      'title': 'Sivaganga',
      'vessels': '0 / 4 Active (STANDBY)',
      'efficiency': 0.0,
      'flag': 'STANDBY',
      'color': AppColors.textMuted,
      'icon': Icons.factory_rounded,
      'vesselsState': [false, false, false, false],
    },
    {
      'id': 'operator3',
      'title': 'Sankili',
      'vessels': '2 / 4 Fermenters Active',
      'efficiency': 0.885, // 88.5%
      'flag': 'RISK (INFECTION)',
      'color': AppColors.red,
      'icon': Icons.factory_rounded,
      'vesselsState': [true, false, null, false],
    },
    {
      'id': 'operator4',
      'title': 'Haliyal',
      'vessels': '0 / 4 Active (STANDBY)',
      'efficiency': 0.0,
      'flag': 'STANDBY',
      'color': AppColors.textMuted,
      'icon': Icons.factory_rounded,
      'vesselsState': [false, false, false, false],
    },
    {
      'id': 'operator5',
      'title': 'Bagalkot',
      'vessels': '1 / 4 Fermenters Active',
      'efficiency': 0.902, // 90.2%
      'flag': 'NORMAL',
      'color': AppColors.blue,
      'icon': Icons.factory_rounded,
      'vesselsState': [true, false, false, false],
    },
  ];

  // Dynamic getters for Global consolidated stats
  int get _totalActiveVessels {
    int count = 0;
    for (var fac in _facilities) {
      final states = fac['vesselsState'] as List<dynamic>;
      count += states.where((s) => s == true || s == null).length;
    }
    return count;
  }

  double get _avgEfficiency {
    int activeFacs = 0;
    double sum = 0.0;
    for (var fac in _facilities) {
      final eff = fac['efficiency'] as double;
      if (eff > 0.0) {
        activeFacs++;
        sum += eff;
      }
    }
    return activeFacs > 0 ? (sum / activeFacs) * 100 : 0.0;
  }

  int get _totalAlarms {
    int alarms = 0;
    for (var fac in _facilities) {
      final states = fac['vesselsState'] as List<dynamic>;
      alarms += states.where((s) => s == null).length;
    }
    return alarms;
  }

  double get _combinedDailyYield {
    double base = 1200.0;
    for (var fac in _facilities) {
      final states = fac['vesselsState'] as List<dynamic>;
      final activeVessels = states.where((s) => s == true || s == null).length;
      base += activeVessels * 53.7;
    }
    return base;
  }

  @override
  void initState() {
    super.initState();
    _currentSubView = widget.skipVideo ? 'consolidated' : 'intro';
    
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _logoYOffset = Tween<double>(begin: 220.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
    _logoScale = Tween<double>(begin: 1.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );
    _contentSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _cardFades = List.generate(5, (index) {
      final start = 0.65 + (index * 0.05);
      final end = (start + 0.15).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _introController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
    _cardSlides = List.generate(5, (index) {
      final start = 0.65 + (index * 0.05);
      final end = (start + 0.15).clamp(0.0, 1.0);
      return Tween<double>(begin: 25.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _introController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
    // Initialize asset video player if on supported platforms
    if (!widget.skipVideo && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        _videoController = VideoPlayerController.asset('assets/flutter_intro_fixed.mp4')
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isVideoInitialized = true;
              });
              _videoController!.play();
            }
          }).catchError((error) {
            debugPrint("Video Player initialization error: $error");
            _skipIntro();
          });
        _videoController!.addListener(_videoListener);
        // Fail-safe timeout of 6 seconds to prevent get stuck on video initialization/playback
        Future.delayed(const Duration(seconds: 6), () {
          if (mounted && _currentSubView == 'intro') {
            _skipIntro();
          }
        });
      } catch (e) {
        debugPrint("Video Player catch exception: $e");
        _currentSubView = 'consolidated';
        _introController.forward();
      }
    } else {
      // Fallback for unsupported platforms (like Windows/Linux) or if skipping video
      _currentSubView = 'consolidated';
      _introController.forward();
    }
    // Initialize telemetry subscription to dynamically update Consolidated view
    _telemetrySubscription = mqttTelemetryService.telemetryStream.listen((packet) {
      if (mounted) {
        setState(() {
          final String code = packet.factoryCode;
          int facIdx = -1;
          if (code == 'F03') facIdx = 0; // Nellikuppam
          else if (code == 'F04') facIdx = 1; // Sivaganga
          else if (code == 'F02') facIdx = 2; // Sankili
          else if (code == 'F01') facIdx = 3; // Haliyal
          else if (code == 'F05') facIdx = 4; // Bagalkot
          
          if (facIdx >= 0 && facIdx < _facilities.length) {
            final int vesselIdx = (packet.fermenter - 1).clamp(0, 3);
            final List<dynamic> states = List<dynamic>.from(_facilities[facIdx]['vesselsState']);
            
            final String alert = packet.predictionLabel.toLowerCase();
            final bool isAlert = alert.contains('risk') ||
                                 alert.contains('infection') ||
                                 alert.contains('alert');
            
            // Since this packet is actively received from the factory stream, this vessel is running!
            states[vesselIdx] = isAlert ? null : true;
            _facilities[facIdx]['vesselsState'] = states;
            
            // Update stats
            _facilities[facIdx]['efficiency'] = packet.fermentationEfficiency / 100.0;
            _facilities[facIdx]['flag'] = packet.predictionLabel.toUpperCase();
            
            // Update factory card color according to alert state
            if (isAlert) {
              _facilities[facIdx]['color'] = AppColors.red;
            } else if (packet.predictionLabel.toUpperCase() == 'GOLDEN BATCH') {
              _facilities[facIdx]['color'] = AppColors.cyan;
            } else {
              _facilities[facIdx]['color'] = AppColors.blue;
            }
            
            final int activeCount = states.where((s) => s == true || s == null).length;
            _facilities[facIdx]['vessels'] = activeCount > 0 
                ? '$activeCount / 4 Fermenters Active'
                : '0 / 4 Active (STANDBY)';
          }
        });
      }
    });
  }
  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _introController.dispose();
    _telemetrySubscription?.cancel();
    super.dispose();
  }
  void _navigateToLogin(String role, String title, IconData icon, Color color) {
    setState(() {
      _selectedRole = role;
      _selectedTitle = title;
      _selectedIcon = icon;
      _selectedColor = color;
      _passwordController.clear();
      _errorMessage = null;
      _currentSubView = 'login';
    });
  }

  void _returnToOverview() {
    setState(() {
      _currentSubView = 'consolidated';
    });
    _introController.reset();
    _introController.forward();
  }

  void _handleLogin() {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final userId = _getOperatorId(_selectedRole);
    final password = _passwordController.text;

    // Validate credentials
    if (_credentials.containsKey(userId) && _credentials[userId] == password) {
      setState(() {
        _isLoading = true;
      });

      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Smooth cross-fade transition to Dashboard with correct factoryCode mapped to role
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DashboardScreen(
                    role: _selectedRole,
                    factoryCode: _getFactoryCodeForRole(_selectedRole),
                  ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      });
    } else {
      setState(() {
        _errorMessage = 'Invalid password for target console';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 960;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [

            // Main Content Area — Positioned.fill avoids AnimatedSwitcher element-tree crashes
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _currentSubView == 'intro' ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: _currentSubView != 'intro',
                  child: _buildIntroVideoView(),
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _currentSubView == 'consolidated' ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: _currentSubView != 'consolidated',
                  child: _buildConsolidatedView(isMobile),
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _currentSubView == 'login' ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: _currentSubView != 'login',
                  child: _buildLoginView(isMobile),
                ),
              ),
            ),

            // Footer Ultimate Edition Indicator
            Positioned(
              bottom: 20,
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo/auraliss_logo.png',
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '© 2026 Auraliss, LLP. All rights reserved.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  // â”€â”€ Sub-view 1: Consolidated Overview Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _videoListener() {
    if (_videoController != null) {
      final value = _videoController!.value;
      if (value.position >= value.duration || (!value.isPlaying && value.position > Duration.zero)) {
        _skipIntro();
      }
    }
  }
  void _skipIntro() {
    if (_currentSubView == 'intro') {
      _videoController?.removeListener(_videoListener);
      setState(() {
        _currentSubView = 'consolidated';
      });
      _introController.forward(from: 0.0);
    }
  }
  Widget _buildIntroVideoView() {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: _isVideoInitialized && _videoController != null
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
  Widget _buildConsolidatedView(bool isMobile) {
    return AnimatedBuilder(
      animation: _introController,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Branding Header (Centering & Transition Splash)
              Transform.translate(
                offset: Offset(0, _logoYOffset.value),
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo/parrys_logo.png',
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: _contentFade.value,
                        child: Column(
                          children: const [
                            Text(
                              'Enterprise Control Console',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              // Consolidated General Summary Cards Panel
              Transform.translate(
                offset: Offset(0, _contentSlide.value),
                child: Opacity(
                  opacity: _contentFade.value,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 860),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: GlassCard(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      borderRadius: 16,
                      backgroundColor: AppColors.glassOverlay,
                      borderColor: const Color(0x1AFFFFFF),
                      child: isMobile
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(child: _buildSummaryMetric('$_totalActiveVessels / 20', 'Active Fermenters')),
                                    Container(height: 24, width: 1, color: const Color(0x1AFFFFFF)),
                                    Expanded(child: _buildSummaryMetric('${_combinedDailyYield.toStringAsFixed(1)} KL', 'Daily Yield')),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(height: 1, width: double.infinity, color: const Color(0x1AFFFFFF)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(child: _buildSummaryMetric('${_avgEfficiency.toStringAsFixed(1)}%', 'Avg Efficiency')),
                                    Container(height: 24, width: 1, color: const Color(0x1AFFFFFF)),
                                    Expanded(child: _buildAlertSummaryMetric('$_totalAlarms RISK ALERTS', 'Active Alarms')),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryMetric('$_totalActiveVessels / 20', 'Active Fermenters'),
                                _buildDivider(),
                                _buildSummaryMetric('${_combinedDailyYield.toStringAsFixed(1)} KL', 'Daily Yield'),
                                _buildDivider(),
                                _buildSummaryMetric('${_avgEfficiency.toStringAsFixed(1)}%', 'Avg Efficiency'),
                                _buildDivider(),
                                _buildAlertSummaryMetric('$_totalAlarms RISK ALERTS', 'Active Alarms'),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              // Facilities Row/Grid
              Transform.translate(
                offset: Offset(0, _contentSlide.value),
                child: Opacity(
                  opacity: _contentFade.value,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                child: isMobile
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Transform.translate(
                                  offset: Offset(0, _cardSlides[0].value),
                                  child: Opacity(
                                    opacity: _cardFades[0].value,
                                    child: _buildFacilityCard(_facilities[0], false, isMobile: true),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Transform.translate(
                                  offset: Offset(0, _cardSlides[1].value),
                                  child: Opacity(
                                    opacity: _cardFades[1].value,
                                    child: _buildFacilityCard(_facilities[1], false, isMobile: true),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Transform.translate(
                                  offset: Offset(0, _cardSlides[2].value),
                                  child: Opacity(
                                    opacity: _cardFades[2].value,
                                    child: _buildFacilityCard(_facilities[2], false, isMobile: true),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Transform.translate(
                                  offset: Offset(0, _cardSlides[3].value),
                                  child: Opacity(
                                    opacity: _cardFades[3].value,
                                    child: _buildFacilityCard(_facilities[3], false, isMobile: true),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Spacer(),
                              Expanded(
                                flex: 2,
                                child: Transform.translate(
                                  offset: Offset(0, _cardSlides[4].value),
                                  child: Opacity(
                                    opacity: _cardFades[4].value,
                                    child: _buildFacilityCard(_facilities[4], false, isMobile: true),
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_facilities.length, (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Transform.translate(
                                offset: Offset(0, _cardSlides[index].value),
                                child: Opacity(
                                  opacity: _cardFades[index].value,
                                  child: _buildFacilityCard(_facilities[index], false, isMobile: false),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                  ),
                ),
              ),


            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertSummaryMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.red,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: const Color(0x1AFFFFFF),
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> fac, bool wrapInWrap, {bool isMobile = false}) {
    final title = fac['title'] as String;
    final vesselsText = fac['vessels'] as String;
    final efficiency = fac['efficiency'] as double;
    final flag = fac['flag'] as String;
    final color = fac['color'] as Color;
    final icon = fac['icon'] as IconData;
    final vesselsState = fac['vesselsState'] as List<dynamic>;

    return GestureDetector(
      onTap: () => _navigateToLogin(fac['id'] as String, title, icon, color),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: wrapInWrap ? 260 : double.infinity,
          height: isMobile ? 140 : 195,
          child: GlassCard(
            padding: EdgeInsets.all(isMobile ? 10 : 16),
            borderRadius: 18,
            borderColor: color.withValues(alpha: 0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
                      ),
                      child: Text(
                        flag,
                        style: TextStyle(
                          color: color,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Center Radial Efficiency Gauge and Status Nodes
                Row(
                  children: [
                    // Efficiency circle paint
                    if (efficiency > 0.0) ...[
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CustomPaint(
                          painter: RadialProgressPainter(progress: efficiency, color: color),
                          child: Center(
                            child: Text(
                              '${(efficiency * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],

                    // Dot indicators of 4 vessels
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FERMENTERS SCAN MATRIX',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(4, (vIndex) {
                              final vState = vesselsState[vIndex];
                              Color dotColor = AppColors.divider; // Standby/Muted
                              List<BoxShadow> glow = [];

                              if (vState == true) {
                                dotColor = AppColors.cyan; // Active
                                glow = [
                                  const BoxShadow(
                                    color: AppColors.cyan,
                                    blurRadius: 6,
                                    spreadRadius: 0.5,
                                  )
                                ];
                              } else if (vState == null) {
                                dotColor = AppColors.red; // Infection Risk
                                glow = [
                                  const BoxShadow(
                                    color: AppColors.red,
                                    blurRadius: 8,
                                    spreadRadius: 1.0,
                                  )
                                ];
                              }

                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: dotColor,
                                    boxShadow: glow,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Bottom Labels
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vesselsText,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€ Sub-view 2: Dedicated Secure Login Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildLoginView(bool isMobile) {
    final targetId = _getOperatorId(_selectedRole);

    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
          child: GlassCard(
            padding: const EdgeInsets.all(32),
            borderRadius: 24,
            borderColor: _selectedColor.withValues(alpha: 0.35),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo/App Title
                  Image.asset(
                    'assets/logo/parrys_logo.png',
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  // Console Profile Picture (Avatar)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _selectedColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _selectedColor.withValues(alpha: 0.25),
                          blurRadius: 16,
                          spreadRadius: 1.5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _selectedIcon,
                      color: _selectedColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title of target
                  Text(
                    _selectedTitle.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Console Operator ID: $targetId',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Display
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.red.withValues(alpha: 0.4), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFFCA5A5), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Secure Password Input Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Enter access password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.glassOverlay,
                      hintText: '••••••••',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _selectedColor, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login and Back Action buttons
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      elevation: ButtonStyleButton.allOrNull(0),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _selectedColor,
                            _selectedColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'AUTHENTICATE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Return to Overview Link Button
                  TextButton.icon(
                    onPressed: _returnToOverview,
                    icon: const Icon(Icons.arrow_back_rounded, size: 14),
                    label: const Text(
                      'RETURN TO OVERVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
      },
    );
  }
}

// â”€â”€ Custom Painter for Circular SCADA Dials â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class RadialProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  RadialProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 3.5;

    // Background track circle
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double sweepAngle = 2 * 3.1415926535 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -3.1415926535 / 2, // Start at the top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RadialProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
