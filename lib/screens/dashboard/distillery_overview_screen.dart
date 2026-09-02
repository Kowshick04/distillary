

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/telemetry_data_model.dart';
import '../../models/distillery_snapshot_model.dart';
import '../../services/distillery_snapshot_store.dart';
import '../../widgets/common/glass_card.dart';
import '../../utils/app_colors.dart';

class DistilleryOverviewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> vessels;
  final TelemetryDataModel? telemetry;
  final String factoryCode; // Added factoryCode routing key

  const DistilleryOverviewScreen({
    super.key,
    required this.vessels,
    this.telemetry,
    this.factoryCode = 'F01',
  });

  @override
  State<DistilleryOverviewScreen> createState() =>
      _DistilleryOverviewScreenState();
}

class _DistilleryOverviewScreenState extends State<DistilleryOverviewScreen>
 {
  bool _showingCurrent = true; // true = Current Data, false = Previous Data

  // â”€â”€ Live Fluctuating Parameters (derived from SSE stream) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // ─── Active snapshot helper ─────────────────────────────────────────────────
  DistilleryExcelSnapshot? get _activeSnapshot =>
      _showingCurrent
          ? distillerySnapshotStore.getCurrentSnapshot(widget.factoryCode)
          : distillerySnapshotStore.getPreviousSnapshot(widget.factoryCode);

  double get _liveWashAlcohol => _activeSnapshot?.washAlcohol ??
      (widget.telemetry != null && widget.telemetry!.washAlcoholFeed > 0
          ? widget.telemetry!.washAlcoholFeed
          : 12.9);

  double get _liveFeedRate => _activeSnapshot?.feedRate ??
      (widget.telemetry != null && widget.telemetry!.feedRate > 0
          ? widget.telemetry!.feedRate
          : 54.7);

  double get _liveProductAlcohol => _activeSnapshot?.productAlcohol ??
      (widget.telemetry != null && widget.telemetry!.productAlcoholFinal > 0
          ? widget.telemetry!.productAlcoholFinal
          : 99.9);

  double get _liveRecovery => _activeSnapshot?.recovery ??
      (widget.telemetry != null && widget.telemetry!.productAlcoholFinal > 0
          ? (95.0 + (widget.telemetry!.productAlcoholFinal - 95.0) * 0.5).clamp(92.0, 99.8)
          : 98.2);

  double get _liveLoss => _activeSnapshot?.loss ??
      (widget.telemetry != null && widget.telemetry!.alcoholLossSpentwash > 0
          ? widget.telemetry!.alcoholLossSpentwash
          : 0.05);

  double get _liveBottomBrix => _activeSnapshot?.bottomBrix ??
      (widget.telemetry != null && widget.telemetry!.bottomSpentwashBrix > 0
          ? widget.telemetry!.bottomSpentwashBrix
          : 4.6);

  // Gauge values
  double get _liveTemp => _activeSnapshot?.analyserTemp ??
      (widget.telemetry != null && widget.telemetry!.analyserTemp > 0
          ? widget.telemetry!.analyserTemp
          : 76.1);
  double get _livePressure => _activeSnapshot?.pressure ??
      (0.63 + ((widget.telemetry?.fermenterPowerKw ?? 28.0) - 28.0) * 0.001);
  double get _liveVacuum => _activeSnapshot?.vacuum ??
      (-0.62 + ((widget.telemetry?.coolingWaterFlowLpm ?? 400.0) - 400.0) * -0.0001);
  double get _liveDp => _activeSnapshot?.dp ??
      (0.22 + ((widget.telemetry?.steamConsumptionKgph ?? 92.0) - 92.0) * 0.0003);

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bool isPortrait = mediaQuery.orientation == Orientation.portrait || mediaQuery.size.width < 650;

    if (isPortrait) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(),
            const SizedBox(height: 10),
            _buildKpiGrid(isPortrait: true),
            const SizedBox(height: 10),
            SizedBox(
              height: 240,
              child: _buildTrendsCard(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: _buildKeyMetricsCard(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: _buildLossAnalysisCard(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: _buildColumnConditionCard(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: _buildSpentWashSummaryCard(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: _buildAlarmCard(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: _buildAlertFooter(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Header & Title (Real-time subtitle + Dates) ──────────────────────
        _buildHeaderRow(),
        const SizedBox(height: 5),

        // ─── Row 1: KPI Cards Grid (flex: 15) ─────────────────────────────────
        Expanded(
          flex: 15,
          child: _buildKpiGrid(isPortrait: false),
        ),
        const SizedBox(height: 5),

        // ─── Row 2: DCS Trends, Column Overview & Metrics (flex: 46) ──────────
        Expanded(
          flex: 46,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: _buildTrendsCard(),
              ),

              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: _buildKeyMetricsCard(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),

        // ─── Row 3: Loss Analysis, Column Status, Spent Wash & Alarms (flex: 33)
        Expanded(
          flex: 33,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: _buildLossAnalysisCard(),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: _buildColumnConditionCard(),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: _buildSpentWashSummaryCard(),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildAlarmCard(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),

        // ─── Row 4: Alert Footer (flex: 6) ────────────────────────────────────
        Expanded(
          flex: 6,
          child: _buildAlertFooter(),
        ),
      ],
    );
  }

  // ─── Header Row ────────────────────────────────────────────────────────────
  Widget _buildHeaderRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 600;
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DISTILLERY DASHBOARD',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Real-time monitoring of distillation process',
                style: TextStyle(
                  fontSize: 11.0,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDataToggle(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.teal.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.teal,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.teal,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'All Systems Normal',
                          style: TextStyle(fontSize: 10.5, color: AppColors.teal, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DISTILLERY DASHBOARD',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Real-time monitoring of distillation process',
                  style: TextStyle(
                    fontSize: 11.0,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildDataToggle(),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.teal.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'All Systems Normal',
                        style: TextStyle(fontSize: 10.5, color: AppColors.teal, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ─── Current / Previous Data Toggle ────────────────────────────────────────
  Widget _buildDataToggle() {
    final bool hasPrev = distillerySnapshotStore.hasPreviousData(widget.factoryCode);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.glassOverlay,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x18FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleTab(
            label: 'Current Data',
            icon: Icons.fiber_manual_record_rounded,
            isActive: _showingCurrent,
            activeColor: AppColors.cyan,
            onTap: () => setState(() => _showingCurrent = true),
          ),
          const SizedBox(width: 2),
          _buildToggleTab(
            label: 'Previous Data',
            icon: Icons.history_rounded,
            isActive: !_showingCurrent,
            activeColor: AppColors.purple,
            onTap: hasPrev ? () => setState(() => _showingCurrent = false) : null,
            disabled: !hasPrev,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback? onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive
              ? Border.all(color: activeColor.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 7,
              color: disabled
                  ? AppColors.divider
                  : isActive
                      ? activeColor
                      : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.0,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: disabled
                    ? AppColors.divider
                    : isActive
                        ? activeColor
                        : AppColors.textMuted,
              ),
            ),
            if (disabled) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.lock_rounded,
                size: 8,
                color: AppColors.divider,
              ),
            ],
          ],
        ),
      ),
    );
  }



  Widget _buildKpiGrid({bool isPortrait = false}) {
    final int seed = int.tryParse(widget.telemetry?.batchId?.toString() ?? '100') ?? 100;
    final washPoints = List.generate(10, (i) => 9.2 + math.sin(seed + i) * 0.2 + (i % 3) * 0.1);
    final feedPoints = List.generate(10, (i) => 58.0 + math.cos(seed + i) * 1.5 + (i % 4) * 0.3);
    final productPoints = List.generate(10, (i) => 95.0 + math.sin(seed * 1.2 + i) * 0.15 + (i % 2) * 0.08);
    final lossPoints = List.generate(10, (i) => 0.12 + math.cos(seed * 0.8 + i) * 0.02 + (i % 3) * 0.01);

    if (isPortrait) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: SizedBox(height: 76, child: _buildKpiCard1(washPoints))),
              const SizedBox(width: 8),
              Expanded(child: SizedBox(height: 76, child: _buildKpiCard2(feedPoints))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: SizedBox(height: 76, child: _buildKpiCard3(productPoints))),
              const SizedBox(width: 8),
              Expanded(child: SizedBox(height: 76, child: _buildKpiCard4(lossPoints))),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildKpiCard1(washPoints)),
        const SizedBox(width: 10),
        Expanded(child: _buildKpiCard2(feedPoints)),
        const SizedBox(width: 10),
        Expanded(child: _buildKpiCard3(productPoints)),
        const SizedBox(width: 10),
        Expanded(child: _buildKpiCard4(lossPoints)),
      ],
    );
  }

  Widget _buildKpiCard1(List<double> washPoints) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 14,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CustomPaint(
              painter: _WashAlcoholGaugePainter(value: _liveWashAlcohol),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardLabelMini('FERMENTED WASH ALCOHOL'),
                const SizedBox(height: 1),
                Text(
                  '${_liveWashAlcohol.toStringAsFixed(1)} % v/v',
                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w900, color: AppColors.green),
                ),
                const SizedBox(height: 0.5),
                const Text('Target: 12 - 14 %', style: TextStyle(fontSize: 8.5, color: AppColors.divider)),
                const Text('LOW DEVIATION', style: TextStyle(fontSize: 8.5, color: AppColors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 48,
            height: 28,
            child: CustomPaint(
              painter: _MiniSparklinePainter(points: washPoints, color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard2(List<double> feedPoints) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 14,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CustomPaint(
              painter: _FeedRateIconPainter(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardLabelMini('FEED RATE'),
                const SizedBox(height: 1),
                Text(
                  '${_liveFeedRate.toStringAsFixed(1)} %',
                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w900, color: AppColors.blue),
                ),
                const SizedBox(height: 0.5),
                const Text('Target: 52 - 55 %', style: TextStyle(fontSize: 8.5, color: AppColors.divider)),
                const Text('NORMAL', style: TextStyle(fontSize: 8.5, color: AppColors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 48,
            height: 28,
            child: CustomPaint(
              painter: _MiniSparklinePainter(points: feedPoints, color: AppColors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard3(List<double> productPoints) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 14,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CustomPaint(
              painter: _ProductCylinderPainter(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardLabelMini('PRODUCT ALCOHOL (FINAL)'),
                const SizedBox(height: 1),
                Text(
                  '${_liveProductAlcohol.toStringAsFixed(1)} % v/v',
                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w900, color: AppColors.amber),
                ),
                const SizedBox(height: 0.5),
                const Text('Target: >= 95 %', style: TextStyle(fontSize: 8.5, color: AppColors.divider)),
                Text(
                  _liveProductAlcohol < 95.0 ? 'CRITICAL' : 'OPTIMAL',
                  style: TextStyle(
                    fontSize: 8.5,
                    color: _liveProductAlcohol < 95.0 ? AppColors.red : AppColors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 48,
            height: 28,
            child: CustomPaint(
              painter: _MiniSparklinePainter(points: productPoints, color: AppColors.amber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard4(List<double> lossPoints) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 14,
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CustomPaint(
              painter: _LossLevelPainter(value: _liveLoss),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardLabelMini('TOTAL ALCOHOL LOSS'),
                const SizedBox(height: 1),
                Text(
                  '${_liveLoss.toStringAsFixed(2)} %',
                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w900, color: AppColors.blue),
                ),
                const SizedBox(height: 0.5),
                const Text('Target: < 0.25 %', style: TextStyle(fontSize: 8.5, color: AppColors.divider)),
                const Text('ACCEPTABLE', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 48,
            height: 28,
            child: CustomPaint(
              painter: _MiniSparklinePainter(points: lossPoints, color: AppColors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLabelMini(String label) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 8.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
        color: AppColors.textMuted,
      ),
    );
  }


  // â”€â”€ Row 2: Line trends 24h Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildTrendsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardLabel('MANDATORY OPERATIONAL TRENDS (LAST 24 HOURS)', Icons.analytics_rounded),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x2200E5FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0x5500E5FF)),
                    ),
                    child: Text(
                      'Product Alc: ${_liveProductAlcohol.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00E5FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x22FF9100),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0x55FF9100)),
                    ),
                    child: Text(
                      'Spent Loss: ${_liveLoss.toStringAsFixed(3)}%',
                      style: const TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF9100),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _LineChartPainter(
                    productVal: _liveProductAlcohol,
                    lossVal: _liveLoss,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // â”€â”€ Row 2: Daily Metrics table Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildKeyMetricsCard() {
    final metrics = [
      _MetricRow(Icons.input_rounded, 'Spent Wash Feed Tank', '${_liveFeedRate.toStringAsFixed(1)} %'),
      _MetricRow(Icons.science_rounded, 'Analyser Column', '${_liveTemp.toStringAsFixed(1)} \u00B0C'),
      _MetricRow(Icons.layers_rounded, 'FFE -3/4', '${(widget.telemetry?.ffeOutletBrix ?? 36.0).toStringAsFixed(1)} %'),
      _MetricRow(Icons.opacity_rounded, 'Spent Wash Tank', '${_liveBottomBrix.toStringAsFixed(1)} %'),
      
      _MetricRow(Icons.trending_up_rounded, 'RC Alcohol Strength', '${_liveProductAlcohol.toStringAsFixed(1)} % v/v'),
      _MetricRow(Icons.sync_rounded, 'MSDH', '${_liveRecovery.toStringAsFixed(1)} %'),
      _MetricRow(Icons.local_drink_rounded, 'Ethanol', '${_liveProductAlcohol.toStringAsFixed(1)} % v/v'),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardLabel('KEY DISTILLATION METRICS (TODAY)', Icons.fact_check_rounded),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: metrics.map((m) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Row(
                      children: [
                        Icon(m.icon, size: 11, color: AppColors.blue),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            m.label,
                            style: const TextStyle(fontSize: 10.0, color: AppColors.textSecondary),
                          ),
                        ),
                        Text(
                          m.value,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Row 3: Alcohol Loss Donut Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildLossAnalysisCard() {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardLabel('ALCOHOL LOSS ANALYSIS', Icons.pie_chart_rounded),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _DonutChartPainter(lossValue: _liveLoss),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _lossLegendItem('Spent Wash', '0.15 % (83%)', AppColors.orange),
                      const SizedBox(height: 4),
                      _lossLegendItem('Lees Loss', '0.02 % (11%)', AppColors.amber),
                      const SizedBox(height: 4),
                      _lossLegendItem('Others', '0.01 % (6%)', AppColors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.green.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.green, size: 11),
                SizedBox(width: 4),
                Text(
                  'Loss is within acceptable limit.',
                  style: TextStyle(fontSize: 10.0, color: AppColors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lossLegendItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 9),
          child: Text(
            value,
            style: const TextStyle(fontSize: 10.0, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmCard() {
    final alertMsg = _liveProductAlcohol < 95.0
        ? 'ALARM: PRODUCT ALCOHOL BELOW TARGET (${_liveProductAlcohol.toStringAsFixed(1)}% vs >95%) - High Priority'
        : 'ALARM: PRODUCT ALCOHOL BELOW TARGET (95.1% vs >95%) - High Priority';
        
    final washMsg = _liveWashAlcohol < 12.0
        ? 'WARNING: FERMENTED WASH ALCOHOL LOW (${_liveWashAlcohol.toStringAsFixed(1)}%) - Monitor'
        : 'WARNING: FERMENTED WASH ALCOHOL LOW (9.5%) - Monitor';

    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'ALARM CENTER',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    // Placeholder trigger
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 9.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAlarmItem(alertMsg, AppColors.red, '10:58 AM', isCritical: true),
                  const SizedBox(height: 6),
                  _buildAlarmItem(washMsg, AppColors.orange, '10:45 AM', isCritical: false),
                  const SizedBox(height: 6),
                  _buildAlarmItem('ALL SYSTEMS NORMAL: No other active alarms.', AppColors.green, '10:30 AM', isNormal: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmItem(String message, Color color, String time, {bool isCritical = false, bool isNormal = false}) {
    final icon = isNormal
        ? Icons.check_circle_outline_rounded
        : Icons.warning_amber_rounded;
    
    final double opacity = isCritical ? 0.15 : (isNormal ? 0.04 : 0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.2,
                fontWeight: FontWeight.bold,
                color: isNormal ? AppColors.textMuted : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            time,
            style: const TextStyle(fontSize: 8.0, color: AppColors.divider, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Row 3: Column Condition Circular Gauges Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildColumnConditionCard() {
    // Dynamic status for Temperature
    final String tempStatus = _liveTemp > 92.0 ? 'High' : (_liveTemp < 60.0 ? 'Low' : 'Normal');
    final Color tempColor = tempStatus == 'Normal' ? AppColors.teal : AppColors.red;

    // Dynamic status for Pressure
    final String pressStatus = _livePressure > 1.0 ? 'High' : (_livePressure < 0.15 ? 'Low' : 'Normal');
    final Color pressColor = pressStatus == 'Normal' ? AppColors.teal : AppColors.amber;

    // Dynamic status for Vacuum
    final String vacStatus = (_liveVacuum > -0.2) ? 'Low Vacuum' : ((_liveVacuum < -0.85) ? 'High Vacuum' : 'Normal');
    final Color vacColor = vacStatus == 'Normal' ? AppColors.teal : AppColors.blue;

    // Dynamic status for Delta P
    final String dpStatus = _liveDp > 0.4 ? 'High' : 'Normal';
    final Color dpColor = dpStatus == 'Normal' ? AppColors.teal : AppColors.cyan;

    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardLabel('ANALYSER COLUMN HEALTH', Icons.speed_rounded),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildGauge(
                    'TEMPERATURE',
                    '${_liveTemp.toStringAsFixed(1)} \u00B0C',
                    _liveTemp,
                    50,
                    110,
                    tempColor,
                    subLabel: '(Column Bottom)',
                    statusText: tempStatus,
                    statusColor: tempColor,
                    warningStart: 92.0,
                  ),
                ),
                Expanded(
                  child: _buildGauge(
                    'PRESSURE',
                    '${_livePressure.toStringAsFixed(2)} kg/cm\u00B2',
                    _livePressure,
                    0,
                    1.5,
                    pressColor,
                    statusText: pressStatus,
                    statusColor: pressColor,
                    warningStart: 1.0,
                  ),
                ),
                Expanded(
                  child: _buildGauge(
                    'VACUUM',
                    '${_liveVacuum.toStringAsFixed(2)} kg/cm\u00B2',
                    _liveVacuum,
                    -1.0,
                    0,
                    vacColor,
                    statusText: vacStatus,
                    statusColor: vacColor,
                  ),
                ),
                Expanded(
                  child: _buildGauge(
                    '\u0394P (Column)',
                    '${_liveDp.toStringAsFixed(2)} kg/cm\u00B2',
                    _liveDp,
                    0,
                    0.6,
                    dpColor,
                    statusText: dpStatus,
                    statusColor: dpColor,
                    warningStart: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGauge(String label, String valueText, double val, double min, double max, Color color, {String? subLabel, String? statusText, Color? statusColor, double? warningStart}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _GaugePainter(
                  val: val,
                  min: min,
                  max: max,
                  color: color,
                  warningStart: warningStart,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valueText,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(fontSize: 8.0, color: AppColors.textMuted, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (subLabel != null) ...[
          Text(
            subLabel,
            style: const TextStyle(fontSize: 7.5, color: AppColors.divider, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 1),
        Text(
          statusText ?? 'Normal',
          style: TextStyle(fontSize: 8.5, color: statusColor ?? AppColors.green, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // â”€â”€ Row 3: Spent Wash Summary Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildSpentWashSummaryCard() {
    final values = [
      _ValueRow('Raw Spent Wash Brix', '${(widget.telemetry?.rawSpentwashBrix ?? 14.7).toStringAsFixed(1)} %'),
      _ValueRow('Bottom Spent Wash Brix', '${_liveBottomBrix.toStringAsFixed(1)} %'),
      _ValueRow('FFE Outlet Spent Wash Brix', '${(widget.telemetry?.ffeOutletBrix ?? 27.7).toStringAsFixed(1)} %'),
      _ValueRow('Concentrated Spent Wash Brix', '${(widget.telemetry?.concSpentwashBrix ?? 56.4).toStringAsFixed(1)} %'),
      _ValueRow('Spent Wash Mosconi', '${_liveLoss.toStringAsFixed(2)} %'),
      _ValueRow('Spent Wash Recycle', '${(widget.telemetry?.spentwashRecycle ?? 6.0).toStringAsFixed(0)} KL'),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardLabel('SPENT WASH SUMMARY', Icons.opacity_rounded),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: values.map((v) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              v.label,
                              style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
                            ),
                            Text(
                              v.value,
                              style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sync_rounded, size: 24, color: AppColors.blue.withValues(alpha: 0.8)),
                        const SizedBox(height: 4),
                        const Text(
                          'RECYCLE',
                          style: TextStyle(fontSize: 8.0, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          '25 KL',
                          style: TextStyle(fontSize: 12.0, color: AppColors.cyan, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.green.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.green, size: 11),
                SizedBox(width: 4),
                Text(
                  'Recycle within recommended limit.',
                  style: TextStyle(fontSize: 10.0, color: AppColors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Row 4: Alert Footer Ticker â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildAlertFooter() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      borderRadius: 10,
      backgroundColor: const Color(0x14000000),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                _footerAlertItem('F3 - Product Alcohol below target (12.3%)', '10:58 AM', true),
                _verticalDivider(),
                _footerAlertItem('Reflux - Slight deviation (93.2%)', '10:45 AM', false),
                _verticalDivider(),
                _footerAlertItem('All systems normal', '10:30 AM', null),
              ],
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              children: [
                Text(
                  'View All Alerts',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 11, color: AppColors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerAlertItem(String message, String time, bool? statusCritical) {
    Color dotColor = AppColors.green;
    if (statusCritical == true) {
      dotColor = AppColors.red;
    } else if (statusCritical == false) {
      dotColor = AppColors.amber;
    }

    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 10.0, color: Colors.white, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            time,
            style: const TextStyle(fontSize: 9.5, color: AppColors.divider),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 10,
      color: const Color(0x1AFFFFFF),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  // Card sub-header label
  Widget _buildCardLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 11, color: AppColors.blue),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ── Custom Painter: Dual-Axis Line Chart ──────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final double productVal;
  final double lossVal;

  _LineChartPainter({
    required this.productVal,
    required this.lossVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double paddingLeft = 48.0;
    const double paddingRight = 48.0;
    const double paddingTop = 12.0;
    const double paddingBottom = 22.0;

    final double chartW = size.width - paddingLeft - paddingRight;
    final double chartH = size.height - paddingTop - paddingBottom;

    if (chartW <= 0 || chartH <= 0) return;

    // Dual-axis scales
    const double minProduct = 94.0;
    const double maxProduct = 100.0;
    const double minLoss = 0.00;
    const double maxLoss = 0.45;

    double yForProduct(double val) {
      final norm = ((val.clamp(minProduct, maxProduct) - minProduct) / (maxProduct - minProduct)).clamp(0.0, 1.0);
      return paddingTop + chartH - (norm * chartH);
    }

    double yForLoss(double val) {
      final norm = ((val.clamp(minLoss, maxLoss) - minLoss) / (maxLoss - minLoss)).clamp(0.0, 1.0);
      return paddingTop + chartH - (norm * chartH);
    }

    final gridPaint = Paint()
      ..color = const Color(0x0EFFFFFF)
      ..strokeWidth = 0.8;

    final cyanAxisPaint = Paint()
      ..color = const Color(0x6600E5FF)
      ..strokeWidth = 1.0;

    final orangeAxisPaint = Paint()
      ..color = const Color(0x66FF9100)
      ..strokeWidth = 1.0;

    // 1. Draw Left Y-Axis (Product Alcohol %) Grid & Ticks
    final productTicks = [94, 95, 96, 97, 98, 99, 100];
    for (var tick in productTicks) {
      final double y = yForProduct(tick.toDouble());
      // Horizontal grid line
      canvas.drawLine(Offset(paddingLeft, y), Offset(paddingLeft + chartW, y), gridPaint);
      // Left Tick mark
      canvas.drawLine(Offset(paddingLeft - 4, y), Offset(paddingLeft, y), cyanAxisPaint);
      // Left Tick text
      _drawText(
        canvas,
        tick.toString(),
        Offset(paddingLeft - 22, y - 6),
        TextStyle(
          fontSize: 9.0,
          fontWeight: FontWeight.bold,
          color: tick == 95 ? const Color(0xFFE57373) : const Color(0xFF00E5FF),
        ),
      );
    }

    // 2. Draw Right Y-Axis (Alcohol Loss %) Ticks
    final lossTicks = [0.00, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45];
    for (var tick in lossTicks) {
      final double y = yForLoss(tick);
      // Right Tick mark
      canvas.drawLine(Offset(paddingLeft + chartW, y), Offset(paddingLeft + chartW + 4, y), orangeAxisPaint);
      // Right Tick text
      _drawText(
        canvas,
        tick.toStringAsFixed(2),
        Offset(paddingLeft + chartW + 7, y - 6),
        TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          color: (tick - 0.25).abs() < 0.001 ? const Color(0xFFEF5350) : const Color(0xFFFF9100),
        ),
      );
    }

    // 3. Draw X-Axis Timestamps
    final xLabels = ['12:00', '15:00', '18:00', '21:00', '00:00', '03:00', '06:00', '09:00', '12:00'];
    final double colStep = chartW / (xLabels.length - 1);
    for (int idx = 0; idx < xLabels.length; idx++) {
      final double x = paddingLeft + colStep * idx;
      canvas.drawLine(Offset(x, paddingTop), Offset(x, paddingTop + chartH), gridPaint);
      _drawText(
        canvas,
        xLabels[idx],
        Offset(x - 12, paddingTop + chartH + 5),
        const TextStyle(fontSize: 8.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
      );
    }

    // 4. Draw Axis Boundaries
    canvas.drawLine(Offset(paddingLeft, paddingTop), Offset(paddingLeft, paddingTop + chartH), cyanAxisPaint);
    canvas.drawLine(Offset(paddingLeft + chartW, paddingTop), Offset(paddingLeft + chartW, paddingTop + chartH), orangeAxisPaint);
    canvas.drawLine(Offset(paddingLeft, paddingTop + chartH), Offset(paddingLeft + chartW, paddingTop + chartH), gridPaint);

    // 5. Draw Rotated Axis Titles
    // Left Title: Product Alcohol (%)
    canvas.save();
    canvas.translate(14, paddingTop + chartH / 2);
    canvas.rotate(-math.pi / 2);
    _drawTextCentered(
      canvas,
      'Product Alcohol (%)',
      Offset.zero,
      const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF), letterSpacing: 0.3),
    );
    canvas.restore();

    // Right Title: Alcohol Loss in Spent Wash (%)
    canvas.save();
    canvas.translate(size.width - 14, paddingTop + chartH / 2);
    canvas.rotate(math.pi / 2);
    _drawTextCentered(
      canvas,
      'Alcohol Loss in Spent Wash (%)',
      Offset.zero,
      const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFFF9100), letterSpacing: 0.3),
    );
    canvas.restore();

    // 6. Draw Threshold Reference Lines
    // Min Product Limit (95.0%) -> Dashed Red line on Left Scale
    final double yProd95 = yForProduct(95.0);
    _drawDashedLine(
      canvas,
      Offset(paddingLeft, yProd95),
      Offset(paddingLeft + chartW, yProd95),
      const Color(0xFFE57373),
      dashWidth: 4,
      dashSpace: 3,
      strokeWidth: 1.2,
    );

    // Loss Alert Limit (0.25%) -> Dotted Red line on Right Scale
    final double yLoss25 = yForLoss(0.25);
    _drawDottedLine(
      canvas,
      Offset(paddingLeft, yLoss25),
      Offset(paddingLeft + chartW, yLoss25),
      const Color(0xFFEF5350),
      dotRadius: 1.2,
      dotSpacing: 4.0,
    );

    // 7. Dynamic Data Curves
    // A. Product Alcohol Series (Cyan)
    final prodSeed = [
      0.999, 0.998, 0.999, 0.997, 0.999, 0.996, 0.998, 0.999, 0.997,
      0.999, 0.998, 0.996, 0.998, 0.999, 0.999, 0.998, 0.999, 1.0
    ];
    _drawCurveSeries(
      canvas: canvas,
      seed: prodSeed,
      activeVal: productVal > 0 ? productVal : 99.72,
      width: chartW,
      paddingLeft: paddingLeft,
      paddingTop: paddingTop,
      chartH: chartH,
      color: const Color(0xFF00E5FF),
      yMapper: yForProduct,
      baselineY: yForProduct(minProduct),
    );

    // B. Alcohol Loss in Spent Wash Series (Orange)
    final lossSeed = [
      0.25, 0.32, 0.40, 0.48, 0.55, 0.52, 0.42, 0.30, 0.22,
      0.28, 0.26, 0.50, 0.58, 0.72, 0.60, 0.58, 0.65, 1.0
    ];
    _drawCurveSeries(
      canvas: canvas,
      seed: lossSeed,
      activeVal: lossVal > 0 ? lossVal : 0.05,
      width: chartW,
      paddingLeft: paddingLeft,
      paddingTop: paddingTop,
      chartH: chartH,
      color: const Color(0xFFFF9100),
      yMapper: yForLoss,
      baselineY: yForLoss(minLoss),
    );

    // 8. Floating Legend Box (Top Left)
    _drawLegendBox(canvas, Offset(paddingLeft + 8, paddingTop + 6));
  }

  void _drawCurveSeries({
    required Canvas canvas,
    required List<double> seed,
    required double activeVal,
    required double width,
    required double paddingLeft,
    required double paddingTop,
    required double chartH,
    required Color color,
    required double Function(double) yMapper,
    required double baselineY,
  }) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double colStep = width / (seed.length - 1);

    double lastX = paddingLeft;
    double lastY = yMapper(activeVal);

    for (int i = 0; i < seed.length; i++) {
      final double val = (i == seed.length - 1) ? activeVal : activeVal * seed[i];
      final double x = paddingLeft + colStep * i;
      final double y = yMapper(val);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      if (i == seed.length - 1) {
        lastX = x;
        lastY = y;
      }
    }

    // Gradient Fill below curve
    final fillPath = Path.from(path)
      ..lineTo(paddingLeft + width, baselineY)
      ..lineTo(paddingLeft, baselineY)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.28),
          color.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(paddingLeft, paddingTop, width, chartH))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Terminal Highlight Node with white center
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawCircle(Offset(lastX, lastY), 6.0, glowPaint);
    canvas.drawCircle(Offset(lastX, lastY), 4.5, Paint()..color = color);
    canvas.drawCircle(Offset(lastX, lastY), 2.5, Paint()..color = Colors.white);
  }

  void _drawLegendBox(Canvas canvas, Offset offset) {
    final double boxW = 162.0;
    final double boxH = 46.0;

    final bgPaint = Paint()
      ..color = const Color(0xAA081422)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0x3300E5FF)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, boxW, boxH),
      const Radius.circular(6),
    );

    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);

    // Row 1: Product Alcohol % (solid cyan)
    final double r1Y = offset.dy + 7;
    canvas.drawLine(Offset(offset.dx + 8, r1Y + 4), Offset(offset.dx + 20, r1Y + 4), Paint()..color = const Color(0xFF00E5FF)..strokeWidth = 2);
    _drawText(canvas, 'Product Alcohol %', Offset(offset.dx + 24, r1Y), const TextStyle(fontSize: 7.8, color: Color(0xFF00E5FF), fontWeight: FontWeight.bold));

    // Row 2: Min Product Limit (dashed red)
    final double r2Y = offset.dy + 16;
    _drawDashedLine(canvas, Offset(offset.dx + 8, r2Y + 4), Offset(offset.dx + 20, r2Y + 4), const Color(0xFFE57373), dashWidth: 3, dashSpace: 2, strokeWidth: 1.2);
    _drawText(canvas, 'Min Product Limit (95.0%)', Offset(offset.dx + 24, r2Y), const TextStyle(fontSize: 7.8, color: Color(0xFFE57373)));

    // Row 3: Alcohol Loss % (Spent Wash) (solid orange)
    final double r3Y = offset.dy + 25;
    canvas.drawLine(Offset(offset.dx + 8, r3Y + 4), Offset(offset.dx + 20, r3Y + 4), Paint()..color = const Color(0xFFFF9100)..strokeWidth = 2);
    _drawText(canvas, 'Alcohol Loss % (Spent Wash)', Offset(offset.dx + 24, r3Y), const TextStyle(fontSize: 7.8, color: Color(0xFFFF9100), fontWeight: FontWeight.bold));

    // Row 4: Loss Alert Limit (dotted red)
    final double r4Y = offset.dy + 34;
    _drawDottedLine(canvas, Offset(offset.dx + 8, r4Y + 4), Offset(offset.dx + 20, r4Y + 4), const Color(0xFFEF5350), dotRadius: 1.0, dotSpacing: 3.0);
    _drawText(canvas, 'Loss Alert Limit (0.25%)', Offset(offset.dx + 24, r4Y), const TextStyle(fontSize: 7.8, color: Color(0xFFEF5350)));
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Color color, {double dashWidth = 4.0, double dashSpace = 3.0, double strokeWidth = 1.0}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

        double curX = p1.dx;
    while (curX < p2.dx) {
      final double endX = math.min(curX + dashWidth, p2.dx);
      canvas.drawLine(Offset(curX, p1.dy), Offset(endX, p1.dy), paint);
      curX += dashWidth + dashSpace;
    }
  }

  void _drawDottedLine(Canvas canvas, Offset p1, Offset p2, Color color, {double dotRadius = 1.2, double dotSpacing = 4.0}) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double curX = p1.dx;
    while (curX <= p2.dx) {
      canvas.drawCircle(Offset(curX, p1.dy), dotRadius, paint);
      curX += dotSpacing;
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawTextCentered(Canvas canvas, String text, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.productVal != productVal || old.lossVal != lossVal;
}

// â”€â”€ Custom Painter: Donut Loss Chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DonutChartPainter extends CustomPainter {
  final double lossValue;
  _DonutChartPainter({required this.lossValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.1;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Segments: Spent Wash (83%), Lees Loss (11%), Others (6%)
    final segments = [
      _DonutSegment(0.83, AppColors.orange),
      _DonutSegment(0.11, AppColors.amber),
      _DonutSegment(0.06, AppColors.blue),
    ];

    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final paint = Paint()
        ..color = seg.color
        ..strokeWidth = 10.0
        ..style = PaintingStyle.stroke;

      final sweepAngle = 2 * math.pi * seg.percentage;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Write text in center
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${lossValue.toStringAsFixed(2)}%\n',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
          ),
          const TextSpan(
            text: 'Total Loss',
            style: TextStyle(fontSize: 8.0, color: AppColors.textMuted, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2);
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) => old.lossValue != lossValue;
}

class _DonutSegment {
  final double percentage;
  final Color color;
  _DonutSegment(this.percentage, this.color);
}

// â”€â”€ Custom Painter: Gauge indicator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _GaugePainter extends CustomPainter {
  final double val;
  final double min;
  final double max;
  final Color color;
  final double? warningStart;

  _GaugePainter({
    required this.val,
    required this.min,
    required this.max,
    required this.color,
    this.warningStart,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2.0);
    final radius = math.min(size.width, size.height) / 2.5;

    final trackPaint = Paint()
      ..color = const Color(0x1AFFFFFF)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw Semicircle arc (140 degrees to 400 degrees)
    final double startAngle = 0.8 * math.pi;
    final double sweepAngle = 1.4 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    // If warningStart is set, draw a distinct warning red/amber segment on the track
    if (warningStart != null) {
      final double warnRatio = ((warningStart! - min) / (max - min)).clamp(0.0, 1.0);
      final double warnStartAngle = startAngle + sweepAngle * warnRatio;
      final double warnSweepAngle = sweepAngle * (1.0 - warnRatio);

      final warnTrackPaint = Paint()
        ..color = AppColors.red.withOpacity(0.25)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawArc(rect, warnStartAngle, warnSweepAngle, false, warnTrackPaint);
    }

    final ratio = ((val - min) / (max - min)).clamp(0.0, 1.0);
    final double activeSweepAngle = sweepAngle * ratio;
    canvas.drawArc(rect, startAngle, activeSweepAngle, false, activePaint);

    // Draw Needle/Indicator
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final angle = startAngle + activeSweepAngle;
    final needleEnd = Offset(
      center.dx + (radius - 2) * math.cos(angle),
      center.dy + (radius - 2) * math.sin(angle),
    );
    canvas.drawLine(center, needleEnd, needlePaint);

    // Center pivot dot
    canvas.drawCircle(center, 2.0, Paint()..color = color);
    canvas.drawCircle(center, 0.8, Paint()..color = Colors.white);

    // Draw min / max bounds text labels
    final labelStyle = const TextStyle(
      fontSize: 7.0,
      color: AppColors.divider,
      fontWeight: FontWeight.bold,
    );

    // Start point text label offset
    final double startX = center.dx + (radius + 8) * math.cos(startAngle);
    final double startY = center.dy + (radius + 8) * math.sin(startAngle);
    _drawTextCentered(canvas, min.toStringAsFixed(0), Offset(startX, startY), labelStyle);

    // End point text label offset
    final double endAngle = startAngle + sweepAngle;
    final double endX = center.dx + (radius + 8) * math.cos(endAngle);
    final double endY = center.dy + (radius + 8) * math.sin(endAngle);
    _drawTextCentered(canvas, max.toStringAsFixed(0), Offset(endX, endY), labelStyle);
  }

  void _drawTextCentered(Canvas canvas, String text, Offset centerOffset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(centerOffset.dx - tp.width / 2, centerOffset.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.val != val || old.min != min || old.max != max || old.color != color || old.warningStart != warningStart;
}

// â”€â”€ Models / Rows â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MetricRow {
  final IconData icon;
  final String label;
  final String value;
  const _MetricRow(this.icon, this.label, this.value);
}

class _ValueRow {
  final String label;
  final String value;
  const _ValueRow(this.label, this.value);
}

// â”€â”€ Custom Painters: Top KPI Visuals â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _WashAlcoholGaugePainter extends CustomPainter {
  final double value;
  _WashAlcoholGaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 1.3);
    final radius = size.width / 2.2;
    
    final trackPaint = Paint()
      ..color = const Color(0x1DFFFFFF)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw arc from 180 degrees to 360 degrees (semicircle)
    final double startAngle = math.pi;
    final double sweepAngle = math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    // Value mapping (usually 0 to 15%)
    final ratio = (value / 15.0).clamp(0.0, 1.0);
    canvas.drawArc(rect, startAngle, sweepAngle * ratio, false, activePaint);

    // Draw needle
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final double angle = startAngle + sweepAngle * ratio;
    final needleEnd = Offset(
      center.dx + (radius - 2) * math.cos(angle),
      center.dy + (radius - 2) * math.sin(angle),
    );
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 3.0, Paint()..color = AppColors.green);
  }

  @override
  bool shouldRepaint(_WashAlcoholGaugePainter old) => old.value != value;
}

class _FeedRateIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.4;

    final ringPaint = Paint()
      ..color = AppColors.blue.withOpacity(0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final iconPaint = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, ringPaint);

    // Draw a speedometer dial pointer path inside the circle
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 4), -math.pi * 0.8, math.pi * 1.6, false, iconPaint);
    
    // Center pointer line
    canvas.drawLine(center, Offset(center.dx + (radius - 5) * math.cos(-math.pi/4), center.dy + (radius - 5) * math.sin(-math.pi/4)), iconPaint);
    
    // Draw left-to-right flow arrows outside
    final arrowPaint = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
       
    // Left input line
    canvas.drawLine(Offset(0, center.dy), Offset(center.dx - radius - 2, center.dy), arrowPaint);
    // Right output arrow
    canvas.drawLine(Offset(center.dx + radius + 2, center.dy), Offset(size.width, center.dy), arrowPaint);
    canvas.drawLine(Offset(size.width - 4, center.dy - 3), Offset(size.width, center.dy), arrowPaint);
    canvas.drawLine(Offset(size.width - 4, center.dy + 3), Offset(size.width, center.dy), arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProductCylinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = 12.0;
    final double h = 32.0;
    final double x = (size.width - w) / 2;
    final double y = (size.height - h) / 2;
    
    final fillPaint = Paint()
      ..color = AppColors.amber
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = AppColors.amber
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(Rect.fromLTRB(x, y, x + w, y + h), const Radius.circular(4));
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, borderPaint);

    // Draw top input line and bottom output arrow
    final linePaint = Paint()
      ..color = AppColors.amber
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
       
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, y), linePaint);
    canvas.drawLine(Offset(size.width / 2, y + h), Offset(size.width / 2, size.height), linePaint);
    canvas.drawLine(Offset(size.width / 2 - 3, size.height - 4), Offset(size.width / 2, size.height), linePaint);
    canvas.drawLine(Offset(size.width / 2 + 3, size.height - 4), Offset(size.width / 2, size.height), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LossLevelPainter extends CustomPainter {
  final double value;
  _LossLevelPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = 14.0;
    final double h = size.height - 12.0;
    final double x = (size.width - w) / 2;
    final double y = 6.0;

    final trackPaint = Paint()
      ..color = const Color(0x1BFFFFFF)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1.0;

    final rect = Rect.fromLTRB(x, y, x + w, y + h);
    canvas.drawRect(rect, trackPaint);
    canvas.drawRect(rect, borderPaint);

    // Draw fluid fill level (0.0 to 0.5% scale)
    final ratio = (value / 0.5).clamp(0.0, 1.0);
    final fillHeight = h * ratio;
    final fillPaint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTRB(x, y + h - fillHeight, x + w, y + h), fillPaint);
  }

  @override
  bool shouldRepaint(_LossLevelPainter old) => old.value != value;
}

class _MiniSparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _MiniSparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double dx = size.width / (points.length - 1);
    
    double minY = points[0];
    double maxY = points[0];
    for (var p in points) {
      if (p < minY) minY = p;
      if (p > maxY) maxY = p;
    }
    final double range = maxY - minY == 0 ? 1.0 : maxY - minY;

    for (int i = 0; i < points.length; i++) {
      final double x = i * dx;
      final double y = size.height - ((points[i] - minY) / range) * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
      
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
      
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) => true;
}
