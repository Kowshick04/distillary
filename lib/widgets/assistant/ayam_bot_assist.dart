import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AyamBotAssist extends StatefulWidget {
  const AyamBotAssist({super.key});

  @override
  State<AyamBotAssist> createState() => _AyamBotAssistState();
}

class _AyamBotAssistState extends State<AyamBotAssist> {
  bool _isOpen = false;
  bool _isListening = false;
  String _recognizedText = "Listening for process query...";
  String _ayamReply = "Active fermentation stage temperature is steady at 32.1\u00B0C. Recommendation: Ensure cooling water flow remains > 400 LPM.";

  void _toggleBot() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _simulateVoice() {
    setState(() {
      _isListening = true;
      _recognizedText = "How is the yeast health status?";
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isListening = false;
          _ayamReply = "Yeast health is optimal. Active fermentation matching score is 98.4%.";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isOpen)
          Positioned(
            right: 80,
            bottom: 30,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.9), // Dark frosted background
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x2BFFFFFF), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.blue, // Cyan
                              child: Icon(Icons.smart_toy_rounded, size: 16, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'AYAM Assistant',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary), // Off-white
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                          onPressed: _toggleBot,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.glassOverlay, // Transparent frosted surface
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _isListening ? _recognizedText : _ayamReply,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4), // Light Gray
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _simulateVoice,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isListening ? AppColors.orange : AppColors.blue, // Orange or Cyan
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening ? AppColors.orange : AppColors.blue).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Floating Bot Avatar
        Positioned(
          right: 20,
          bottom: 20,
          child: GestureDetector(
            onTap: _toggleBot,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.blue, AppColors.cyan], // Cyan to Teal
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
