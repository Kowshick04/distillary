import 'package:flutter/material.dart';
import '../common/glass_card.dart';
import '../../models/telemetry_data_model.dart';
import '../../utils/app_colors.dart';

class AiRecommendationsCard extends StatelessWidget {
  final TelemetryDataModel? telemetry;
  const AiRecommendationsCard({super.key, this.telemetry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primaryBlue, size: 16),
              SizedBox(width: 8),
              Text(
                'AI OPTIMIZATION RECOMMENDATIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• Maintain cooling water flow rate above 380 L/min to stabilize column temperature.\n'
            '• Monitor residual sugar (Brix) to ensure complete fermentation before transfer.\n'
            '• Agitator vibration and health levels are nominal (97%).',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}
