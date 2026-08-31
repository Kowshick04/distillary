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



  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â  @override

  Widget build(BuildContext context) {

    return LayoutBuilder(

      builder: (context, constraints) {

        final bool isMobile = constraints.maxWidth < 600;

        

        if (isMobile) {

          return SingleChildScrollView(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // Header & Title

                _buildHeaderRow(isMobile: true),

                const SizedBox(height: 12),



                // Row 1: KPI Cards Grid

                SingleChildScrollView(

                  scrollDirection: Axis.horizontal,

                  child: SizedBox(

                    height: 75, // Safe height for horizontal KPIs

                    child: _buildKpiGrid(isMobile: true),

                  ),

                ),

                const SizedBox(height: 12),



                // Row 2: DCS Trends & Key Metrics stacked

                SizedBox(

                  height: 240,

                  child: _buildTrendsCard(),

                ),

                const SizedBox(height: 12),

                SizedBox(height: 180, child: _buildKeyMetricsCard()),

                const SizedBox(height: 12),



                // Row 3: Loss Analysis, Column Status, Spent Wash & Alarms stacked

                SizedBox(height: 170, child: _buildLossAnalysisCard()),

                const SizedBox(height: 12),

                SizedBox(height: 260, child: _buildColumnConditionCard(isMobile: true)),

                const SizedBox(height: 12),

                SizedBox(height: 180, child: _buildSpentWashSummaryCard()),

                const SizedBox(height: 12),

                SizedBox(height: 165, child: _buildAlarmCard()),

                const SizedBox(height: 12),



                // Row 4: Alert Footer

                SizedBox(height: 50, child: _buildAlertFooter()),

              ],

            ),

          );

        } else {

          return Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // Header & Title

              _buildHeaderRow(),

              const SizedBox(height: 5),



              // Row 1: KPI Cards Grid

              Expanded(

                flex: 15,

                child: _buildKpiGrid(isMobile: false),

              ),

              const SizedBox(height: 5),



              // Row 2: DCS Trends, Column Overview & Metrics

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



              // Row 3: Loss Analysis, Column Status, Spent Wash & Alarms

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

                      child: _buildColumnConditionCard(isMobile: false),

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



              // Row 4: Alert Footer

              Expanded(

                flex: 6,

                child: _buildAlertFooter(),

              ),

            ],

          );

        }

      },

    );

  }



  Widget _buildHeaderRow({bool isMobile = false}) {
    final titleCol = Column(
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
        const Text(
          'Real-time monitoring of distillation process',
          style: TextStyle(
            fontSize: 11.0,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final actionsRow = Row(
      children: [
        _buildDataToggle(),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
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
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleCol,
          const SizedBox(height: 10),
          actionsRow,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        titleCol,
        actionsRow,
      ],
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







  Widget _buildKpiGrid({bool isMobile = false}) {

    final washPoints = List.generate(10, (i) => 9.2 + math.sin((widget.telemetry?.hashCode ?? 100) + i) * 0.2 + (i % 3) * 0.1);

    final feedPoints = List.generate(10, (i) => 58.0 + math.cos((widget.telemetry?.hashCode ?? 100) + i) * 1.5 + (i % 4) * 0.3);

    final productPoints = List.generate(10, (i) => 95.0 + math.sin((widget.telemetry?.hashCode ?? 100) * 1.2 + i) * 0.15 + (i % 2) * 0.08);

    final lossPoints = List.generate(10, (i) => 0.12 + math.cos((widget.telemetry?.hashCode ?? 100) * 0.8 + i) * 0.02 + (i % 3) * 0.01);



    Widget buildCard(Widget card) {

      return isMobile ? SizedBox(width: 240, child: card) : Expanded(child: card);

    }



    return Row(

      children: [

        // Card 1: FERMENTED WASH ALCOHOL

        buildCard(

          GlassCard(

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

          ),

        ),

        const SizedBox(width: 10),



        // Card 2: FEED RATE

        buildCard(

          GlassCard(

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

          ),

        ),

        const SizedBox(width: 10),



        // Card 3: PRODUCT ALCOHOL (FINAL)

        buildCard(

          GlassCard(

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

          ),

        ),

        const SizedBox(width: 10),



        // Card 4: TOTAL ALCOHOL LOSS

        buildCard(

          GlassCard(

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

                        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w900, color: AppColors.purple),

                      ),

                      const SizedBox(height: 0.5),

                      const Text('Target: < 0.25 %', style: TextStyle(fontSize: 8.5, color: AppColors.divider)),

                      const Text('ACCEPTABLE', style: TextStyle(fontSize: 8.5, color: AppColors.purple, fontWeight: FontWeight.bold)),

                    ],

                  ),

                ),

                const SizedBox(width: 4),

                SizedBox(

                  width: 48,

                  height: 28,

                  child: CustomPaint(

                    painter: _MiniSparklinePainter(points: lossPoints, color: AppColors.purple),

                  ),

                ),

              ],

            ),

          ),

        ),

      ],

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

          _buildCardLabel('MANDATORY OPERATIONAL TRENDS (LAST 24 HOURS)', Icons.analytics_rounded),

          const SizedBox(height: 6),

          // Legend

          Row(

            children: [

              _chartLegendItem('PRODUCT ALCOHOL %', AppColors.green),

              const SizedBox(width: 8),

              _chartLegendItem('TOTAL ALCOHOL LOSS %', AppColors.orange),

            ],

          ),

          const SizedBox(height: 8),

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

      _MetricRow(Icons.science_rounded, 'Analyzer Column', '${_liveTemp.toStringAsFixed(1)} \u00B0C'),

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

                      _lossLegendItem('Spent Wash', '0.15 % (83%)', AppColors.green),

                      const SizedBox(height: 4),

                      _lossLegendItem('Lees Loss', '0.02 % (11%)', AppColors.orange),

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

              color: AppColors.green.withValues(alpha: 0.08),

              borderRadius: BorderRadius.circular(4),

              border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),

            ),

            child: const Row(

              children: [

                Icon(Icons.check_circle_rounded, color: AppColors.green, size: 11),

                SizedBox(width: 4),

                Expanded(

                  child: Text(

                    'Loss is within acceptable limit.',

                    style: TextStyle(fontSize: 9.0, color: AppColors.green, fontWeight: FontWeight.bold),

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                  ),

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

  Widget _buildColumnConditionCard({bool isMobile = false}) {
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
          _buildCardLabel('DISTILLATION COLUMN HEALTH', Icons.speed_rounded),
          const SizedBox(height: 6),
          isMobile
              ? Expanded(
                  child: Column(
                    children: [
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          children: [
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
                )
              : Expanded(
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

              color: AppColors.green.withValues(alpha: 0.08),

              borderRadius: BorderRadius.circular(4),

              border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),

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









// â”€â”€ Custom Painter: Line Chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _LineChartPainter extends CustomPainter {

  final double productVal;

  final double lossVal;



  _LineChartPainter({

    required this.productVal,

    required this.lossVal,

  });



  @override

  void paint(Canvas canvas, Size size) {

    final gridPaint = Paint()

      ..color = const Color(0x10FFFFFF)

      ..strokeWidth = 0.8;



    final axisPaint = Paint()

      ..color = const Color(0x24FFFFFF)

      ..strokeWidth = 1.0;



    final double paddingLeft = 24.0;

    final double paddingBottom = 16.0;

    final double chartW = size.width - paddingLeft;

    final double chartH = size.height - paddingBottom;



    // Draw Shaded Threshold Bands

    // 1. Top Green target band (> 95%)

    final double y95 = chartH - (95.0 / 100.0) * chartH;

    final greenBandPaint = Paint()..color = AppColors.green.withValues(alpha: 0.05);

    canvas.drawRect(Rect.fromLTRB(paddingLeft, 0, size.width, y95), greenBandPaint);



    // 2. Bottom Red loss band (> 0.25%, i.e. 12.5 on chart scale)

    final double y125 = chartH - (12.5 / 100.0) * chartH;

    final redBandPaint = Paint()..color = AppColors.red.withValues(alpha: 0.05);

    canvas.drawRect(Rect.fromLTRB(paddingLeft, y125, size.width, chartH), redBandPaint);



    // Draw Grid Lines (Y axis labels: 0, 25, 50, 75, 100, 125)

    final yLabels = [0, 20, 40, 60, 80, 100];

    for (int idx = 0; idx < yLabels.length; idx++) {

      final double y = chartH - (chartH / (yLabels.length - 1)) * idx;

      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width, y), gridPaint);

      

      // Draw label

      _drawText(canvas, yLabels[idx].toString(), Offset(0, y - 5),

          const TextStyle(fontSize: 8.5, color: AppColors.divider, fontWeight: FontWeight.bold));

    }



    // Shaded Band Labels & Threshold Lines

    final dashedLinePaint = Paint()

      ..color = const Color(0x33FFFFFF)

      ..strokeWidth = 1.0;

    

    // Draw top threshold line

    canvas.drawLine(Offset(paddingLeft, y95), Offset(size.width, y95), dashedLinePaint);

    _drawText(canvas, '> 95 %', Offset(paddingLeft + 10, y95 + 4),

        const TextStyle(fontSize: 8.0, color: AppColors.green, fontWeight: FontWeight.bold));

    _drawText(canvas, 'Product Alc', Offset(size.width - 65, y95 + 4),

        const TextStyle(fontSize: 8.0, color: AppColors.green, fontWeight: FontWeight.bold));



    // Draw bottom threshold line

    canvas.drawLine(Offset(paddingLeft, y125), Offset(size.width, y125), dashedLinePaint);

    _drawText(canvas, '> 0.25 %', Offset(paddingLeft + 10, y125 - 12),

        const TextStyle(fontSize: 8.0, color: AppColors.red, fontWeight: FontWeight.bold));

    _drawText(canvas, 'Loss', Offset(size.width - 35, y125 + 4),

        const TextStyle(fontSize: 8.0, color: AppColors.red, fontWeight: FontWeight.bold));



    // X Axis time labels

    final xLabels = ['11:30', '15:30', '19:30', '23:30', '03:30', '07:30', '11:30'];

    final double colStep = chartW / (xLabels.length - 1);

    for (int idx = 0; idx < xLabels.length; idx++) {

      final double x = paddingLeft + colStep * idx;

      canvas.drawLine(Offset(x, 0), Offset(x, chartH), gridPaint);



      // Label

      _drawText(canvas, xLabels[idx], Offset(x - 10, chartH + 4),

          const TextStyle(fontSize: 8.5, color: AppColors.divider, fontWeight: FontWeight.bold));

    }



    canvas.drawLine(Offset(paddingLeft, chartH), Offset(size.width, chartH), axisPaint);

    canvas.drawLine(Offset(paddingLeft, 0), Offset(paddingLeft, chartH), axisPaint);



    // Mock trend line coords fluctuation base

    final pointsSeed = [0.96, 0.98, 0.94, 0.99, 0.97, 0.95, 1.0];



    // Draw line series

    // 1. PRODUCT ALCOHOL % (Cyan color)

    _drawLineSeries(canvas, pointsSeed, productVal, chartW, chartH, paddingLeft, AppColors.green, 100);

    // 2. TOTAL ALCOHOL LOSS % (Orange color, scaled by 50 to fit scale)

    _drawLineSeries(canvas, pointsSeed, lossVal * 50.0, chartW, chartH, paddingLeft, AppColors.orange, 100);

  }



  void _drawLineSeries(

      Canvas canvas, List<double> seed, double activeVal, double width, double height, double px, Color color, double maxY) {

    final linePaint = Paint()

      ..color = color

      ..strokeWidth = 1.8

      ..style = PaintingStyle.stroke

      ..strokeCap = StrokeCap.round;



    final dotPaint = Paint()

      ..color = color

      ..style = PaintingStyle.fill;



    final glowPaint = Paint()

      ..color = color.withValues(alpha: 0.15)

      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);



    final path = Path();

    final double colStep = width / (seed.length - 1);



    for (int i = 0; i < seed.length; i++) {

      final val = (i == seed.length - 1) ? activeVal : activeVal * (0.98 + seed[i] * 0.04);

      final double x = px + colStep * i;

      final double y = height - (val / maxY) * height;



      if (i == 0) {

        path.moveTo(x, y);

      } else {

        path.lineTo(x, y);

      }

    }



    canvas.drawPath(path, linePaint);



    // Draw terminal point glowing dot

    final double lastX = px + width;

    final double lastY = height - (activeVal / maxY) * height;

    canvas.drawCircle(Offset(lastX, lastY), 4.5, glowPaint);

    canvas.drawCircle(Offset(lastX, lastY), 2.2, dotPaint);

  }



  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {

    final tp = TextPainter(

      text: TextSpan(text: text, style: style),

      textDirection: TextDirection.ltr,

    )..layout();

    tp.paint(canvas, offset);

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

      _DonutSegment(0.83, AppColors.green),

      _DonutSegment(0.11, AppColors.orange),

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

        ..color = AppColors.red.withValues(alpha: 0.25)

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

      ..color = AppColors.blue.withValues(alpha: 0.2)

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

      ..color = AppColors.purple

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

