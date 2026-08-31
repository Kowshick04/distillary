import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class RadialNavItem {
  final String route;
  final IconData icon;
  final String label;

  const RadialNavItem({
    required this.route,
    required this.icon,
    required this.label,
  });
}

class RadialAppBar extends StatefulWidget {
  final String currentRoute;
  final Function(String route)? onActionSelected;

  const RadialAppBar({
    super.key,
    this.currentRoute = "dashboard",
    this.onActionSelected,
  });

  @override
  State<RadialAppBar> createState() => _RadialAppBarState();
}

class _RadialAppBarState extends State<RadialAppBar> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  static const List<RadialNavItem> _navItems = [
    RadialNavItem(route: "live_fermenters", icon: Icons.science_rounded, label: "Live Fermenters"),
    RadialNavItem(route: "batch_monitoring", icon: Icons.bar_chart_rounded, label: "Batch Monitoring"),
    RadialNavItem(route: "historical_trends", icon: Icons.show_chart_rounded, label: "Historical Trends"),
    RadialNavItem(route: "analytics", icon: Icons.analytics_rounded, label: "Analytics"),
    RadialNavItem(route: "ai_insights", icon: Icons.auto_awesome_rounded, label: "AI Insights"),
    RadialNavItem(route: "alarm_center", icon: Icons.warning_amber_rounded, label: "Alarm Center"),
    RadialNavItem(route: "reports", icon: Icons.assessment_rounded, label: "Reports"),
    RadialNavItem(route: "settings", icon: Icons.settings_rounded, label: "Settings"),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9), // Dark frosted background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x2BFFFFFF), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Logo / Toggle button
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.blue,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _expandAnimation,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Primary Dock Nav Icons
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _navItems.map((item) {
                  final isActive = widget.currentRoute == item.route;
                  return Tooltip(
                    message: item.label,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDockIcon(item.icon, item.route, isActive),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Help / Bottom Icon
          _buildDockIcon(Icons.help_outline_rounded, "help", false),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDockIcon(IconData icon, String route, bool isActive) {
    return GestureDetector(
      onTap: () {
        widget.onActionSelected?.call(route);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? AppColors.blue.withValues(alpha: 0.15) : Colors.transparent, // Frosted active selection
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.blue : AppColors.textMuted, // Cyan or Steel Gray
          size: 20,
        ),
      ),
    );
  }
}
